defmodule UnifiedExamples.Button.Screen do
  @moduledoc """
  Shared-template button proof for the standalone example-app suite.
  """

  use UnifiedExamples.Shared.Template,
    id: :button_example_screen,
    title: "Button Widget Example",
    summary: "Focused action-oriented example using the shared suite shell",
    widget: :button,
    notes: "Click the button to inspect the canonical signal compiled from the authored DSL."

  signals do
    namespace(:examples)

    interaction do
      id(:save_profile_click)
      family(:click)
      intent(:save_profile)
      source_context(element_id: :button_example_primary_action, scope: :screen)
      target_intent(binding: :button_signal_preview, action: :preview_signal)
      payload_mapping(action: :save_profile, example: :button, source: :dsl_button)
      summary("Preview the canonical click signal for the button example.")
    end
  end

  example_panel do
    button :button_example_primary_action do
      label("Save profile")
      interaction_refs([:save_profile_click])
      theme_ref(:example_suite_default)
      style_refs([:example_primary_button])
      tone(:accent)
      variant(:solid)
    end
  end
end
