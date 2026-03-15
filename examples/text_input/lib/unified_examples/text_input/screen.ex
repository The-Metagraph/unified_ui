defmodule UnifiedExamples.TextInput.Screen do
  @moduledoc """
  Shared-template text_input proof for the standalone example-app suite.
  """

  use UnifiedExamples.Shared.Template,
    id: :text_input_example_screen,
    title: "Text Input Widget Example",
    summary: "Focused input-oriented example using the shared suite shell",
    widget: :text_input,
    notes: "Text input examples keep the shared shell while foregrounding one input control."

  example_panel do
    text_input :text_input_example_primary_input do
      placeholder("Type your note")
      theme_ref(:example_suite_default)
      style_refs([:example_primary_input])
      tone(:surface)
      variant(:filled)
    end
  end
end
