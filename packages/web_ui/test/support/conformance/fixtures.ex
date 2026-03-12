defmodule WebUi.TestSupport.Conformance.Fixtures do
  @moduledoc false

  alias WebUi.WidgetRegistry

  @spec runtime_context(keyword()) :: map()
  def runtime_context(opts \\ []) when is_list(opts) do
    prefix = Keyword.get(opts, :prefix, "scn")

    %{
      correlation_id: "#{prefix}-corr",
      request_id: "#{prefix}-req",
      session_id: Keyword.get(opts, :session_id, "#{prefix}-session"),
      client_id: Keyword.get(opts, :client_id, "#{prefix}-client"),
      user_id: Keyword.get(opts, :user_id, "#{prefix}-user"),
      trace_id: Keyword.get(opts, :trace_id, "#{prefix}-trace")
    }
  end

  @spec event_envelope(keyword()) :: map()
  def event_envelope(opts \\ []) when is_list(opts) do
    context = Keyword.get(opts, :context, runtime_context(prefix: Keyword.get(opts, :prefix, "scn-event")))

    %{
      specversion: "1.0",
      id: Keyword.get(opts, :id, "evt-#{Keyword.get(opts, :prefix, "scn-event")}"),
      source: Keyword.get(opts, :source, "webui.conformance"),
      type: Keyword.get(opts, :type, "runtime.command"),
      data: Keyword.get(opts, :data, %{action: "save"}),
      correlation_id: context.correlation_id,
      request_id: context.request_id,
      session_id: context.session_id,
      client_id: context.client_id,
      user_id: context.user_id,
      trace_id: context.trace_id
    }
  end

  @spec builtin_widget_descriptor(String.t()) :: map()
  def builtin_widget_descriptor(widget_id \\ "button") when is_binary(widget_id) do
    {:ok, registry} = WidgetRegistry.new()
    {:ok, descriptor} = WidgetRegistry.descriptor(registry, widget_id)
    Map.from_struct(descriptor)
  end

  @spec custom_widget_descriptor(keyword()) :: map()
  def custom_widget_descriptor(opts \\ []) when is_list(opts) do
    namespace = Keyword.get(opts, :namespace, "acme")
    name = Keyword.get(opts, :name, "widget")
    widget_id = Keyword.get(opts, :widget_id, "custom.#{namespace}.#{name}")
    category = Keyword.get(opts, :category, "runtime")
    state_model = Keyword.get(opts, :state_model, "stateful")

    %{
      widget_id: widget_id,
      origin: "custom",
      category: category,
      state_model: state_model,
      props_schema: Keyword.get(opts, :props_schema, %{type: "object", additional_properties: true}),
      event_schema:
        Keyword.get(opts, :event_schema, %{
          version: "v1",
          event_types: ["custom.#{namespace}.#{name}.selected"]
        }),
      version: Keyword.get(opts, :version, "v1"),
      capabilities: Keyword.get(opts, :capabilities, ["emit_widget_events@1"])
    }
  end
end
