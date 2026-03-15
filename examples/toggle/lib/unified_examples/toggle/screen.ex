defmodule UnifiedExamples.Toggle.Screen do
  @moduledoc """
  Shared-template toggle proof for the standalone example-app suite.
  """

  use UnifiedExamples.Shared.Template,
    id: :toggle_example_screen,
    title: "Toggle Widget Example",
    summary: "Focused input-oriented example using the shared suite shell",
    widget: :toggle,
    notes:
      "Toggle examples keep the shared form shell while foregrounding one boolean switch control."

  example_form_panel do
    field :toggle_example_primary_field do
      field_name(:enabled)
      label("Enabled")

      toggle :toggle_example_primary_input do
        theme_ref(:example_suite_default)
        style_refs([:example_primary_input])
        tone(:surface)
        variant(:filled)
      end
    end
  end
end
