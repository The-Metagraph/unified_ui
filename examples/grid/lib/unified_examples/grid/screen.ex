defmodule UnifiedExamples.Grid.Screen do
  @moduledoc """
  Shared-template grid proof for the standalone example-app suite.
  """

  use UnifiedExamples.Shared.Template,
    id: :grid_example_screen,
    title: "Grid Widget Example",
    summary: "Focused layout-oriented example using the shared suite shell",
    widget: :grid,
    notes:
      "Grid examples keep the shared shell while foregrounding one multi-cell layout surface."

  example_panel do
    grid :grid_example_primary_grid do
      columns(2)
      rows(2)
      gap(:sm)

      text :grid_example_cell_a do
        value("CPU")
        theme_ref(:example_suite_default)
        tone(:accent)
        variant(:headline)
      end

      text :grid_example_cell_b do
        value("74%")
        theme_ref(:example_suite_default)
        tone(:surface)
        variant(:body)
      end

      text :grid_example_cell_c do
        value("Latency")
        theme_ref(:example_suite_default)
        tone(:accent)
        variant(:headline)
      end

      text :grid_example_cell_d do
        value("132ms")
        theme_ref(:example_suite_default)
        tone(:surface)
        variant(:body)
      end
    end
  end
end
