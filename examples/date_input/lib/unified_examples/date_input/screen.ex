defmodule UnifiedExamples.DateInput.Screen do
  @moduledoc """
  Shared-template date_input proof for the standalone example-app suite.
  """

  use UnifiedExamples.Shared.Template,
    id: :date_input_example_screen,
    title: "Date Input Widget Example",
    summary: "Focused input-oriented example using the shared suite shell",
    widget: :date_input,
    notes: "Date input examples keep the shared form shell while foregrounding one date control."

  example_form_panel do
    field :date_input_example_primary_field do
      field_name(:publish_on)
      label("Publish on")

      date_input :date_input_example_primary_input do
        min("2026-01-01")
        max("2026-12-31")
        theme_ref(:example_suite_default)
        style_refs([:example_primary_input])
        tone(:surface)
        variant(:filled)
      end
    end
  end
end
