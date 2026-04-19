defmodule UnifiedExamples.ProcessMonitorTest do
  use ExUnit.Case, async: false

  import Phoenix.ConnTest

  alias UnifiedExamples.ProcessMonitor
  alias UnifiedExamples.ProcessMonitor.Screen

  @endpoint UnifiedExamples.ProcessMonitor.Endpoint

  test "process-monitor example exposes self-contained example metadata" do
    metadata = ProcessMonitor.metadata()

    assert metadata.id == :process_monitor_example_screen
    assert metadata.root_id == :process_monitor_example_screen_root
    assert metadata.title == "Process Monitor Widget Example"
    assert metadata.summary == "Focused operational example using the local example shell"
    assert metadata.notes == "Process-monitor examples foreground one canonical process inventory inside the local shell."
    assert metadata.widget == :process_monitor
    assert metadata.theme_id == :example_suite_default
    assert metadata.app == :unified_example_process_monitor
    assert metadata.directory == "examples/process_monitor"
    assert metadata.purpose == :widget_proof
    assert metadata.template_mode == :local
    refute metadata.uses_examples_shared?
    assert metadata.runtime_modules == [
             UnifiedExamples.ProcessMonitor.Application,
             UnifiedExamples.ProcessMonitor.Endpoint,
             UnifiedExamples.ProcessMonitor.Router,
             UnifiedExamples.ProcessMonitor.Layouts,
             UnifiedExamples.ProcessMonitor.Live
           ]
    assert metadata.authored_modules == [
             UnifiedExamples.ProcessMonitor.Screen,
             UnifiedExamples.ProcessMonitor.Theme,
             UnifiedExamples.ProcessMonitor.StyleProfile,
             UnifiedExamples.ProcessMonitor.Helpers
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

  test "process-monitor example renders the local shell and foregrounds one primary process monitor" do
    assert {:ok, runtime_state} = ProcessMonitor.boot()
    assert {:ok, html} = ProcessMonitor.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :process_monitor_example_screen_shell
    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "data-live-ui-widget=\"process-monitor\""
    assert html =~ "Process Monitor Widget Example"
    assert html =~ "queue-consumer"
    assert html =~ "Inspect the process monitor monitoring story"
    assert html =~ "Meaningful Interaction Story"
  end

  test "process-monitor example boots through its Phoenix LiveView app entrypoint" do
    conn = get(build_conn(), "/")
    body = html_response(conn, 200)

    assert body =~ "data-example-directory=\"examples/process_monitor\""
    assert body =~ "Process Monitor Widget Example"
    assert body =~ "data-live-ui-widget=\"process-monitor\""
    assert body =~ "jido_run inspired live_ui example"
    assert body =~ "<meta name=\"csrf-token\""
    assert body =~ "/vendor/phoenix/phoenix.js"
    assert body =~ "/vendor/live_view/phoenix_live_view.js"
  end
end
