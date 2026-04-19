defmodule UnifiedExamples.ListTest do
  use ExUnit.Case, async: false

  import Phoenix.ConnTest

  alias UnifiedExamples.List
  alias UnifiedExamples.List.Screen

  @endpoint UnifiedExamples.List.Endpoint

  test "list example exposes self-contained example metadata" do
    metadata = List.metadata()

    assert metadata.id == :list_example_screen
    assert metadata.root_id == :list_example_screen_root
    assert metadata.title == "List Widget Example"
    assert metadata.summary == "Focused data-oriented example using the local example shell"
    assert metadata.notes == "List examples foreground one canonical data list inside the local shell."
    assert metadata.widget == :list
    assert metadata.theme_id == :example_suite_default
    assert metadata.app == :unified_example_list
    assert metadata.directory == "examples/list"
    assert metadata.purpose == :widget_proof
    assert metadata.template_mode == :local
    refute metadata.uses_examples_shared?
    assert metadata.runtime_modules == [
             UnifiedExamples.List.Application,
             UnifiedExamples.List.Endpoint,
             UnifiedExamples.List.Router,
             UnifiedExamples.List.Layouts,
             UnifiedExamples.List.Live
           ]
    assert metadata.authored_modules == [
             UnifiedExamples.List.Screen,
             UnifiedExamples.List.Theme,
             UnifiedExamples.List.StyleProfile,
             UnifiedExamples.List.Helpers
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

  test "list example renders the local shell and foregrounds one primary list" do
    assert {:ok, runtime_state} = List.boot()
    assert {:ok, html} = List.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :list_example_screen_shell
    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "data-live-ui-widget=\"list\""
    assert html =~ "List Widget Example"
    assert html =~ "Database failover"
    assert html =~ "Queue backlog"
    assert html =~ "Docs refresh"
    assert html =~ "Inspect the list data story"
    assert html =~ "Meaningful Interaction Story"
  end

  test "list example boots through its Phoenix LiveView app entrypoint" do
    conn = get(build_conn(), "/")
    body = html_response(conn, 200)

    assert body =~ "data-example-directory=\"examples/list\""
    assert body =~ "List Widget Example"
    assert body =~ "data-live-ui-widget=\"list\""
    assert body =~ "jido_run inspired live_ui example"
    assert body =~ "<meta name=\"csrf-token\""
    assert body =~ "/vendor/phoenix/phoenix.js"
    assert body =~ "/vendor/live_view/phoenix_live_view.js"
  end
end
