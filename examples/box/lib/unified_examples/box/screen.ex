defmodule UnifiedExamples.Box.Screen do
  @moduledoc """
  Shared-template box proof for the standalone example-app suite.
  """

  use UnifiedExamples.Shared.Template,
    id: :box_example_screen,
    title: "Box Widget Example",
    summary: "Focused layout-oriented example using the shared suite shell",
    widget: :box,
    notes:
      "Box examples keep the shared shell while foregrounding the shared panel box as the primary layout container."

  example_panel do
    text :box_example_heading do
      value("Shared box container")
      theme_ref(:example_suite_default)
      tone(:accent)
      variant(:headline)
    end

    spacer :box_example_gap do
      size(:sm)
    end

    text :box_example_body do
      value("Box widgets gather related content inside a shared visual boundary.")
      theme_ref(:example_suite_default)
      tone(:surface)
      variant(:body)
    end
  end
end
