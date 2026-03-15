defmodule UnifiedExamples.Field.Screen do
  @moduledoc """
  Shared-template field proof for the standalone example-app suite.
  """

  use UnifiedExamples.Shared.Template,
    id: :field_example_screen,
    title: "Field Example",
    summary: "Focused form-oriented example using the shared suite shell",
    widget: :field,
    notes:
      "Field examples keep the shared form shell while foregrounding one primary labeled field."

  example_form_panel do
    field :field_example_primary_field do
      field_name(:display_name)
      label("Display name")
      help("This field keeps one labeled control in focus.")

      text_input :field_example_primary_input do
        placeholder("Display name")
        theme_ref(:example_suite_default)
        style_refs([:example_primary_input])
        tone(:surface)
        variant(:filled)
      end
    end
  end
end
