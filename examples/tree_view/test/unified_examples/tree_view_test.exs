defmodule UnifiedExamples.TreeViewTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Tree
  alias UnifiedExamples.TreeView

  test "tree view example exposes standalone example metadata" do
    assert TreeView.metadata() == %{
             id: :tree_view_example_screen,
             root_id: :tree_view_example_screen_root,
             title: "Tree View Widget Example",
             summary: "Focused data-oriented example using the shared suite shell",
             notes:
               "Tree view examples foreground one canonical hierarchy inside the shared shell.",
             widget: :tree_view,
             theme_id: :example_suite_default,
             app: :unified_example_tree_view,
             directory: "examples/tree_view",
             purpose: :widget_proof
           }
  end

  test "tree view example renders the shared shell and foregrounds one primary tree" do
    assert {:ok, runtime_state} = TreeView.boot()
    assert {:ok, html} = TreeView.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :tree_view_example_screen_shell

    assert %UnifiedIUR.Element{kind: :tree_view} =
             Tree.find_by_id(runtime_state.assigns.iur, :tree_view_example_primary_tree)

    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "data-live-ui-widget=\"tree-view\""
    assert html =~ "Tree View Widget Example"
    assert html =~ "Platform"
    assert html =~ "API"
    assert html =~ "Payments"
  end
end
