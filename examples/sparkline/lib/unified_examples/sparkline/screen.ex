defmodule UnifiedExamples.Sparkline.Screen do
  @moduledoc """
  Shared-template sparkline proof for the standalone example-app suite.
  """

  alias UnifiedExamples.Shared.Fixtures

  use UnifiedExamples.Shared.Template,
    id: :sparkline_example_screen,
    title: "Sparkline Widget Example",
    summary: "Focused feedback-oriented example using the shared suite shell",
    widget: :sparkline,
    notes: "Sparkline examples foreground one canonical trend line inside the shared shell."

  example_panel do
    sparkline :sparkline_example_primary_chart do
      points(Fixtures.sparkline_points())
      theme_ref(:example_suite_default)
      tone(:surface)
      variant(:quiet)
    end
  end
end
