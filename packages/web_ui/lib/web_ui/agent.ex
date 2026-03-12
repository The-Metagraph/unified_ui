defmodule WebUi.Agent do
  @moduledoc """
  Runtime authority dispatch boundary for routing events into host-owned handlers.
  """

  alias WebUi.Observability.Diagnostics
  alias WebUi.Observability.Metrics
  alias WebUi.Observability.RuntimeEvent
  alias WebUi.RuntimeContext
  alias WebUi.ServiceRequestEnvelope
  alias WebUi.ServiceResultEnvelope
  alias WebUi.TypedError

  @enforce_keys [:routes]
  defstruct routes: %{}, default_timeout_ms: 1_000

  @type route :: %{
          event_type: String.t(),
          service: String.t(),
          operation: String.t(),
          handler: (ServiceRequestEnvelope.t() -> term())
        }

  @type dispatch_success :: %{
          service: String.t(),
          operation: String.t(),
          payload: map(),
          context: RuntimeContext.t(),
          request: ServiceRequestEnvelope.t()
        }

  @type t :: %__MODULE__{routes: %{String.t() => route()}, default_timeout_ms: pos_integer()}

  @spec new([route()], keyword()) :: {:ok, t()} | {:error, TypedError.t()}
  def new(routes, opts \\ [])

  def new(routes, opts) when is_list(routes) and is_list(opts) do
    with {:ok, route_map} <- build_route_map(routes) do
      {:ok,
       %__MODULE__{
         routes: route_map,
         default_timeout_ms: Keyword.get(opts, :default_timeout_ms, 1_000)
       }}
    end
  end

  def new(_routes, _opts) do
    {:error,
     TypedError.new(
       "agent.invalid_route_table",
       "validation",
       false,
       %{reason: "routes must be a list"},
       "unknown"
     )}
  end

  @spec dispatch(t(), map(), map(), keyword()) :: {:ok, dispatch_success()} | {:error, TypedError.t()}
  def dispatch(agent, event_envelope, context, opts \\ [])

  def dispatch(%__MODULE__{} = agent, event_envelope, context, opts)
      when is_map(event_envelope) and is_map(context) and is_list(opts) do
    with {:ok, runtime_context} <- RuntimeContext.validate(context),
         :ok <- validate_context_integrity(event_envelope, runtime_context),
         {:ok, route} <- resolve_route(agent, event_envelope, runtime_context),
         {:ok, request} <- ServiceRequestEnvelope.from_event(route.service, route.operation, event_envelope, runtime_context),
         {:ok, payload} <- invoke_handler(route.handler, request, runtime_context, Keyword.get(opts, :timeout_ms, agent.default_timeout_ms)) do
      {:ok,
       %{
         service: route.service,
         operation: route.operation,
         payload: payload,
         context: runtime_context,
         request: request
       }}
    end
  end

  def dispatch(%__MODULE__{}, _event_envelope, context, _opts) do
    {:error,
     TypedError.new(
       "agent.invalid_event_shape",
       "protocol",
       false,
       %{reason: "event envelope must be a map"},
       fetch_any(context || %{}, :correlation_id) || "unknown"
     )}
  end

  @spec dispatch_result(t(), map(), map(), keyword()) :: {:ok, ServiceResultEnvelope.t()}
  def dispatch_result(%__MODULE__{} = agent, event_envelope, context, opts \\ [])
      when is_map(event_envelope) and is_map(context) and is_list(opts) do
    started_at = System.monotonic_time()

    result =
      case dispatch(agent, event_envelope, context, opts) do
      {:ok, %{request: request, payload: payload}} ->
        events = extract_events(payload)
        normalized_payload = Map.delete(payload, :events)
          service_event = service_terminal_event(request.service, request.operation, request.context, "ok", normalized_payload)

          emit_metric(
            opts,
            "webui_service_operation_latency",
            %{service: request.service, operation: request.operation, outcome: "ok"},
            elapsed_ms(started_at),
            request.context
          )

          {:ok, ServiceResultEnvelope.success(request, normalized_payload, [service_event | events])}

      {:error, %TypedError{} = error} ->
        {service, operation} = resolve_service_operation(agent, event_envelope)
          denied_event = denied_dispatch_event(error, context, service, operation)

          emit_metric(
            opts,
            "webui_service_operation_latency",
            %{service: service, operation: operation, outcome: "error"},
            elapsed_ms(started_at),
            context
          )

          {:ok, ServiceResultEnvelope.error_for(service, operation, context, error, [denied_event])}
      end

    emit_service_observability(result, opts)
    result
  end

  defp build_route_map(routes) do
    Enum.reduce_while(routes, {:ok, %{}}, fn route, {:ok, acc} ->
      with {:ok, normalized} <- validate_route(route) do
        event_type = normalized.event_type

        if Map.has_key?(acc, event_type) do
          {:halt,
           {:error,
            TypedError.new(
              "agent.duplicate_route",
              "validation",
              false,
              %{event_type: event_type},
              "unknown"
            )}}
        else
          {:cont, {:ok, Map.put(acc, event_type, normalized)}}
        end
      else
        {:error, %TypedError{} = error} -> {:halt, {:error, error}}
      end
    end)
  end

  defp validate_route(route) when is_map(route) do
    event_type = fetch_any(route, :event_type)
    service = fetch_any(route, :service)
    operation = fetch_any(route, :operation)
    handler = fetch_any(route, :handler)

    cond do
      not (is_binary(event_type) and event_type != "") ->
        {:error,
         TypedError.new("agent.invalid_route_event_type", "validation", false, %{route: route}, "unknown")}

      not (is_binary(service) and service != "") ->
        {:error,
         TypedError.new("agent.invalid_route_service", "validation", false, %{route: route}, "unknown")}

      not (is_binary(operation) and operation != "") ->
        {:error,
         TypedError.new("agent.invalid_route_operation", "validation", false, %{route: route}, "unknown")}

      not is_function(handler, 1) ->
        {:error,
         TypedError.new("agent.invalid_route_handler", "validation", false, %{route: route}, "unknown")}

      true ->
        {:ok,
         %{
           event_type: event_type,
           service: service,
           operation: operation,
           handler: handler
         }}
    end
  end

  defp validate_route(_route) do
    {:error,
     TypedError.new(
       "agent.invalid_route_shape",
       "validation",
       false,
       %{reason: "route must be a map"},
       "unknown"
     )}
  end

  defp resolve_route(%__MODULE__{routes: routes}, event_envelope, runtime_context) do
    event_type = fetch_any(event_envelope, :type)

    case Map.get(routes, event_type) do
      nil ->
        {:error,
         TypedError.new(
           "agent.unknown_event_type",
           "protocol",
           false,
           %{event_type: event_type},
           runtime_context.correlation_id
         )}

      route ->
        {:ok, route}
    end
  end

  defp invoke_handler(handler, request, runtime_context, timeout_ms) do
    task = Task.async(fn -> safe_call(handler, request) end)

    case Task.yield(task, timeout_ms) || Task.shutdown(task, :brutal_kill) do
      {:ok, {:ok, payload}} when is_map(payload) ->
        {:ok, payload}

      {:ok, {:ok, _payload}} ->
        {:error,
         TypedError.new(
           "agent.invalid_handler_payload",
           "internal",
           false,
           %{reason: "handler success payload must be a map"},
           runtime_context.correlation_id
         )}

      {:ok, {:error, %TypedError{} = error}} ->
        {:error, normalize_error_correlation(error, runtime_context)}

      {:ok, {:error, {:dependency, reason}}} ->
        {:error,
         TypedError.new(
           "agent.runtime_dependency_error",
           "dependency",
           true,
           %{reason: inspect(reason)},
           runtime_context.correlation_id
         )}

      {:ok, {:error, {:timeout, timeout_reason}}} ->
        {:error,
         TypedError.new(
           "agent.runtime_timeout",
           "timeout",
           true,
           %{reason: inspect(timeout_reason), timeout_ms: timeout_ms},
           runtime_context.correlation_id
         )}

      {:ok, {:error, reason}} ->
        {:error,
         TypedError.new(
           "agent.runtime_internal_error",
           "internal",
           false,
           %{reason: inspect(reason)},
           runtime_context.correlation_id
         )}

      {:ok, {:exception, kind, reason, stacktrace}} ->
        {:error,
         TypedError.new(
           "agent.runtime_internal_error",
           "internal",
           false,
           %{kind: inspect(kind), reason: inspect(reason), stacktrace: Exception.format_stacktrace(stacktrace)},
           runtime_context.correlation_id
         )}

      nil ->
        {:error,
         TypedError.new(
           "agent.runtime_timeout",
           "timeout",
           true,
           %{timeout_ms: timeout_ms},
           runtime_context.correlation_id
         )}

      other ->
        {:error,
         TypedError.new(
           "agent.runtime_internal_error",
           "internal",
           false,
           %{unexpected_result: inspect(other)},
           runtime_context.correlation_id
         )}
    end
  end

  defp safe_call(handler, request) do
    handler.(request)
  rescue
    exception ->
      {:exception, :error, exception, __STACKTRACE__}
  catch
    kind, reason ->
      {:exception, kind, reason, __STACKTRACE__}
  end

  defp normalize_error_correlation(%TypedError{} = error, runtime_context) do
    if error.correlation_id in [nil, "", "unknown"] do
      %{error | correlation_id: runtime_context.correlation_id}
    else
      error
    end
  end

  defp resolve_service_operation(%__MODULE__{routes: routes}, event_envelope) do
    event_type = fetch_any(event_envelope, :type)

    case Map.get(routes, event_type) do
      nil -> {"unknown_service", "unknown_operation"}
      route -> {route.service, route.operation}
    end
  end

  defp validate_context_integrity(event_envelope, runtime_context) do
    event_correlation = fetch_any(event_envelope, :correlation_id)
    event_request = fetch_any(event_envelope, :request_id)

    mismatches =
      []
      |> maybe_add_context_mismatch(:correlation_id, event_correlation, runtime_context.correlation_id)
      |> maybe_add_context_mismatch(:request_id, event_request, runtime_context.request_id)

    case mismatches do
      [] ->
        :ok

      _ ->
        {:error,
         TypedError.new(
           "agent.context_integrity_mismatch",
           "validation",
           false,
           %{mismatches: mismatches},
           runtime_context.correlation_id
         )}
    end
  end

  defp denied_dispatch_event(%TypedError{} = error, context, service, operation) do
    Diagnostics.denied_path_event(
      "runtime.dispatch.denied.v1",
      "WebUi.Agent",
      service,
      context,
      error,
      %{operation: operation}
    )
    |> Map.put(:operation, operation)
  end

  defp maybe_add_context_mismatch(mismatches, _field, nil, _context_value), do: mismatches
  defp maybe_add_context_mismatch(mismatches, _field, "", _context_value), do: mismatches

  defp maybe_add_context_mismatch(mismatches, field, event_value, context_value) do
    if event_value == context_value do
      mismatches
    else
      mismatches ++ [%{field: field, event_value: event_value, context_value: context_value}]
    end
  end

  defp extract_events(payload) when is_map(payload) do
    case fetch_any(payload, :events) do
      events when is_list(events) -> Enum.filter(events, &is_map/1)
      _ -> []
    end
  end

  defp fetch_any(map, key), do: Map.get(map, key) || Map.get(map, Atom.to_string(key))

  defp emit_service_observability({:ok, %ServiceResultEnvelope{} = envelope}, opts) do
    event =
      service_terminal_event(
        envelope.service,
        envelope.operation,
        envelope.context,
        envelope.outcome,
        %{
          error_code: envelope.error && envelope.error.error_code
        }
      )

    case Keyword.get(opts, :observability_fun) do
      fun when is_function(fun, 1) -> fun.(event)
      _ -> :ok
    end
  end

  defp emit_service_observability(_result, _opts), do: :ok

  defp service_terminal_event(service, operation, context, outcome, payload) do
    {:ok, event} =
      RuntimeEvent.build(
        %{
          event_name: "runtime.service.operation.terminal.v1",
          event_version: "v1",
          service: service,
          source: "WebUi.Agent",
          outcome: outcome,
          payload: Map.put(payload, :operation, operation)
        },
        context
      )

    event
    |> Map.put(:operation, operation)
    |> Map.put(:service, service)
  end

  defp emit_metric(opts, metric_name, labels, value, context) do
    case Metrics.metric_record(metric_name, labels, value, context) do
      {:ok, metric_record} ->
        case Keyword.get(opts, :metrics_fun) do
          fun when is_function(fun, 1) -> fun.(metric_record)
          _ -> :ok
        end

      {:error, _error} ->
        :ok
    end
  end

  defp elapsed_ms(started_at) do
    System.monotonic_time()
    |> Kernel.-(started_at)
    |> System.convert_time_unit(:native, :millisecond)
  end
end
