defmodule UnifiedExamples.SupervisionTreeViewerTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Tree
  alias UnifiedExamples.SupervisionTreeViewer

  test "supervision tree example exposes standalone example metadata" do
    assert SupervisionTreeViewer.metadata() == %{
             id: :supervision_tree_viewer_example_screen,
             root_id: :supervision_tree_viewer_example_screen_root,
             title: "Supervision Tree Viewer Example",
             summary: "Focused operational example using the shared suite shell",
             notes:
               "Supervision-tree examples foreground one canonical supervision hierarchy inside the shared shell.",
             widget: :supervision_tree_viewer,
             theme_id: :example_suite_default,
             app: :unified_example_supervision_tree_viewer,
             directory: "examples/supervision_tree_viewer",
             purpose: :widget_proof
           }
  end

  test "supervision tree example renders the shared shell and foregrounds one primary topology" do
    assert {:ok, runtime_state} = SupervisionTreeViewer.boot()
    assert {:ok, html} = SupervisionTreeViewer.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :supervision_tree_viewer_example_screen_shell

    assert %UnifiedIUR.Element{kind: :supervision_tree_viewer} =
             Tree.find_by_id(
               runtime_state.assigns.iur,
               :supervision_tree_viewer_example_primary_supervision_tree_viewer
             )

    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "data-live-ui-widget=\"supervision-tree-viewer\""
    assert html =~ "Supervision Tree Viewer Example"
    assert html =~ "Root Supervisor"
    assert html =~ "Queue Worker"
  end
end
