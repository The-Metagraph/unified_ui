defmodule UnifiedExamples.TextTest do
  use ExUnit.Case, async: true

  alias UnifiedExamples.Text

  test "baseline example app exposes the standard standalone metadata contract" do
    assert Text.metadata() == %{
             id: :text_example_screen,
             root_id: :text_example_screen_root,
             title: "Example App Skeleton",
             summary: "Baseline standalone app proving the shared example runtime path",
             notes: "This skeleton is the baseline structure for standalone example apps.",
             widget: :text,
             theme_id: :example_suite_default,
             app: :unified_example_text,
             directory: "examples/text",
             purpose: :baseline_skeleton
           }
  end

  test "baseline example app boots and renders through the shared live_ui runtime path" do
    assert {:ok, runtime_state} = Text.boot()
    assert {:ok, assigns} = Text.component_assigns()
    assert {:ok, html} = Text.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :text_example_screen_shell
    assert assigns.id == "unified_examples-text-screen"
    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "Example App Skeleton"
    assert html =~ "Skeleton ready"
    assert html =~ "data-live-ui-widget=\"text\""
  end
end
