defmodule WebUi.WidgetRenderTest do
  use ExUnit.Case, async: true

  alias WebUi.Widget
  alias WebUi.WidgetRegistry

  defp registry do
    {:ok, registry} = WidgetRegistry.new()
    registry
  end

  defp base_request(overrides \\ %{}) do
    base = %{
      widget_id: "button",
      props: %{label: "Save", attrs: %{kind: "primary"}},
      state: %{pressed: false},
      context: %{correlation_id: "corr-411", request_id: "req-411"}
    }

    Map.merge(base, overrides)
  end

  test "render success returns deterministic widget node and rendered lifecycle event" do
    result_a = Widget.render(registry(), base_request())
    result_b = Widget.render(registry(), base_request())

    assert result_a == result_b
    assert result_a.outcome == "ok"
    assert result_a.widget_id == "button"
    assert result_a.node.termui_module == "TermUI.Widget.Button"
    assert result_a.node.props["label"] == "Save"

    rendered_event = hd(result_a.events)

    assert rendered_event.event_name == "runtime.widget.rendered.v1"
    assert rendered_event.correlation_id == "corr-411"
    assert rendered_event.request_id == "req-411"
  end

  test "render fails with typed validation errors for invalid requests" do
    result = Widget.render(registry(), base_request(%{props: "invalid"}))

    assert result.outcome == "error"
    assert result.error.error_code == "widget_render_request.invalid_props"

    failure_event = hd(result.events)
    assert failure_event.event_name == "runtime.widget.render_failed.v1"
    assert failure_event.error_code == "widget_render_request.invalid_props"
  end

  test "render fails with typed descriptor error for unknown widgets" do
    result = Widget.render(registry(), base_request(%{widget_id: "not_a_widget"}))

    assert result.outcome == "error"
    assert result.error.error_code == "widget_registry.descriptor_not_found"
    assert hd(result.events).correlation_id == "corr-411"
  end
end
