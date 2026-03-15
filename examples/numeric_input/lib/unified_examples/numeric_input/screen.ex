defmodule UnifiedExamples.NumericInput.Screen do
  @moduledoc """
  Shared-template numeric_input proof for the standalone example-app suite.
  """

  use UnifiedExamples.Shared.Template,
    id: :numeric_input_example_screen,
    title: "Numeric Input Widget Example",
    summary: "Focused input-oriented example using the shared suite shell",
    widget: :numeric_input,
    notes:
      "Numeric input examples keep the shared form shell while foregrounding one numeric control."

  example_form_panel do
    field :numeric_input_example_primary_field do
      field_name(:quantity)
      label("Quantity")

      numeric_input :numeric_input_example_primary_input do
        placeholder("0")
        min(0)
        max(100)
        step(5)
        theme_ref(:example_suite_default)
        style_refs([:example_primary_input])
        tone(:surface)
        variant(:filled)
      end
    end
  end
end
