defmodule UnifiedExamples.Status.Screen do
  @moduledoc """
  Shared-template status proof for the standalone example-app suite.
  """

  alias UnifiedExamples.Shared.Fixtures

  @status_snapshot Fixtures.status_snapshot()
  @status_text @status_snapshot.text
  @status_severity @status_snapshot.severity
  @status_kind @status_snapshot.status

  use UnifiedExamples.Shared.Template,
    id: :status_example_screen,
    title: "Status Widget Example",
    summary: "Focused feedback-oriented example using the shared suite shell",
    widget: :status,
    notes: "Status examples foreground one canonical status line inside the shared shell."

  example_panel do
    status :status_example_primary_status do
      value(@status_text)
      severity(@status_severity)
      status(@status_kind)
      theme_ref(:example_suite_default)
      tone(:surface)
      variant(:quiet)
    end
  end
end
