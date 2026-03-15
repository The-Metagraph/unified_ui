defmodule UnifiedExamples.Checkbox.Screen do
  @moduledoc """
  Shared-template checkbox proof for the standalone example-app suite.
  """

  use UnifiedExamples.Shared.Template,
    id: :checkbox_example_screen,
    title: "Checkbox Widget Example",
    summary: "Focused input-oriented example using the shared suite shell",
    widget: :checkbox,
    notes: "Checkbox examples keep the shared form shell while foregrounding one boolean control."

  example_form_panel do
    field :checkbox_example_primary_field do
      field_name(:subscribed)
      label("Subscribed")

      checkbox :checkbox_example_primary_input do
        theme_ref(:example_suite_default)
        style_refs([:example_primary_input])
        tone(:surface)
        variant(:filled)
      end
    end
  end
end
