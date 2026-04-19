defmodule UnifiedExamples.TreeViewTest do
  use ExUnit.Case, async: false

  import Phoenix.ConnTest

  alias UnifiedExamples.TreeView
  alias UnifiedExamples.TreeView.Screen

  @endpoint UnifiedExamples.TreeView.Endpoint

  test "tree view example exposes self-contained example metadata" do
    metadata = TreeView.metadata()

    assert metadata.id == :tree_view_example_screen
    assert metadata.root_id == :tree_view_example_screen_root
    assert metadata.title == "Tree View Widget Example"
    assert metadata.summary == "Focused data-oriented example using the local example shell"
    assert metadata.notes == "Tree view examples foreground one canonical hierarchy inside the local shell."
    assert metadata.widget == :tree_view
    assert metadata.theme_id == :example_suite_default
    assert metadata.app == :unified_example_tree_view
    assert metadata.directory == "examples/tree_view"
    assert metadata.purpose == :widget_proof
    assert metadata.template_mode == :local
    refute metadata.uses_examples_shared?
    assert metadata.runtime_modules == [
             UnifiedExamples.TreeView.Application,
             UnifiedExamples.TreeView.Endpoint,
             UnifiedExamples.TreeView.Router,
             UnifiedExamples.TreeView.Layouts,
             UnifiedExamples.TreeView.Live
           ]
    assert metadata.authored_modules == [
             UnifiedExamples.TreeView.Screen,
             UnifiedExamples.TreeView.Theme,
             UnifiedExamples.TreeView.StyleProfile,
             UnifiedExamples.TreeView.Helpers
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
    assert metadata.interaction_demo.family == :selection
    assert Screen.local_style_profile() == Screen.shared_style_profile()
  end

  test "tree view example renders the local shell and foregrounds one primary tree" do
    assert {:ok, runtime_state} = TreeView.boot()
    assert {:ok, html} = TreeView.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :tree_view_example_screen_shell
    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "data-live-ui-widget=\"tree-view\""
    assert html =~ "Tree View Widget Example"
    assert html =~ "Platform"
    assert html =~ "API"
    assert html =~ "Payments"
    assert html =~ "Inspect the tree view data story"
    assert html =~ "Meaningful Interaction Story"
  end

  test "tree view example boots through its Phoenix LiveView app entrypoint" do
    conn = get(build_conn(), "/")
    body = html_response(conn, 200)

    assert body =~ "data-example-directory=\"examples/tree_view\""
    assert body =~ "Tree View Widget Example"
    assert body =~ "data-live-ui-widget=\"tree-view\""
    assert body =~ "jido_run inspired live_ui example"
    assert body =~ "<meta name=\"csrf-token\""
    assert body =~ "/vendor/phoenix/phoenix.js"
    assert body =~ "/vendor/live_view/phoenix_live_view.js"
  end
end
