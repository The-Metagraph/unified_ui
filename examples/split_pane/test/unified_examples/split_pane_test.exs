defmodule UnifiedExamples.SplitPaneTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Tree
  alias UnifiedExamples.SplitPane

  test "split pane example exposes standalone example metadata" do
    assert SplitPane.metadata() == %{
             id: :split_pane_example_screen,
             root_id: :split_pane_example_screen_root,
             title: "Split Pane Widget Example",
             summary: "Focused display-system example using the shared suite shell",
             notes:
               "Split-pane examples foreground one canonical dual-region layout inside the shared shell.",
             widget: :split_pane,
             theme_id: :example_suite_default,
             app: :unified_example_split_pane,
             directory: "examples/split_pane",
             purpose: :widget_proof
           }
  end

  test "split pane example renders the shared shell and foregrounds one primary split pane" do
    assert {:ok, runtime_state} = SplitPane.boot()
    assert {:ok, html} = SplitPane.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :split_pane_example_screen_shell

    assert %UnifiedIUR.Element{kind: :split_pane} =
             Tree.find_by_id(runtime_state.assigns.iur, :split_pane_example_primary_split_pane)

    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "data-live-ui-widget=\"split-pane\""
    assert html =~ "data-live-ui-split-pane-slot=\"primary\""
    assert html =~ "data-live-ui-split-pane-slot=\"secondary\""
    assert html =~ "Split Pane Widget Example"
  end
end
