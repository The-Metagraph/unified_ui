defmodule WebUi.Integration.Phase04WidgetRegistryTest do
  use ExUnit.Case, async: true

  alias WebUi.Widget
  alias WebUi.WidgetRegistry

  defp registry do
    {:ok, registry} = WidgetRegistry.new()
    registry
  end

  @tag :conformance
  test "SCN-007 built-in widget catalog exactly matches term_ui baseline IDs" do
    expected_ids = [
      "block",
      "button",
      "label",
      "list",
      "pick_list",
      "progress",
      "text_input_primitive",
      "alert_dialog",
      "bar_chart",
      "canvas",
      "cluster_dashboard",
      "command_palette",
      "context_menu",
      "dialog",
      "form_builder",
      "gauge",
      "line_chart",
      "log_viewer",
      "markdown_viewer",
      "menu",
      "process_monitor",
      "scroll_bar",
      "sparkline",
      "split_pane",
      "stream_widget",
      "supervision_tree_viewer",
      "table",
      "tabs",
      "text_input",
      "toast",
      "toast_manager",
      "tree_view",
      "viewport"
    ]

    assert WidgetRegistry.builtin_widget_ids() == expected_ids
    assert :ok == WidgetRegistry.parity_check()
  end

  @tag :conformance
  test "SCN-008 descriptors are complete and query APIs are deterministic" do
    reg = registry()

    builtin_descriptors = WidgetRegistry.list_by_origin(reg, "builtin")

    assert length(builtin_descriptors) == 33

    for descriptor <- builtin_descriptors do
      assert is_binary(descriptor.widget_id)
      assert descriptor.origin == "builtin"
      assert descriptor.category in WidgetRegistry.allowed_categories()
      assert is_map(descriptor.props_schema)
      assert is_map(descriptor.event_schema)
      assert is_list(descriptor.event_schema.event_types)
    end

    assert WidgetRegistry.descriptor(reg, "button") == WidgetRegistry.descriptor(reg, "button")
  end

  @tag :conformance
  test "SCN-012 equivalent render requests produce equivalent render outputs" do
    reg = registry()

    request = %{
      widget_id: "button",
      props: %{label: "Save", attrs: %{kind: "primary"}},
      state: %{pressed: false},
      context: %{correlation_id: "corr-440", request_id: "req-440"}
    }

    assert Widget.render(reg, request) == Widget.render(reg, request)
  end

  @tag :conformance
  test "SCN-009 invalid render requests fail with typed validation errors" do
    reg = registry()

    result =
      Widget.render(reg, %{
        widget_id: "button",
        props: "invalid",
        context: %{correlation_id: "corr-441", request_id: "req-441"}
      })

    assert result.outcome == "error"
    assert result.error.error_code == "widget_render_request.invalid_props"
  end

  @tag :conformance
  test "SCN-011 render lifecycle events preserve correlation/request metadata" do
    reg = registry()

    result =
      Widget.render(reg, %{
        widget_id: "button",
        props: %{label: "Save"},
        state: %{},
        context: %{correlation_id: "corr-442", request_id: "req-442"}
      })

    assert result.outcome == "ok"

    event = hd(result.events)

    assert event.event_name == "runtime.widget.rendered.v1"
    assert event.correlation_id == "corr-442"
    assert event.request_id == "req-442"
  end
end
