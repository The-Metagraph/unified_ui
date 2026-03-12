defmodule WebUi.Channel do
  @moduledoc """
  Stateless orchestration boundary for canonical websocket ingress and egress.
  """

  alias WebUi.CloudEvent
  alias WebUi.Observability.Metrics
  alias WebUi.Observability.RuntimeEvent
  alias WebUi.ServiceResultEnvelope
  alias WebUi.Transport.Naming
  alias WebUi.TypedError
  alias WebUi.Agent, as: RuntimeAgent

  @send_event "runtime.event.send.v1"
  @ping_event "runtime.event.ping.v1"

  @recv_event "runtime.event.recv.v1"
  @error_event "runtime.event.error.v1"
  @pong_event "runtime.event.pong.v1"

  @spec observe_ws_connection(String.t(), String.t(), keyword()) :: :ok
  def observe_ws_connection(endpoint, outcome, opts \\ []) when is_binary(endpoint) and is_binary(outcome) and is_list(opts) do
    context = %{correlation_id: "transport", request_id: "transport"}

    emit_metric(
      opts,
      "webui_ws_connection_total",
      %{endpoint: endpoint, outcome: outcome},
      1,
      context
    )

    emit_runtime_event(
      opts,
      %{
        event_name: "runtime.transport.connection.v1",
        event_version: "v1",
        service: "transport",
        source: "WebUi.Channel",
        outcome: outcome == "ok" && "ok" || "error",
        payload: %{endpoint: endpoint, outcome: outcome}
      },
      context
    )

    :ok
  end

  @spec observe_ws_disconnect(String.t(), String.t(), keyword()) :: :ok
  def observe_ws_disconnect(endpoint, reason, opts \\ []) when is_binary(endpoint) and is_binary(reason) and is_list(opts) do
    context = %{correlation_id: "transport", request_id: "transport"}

    emit_metric(
      opts,
      "webui_ws_disconnect_total",
      %{endpoint: endpoint, reason: reason},
      1,
      context
    )

    emit_runtime_event(
      opts,
      %{
        event_name: "runtime.transport.disconnect.v1",
        event_version: "v1",
        service: "transport",
        source: "WebUi.Channel",
        outcome: "error",
        payload: %{endpoint: endpoint, reason: reason}
      },
      context
    )

    :ok
  end

  @spec handle_client_message(String.t(), String.t(), map(), keyword()) :: {:ok, map()}
  def handle_client_message(topic, event_name, payload, opts \\ []) when is_list(opts) do
    context = payload_context(payload)

    emit_runtime_event(
      opts,
      %{
        event_name: "runtime.transport.ingress.v1",
        event_version: "v1",
        service: "transport",
        source: "WebUi.Channel",
        outcome: "ok",
        payload: %{topic: topic, client_event: event_name}
      },
      context
    )

    emit_metric(
      opts,
      "webui_event_ingress_total",
      %{service: "transport", event_type: event_name, outcome: "ok"},
      1,
      context
    )

    with :ok <- Naming.validate_topic(topic),
         :ok <- Naming.validate_client_event_name(event_name) do
      {:ok, response} = do_handle_event(event_name, payload, opts)
      emit_egress_observability(opts, event_name, response, context)
      {:ok, response}
    else
      {:error, %TypedError{} = error} ->
        emit_runtime_event(
          opts,
          %{
            event_name: "runtime.transport.ingress_failed.v1",
            event_version: "v1",
            service: "transport",
            source: "WebUi.Channel",
            outcome: "error",
            payload: %{topic: topic, client_event: event_name, error_code: error.error_code, category: error.category}
          },
          context
        )

        emit_metric(
          opts,
          "webui_event_ingress_total",
          %{service: "transport", event_type: event_name, outcome: "error"},
          1,
          context
        )

        response = error_envelope(error)
        emit_egress_observability(opts, event_name, response, context)
        {:ok, response}
    end
  end

  defp do_handle_event(@send_event, payload, opts) do
    with {:ok, normalized} <- normalize_ingress_payload(payload, opts),
         {:ok, dispatch_outcome} <- dispatch_runtime(normalized.event, normalized.context, opts) do
      {:ok, normalize_dispatch_result(normalized.context, {:ok, dispatch_outcome}, opts)}
    else
      {:error, %TypedError{} = error} ->
        {:ok, error_envelope(error)}
    end
  end

  defp do_handle_event(@ping_event, payload, _opts) do
    {:ok,
     %{
       event_name: @pong_event,
      payload: %{
        correlation_id: fetch_payload_value(payload, :correlation_id) || "ping",
        request_id: fetch_payload_value(payload, :request_id) || "ping"
      }
     }}
  end

  @spec normalize_dispatch_result(map(), tuple() | any()) :: map()
  def normalize_dispatch_result(context, result), do: normalize_dispatch_result(context, result, [])

  @spec normalize_dispatch_result(map(), tuple() | any(), keyword()) :: map()
  def normalize_dispatch_result(_context, {:ok, %ServiceResultEnvelope{} = envelope}, _opts) do
    %{
      event_name: @recv_event,
      payload: %{
        result: ServiceResultEnvelope.to_map(envelope),
        context: envelope.context
      }
    }
  end

  def normalize_dispatch_result(context, {:ok, event}, opts) when is_map(context) and is_map(event) do
    with {:ok, encoded_event} <- CloudEvent.encode(event) do
      %{
        event_name: @recv_event,
        payload: %{
          event: encoded_event,
          context: context
        }
      }
    else
      {:error, %TypedError{} = error} ->
        emit_runtime_event(
          opts,
          %{
            event_name: "runtime.transport.encode_failed.v1",
            event_version: "v1",
            service: "transport",
            source: "WebUi.Channel",
            outcome: "error",
            payload: %{error_code: error.error_code, category: error.category}
          },
          context
        )

        emit_metric(
          opts,
          "webui_event_encode_error_total",
          %{service: "transport", error_code: error.error_code},
          1,
          context
        )

        error_envelope(error)
    end
  end

  def normalize_dispatch_result(_context, {:error, reason}, _opts) do
    reason
    |> to_typed_error()
    |> error_envelope()
  end

  def normalize_dispatch_result(_context, reason, _opts) do
    reason
    |> to_typed_error()
    |> error_envelope()
  end

  defp dispatch_runtime(event, context, opts) do
    dispatch_fun = Keyword.get(opts, :dispatch_fun)
    runtime_agent = Keyword.get(opts, :agent)

    cond do
      is_function(dispatch_fun, 2) ->
        case dispatch_fun.(event, context) do
          {:ok, %ServiceResultEnvelope{} = envelope} -> {:ok, envelope}
          {:ok, payload} when is_map(payload) -> {:ok, payload}
          {:error, %TypedError{} = error} -> {:error, error}
          {:error, reason} -> {:error, to_typed_error(reason)}
          other -> {:error, to_typed_error({:invalid_dispatch_result, other})}
        end

      match?(%RuntimeAgent{}, runtime_agent) ->
        RuntimeAgent.dispatch_result(runtime_agent, event, context, opts)

      true ->
        {:ok, event}
    end
  end

  defp normalize_ingress_payload(payload, opts) when is_map(payload) do
    with {:ok, event} <- fetch_event(payload),
         {:ok, validated_event} <- CloudEvent.decode(event),
         {:ok, context} <- CloudEvent.extract_context(validated_event) do
      {:ok, %{event: validated_event, context: context}}
    else
      {:error, %TypedError{} = error} ->
        context = payload_context(payload)

        emit_runtime_event(
          opts,
          %{
            event_name: "runtime.transport.decode_failed.v1",
            event_version: "v1",
            service: "transport",
            source: "WebUi.Channel",
            outcome: "error",
            payload: %{error_code: error.error_code, category: error.category}
          },
          context
        )

        emit_metric(
          opts,
          "webui_event_decode_error_total",
          %{service: "transport", error_code: error.error_code},
          1,
          context
        )

        {:error, error}
    end
  end

  defp normalize_ingress_payload(_payload, _opts) do
    {:error,
     TypedError.new(
       "channel.invalid_payload",
       "protocol",
       false,
       %{reason: "payload must be a map"}
     )}
  end

  defp fetch_event(payload) do
    case fetch_payload_value(payload, :event) do
      event when is_map(event) -> {:ok, event}
      _ ->
        {:error,
         TypedError.new(
           "channel.missing_event_payload",
           "protocol",
           false,
           %{required_key: :event}
         )}
    end
  end

  defp fetch_payload_value(payload, key) when is_map(payload) do
    Map.get(payload, key) || Map.get(payload, Atom.to_string(key))
  end

  defp to_typed_error(%TypedError{} = error), do: error

  defp to_typed_error({:timeout, timeout_ms}) do
    TypedError.new(
      "channel.runtime_timeout",
      "timeout",
      true,
      %{timeout_ms: timeout_ms}
    )
  end

  defp to_typed_error({:dependency, reason}) do
    TypedError.new(
      "channel.runtime_dependency_error",
      "dependency",
      true,
      %{reason: inspect(reason)}
    )
  end

  defp to_typed_error(reason) do
    TypedError.new(
      "channel.runtime_internal_error",
      "internal",
      false,
      %{reason: inspect(reason)}
    )
  end

  defp error_envelope(%TypedError{} = error) do
    %{
      event_name: @error_event,
      payload: %{
        error: %{
          error_code: error.error_code,
          category: error.category,
          retryable: error.retryable,
          details: error.details,
          correlation_id: error.correlation_id
        }
      }
    }
  end

  defp emit_egress_observability(opts, inbound_event_name, response, context) do
    response_event_name = fetch_payload_value(response, :event_name) || "runtime.event.unknown.v1"

    outcome =
      if response_event_name == @error_event do
        "error"
      else
        "ok"
      end

    emit_runtime_event(
      opts,
      %{
        event_name: "runtime.transport.egress.v1",
        event_version: "v1",
        service: "transport",
        source: "WebUi.Channel",
        outcome: outcome,
        payload: %{client_event: inbound_event_name, response_event: response_event_name}
      },
      context
    )

    emit_metric(
      opts,
      "webui_event_egress_total",
      %{service: "transport", event_type: response_event_name, outcome: outcome},
      1,
      context
    )
  end

  defp emit_runtime_event(opts, attrs, context) when is_list(opts) and is_map(attrs) and is_map(context) do
    case RuntimeEvent.build(attrs, context) do
      {:ok, event} ->
        case Keyword.get(opts, :observability_fun) do
          fun when is_function(fun, 1) -> fun.(event)
          _ -> :ok
        end

      {:error, %TypedError{} = error} ->
        conformance_event = RuntimeEvent.conformance_failure_event(error, context, attrs)

        case Keyword.get(opts, :observability_fun) do
          fun when is_function(fun, 1) -> fun.(conformance_event)
          _ -> :ok
        end
    end
  end

  defp emit_metric(opts, metric_name, labels, value, context)
       when is_list(opts) and is_binary(metric_name) and is_map(labels) and is_map(context) do
    case Metrics.metric_record(metric_name, labels, value, context) do
      {:ok, metric_record} ->
        case Keyword.get(opts, :metrics_fun) do
          fun when is_function(fun, 1) -> fun.(metric_record)
          _ -> :ok
        end

      {:error, %TypedError{} = error} ->
        emit_runtime_event(
          opts,
          %{
            event_name: "runtime.observability.metric_rejected.v1",
            event_version: "v1",
            service: "observability",
            source: "WebUi.Channel",
            outcome: "error",
            payload: %{
              metric_name: metric_name,
              error_code: error.error_code,
              details: error.details,
              joinability_context: %{
                correlation_id: Map.get(context, :correlation_id, "unknown"),
                request_id: Map.get(context, :request_id, "unknown")
              }
            }
          },
          context
        )
    end
  end

  defp payload_context(payload) when is_map(payload) do
    event = fetch_payload_value(payload, :event)
    event_context = if is_map(event), do: event, else: %{}

    %{
      correlation_id:
        fetch_payload_value(payload, :correlation_id) ||
          fetch_payload_value(event_context, :correlation_id) ||
          "unknown",
      request_id:
        fetch_payload_value(payload, :request_id) ||
          fetch_payload_value(event_context, :request_id) ||
          "unknown",
      session_id:
        fetch_payload_value(payload, :session_id) ||
          fetch_payload_value(event_context, :session_id),
      client_id:
        fetch_payload_value(payload, :client_id) ||
          fetch_payload_value(event_context, :client_id)
    }
  end

  defp payload_context(_payload), do: %{correlation_id: "unknown", request_id: "unknown"}
end
