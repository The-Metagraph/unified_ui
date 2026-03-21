defmodule WebUi.FrontendRuntime.Boot do
  @moduledoc """
  Frontend hydration and boot diagnostics.
  """

  alias WebUi.FrontendRuntime.{Error, Model}

  @required_fields ~w[runtime_id title source_kind boundary_mode tree local_state diagnostics metadata]a

  @spec hydrate(map()) :: {:ok, Model.t()} | {:error, Error.t()}
  def hydrate(payload) when is_map(payload) do
    missing =
      Enum.reject(@required_fields, fn field ->
        Map.has_key?(payload, field) or Map.has_key?(payload, Atom.to_string(field))
      end)

    case missing do
      [] ->
        {:ok,
         %Model{
           runtime_id: fetch(payload, :runtime_id),
           title: fetch(payload, :title),
           source_kind: fetch(payload, :source_kind),
           boundary_mode: fetch(payload, :boundary_mode),
           tree: fetch(payload, :tree),
           local_state: fetch(payload, :local_state),
           diagnostics: fetch(payload, :diagnostics),
           metadata: fetch(payload, :metadata)
         }}

      fields ->
        {:error,
         Error.new(:invalid_hydration_payload, "Missing hydration fields", %{fields: fields})}
    end
  end

  def hydrate(_payload) do
    {:error, Error.new(:invalid_hydration_payload, "Expected hydration payload to be a map")}
  end

  defp fetch(map, key) do
    Map.get(map, key) || Map.get(map, Atom.to_string(key))
  end
end
