defmodule UnifiedExamples.Column.Screen do
  @moduledoc """
  Shared-template column proof for the standalone example-app suite.
  """

  use UnifiedExamples.Shared.Template,
    id: :column_example_screen,
    title: "Column Widget Example",
    summary: "Focused layout-oriented example using the shared suite shell",
    widget: :column,
    notes: "Column examples keep the shared shell while foregrounding one vertical layout flow."

  example_panel do
    column :column_example_primary_column do
      gap(:sm)
      align(:stretch)

      text :column_example_heading do
        value("On-call checklist")
        theme_ref(:example_suite_default)
        tone(:accent)
        variant(:headline)
      end

      text :column_example_body do
        value("Columns stack related actions in a readable vertical flow.")
        theme_ref(:example_suite_default)
        tone(:surface)
        variant(:body)
      end

      button :column_example_action do
        label("Acknowledge")
        theme_ref(:example_suite_default)
        style_refs([:example_primary_button])
        tone(:accent)
        variant(:quiet)
      end
    end
  end
end
