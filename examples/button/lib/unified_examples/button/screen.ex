defmodule UnifiedExamples.Button.Screen do
  @moduledoc """
  Shared-template button proof for the standalone example-app suite.
  """

  use UnifiedExamples.Shared.Template,
    id: :button_example_screen,
    title: "Button Widget Example",
    summary: "Focused action-oriented example using the shared suite shell",
    widget: :button,
    notes: "Buttons keep the shared shell while foregrounding one primary action.",
    interaction_demo: %{
      mode: :custom,
      family: :click,
      source: :primary_widget,
      source_label: "Primary action button",
      trigger_label: nil,
      idle_prompt: "Click Save profile to emit the authored canonical button signal.",
      outcome:
        "The button example should make the primary action feel live and explain the emitted click signal in reviewer-friendly language."
    }

  signals do
    namespace(:examples)

    interaction do
      id(:save_profile_click)
      family(:click)
      intent(:save_profile)
      source_context(element_id: :button_example_primary_action, scope: :screen)
      target_intent(action: :review_example)
      payload_mapping(action: :save_profile, example: :button, source: :dsl_button)
      summary("Click Save profile to emit the authored canonical button signal.")
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
