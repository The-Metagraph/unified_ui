defmodule WebUi.Integration.Phase05WidgetEventContractsTest do
  use ExUnit.Case, async: true

  alias WebUi.Events.ElmBindings
  alias WebUi.Events.EventCatalog
  alias WebUi.Ui.Message
  alias WebUi.Ui.Runtime
  alias WebUi.WidgetRegistry

  defp registry do
    {:ok, registry} = WidgetRegistry.new()
    registry
  end

  defp booted_model(correlation_id \\ "corr-540", request_id \\ "req-540") do
    {:ok, model, _commands} = Runtime.init(%{runtime_context: %{correlation_id: correlation_id, request_id: request_id}})
    model
  end

  defp sample_data_for(event_type, widget_id) do
    {:ok, required_keys} = EventCatalog.required_key_spec(event_type)

    required_keys.required_all_of
    |> Enum.reduce(%{"widget_id" => widget_id}, fn key, acc -> Map.put(acc, key, sample_value(key, widget_id)) end)
    |> then(fn data ->
      Enum.reduce(required_keys.required_any_of, data, fn alternatives, acc ->
        case alternatives do
          [first | _] -> Map.put_new(acc, first, sample_value(first, widget_id))
          [] -> acc
        end
      end)
    end)
  end

  defp sample_value("widget_id", widget_id), do: widget_id
  defp sample_value("input_id", widget_id), do: widget_id <> "_input"
  defp sample_value("form_id", widget_id), do: widget_id <> "_form"
  defp sample_value("button_id", widget_id), do: widget_id <> "_button"
  defp sample_value("action", _widget_id), do: "sample_action"
  defp sample_value("id", widget_id), do: widget_id <> "_id"
  defp sample_value(key, _widget_id), do: key <> "_value"

  @tag :conformance
  test "SCN-wgt-013 each interactive built-in widget emits mapped event types only" do
    reg = registry()

    for descriptor <- WidgetRegistry.list_by_origin(reg, "builtin"),
        descriptor.event_schema.interaction_mode == "interactive",
        event_type <- descriptor.event_schema.event_types do
      message =
        Message.widget_event(%{
          type: event_type,
          widget_id: descriptor.widget_id,
          widget_kind: descriptor.widget_id,
          data: sample_data_for(event_type, descriptor.widget_id)
        })

      {_model, [command]} = Runtime.update(booted_model(), message)
      assert command.payload.event["type"] == event_type
      assert event_type in descriptor.event_schema.event_types
    end
  end

  @tag :conformance
  test "SCN-wgt-014 canonical required data keys validate for all cataloged event types" do
    for event_type <- EventCatalog.all_event_types() do
      assert :ok == EventCatalog.validate_event(event_type, sample_data_for(event_type, "widget_under_test"))
    end
  end

  @tag :conformance
  test "SCN-wgt-015 click/change/submit events include route-key compatibility fields" do
    route_cases = [
      {"unified.button.clicked", ["action", "button_id", "widget_id", "id"]},
      {"unified.input.changed", ["input_id", "widget_id", "field", "action", "id"]},
      {"unified.form.submitted", ["form_id", "action", "id"]}
    ]

    for {event_type, required_route_keys} <- route_cases do
      message =
        Message.widget_event(%{
          type: event_type,
          widget_id: "route_widget",
          widget_kind: "route_widget",
          data: sample_data_for(event_type, "route_widget")
        })

      {_model, [command]} = Runtime.update(booted_model(), message)
      event_data = command.payload.event["data"]

      for required_key <- required_route_keys do
        assert event_data[required_key] not in [nil, ""]
      end
    end
  end

  @tag :conformance
  test "SCN-ui-007 standard Html binding helpers produce canonical outbound envelopes" do
    bindings = [
      ElmBindings.on_click("save_button", "button", %{action: "save"}),
      ElmBindings.on_input("email_input", "text_input", "person@example.com"),
      ElmBindings.on_submit("login_form", "form")
    ]

    for {:ok, event} <- bindings do
      {_model, [command]} = Runtime.update(booted_model(), Message.widget_event(event))
      assert command.payload.event["specversion"] == "1.0"
      assert command.payload.event["type"] == event.type
      assert command.payload.event["data"]["widget_id"] == event.widget_id
    end
  end

  @tag :conformance
  test "SCN-ui-008 Browser/global binding helpers produce advanced canonical events" do
    bindings = [
      ElmBindings.on_resize("main_viewport", "viewport", 120, 50),
      ElmBindings.decode_action_key("command_palette", "command_palette", %{"key" => "Enter", "code" => "Enter"}),
      ElmBindings.decode_canvas_pointer("render_canvas", %{"clientX" => 10, "clientY" => 20, "type" => "move"})
    ]

    for {:ok, event} <- bindings do
      {_model, [command]} = Runtime.update(booted_model(), Message.widget_event(event))
      assert command.payload.event["type"] == event.type
      assert command.payload.event["data"]["widget_id"] == event.widget_id
    end
  end

  @tag :conformance
  test "SCN-ui-009 widget dispatch preserves correlation and request identifiers" do
    {:ok, event} = ElmBindings.on_click("confirm_button", "button", %{action: "confirm"})
    model = booted_model("corr-549", "req-549")

    {_updated_model, [command]} = Runtime.update(model, Message.widget_event(event))

    assert command.payload.event["correlation_id"] == "corr-549"
    assert command.payload.event["request_id"] == "req-549"
    assert command.payload.event["type"] == "unified.button.clicked"
  end
end
