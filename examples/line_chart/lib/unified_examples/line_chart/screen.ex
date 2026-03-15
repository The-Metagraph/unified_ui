defmodule UnifiedExamples.LineChart.Screen do
  @moduledoc """
  Shared-template line-chart proof for the standalone example-app suite.
  """

  alias UnifiedExamples.Shared.Fixtures

  use UnifiedExamples.Shared.Template,
    id: :line_chart_example_screen,
    title: "Line Chart Widget Example",
    summary: "Focused feedback-oriented example using the shared suite shell",
    widget: :line_chart,
    notes:
      "Line chart examples foreground one canonical time-series chart inside the shared shell."

  example_panel do
    line_chart :line_chart_example_primary_chart do
      series(Fixtures.line_chart_series())
      x_label("Time")
      y_label("Errors")
      theme_ref(:example_suite_default)
      tone(:surface)
      variant(:quiet)
    end
  end
end
