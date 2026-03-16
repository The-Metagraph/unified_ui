defmodule UnifiedExamples.Image.Screen do
  @moduledoc """
  Shared-template image proof for the standalone example-app suite.
  """

  use UnifiedExamples.Shared.Template,
    id: :image_example_screen,
    title: "Image Widget Example",
    summary: "Focused content-oriented example using the shared suite shell",
    widget: :image,
    notes: "Image examples keep the shared shell while foregrounding one primary image widget.",
    interaction_demo: %{
      trigger_label: "Highlight the image story",
      idle_prompt:
        "Use the shared trigger to spotlight the image example and review how the authored media is framed.",
      outcome:
        "The image example should make the media block feel intentional and show how passive visuals still participate in a meaningful interaction story."
    }

  example_panel do
    image :image_example_primary_image do
      source("https://example.invalid/assets/unified-example.png")
      alt_text("Illustrative unified example image")
      fit(:contain)
      theme_ref(:example_suite_default)
      tone(:accent)
      variant(:panel)
    end
  end
end
