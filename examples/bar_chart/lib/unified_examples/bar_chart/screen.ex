defmodule UnifiedExamples.BarChart.Screen do
  @moduledoc """
  Shared-template bar-chart proof for the standalone example-app suite.
  """

  alias UnifiedExamples.Shared.Fixtures

  use UnifiedExamples.Shared.Template,
    id: :bar_chart_example_screen,
    title: "Bar Chart Widget Example",
    summary: "Focused feedback-oriented example using the shared suite shell",
    widget: :bar_chart,
    notes:
      "Bar chart examples foreground one canonical categorical chart inside the shared shell."

  example_panel do
    bar_chart :bar_chart_example_primary_chart do
      series(Fixtures.bar_chart_series())
      x_label("Service")
      y_label("Requests")
      theme_ref(:example_suite_default)
      tone(:surface)
      variant(:quiet)
    end
  end
end
