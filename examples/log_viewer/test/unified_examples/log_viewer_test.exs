defmodule UnifiedExamples.LogViewerTest do
  use ExUnit.Case, async: false

  import Phoenix.ConnTest

  alias UnifiedExamples.LogViewer
  alias UnifiedExamples.LogViewer.Screen

  @endpoint UnifiedExamples.LogViewer.Endpoint

  test "log viewer example exposes self-contained example metadata" do
    metadata = LogViewer.metadata()

    assert metadata.id == :log_viewer_example_screen
    assert metadata.root_id == :log_viewer_example_screen_root
    assert metadata.title == "Log Viewer Widget Example"
    assert metadata.summary == "Focused data-oriented example using the local example shell"
    assert metadata.notes == "Log viewer examples foreground one canonical event stream inside the local shell."
    assert metadata.widget == :log_viewer
    assert metadata.theme_id == :example_suite_default
    assert metadata.app == :unified_example_log_viewer
    assert metadata.directory == "examples/log_viewer"
    assert metadata.purpose == :widget_proof
    assert metadata.template_mode == :local
    refute metadata.uses_examples_shared?
    assert metadata.runtime_modules == [
             UnifiedExamples.LogViewer.Application,
             UnifiedExamples.LogViewer.Endpoint,
             UnifiedExamples.LogViewer.Router,
             UnifiedExamples.LogViewer.Layouts,
             UnifiedExamples.LogViewer.Live
           ]
    assert metadata.authored_modules == [
             UnifiedExamples.LogViewer.Screen,
             UnifiedExamples.LogViewer.Theme,
             UnifiedExamples.LogViewer.StyleProfile,
             UnifiedExamples.LogViewer.Helpers
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
    assert metadata.interaction_demo.family == :focus
    assert Screen.local_style_profile() == Screen.shared_style_profile()
  end

  test "log viewer example renders the local shell and foregrounds one primary log stream" do
    assert {:ok, runtime_state} = LogViewer.boot()
    assert {:ok, html} = LogViewer.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :log_viewer_example_screen_shell
    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "data-live-ui-widget=\"log-viewer\""
    assert html =~ "Log Viewer Widget Example"
    assert html =~ "Deploy started"
    assert html =~ "Queue lag detected"
    assert html =~ "2026-03-15T14:00:00Z"
    assert html =~ "Inspect the log viewer data story"
    assert html =~ "Meaningful Interaction Story"
  end

  test "log viewer example boots through its Phoenix LiveView app entrypoint" do
    conn = get(build_conn(), "/")
    body = html_response(conn, 200)

    assert body =~ "data-example-directory=\"examples/log_viewer\""
    assert body =~ "Log Viewer Widget Example"
    assert body =~ "data-live-ui-widget=\"log-viewer\""
    assert body =~ "jido_run inspired live_ui example"
    assert body =~ "<meta name=\"csrf-token\""
    assert body =~ "/vendor/phoenix/phoenix.js"
    assert body =~ "/vendor/live_view/phoenix_live_view.js"
  end
end
