defmodule UnifiedExamples.Row.Screen do
  @moduledoc """
  Shared-template row proof for the standalone example-app suite.
  """

  use UnifiedExamples.Shared.Template,
    id: :row_example_screen,
    title: "Row Widget Example",
    summary: "Focused layout-oriented example using the shared suite shell",
    widget: :row,
    notes: "Row examples keep the shared shell while foregrounding one horizontal layout flow."

  example_panel do
    row :row_example_primary_row do
      gap(:sm)
      align(:center)
      justify(:between)

      text :row_example_primary_label do
        value("Release train")
        theme_ref(:example_suite_default)
        tone(:accent)
        variant(:headline)
      end

      text :row_example_primary_detail do
        value("Queue active")
        theme_ref(:example_suite_default)
        tone(:surface)
        variant(:body)
      end

      button :row_example_primary_action do
        label("Review")
        theme_ref(:example_suite_default)
        style_refs([:example_primary_button])
        tone(:accent)
        variant(:quiet)
      end
    end
  end
end
