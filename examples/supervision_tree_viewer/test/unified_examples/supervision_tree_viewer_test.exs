defmodule UnifiedExamples.SupervisionTreeViewerTest do
  use ExUnit.Case, async: false

  import Phoenix.ConnTest

  alias UnifiedExamples.SupervisionTreeViewer
  alias UnifiedExamples.SupervisionTreeViewer.Screen

  @endpoint UnifiedExamples.SupervisionTreeViewer.Endpoint

  test "supervision-tree-viewer example exposes self-contained example metadata" do
    metadata = SupervisionTreeViewer.metadata()

    assert metadata.id == :supervision_tree_viewer_example_screen
    assert metadata.root_id == :supervision_tree_viewer_example_screen_root
    assert metadata.title == "Supervision Tree Viewer Example"
    assert metadata.summary == "Focused operational example using the local example shell"
    assert metadata.notes == "Supervision-tree examples foreground one canonical supervision hierarchy inside the local shell."
    assert metadata.widget == :supervision_tree_viewer
    assert metadata.theme_id == :example_suite_default
    assert metadata.app == :unified_example_supervision_tree_viewer
    assert metadata.directory == "examples/supervision_tree_viewer"
    assert metadata.purpose == :widget_proof
    assert metadata.template_mode == :local
    refute metadata.uses_examples_shared?
    assert metadata.runtime_modules == [
             UnifiedExamples.SupervisionTreeViewer.Application,
             UnifiedExamples.SupervisionTreeViewer.Endpoint,
             UnifiedExamples.SupervisionTreeViewer.Router,
             UnifiedExamples.SupervisionTreeViewer.Layouts,
             UnifiedExamples.SupervisionTreeViewer.Live
           ]
    assert metadata.authored_modules == [
             UnifiedExamples.SupervisionTreeViewer.Screen,
             UnifiedExamples.SupervisionTreeViewer.Theme,
             UnifiedExamples.SupervisionTreeViewer.StyleProfile,
             UnifiedExamples.SupervisionTreeViewer.Helpers
           ]
    assert metadata.style_contract.component_style_ids == [
             :example_shell,
             :example_panel,
             :example_form_shell,
             :example_title,
             :example_summary,
             :example_notes,
             :example_primary_button,
             :example_primary_input
           ]
    assert metadata.interaction_demo.mode == :shared_trigger
    assert metadata.interaction_demo.family == :command
    assert Screen.local_style_profile() == Screen.shared_style_profile()
  end

  test "supervision-tree-viewer example renders the local shell and foregrounds one primary supervision tree viewer" do
    assert {:ok, runtime_state} = SupervisionTreeViewer.boot()
    assert {:ok, html} = SupervisionTreeViewer.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :supervision_tree_viewer_example_screen_shell
    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "data-live-ui-widget=\"supervision-tree-viewer\""
    assert html =~ "Supervision Tree Viewer Example"
    assert html =~ "Root Supervisor"
    assert html =~ "Inspect the supervision tree viewer monitoring story"
    assert html =~ "Meaningful Interaction Story"
  end

  test "supervision-tree-viewer example boots through its Phoenix LiveView app entrypoint" do
    conn = get(build_conn(), "/")
    body = html_response(conn, 200)

    assert body =~ "data-example-directory=\"examples/supervision_tree_viewer\""
    assert body =~ "Supervision Tree Viewer Example"
    assert body =~ "data-live-ui-widget=\"supervision-tree-viewer\""
    assert body =~ "jido_run inspired live_ui example"
    assert body =~ "<meta name=\"csrf-token\""
    assert body =~ "/vendor/phoenix/phoenix.js"
    assert body =~ "/vendor/live_view/phoenix_live_view.js"
  end
end
