defmodule WebUi.Endpoint do
  @moduledoc """
  Transport boundary bootstrap contract for SPA + websocket routing.
  """

  alias WebUi.TypedError

  @default_spa_path "/"
  @default_assets_path "/assets"
  @default_websocket_path "/socket/webui"

  @type startup_config :: %{
          optional(:spa_path) => String.t(),
          optional(:assets_path) => String.t(),
          optional(:websocket_path) => String.t()
        }

  @spec route_spec() :: map()
  def route_spec do
    %{
      spa: %{method: "GET", path: @default_spa_path},
      assets: %{method: "GET", path: @default_assets_path <> "/*path"},
      websocket: %{transport: "websocket", path: @default_websocket_path}
    }
  end

  @spec startup_requirements() :: [atom()]
  def startup_requirements do
    [:spa_path, :assets_path, :websocket_path]
  end

  @spec validate_startup_config(startup_config()) :: {:ok, startup_config()} | {:error, TypedError.t()}
  def validate_startup_config(config) when is_map(config) do
    with :ok <- validate_required_keys(config),
         :ok <- validate_path_fields(config) do
      {:ok,
       %{
         spa_path: Map.fetch!(config, :spa_path),
         assets_path: Map.fetch!(config, :assets_path),
         websocket_path: Map.fetch!(config, :websocket_path)
       }}
    end
  end

  def validate_startup_config(_config) do
    {:error,
     TypedError.new(
       "endpoint.invalid_config_shape",
       "validation",
       false,
       %{reason: "startup config must be a map"}
     )}
  end

  defp validate_required_keys(config) do
    missing = startup_requirements() |> Enum.reject(&Map.has_key?(config, &1))

    case missing do
      [] ->
        :ok

      _ ->
        {:error,
         TypedError.new(
           "endpoint.missing_required_keys",
           "validation",
           false,
           %{missing_keys: missing}
         )}
    end
  end

  defp validate_path_fields(config) do
    invalid_keys =
      startup_requirements()
      |> Enum.filter(fn key ->
        value = Map.fetch!(config, key)
        not (is_binary(value) and String.starts_with?(value, "/"))
      end)

    case invalid_keys do
      [] ->
        :ok

      _ ->
        {:error,
         TypedError.new(
           "endpoint.invalid_route_path",
           "validation",
           false,
           %{invalid_keys: invalid_keys}
         )}
    end
  end
end
