defmodule UnifiedExamples.LogViewer.Screen do
  @moduledoc """
  Shared-template log-viewer proof for the standalone example-app suite.
  """

  alias UnifiedExamples.Shared.Fixtures

  use UnifiedExamples.Shared.Template,
    id: :log_viewer_example_screen,
    title: "Log Viewer Widget Example",
    summary: "Focused data-oriented example using the shared suite shell",
    widget: :log_viewer,
    notes: "Log viewer examples foreground one canonical event stream inside the shared shell."

  example_panel do
    log_viewer :log_viewer_example_primary_logs do
      log_entries(Fixtures.event_log_entries())
      show_timestamps?(true)
      wrap?(true)
      theme_ref(:example_suite_default)
      tone(:surface)
      variant(:quiet)
    end
  end
end
