defmodule UnifiedExamples.Icon.Screen do
  @moduledoc """
  Shared-template icon proof for the standalone example-app suite.
  """

  use UnifiedExamples.Shared.Template,
    id: :icon_example_screen,
    title: "Icon Widget Example",
    summary: "Focused content-oriented example using the shared suite shell",
    widget: :icon,
    notes: "Icon examples keep the shared shell while foregrounding one primary icon widget.",
    interaction_demo: %{
      trigger_label: "Highlight the icon story",
      idle_prompt:
        "Use the shared trigger to spotlight the icon example and review how the glyph participates in the shared story.",
      outcome:
        "The icon example should explain the authored glyph choice and make the visual emphasis obvious to reviewers."
    }

  example_panel do
    icon :icon_example_primary_icon do
      name(:sparkles)
      set(:system)
      fallback_text("sparkles")
      theme_ref(:example_suite_default)
      tone(:accent)
      variant(:headline)
    end
  end
end
