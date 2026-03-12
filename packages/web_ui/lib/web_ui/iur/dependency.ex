defmodule WebUi.Iur.Dependency do
  @moduledoc """
  Canonical Unified-IUR dependency and compatibility helpers.
  """

  alias WebUi.TypedError

  @canonical_schema "unified_iur"
  @canonical_sources [
    "pcharbon70/unified_iur",
    "github.com/pcharbon70/unified_iur",
    "https://github.com/pcharbon70/unified_iur"
  ]
  @canonical_module_prefix "Elixir.UnifiedIUR."

  @spec canonical_schema() :: String.t()
  def canonical_schema, do: @canonical_schema

  @spec canonical_sources() :: [String.t()]
  def canonical_sources, do: @canonical_sources

  @spec dependency_version() :: String.t() | nil
  def dependency_version do
    case Application.spec(:unified_iur, :vsn) do
      version when is_list(version) -> to_string(version)
      version when is_binary(version) -> version
      _ -> nil
    end
  end

  @spec canonical_iur_struct?(term()) :: boolean()
  def canonical_iur_struct?(%_{} = struct) do
    struct
    |> Map.get(:__struct__)
    |> Atom.to_string()
    |> String.starts_with?(@canonical_module_prefix)
  end

  def canonical_iur_struct?(_other), do: false

  @spec validate_schema_markers(map(), String.t()) :: :ok | {:error, TypedError.t()}
  def validate_schema_markers(spec, correlation_id \\ "iur")

  def validate_schema_markers(spec, correlation_id)
      when is_map(spec) and is_binary(correlation_id) do
    schema = fetch_any(spec, :schema)
    source = fetch_any(spec, :schema_source)
    version = fetch_any(spec, :schema_version)

    with :ok <- validate_schema(schema, correlation_id),
         :ok <- validate_source(source, correlation_id),
         :ok <- validate_version(version, correlation_id) do
      :ok
    end
  end

  def validate_schema_markers(_spec, correlation_id) when is_binary(correlation_id) do
    {:error,
     TypedError.new(
       "iur.interpreter.invalid_schema_markers",
       "validation",
       false,
       %{reason: "schema markers input must be a map"},
       correlation_id
     )}
  end

  defp validate_schema(nil, _correlation_id), do: :ok

  defp validate_schema(schema, _correlation_id)
       when is_binary(schema) and schema == @canonical_schema,
       do: :ok

  defp validate_schema(schema, correlation_id) do
    {:error,
     TypedError.new(
       "iur.interpreter.unsupported_schema",
       "validation",
       false,
       %{schema: schema, allowed_schema: @canonical_schema},
       correlation_id
     )}
  end

  defp validate_source(nil, _correlation_id), do: :ok

  defp validate_source(source, _correlation_id)
       when is_binary(source) and source in @canonical_sources,
       do: :ok

  defp validate_source(source, correlation_id) do
    {:error,
     TypedError.new(
       "iur.interpreter.unsupported_schema_source",
       "validation",
       false,
       %{schema_source: source, allowed_sources: @canonical_sources},
       correlation_id
     )}
  end

  defp validate_version(nil, _correlation_id), do: :ok

  defp validate_version(version, correlation_id) when is_binary(version) and version != "" do
    if version == dependency_version() do
      :ok
    else
      {:error,
       TypedError.new(
         "iur.interpreter.unsupported_schema_version",
         "validation",
         false,
         %{schema_version: version, dependency_version: dependency_version()},
         correlation_id
       )}
    end
  end

  defp validate_version(version, correlation_id) do
    {:error,
     TypedError.new(
       "iur.interpreter.unsupported_schema_version",
       "validation",
       false,
       %{schema_version: version, dependency_version: dependency_version()},
       correlation_id
     )}
  end

  defp fetch_any(map, key) when is_map(map) and is_atom(key) do
    Map.get(map, key) || Map.get(map, Atom.to_string(key))
  end
end
