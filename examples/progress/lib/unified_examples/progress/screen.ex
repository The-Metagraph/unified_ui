defmodule UnifiedExamples.Progress.Screen do
  @moduledoc """
  Shared-template progress proof for the standalone example-app suite.
  """

  alias UnifiedExamples.Shared.Fixtures

  @progress_snapshot Fixtures.progress_snapshot()
  @progress_current @progress_snapshot.current
  @progress_total @progress_snapshot.total
  @progress_label @progress_snapshot.label
  @progress_severity @progress_snapshot.severity
  @progress_status @progress_snapshot.status

  use UnifiedExamples.Shared.Template,
    id: :progress_example_screen,
    title: "Progress Widget Example",
    summary: "Focused feedback-oriented example using the shared suite shell",
    widget: :progress,
    notes:
      "Progress examples foreground one canonical progress indicator inside the shared shell."

  example_panel do
    progress :progress_example_primary_progress do
      current(@progress_current)
      maximum(@progress_total)
      label(@progress_label)
      severity(@progress_severity)
      status(@progress_status)
      theme_ref(:example_suite_default)
      tone(:surface)
      variant(:quiet)
    end
  end
end
