defmodule UnifiedExamples.ScrollBarTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Tree
  alias UnifiedExamples.ScrollBar

  test "scroll bar example exposes standalone example metadata" do
    assert ScrollBar.metadata() == %{
             id: :scroll_bar_example_screen,
             root_id: :scroll_bar_example_screen_root,
             title: "Scroll Bar Widget Example",
             summary: "Focused display-system example using the shared suite shell",
             notes:
               "Scroll-bar examples foreground one canonical viewport control inside the shared shell.",
             widget: :scroll_bar,
             theme_id: :example_suite_default,
             app: :unified_example_scroll_bar,
             directory: "examples/scroll_bar",
             purpose: :widget_proof
           }
  end

  test "scroll bar example renders the shared shell and foregrounds one primary scroll bar" do
    assert {:ok, runtime_state} = ScrollBar.boot()
    assert {:ok, html} = ScrollBar.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :scroll_bar_example_screen_shell

    assert %UnifiedIUR.Element{kind: :scroll_bar} =
             Tree.find_by_id(runtime_state.assigns.iur, :scroll_bar_example_primary_scroll_bar)

    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "data-live-ui-widget=\"scroll-bar\""
    assert html =~ "data-live-ui-viewport-ref=\"scroll_bar_example_support_viewport\""
    assert html =~ "Scroll Bar Widget Example"
  end
end
