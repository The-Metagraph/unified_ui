defmodule UnifiedExamples.Button.Screen do
  @moduledoc """
  Shared-template button proof for the standalone example-app suite.
  """

  use UnifiedExamples.Shared.Template,
    id: :button_example_screen,
    title: "Button Widget Example",
    summary: "Focused action-oriented example using the shared suite shell",
    widget: :button,
    notes: "Buttons keep the shared shell while foregrounding one primary action."

  example_panel do
    button :button_example_primary_action do
      label("Save profile")
      theme_ref(:example_suite_default)
      style_refs([:example_primary_button])
      tone(:accent)
      variant(:quiet)
    end
  end
end
