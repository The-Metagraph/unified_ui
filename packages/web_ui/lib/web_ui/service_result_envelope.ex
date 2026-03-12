defmodule WebUi.ServiceResultEnvelope do
  @moduledoc """
  Typed runtime result envelope for normalized success/error outcomes.
  """

  alias WebUi.Observability.Diagnostics
  alias WebUi.Observability.RuntimeEvent
  alias WebUi.RuntimeContext
  alias WebUi.ServiceRequestEnvelope
  alias WebUi.TypedError

  @enforce_keys [:service, :operation, :context, :outcome, :events]
  defstruct [:service, :operation, :context, :outcome, :payload, :error, :events]

  @type outcome :: String.t()

  @type t :: %__MODULE__{
          service: String.t(),
          operation: String.t(),
          context: RuntimeContext.t(),
          outcome: outcome(),
          payload: map() | nil,
          error: TypedError.t() | nil,
          events: [map()]
        }

  @spec success(ServiceRequestEnvelope.t(), map(), [map()]) :: t()
  def success(%ServiceRequestEnvelope{} = request, payload, events \\ []) when is_map(payload) and is_list(events) do
    %__MODULE__{
      service: request.service,
      operation: request.operation,
      context: request.context,
      outcome: "ok",
      payload: normalize_payload(payload),
      error: nil,
      events: normalize_events(events, request.context, request.service)
    }
  end

  @spec error(ServiceRequestEnvelope.t(), term(), [map()]) :: t()
  def error(%ServiceRequestEnvelope{} = request, reason, events \\ []) when is_list(events) do
    typed_error = normalize_error(reason, request.context)

    %__MODULE__{
      service: request.service,
      operation: request.operation,
      context: request.context,
      outcome: "error",
      payload: nil,
      error: typed_error,
      events: normalize_events(events, request.context, request.service)
    }
  end

  @spec error_for(String.t(), String.t(), map(), term(), [map()]) :: t()
  def error_for(service, operation, context, reason, events \\ [])
      when is_binary(service) and is_binary(operation) and is_map(context) and is_list(events) do
    normalized_context = normalize_context(context)
    typed_error = normalize_error(reason, normalized_context)

    %__MODULE__{
      service: service,
      operation: operation,
      context: normalized_context,
      outcome: "error",
      payload: nil,
      error: typed_error,
      events: normalize_events(events, normalized_context, service)
    }
  end

  @spec to_map(t()) :: map()
  def to_map(%__MODULE__{} = envelope) do
    %{
      service: envelope.service,
      operation: envelope.operation,
      context: envelope.context,
      outcome: envelope.outcome,
      payload: envelope.payload,
      error: to_error_map(envelope.error),
      events: envelope.events
    }
  end

  @spec normalize_error(term(), map()) :: TypedError.t()
  def normalize_error(%TypedError{} = error, context) when is_map(context) do
    if error.correlation_id in [nil, "", "unknown"] do
      %{error | correlation_id: Map.get(context, :correlation_id, "unknown")}
    else
      error
    end
  end

  def normalize_error({:validation, code, details}, context) do
    TypedError.new(
      to_code(code, "service.validation_failed"),
      "validation",
      false,
      ensure_map(details),
      Map.get(context, :correlation_id, "unknown")
    )
  end

  def normalize_error({:authorization, code, details}, context) do
    TypedError.new(
      to_code(code, "service.authorization_denied"),
      "authorization",
      false,
      ensure_map(details),
      Map.get(context, :correlation_id, "unknown")
    )
  end

  def normalize_error({:conflict, code, details}, context) do
    TypedError.new(
      to_code(code, "service.conflict"),
      "conflict",
      false,
      ensure_map(details),
      Map.get(context, :correlation_id, "unknown")
    )
  end

  def normalize_error({:timeout, reason}, context) do
    TypedError.new(
      "service.timeout",
      "timeout",
      true,
      %{reason: inspect(reason)},
      Map.get(context, :correlation_id, "unknown")
    )
  end

  def normalize_error({:dependency, reason}, context) do
    TypedError.new(
      "service.dependency_failure",
      "dependency",
      true,
      %{reason: inspect(reason)},
      Map.get(context, :correlation_id, "unknown")
    )
  end

  def normalize_error(reason, context) do
    TypedError.new(
      "service.internal_error",
      "internal",
      false,
      %{reason: inspect(reason)},
      Map.get(context, :correlation_id, "unknown")
    )
  end

  defp normalize_events(events, context, service) do
    events
    |> Enum.filter(&is_map/1)
    |> Enum.map(fn event ->
      case RuntimeEvent.validate(event) do
        :ok ->
          event

        {:error, %TypedError{} = error} ->
          RuntimeEvent.conformance_failure_event(
            error,
            context,
            %{
              service: service,
              invalid_event: Diagnostics.redact_payload(event)
            }
          )
      end
    end)
  end

  defp normalize_context(context) do
    case RuntimeContext.validate(context) do
      {:ok, normalized} ->
        normalized

      {:error, _} ->
        %{
          correlation_id: fetch_any(context, :correlation_id) || "unknown",
          request_id: fetch_any(context, :request_id) || "unknown",
          session_id: fetch_any(context, :session_id),
          client_id: fetch_any(context, :client_id),
          user_id: fetch_any(context, :user_id),
          trace_id: fetch_any(context, :trace_id)
        }
    end
  end

  defp to_error_map(nil), do: nil

  defp to_error_map(%TypedError{} = error) do
    %{
      error_code: error.error_code,
      category: error.category,
      retryable: error.retryable,
      details: error.details,
      correlation_id: error.correlation_id
    }
  end

  defp to_code(value, _fallback) when is_binary(value) and value != "", do: value
  defp to_code(_value, fallback), do: fallback

  defp normalize_payload(payload) when is_map(payload) do
    ui_hints = normalize_ui_hints(fetch_any(payload, :ui_hints))

    if is_nil(ui_hints) do
      payload
    else
      Map.put(payload, :ui_hints, ui_hints)
    end
  end

  defp normalize_ui_hints(hints) when is_map(hints) do
    next_actions =
      hints
      |> fetch_any(:next_actions)
      |> List.wrap()
      |> Enum.filter(&(is_binary(&1) and &1 != ""))
      |> Enum.uniq()

    severity =
      case fetch_any(hints, :severity) do
        level when level in ["info", "warning", "error"] -> level
        _ -> "info"
      end

    %{
      primary_notice: to_optional_string(fetch_any(hints, :primary_notice)),
      severity: severity,
      next_actions: next_actions,
      focus_field: to_optional_string(fetch_any(hints, :focus_field))
    }
  end

  defp normalize_ui_hints(_hints), do: nil

  defp to_optional_string(value) when is_binary(value) and value != "", do: value
  defp to_optional_string(_value), do: nil

  defp ensure_map(value) when is_map(value), do: value
  defp ensure_map(_value), do: %{}

  defp fetch_any(map, key), do: Map.get(map, key) || Map.get(map, Atom.to_string(key))
end
