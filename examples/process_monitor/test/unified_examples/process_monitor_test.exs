defmodule UnifiedExamples.ProcessMonitorTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Tree
  alias UnifiedExamples.ProcessMonitor

  test "process monitor example exposes standalone example metadata" do
    assert ProcessMonitor.metadata() == %{
             id: :process_monitor_example_screen,
             root_id: :process_monitor_example_screen_root,
             title: "Process Monitor Widget Example",
             summary: "Focused operational example using the shared suite shell",
             notes:
               "Process-monitor examples foreground one canonical process inventory inside the shared shell.",
             widget: :process_monitor,
             theme_id: :example_suite_default,
             app: :unified_example_process_monitor,
             directory: "examples/process_monitor",
             purpose: :widget_proof
           }
  end

  test "process monitor example renders the shared shell and foregrounds one primary monitor" do
    assert {:ok, runtime_state} = ProcessMonitor.boot()
    assert {:ok, html} = ProcessMonitor.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :process_monitor_example_screen_shell

    assert %UnifiedIUR.Element{kind: :process_monitor} =
             Tree.find_by_id(
               runtime_state.assigns.iur,
               :process_monitor_example_primary_process_monitor
             )

    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "data-live-ui-widget=\"process-monitor\""
    assert html =~ "Process Monitor Widget Example"
    assert html =~ "data-process-id=\"proc-api\""
    assert html =~ "#PID&lt;0.210.0&gt;"
  end
end
