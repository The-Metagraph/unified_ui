defmodule UnifiedExamples.Text.Screen do
  @moduledoc """
  Shared-template text proof for the standalone example-app suite.
  """

  use UnifiedExamples.Shared.Template,
    id: :text_example_screen,
    title: "Text Widget Example",
    summary: "Focused content-oriented example using the shared suite shell",
    widget: :text,
    notes: "Text examples keep the shared shell while foregrounding one primary content widget.",
    interaction_demo: %{
      trigger_label: "Highlight the text story",
      idle_prompt:
        "Use the shared trigger to spotlight the text example and see how its authored copy becomes a reviewed interaction story.",
      outcome:
        "The text example should spotlight its authored copy and explain why the shared trigger exists for otherwise passive content."
    }

  example_panel do
    text :text_example_primary_content do
      value("Shared text example")
      theme_ref(:example_suite_default)
      tone(:accent)
      variant(:headline)
    end
  end
end
