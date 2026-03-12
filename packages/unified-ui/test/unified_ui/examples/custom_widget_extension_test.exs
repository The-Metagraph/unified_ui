defmodule UnifiedUi.Examples.CustomWidgetExtensionTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Layouts.VBox
  alias UnifiedIUR.Widgets.Text
  alias UnifiedUi.Adapters.State

  @example_file Path.expand("examples/custom_widget/lib/unified_ui_observability/extension.ex")
  Code.require_file(@example_file)

  test "example extension loads and exposes widget/renderer modules" do
    extension_module = UnifiedUiObservability.Extension
    widget_module = UnifiedUiObservability.Extension.Widgets.MetricBadge
    renderer_module = UnifiedUiObservability.Extension.Renderers.Terminal

    assert Code.ensure_loaded?(extension_module)
    assert Code.ensure_loaded?(widget_module)
    assert Code.ensure_loaded?(renderer_module)

    assert %{
             widget: ^widget_module,
             renderer: ^renderer_module
           } = extension_module.components()
  end

  test "example extension widget and renderer functions work" do
    terminal_renderer = UnifiedUiObservability.Extension.Renderers.Terminal
    metric_badge_module = UnifiedUiObservability.Extension.Widgets.MetricBadge

    widget = struct(metric_badge_module, id: :latency, name: "Latency", value: 42)
    assert %{id: :latency, name: "Latency", value: 42, visible: true} = widget

    iur = %VBox{id: :root, children: [widget]}
    assert {:ok, renderer_state} = terminal_renderer.render(iur)
    assert {:ok, _root} = State.get_root(renderer_state)

    assert {:ok, unchanged_state} = terminal_renderer.update(iur, renderer_state)
    assert unchanged_state == renderer_state

    updated_widget = struct(metric_badge_module, id: :latency, name: "Latency", value: 43)

    updated_iur = %VBox{
      id: :root,
      children: [updated_widget]
    }

    assert {:ok, updated_state} = terminal_renderer.update(updated_iur, renderer_state)
    assert updated_state.version == renderer_state.version + 1

    iur_without_custom = %VBox{id: :root, children: [%Text{content: "fallback"}]}
    assert {:ok, fallback_state} = terminal_renderer.render(iur_without_custom)
    assert {:ok, _root} = State.get_root(fallback_state)
  end
end
