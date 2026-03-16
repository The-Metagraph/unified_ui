defmodule UnifiedExamples.TextInput.Screen do
  @moduledoc """
  Shared-template text_input proof for the standalone example-app suite.
  """

  use UnifiedExamples.Shared.Template,
    id: :text_input_example_screen,
    title: "Text Input Widget Example",
    summary: "Focused input-oriented example using the shared suite shell",
    widget: :text_input,
    notes: "Text input examples keep the shared shell while foregrounding one input control.",
    interaction_demo: %{
      mode: :custom,
      family: :change,
      source: :primary_widget,
      source_label: "Primary text input",
      trigger_label: nil,
      idle_prompt:
        "Type into the draft field to capture the authored change signal and latest value.",
      outcome:
        "The text input example should mirror the live draft value and explain the emitted change signal clearly."
    }

  signals do
    namespace(:examples)

    interaction do
      id(:draft_note_change)
      family(:change)
      intent(:draft_note)
      source_context(element_id: :text_input_example_primary_input, scope: :screen)
      target_intent(action: :review_example)
      payload_mapping(example: :text_input, source: :dsl_text_input)
      summary("Type into the draft field to capture the authored change signal.")
    end
  end

  example_panel do
    text_input :text_input_example_primary_input do
      placeholder("Type your note")
      value_path([:draft_note])
      default_value("review-ready note")
      interaction_refs([:draft_note_change])
      theme_ref(:example_suite_default)
      style_refs([:example_primary_input])
      tone(:surface)
      variant(:filled)
    end
  end
end
