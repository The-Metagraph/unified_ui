defmodule UnifiedExamples.Icon.Screen do
  @moduledoc """
  Shared-template icon proof for the standalone example-app suite.
  """

  use UnifiedExamples.Shared.Template,
    id: :icon_example_screen,
    title: "Icon Widget Example",
    summary: "Focused content-oriented example using the shared suite shell",
    widget: :icon,
    notes: "Icon examples keep the shared shell while foregrounding one primary icon widget."

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
