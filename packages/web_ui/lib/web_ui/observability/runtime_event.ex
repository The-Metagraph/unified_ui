defmodule WebUi.Observability.RuntimeEvent do
  @moduledoc """
  Runtime event envelope builder and validator for observability conformance.
  """

  alias WebUi.TypedError

  @required_fields [:event_name, :event_version, :timestamp, :service, :source, :correlation_id, :request_id, :outcome, :payload]
  @allowed_outcomes ["ok", "error", "cancelled", "timeout"]
  @event_name_version_regex ~r/\.v[0-9]+$/

  @spec required_fields() :: [atom()]
  def required_fields, do: @required_fields

  @spec allowed_outcomes() :: [String.t()]
  def allowed_outcomes, do: @allowed_outcomes

  @spec build(map(), map()) :: {:ok, map()} | {:error, TypedError.t()}
  def build(attrs, context \\ %{})

  def build(attrs, context) when is_map(attrs) and is_map(context) do
    event =
      %{
        event_name: fetch_any(attrs, :event_name),
        event_version: fetch_any(attrs, :event_version) || "v1",
        timestamp: fetch_any(attrs, :timestamp) || DateTime.utc_now() |> DateTime.truncate(:second) |> DateTime.to_iso8601(),
        service: fetch_any(attrs, :service) || "unknown_service",
        source: fetch_any(attrs, :source) || "unknown_source",
        correlation_id: fetch_any(attrs, :correlation_id) || fetch_any(context, :correlation_id) || "unknown",
        request_id: fetch_any(attrs, :request_id) || fetch_any(context, :request_id) || "unknown",
        session_id: fetch_any(attrs, :session_id) || fetch_any(context, :session_id),
        client_id: fetch_any(attrs, :client_id) || fetch_any(context, :client_id),
        outcome: fetch_any(attrs, :outcome) || "ok",
        payload: fetch_any(attrs, :payload) || %{}
      }
      |> Map.merge(Map.drop(attrs, @required_fields))

    case validate(event) do
      :ok -> {:ok, event}
      {:error, %TypedError{} = error} -> {:error, error}
    end
  end

  def build(_attrs, _context) do
    {:error,
     TypedError.new(
       "observability.invalid_runtime_event_shape",
       "validation",
       false,
       %{reason: "runtime event attributes and context must be maps"}
     )}
  end

  @spec validate(map()) :: :ok | {:error, TypedError.t()}
  def validate(event) when is_map(event) do
    missing =
      @required_fields
      |> Enum.filter(fn key ->
        case fetch_any(event, key) do
          value when is_binary(value) and value != "" -> false
          value when is_map(value) -> false
          _ -> true
        end
      end)

    cond do
      missing != [] ->
        {:error,
         TypedError.new(
           "observability.missing_required_event_fields",
           "validation",
           false,
           %{missing_fields: missing},
           fetch_any(event, :correlation_id) || "unknown"
         )}

      not valid_event_name?(fetch_any(event, :event_name)) ->
        {:error,
         TypedError.new(
           "observability.invalid_event_name",
           "validation",
           false,
           %{event_name: fetch_any(event, :event_name)},
           fetch_any(event, :correlation_id) || "unknown"
         )}

      not valid_timestamp?(fetch_any(event, :timestamp)) ->
        {:error,
         TypedError.new(
           "observability.invalid_event_timestamp",
           "validation",
           false,
           %{timestamp: fetch_any(event, :timestamp)},
           fetch_any(event, :correlation_id) || "unknown"
         )}

      fetch_any(event, :outcome) not in @allowed_outcomes ->
        {:error,
         TypedError.new(
           "observability.invalid_event_outcome",
           "validation",
           false,
           %{outcome: fetch_any(event, :outcome), allowed_outcomes: @allowed_outcomes},
           fetch_any(event, :correlation_id) || "unknown"
         )}

      not is_map(fetch_any(event, :payload)) ->
        {:error,
         TypedError.new(
           "observability.invalid_event_payload",
           "validation",
           false,
           %{required_shape: "map"},
           fetch_any(event, :correlation_id) || "unknown"
         )}

      not valid_id?(fetch_any(event, :correlation_id)) or not valid_id?(fetch_any(event, :request_id)) ->
        {:error,
         TypedError.new(
           "observability.invalid_event_context",
           "validation",
           false,
           %{correlation_id: fetch_any(event, :correlation_id), request_id: fetch_any(event, :request_id)},
           fetch_any(event, :correlation_id) || "unknown"
         )}

      true ->
        :ok
    end
  end

  def validate(_event) do
    {:error,
     TypedError.new(
       "observability.invalid_runtime_event_shape",
       "validation",
       false,
       %{reason: "runtime event must be a map"}
     )}
  end

  @spec conformance_failure_event(TypedError.t(), map(), map()) :: map()
  def conformance_failure_event(%TypedError{} = error, context, payload \\ %{}) when is_map(context) and is_map(payload) do
    {:ok, event} =
      build(
        %{
          event_name: "runtime.observability.conformance_failed.v1",
          event_version: "v1",
          service: "observability",
          source: "WebUi.Observability.RuntimeEvent",
          outcome: "error",
          payload: %{
            error_code: error.error_code,
            category: error.category,
            details: error.details,
            failure_payload: payload
          }
        },
        %{
          correlation_id: fetch_any(context, :correlation_id) || error.correlation_id,
          request_id: fetch_any(context, :request_id) || "unknown",
          session_id: fetch_any(context, :session_id),
          client_id: fetch_any(context, :client_id)
        }
      )

    event
  end

  defp valid_event_name?(value) when is_binary(value) do
    value != "" and Regex.match?(@event_name_version_regex, value)
  end

  defp valid_event_name?(_value), do: false

  defp valid_timestamp?(value) when is_binary(value) do
    match?({:ok, _dt, _offset}, DateTime.from_iso8601(value))
  end

  defp valid_timestamp?(_value), do: false

  defp valid_id?(value), do: is_binary(value) and value != ""

  defp fetch_any(map, key), do: Map.get(map, key) || Map.get(map, Atom.to_string(key))
end
