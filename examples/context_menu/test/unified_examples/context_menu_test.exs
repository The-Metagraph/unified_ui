defmodule UnifiedExamples.ContextMenuTest do
  use ExUnit.Case, async: false

  import Phoenix.ConnTest

  alias UnifiedExamples.ContextMenu
  alias UnifiedExamples.ContextMenu.Screen

  @endpoint UnifiedExamples.ContextMenu.Endpoint

  test "context menu example exposes self-contained example metadata" do
    metadata = ContextMenu.metadata()

    assert metadata.id == :context_menu_example_screen
    assert metadata.root_id == :context_menu_example_screen_root
    assert metadata.title == "Context Menu Widget Example"
    assert metadata.summary == "Focused overlay example using the local example shell"
    assert metadata.notes == "Context-menu examples foreground one canonical anchored action menu inside the local shell."
    assert metadata.widget == :context_menu
    assert metadata.theme_id == :example_suite_default
    assert metadata.app == :unified_example_context_menu
    assert metadata.directory == "examples/context_menu"
    assert metadata.purpose == :widget_proof
    assert metadata.template_mode == :local
    refute metadata.uses_examples_shared?
    assert metadata.runtime_modules == [
             UnifiedExamples.ContextMenu.Application,
             UnifiedExamples.ContextMenu.Endpoint,
             UnifiedExamples.ContextMenu.Router,
             UnifiedExamples.ContextMenu.Layouts,
             UnifiedExamples.ContextMenu.Live
           ]
    assert metadata.authored_modules == [
             UnifiedExamples.ContextMenu.Screen,
             UnifiedExamples.ContextMenu.Theme,
             UnifiedExamples.ContextMenu.StyleProfile,
             UnifiedExamples.ContextMenu.Helpers
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
    assert metadata.interaction_demo.family == :open
    assert Screen.local_style_profile() == Screen.shared_style_profile()
  end

  test "context menu example renders the local shell and foregrounds one primary context menu" do
    assert {:ok, runtime_state} = ContextMenu.boot()
    assert {:ok, html} = ContextMenu.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :context_menu_example_screen_shell
    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "data-live-ui-widget=\"context-menu\""
    assert html =~ "Context Menu Widget Example"
    assert html =~ "Retry sync"
    assert html =~ "Inspect the context menu layered story"
    assert html =~ "Meaningful Interaction Story"
  end

  test "context menu example boots through its Phoenix LiveView app entrypoint" do
    conn = get(build_conn(), "/")
    body = html_response(conn, 200)

    assert body =~ "data-example-directory=\"examples/context_menu\""
    assert body =~ "Context Menu Widget Example"
    assert body =~ "data-live-ui-widget=\"context-menu\""
    assert body =~ "jido_run inspired live_ui example"
    assert body =~ "<meta name=\"csrf-token\""
    assert body =~ "/vendor/phoenix/phoenix.js"
    assert body =~ "/vendor/live_view/phoenix_live_view.js"
  end
end
