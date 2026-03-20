defmodule Unified.SpecCompliance.Manifest do
  @moduledoc false

  @spec load_json(String.t()) :: {:ok, term()} | {:error, map()}
  def load_json(path) do
    case File.read(path) do
      {:ok, body} ->
        case JSON.decode(body) do
          {:ok, data} ->
            {:ok, data}

          {:error, reason} ->
            {:error,
             %{
               code: "invalid_manifest_json",
               severity: :error,
               file: relative_path(path),
               message: "Could not decode #{relative_path(path)}: #{format_decode_error(reason)}"
             }}
        end

      {:error, :enoent} ->
        {:error,
         %{
           code: "missing_manifest",
           severity: :error,
           file: relative_path(path),
           message: "Missing manifest at #{relative_path(path)}"
         }}

      {:error, reason} ->
        {:error,
         %{
           code: "manifest_read_failed",
           severity: :error,
           file: relative_path(path),
           message: "Could not load #{relative_path(path)}: #{inspect(reason)}"
         }}
    end
  end

  @spec relative_path(String.t()) :: String.t()
  def relative_path(path) do
    cwd = File.cwd!()

    case Path.relative_to(path, cwd) do
      relative when relative == path -> path
      relative -> relative
    end
  end

  defp format_decode_error(reason) do
    inspect(reason)
  end
end
