defmodule WebUi.Widget do
  @moduledoc """
  Deterministic widget render boundary for built-in registry descriptors.
  """

  alias WebUi.CloudEvent
  alias WebUi.Observability.Diagnostics
  alias WebUi.Observability.RuntimeEvent
  alias WebUi.TypedError
  alias WebUi.WidgetRegistry
  alias WebUi.WidgetRenderRequest
  alias WebUi.WidgetRenderResult

  @blocked_extension_actions ["mutate_domain_state", "execute_runtime_command", "write_persistence"]

  @spec validate_render_request(WidgetRegistry.t(), map() | WidgetRenderRequest.t()) ::
          {:ok, WidgetRenderRequest.t()} | {:error, TypedError.t()}
  def validate_render_request(%WidgetRegistry{} = registry, request) do
    with {:ok, normalized_request} <- WidgetRenderRequest.validate(request),
         {:ok, _descriptor} <- WidgetRegistry.descriptor(registry, normalized_request.widget_id) do
      {:ok, normalized_request}
    else
      {:error, %TypedError{} = error} -> {:error, error}
    end
  end

  @spec render(WidgetRegistry.t(), map() | WidgetRenderRequest.t(), keyword()) :: WidgetRenderResult.t()
  def render(%WidgetRegistry{} = registry, request, opts \\ []) when is_list(opts) do
    context = request_context(request)

    with {:ok, normalized_request} <- validate_render_request(registry, request),
         {:ok, descriptor} <- WidgetRegistry.descriptor(registry, normalized_request.widget_id),
         {:ok, entry} <- WidgetRegistry.entry(registry, normalized_request.widget_id) do
      case entry.origin do
        "custom" ->
          case render_custom_widget(registry, normalized_request, descriptor, entry, opts) do
            {:ok, node, extra_events} ->
              WidgetRenderResult.success(normalized_request.widget_id, node, normalized_request.context, extra_events)

            {:error, %TypedError{} = error, extra_events} ->
              WidgetRenderResult.error(normalized_request.widget_id, error, normalized_request.context, extra_events)
          end

        _ ->
          node = render_node(descriptor, entry, normalized_request.props, normalized_request.state)
          WidgetRenderResult.success(normalized_request.widget_id, node, normalized_request.context)
      end
    else
      {:error, %TypedError{} = error} ->
        widget_id = request_widget_id(request)
        WidgetRenderResult.error(widget_id, error, context)
    end
  end

  defp render_custom_widget(registry, request, descriptor, entry, opts) do
    with {:ok, dispatch_fun} <- fetch_extension_dispatch_fun(opts),
         {:ok, implementation_ref} <- WidgetRegistry.implementation_ref(registry, descriptor.widget_id),
         :ok <- ensure_extension_request_allowed(request),
         {:ok, extension_result} <- dispatch_custom(implementation_ref, request, descriptor, dispatch_fun),
         {:ok, node, extension_events} <- normalize_custom_render(extension_result, descriptor, entry, request.context) do
      {:ok, node, extension_events}
    else
      {:error, %TypedError{} = error} ->
        {:error, error, []}

      {:error, %TypedError{} = error, events} ->
        {:error, error, events}
    end
  end

  defp fetch_extension_dispatch_fun(opts) do
    case Keyword.get(opts, :extension_dispatch_fun) do
      dispatch_fun when is_function(dispatch_fun, 2) ->
        {:ok, dispatch_fun}

      _ ->
        {:error,
         TypedError.new(
           "widget.extension_dispatch_unavailable",
           "validation",
           false,
           %{reason: "custom widget renders require extension_dispatch_fun/2"}
         )}
    end
  end

  defp ensure_extension_request_allowed(%WidgetRenderRequest{} = request) do
    action = extension_action(request.props)

    if is_binary(action) and action in @blocked_extension_actions do
      error =
        TypedError.new(
          "widget.extension_action_denied",
          "authorization",
          false,
          %{widget_id: request.widget_id, action: action},
          request.context.correlation_id
        )

      telemetry_event =
        Diagnostics.denied_path_event(
          "runtime.widget.extension_denied.v1",
          "WebUi.Widget",
          "widget_extension",
          request.context,
          error,
          %{widget_id: request.widget_id, denied_action: action}
        )
        |> Map.put(:widget_id, request.widget_id)
        |> Map.put(:denied_action, action)
        |> Map.put(:error_code, error.error_code)

      {:error, error, [telemetry_event]}
    else
      :ok
    end
  end

  defp dispatch_custom(implementation_ref, request, descriptor, dispatch_fun) do
    payload = %{
      widget_id: request.widget_id,
      descriptor: descriptor,
      props: request.props,
      state: request.state,
      context: request.context
    }

    try do
      case dispatch_fun.(implementation_ref, payload) do
        {:ok, result} when is_map(result) ->
          {:ok, result}

        {:error, %TypedError{} = error} ->
          {:error, error}

        {:error, reason} ->
          {:error,
           TypedError.new(
             "widget.extension_dispatch_failed",
             "dependency",
             true,
             %{implementation_ref: implementation_ref, reason: inspect(reason)},
             request.context.correlation_id
           )}

        other ->
          {:error,
           TypedError.new(
             "widget.extension_dispatch_invalid_result",
             "internal",
             false,
             %{implementation_ref: implementation_ref, result: inspect(other)},
             request.context.correlation_id
           )}
      end
    rescue
      exception ->
        {:error,
         TypedError.new(
           "widget.extension_dispatch_exception",
           "internal",
           false,
           %{implementation_ref: implementation_ref, exception: Exception.message(exception)},
           request.context.correlation_id
         )}
    end
  end

  defp normalize_custom_render(result, descriptor, entry, context) when is_map(result) and is_map(context) do
    node =
      case Map.get(result, :node) || Map.get(result, "node") do
        node when is_map(node) -> normalize_map(node)
        _ -> render_node(descriptor, entry, result_props(result), result_state(result))
      end

    with {:ok, extension_events} <- normalize_extension_events(result, context, descriptor.widget_id) do
      {:ok, node, extension_events}
    end
  end

  defp normalize_extension_events(result, context, widget_id) do
    case Map.get(result, :events) || Map.get(result, "events") do
      nil ->
        {:ok, []}

      events when is_list(events) ->
        events
        |> Enum.reduce_while({:ok, []}, fn event, {:ok, acc} ->
          case normalize_extension_event(event, context, widget_id) do
            {:ok, normalized} -> {:cont, {:ok, [normalized | acc]}}
            {:error, %TypedError{} = error} -> {:halt, {:error, error}}
          end
        end)
        |> case do
          {:ok, normalized} -> {:ok, Enum.reverse(normalized)}
          {:error, %TypedError{} = error} -> {:error, error}
        end

      _ ->
        {:error,
         TypedError.new(
           "widget.extension_invalid_events",
           "validation",
           false,
           %{widget_id: widget_id, reason: "events must be a list"}
         )}
    end
  end

  defp normalize_extension_event(event, context, widget_id) when is_map(event) do
    event_name = Map.get(event, :event_name) || Map.get(event, "event_name")

    if is_binary(event_name) and event_name != "" do
      event_payload = Map.get(event, :payload) || Map.get(event, "payload") || %{}

      case RuntimeEvent.build(
             %{
               event_name: event_name,
               event_version: Map.get(event, :event_version) || Map.get(event, "event_version") || "v1",
               service: Map.get(event, :service) || Map.get(event, "service") || "widget_extension",
               source: Map.get(event, :source) || Map.get(event, "source") || "WebUi.Widget",
               outcome: Map.get(event, :outcome) || Map.get(event, "outcome") || "ok",
               payload: event_payload |> normalize_map() |> Map.put_new("widget_id", widget_id)
             },
             context
           ) do
        {:ok, normalized} ->
          {:ok,
           normalized
           |> Map.put("event_name", normalized.event_name)
           |> Map.put("widget_id", widget_id)}

        {:error, %TypedError{} = error} ->
          {:error, error}
      end
    else
      candidate_envelope = normalize_map(event)

      case CloudEvent.decode(candidate_envelope) do
        {:ok, validated} ->
          envelope_type = Map.get(validated, :type) || Map.get(validated, "type")

          if custom_dispatch_event_type?(envelope_type) do
            {:ok, runtime_event} =
              RuntimeEvent.build(
                %{
                  event_name: "runtime.widget.extension_event.v1",
                  event_version: "v1",
                  service: "widget_extension",
                  source: "WebUi.Widget",
                  outcome: "ok",
                  payload: %{
                    widget_id: widget_id,
                    envelope_type: envelope_type
                  }
                },
                context
              )

            {:ok,
             runtime_event
             |> Map.put("event_name", runtime_event.event_name)
             |> Map.put("widget_id", widget_id)
             |> Map.put("envelope_type", envelope_type)}
          else
            {:error,
             TypedError.new(
               "widget.extension_invalid_event_type",
               "validation",
               false,
               %{widget_id: widget_id, event_type: envelope_type}
             )}
          end

        {:error, %TypedError{} = error} ->
          {:error,
           TypedError.new(
             "widget.extension_invalid_event_envelope",
             "validation",
             false,
             %{widget_id: widget_id, error: error.error_code}
           )}
      end
    end
  end

  defp normalize_extension_event(_event, _context, widget_id) do
    {:error,
     TypedError.new(
       "widget.extension_invalid_event_envelope",
       "validation",
       false,
       %{widget_id: widget_id, reason: "event must be a map"}
     )}
  end

  defp result_props(result) do
    case Map.get(result, :props) || Map.get(result, "props") do
      props when is_map(props) -> props
      _ -> %{}
    end
  end

  defp result_state(result) do
    case Map.get(result, :state) || Map.get(result, "state") do
      state when is_map(state) -> state
      _ -> %{}
    end
  end

  defp extension_action(props) when is_map(props) do
    Map.get(props, :action) ||
      Map.get(props, "action") ||
      Map.get(props, :requested_action) ||
      Map.get(props, "requested_action") ||
      Map.get(props, :operation) ||
      Map.get(props, "operation")
  end

  defp extension_action(_props), do: nil

  defp custom_dispatch_event_type?(event_type) when is_binary(event_type) do
    String.starts_with?(event_type, "unified.") or
      Regex.match?(~r/^custom\.[a-z0-9]+(?:_[a-z0-9]+)*(?:\.[a-z0-9]+(?:_[a-z0-9]+)*)+$/, event_type)
  end

  defp custom_dispatch_event_type?(_event_type), do: false

  defp render_node(descriptor, entry, props, state) do
    %{
      widget_id: descriptor.widget_id,
      termui_module: entry.termui_module,
      descriptor_version: descriptor.version,
      category: descriptor.category,
      state_model: descriptor.state_model,
      props: normalize_map(props),
      state: normalize_map(state)
    }
  end

  defp normalize_map(map) when is_map(map) do
    map
    |> Enum.map(fn {key, value} -> {to_string(key), normalize_value(value)} end)
    |> Enum.sort_by(&elem(&1, 0))
    |> Enum.into(%{})
  end

  defp normalize_value(value) when is_map(value), do: normalize_map(value)
  defp normalize_value(value) when is_list(value), do: Enum.map(value, &normalize_value/1)
  defp normalize_value(value), do: value

  defp request_widget_id(%WidgetRenderRequest{widget_id: widget_id}), do: widget_id

  defp request_widget_id(request) when is_map(request) do
    Map.get(request, :widget_id) || Map.get(request, "widget_id") || "unknown_widget"
  end

  defp request_widget_id(_request), do: "unknown_widget"

  defp request_context(%WidgetRenderRequest{context: context}), do: context

  defp request_context(request) when is_map(request) do
    case Map.get(request, :context) || Map.get(request, "context") do
      context when is_map(context) -> context
      _ -> %{}
    end
  end

  defp request_context(_request), do: %{}
end
