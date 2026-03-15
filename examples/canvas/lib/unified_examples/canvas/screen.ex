defmodule UnifiedExamples.Canvas.Screen do
  @moduledoc """
  Shared-template canvas proof for the standalone example-app suite.
  """

  alias UnifiedExamples.Shared.Fixtures

  @canvas_operations Fixtures.canvas_operations()

  use UnifiedExamples.Shared.Template,
    id: :canvas_example_screen,
    title: "Canvas Widget Example",
    summary: "Focused display-system example using the shared suite shell",
    widget: :canvas,
    notes: "Canvas examples foreground one canonical drawing surface inside the shared shell."

  example_panel do
    canvas :canvas_example_primary_canvas do
      width(72)
      height(18)
      operations(@canvas_operations)
      theme_ref(:example_suite_default)
      tone(:surface)
      variant(:quiet)
    end
  end
end
