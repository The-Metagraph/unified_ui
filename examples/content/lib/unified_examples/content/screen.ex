defmodule UnifiedExamples.Content.Screen do
  @moduledoc """
  Shared-template content proof for the standalone example-app suite.
  """

  use UnifiedExamples.Shared.Template,
    id: :content_example_screen,
    title: "Content Widget Example",
    summary: "Focused content-oriented example using the shared suite shell",
    widget: :content,
    notes:
      "Content examples keep the shared shell while foregrounding one primary content container."

  example_panel do
    UnifiedUi.Dsl.Composition.Box.Composition.Children.Content.content :content_example_primary_content do
      summary("Primary content container")
      theme_ref(:example_suite_default)
      tone(:surface)
      variant(:panel)

      text :content_example_heading do
        value("Shared content block")
        theme_ref(:example_suite_default)
        tone(:accent)
        variant(:headline)
      end

      text :content_example_body do
        value("Content widgets group related child widgets inside one authored subject.")
        theme_ref(:example_suite_default)
        tone(:surface)
        variant(:body)
      end
    end
  end
end
