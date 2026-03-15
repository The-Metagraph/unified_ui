defmodule UnifiedExamples.Gauge.Screen do
  @moduledoc """
  Shared-template gauge proof for the standalone example-app suite.
  """

  alias UnifiedExamples.Shared.Fixtures

  @gauge_snapshot Fixtures.gauge_snapshot()
  @gauge_current @gauge_snapshot.current
  @gauge_minimum @gauge_snapshot.minimum
  @gauge_maximum @gauge_snapshot.maximum
  @gauge_label @gauge_snapshot.label
  @gauge_severity @gauge_snapshot.severity
  @gauge_status @gauge_snapshot.status

  use UnifiedExamples.Shared.Template,
    id: :gauge_example_screen,
    title: "Gauge Widget Example",
    summary: "Focused feedback-oriented example using the shared suite shell",
    widget: :gauge,
    notes: "Gauge examples foreground one canonical measurement widget inside the shared shell."

  example_panel do
    gauge :gauge_example_primary_gauge do
      current(@gauge_current)
      minimum(@gauge_minimum)
      maximum(@gauge_maximum)
      label(@gauge_label)
      severity(@gauge_severity)
      status(@gauge_status)
      theme_ref(:example_suite_default)
      tone(:surface)
      variant(:quiet)
    end
  end
end
