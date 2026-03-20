defmodule Unified.SpecCompliance.State do
  @moduledoc false

  @default_state_path ".spec/state.json"

  @spec load(String.t(), Keyword.t()) :: {:ok, map()} | {:error, map()}
  def load(root, opts \\ []) do
    refresh? = Keyword.get(opts, :refresh_state, false)
    state_path = Keyword.get(opts, :state_path, @default_state_path)
    absolute_path = Path.expand(state_path, root)

    case maybe_refresh(root, absolute_path, refresh?) do
      :ok ->
        decode_state(absolute_path, state_path)

      {:error, :enoent} ->
        {:error,
         %{
           code: "missing_state_file",
           severity: :error,
           file: state_path,
           message:
             "Missing #{state_path}. Run `mix spec.plan` or pass `--refresh-state` to regenerate it."
         }}

      {:error, reason} when is_binary(reason) ->
        {:error,
         %{
           code: "state_refresh_failed",
           severity: :error,
           file: state_path,
           message: reason
         }}
    end
  end

  @spec requirements_by_id(map()) :: %{optional(String.t()) => map()}
  def requirements_by_id(state) do
    state
    |> Map.get("index", %{})
    |> Map.get("requirements", [])
    |> Map.new(fn requirement -> {requirement["id"], requirement} end)
  end

  defp maybe_refresh(_root, absolute_path, false) do
    if File.exists?(absolute_path), do: :ok, else: {:error, :enoent}
  end

  defp maybe_refresh(root, _absolute_path, true) do
    Mix.Task.reenable("spec.plan")

    try do
      Mix.Task.run("spec.plan", ["--root", root])
      :ok
    rescue
      error in Mix.Error ->
        {:error, Exception.message(error)}
    end
  end

  defp decode_state(absolute_path, state_path) do
    case File.read(absolute_path) do
      {:ok, body} ->
        case JSON.decode(body) do
          {:ok, state} when is_map(state) ->
            {:ok, state}

          {:ok, _state} ->
            {:error,
             %{
               code: "invalid_state_shape",
               severity: :error,
               file: state_path,
               message: "#{state_path} must decode to a JSON object"
             }}

          {:error, reason} ->
            {:error,
             %{
               code: "invalid_state_json",
               severity: :error,
               file: state_path,
               message: "Could not decode #{state_path}: #{inspect(reason)}"
             }}
        end

      {:error, :enoent} ->
        {:error, :enoent}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
