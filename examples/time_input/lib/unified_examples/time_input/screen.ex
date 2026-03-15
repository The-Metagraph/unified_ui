defmodule UnifiedExamples.TimeInput.Screen do
  @moduledoc """
  Shared-template time_input proof for the standalone example-app suite.
  """

  use UnifiedExamples.Shared.Template,
    id: :time_input_example_screen,
    title: "Time Input Widget Example",
    summary: "Focused input-oriented example using the shared suite shell",
    widget: :time_input,
    notes: "Time input examples keep the shared form shell while foregrounding one time control."

  example_form_panel do
    field :time_input_example_primary_field do
      field_name(:publish_at)
      label("Publish at")

      time_input :time_input_example_primary_input do
        min("08:00")
        max("18:00")
        step(900)
        theme_ref(:example_suite_default)
        style_refs([:example_primary_input])
        tone(:surface)
        variant(:filled)
      end
    end
  end
end
