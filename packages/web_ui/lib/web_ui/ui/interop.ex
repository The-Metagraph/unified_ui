defmodule WebUi.Ui.Interop do
  @moduledoc """
  Typed JS interop bridge policy for extension-plane operations.
  """

  alias WebUi.Observability.Metrics
  alias WebUi.TypedError

  @supported_operations [
    "copy_to_clipboard",
    "open_external_url",
    "request_notification_permission",
    "browser_storage_read"
  ]

  @blocked_runtime_actions [
    "mutate_domain_state",
    "execute_runtime_command",
    "write_persistence"
  ]

  @spec supported_operations() :: [String.t()]
  def supported_operations, do: @supported_operations

  @spec build_port_command(String.t(), map(), map()) :: {:ok, map()} | {:error, TypedError.t()}
  def build_port_command(operation, payload, runtime_context)
      when is_binary(operation) and is_map(payload) and is_map(runtime_context) do
    if operation in @supported_operations do
      {:ok,
       %{
         kind: :port_out,
         event_name: "ui.port.command.v1",
         payload: %{
           operation: operation,
           data: payload,
           provenance: provenance(runtime_context)
         }
       }}
    else
      {:error,
       TypedError.new(
         "ui.interop.unsupported_operation",
         "validation",
         false,
         %{operation: operation, supported_operations: @supported_operations},
         Map.get(runtime_context, :correlation_id, "unknown")
       )}
    end
  end

  def build_port_command(_operation, _payload, runtime_context) do
    {:error,
     TypedError.new(
       "ui.interop.invalid_outbound_payload",
       "validation",
       false,
       %{reason: "operation must be string and payload/runtime_context must be maps"},
       Map.get(runtime_context || %{}, :correlation_id, "unknown")
     )}
  end

  @spec decode_port_event(map()) :: {:ok, map()} | {:error, TypedError.t()}
  def decode_port_event(payload) when is_map(payload) do
    operation = fetch_string(payload, :operation)
    data = fetch_map(payload, :data)

    cond do
      is_nil(operation) ->
        {:error,
         TypedError.new(
           "ui.interop.missing_operation",
           "protocol",
           false,
           %{required_key: :operation}
         )}

      map_size(data) == 0 and fetch_any(payload, :data) != %{} ->
        {:error,
         TypedError.new(
           "ui.interop.invalid_data",
           "protocol",
           false,
           %{required_key: :data, required_shape: "map"}
         )}

      true ->
        {:ok,
         %{
           operation: operation,
           data: data,
           provenance: fetch_map(payload, :provenance)
         }}
    end
  end

  def decode_port_event(_payload) do
    {:error,
     TypedError.new(
       "ui.interop.invalid_event_shape",
       "protocol",
       false,
       %{reason: "port event must be a map"}
     )}
  end

  @spec authorize_port_event(map(), map()) :: :ok | {:error, TypedError.t()}
  def authorize_port_event(%{operation: operation}, runtime_context) when is_binary(operation) and is_map(runtime_context) do
    cond do
      operation in @blocked_runtime_actions ->
        {:error,
         TypedError.new(
           "ui.interop.denied_runtime_action",
           "authorization",
           false,
           %{operation: operation},
           Map.get(runtime_context, :correlation_id, "unknown")
         )}

      true ->
        :ok
    end
  end

  def authorize_port_event(_event, runtime_context) do
    {:error,
     TypedError.new(
       "ui.interop.invalid_event_shape",
       "protocol",
       false,
       %{reason: "decoded event is malformed"},
       Map.get(runtime_context || %{}, :correlation_id, "unknown")
     )}
  end

  @spec telemetry_error(TypedError.t(), map()) :: map()
  def telemetry_error(%TypedError{} = error, payload) when is_map(payload) do
    telemetry = %{
      event_name: "runtime.js_interop.error.v1",
      event_version: "v1",
      source: "WebUi.Ui.Interop",
      correlation_id: error.correlation_id,
      request_id: fetch_string(payload, :request_id) || "unknown",
      outcome: "error",
      error_code: error.error_code,
      category: error.category
    }

    case Metrics.metric_record(
           "webui_js_interop_error_total",
           %{bridge: "extension_port", error_code: error.error_code},
           1,
           %{correlation_id: error.correlation_id, request_id: fetch_string(payload, :request_id) || "unknown"}
         ) do
      {:ok, metric_record} -> Map.put(telemetry, :metric, metric_record)
      {:error, _error} -> telemetry
    end
  end

  defp provenance(runtime_context) do
    %{
      origin: "extension_port",
      source_plane: "Extension Plane",
      correlation_id: Map.get(runtime_context, :correlation_id),
      request_id: Map.get(runtime_context, :request_id)
    }
  end

  defp fetch_any(map, key), do: Map.get(map, key) || Map.get(map, Atom.to_string(key))

  defp fetch_string(map, key) do
    case fetch_any(map, key) do
      value when is_binary(value) and value != "" -> value
      _ -> nil
    end
  end

  defp fetch_map(map, key) do
    case fetch_any(map, key) do
      value when is_map(value) -> value
      _ -> %{}
    end
  end
end
