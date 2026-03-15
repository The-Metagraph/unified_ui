defmodule UnifiedExamples.ProcessMonitor.Screen do
  @moduledoc """
  Shared-template process-monitor proof for the standalone example-app suite.
  """

  alias UnifiedExamples.Shared.Fixtures

  @process_snapshot Fixtures.process_monitor_snapshot()

  use UnifiedExamples.Shared.Template,
    id: :process_monitor_example_screen,
    title: "Process Monitor Widget Example",
    summary: "Focused operational example using the shared suite shell",
    widget: :process_monitor,
    notes:
      "Process-monitor examples foreground one canonical process inventory inside the shared shell."

  example_panel do
    process_monitor :process_monitor_example_primary_process_monitor do
      processes(@process_snapshot.processes)
      sort_by(@process_snapshot.sort_by)
      severity(@process_snapshot.severity)
      theme_ref(:example_suite_default)
      tone(:surface)
      variant(:quiet)
    end
  end
end
