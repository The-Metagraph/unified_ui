defmodule UnifiedExamples.Label.Screen do
  @moduledoc """
  Shared-template label proof for the standalone example-app suite.
  """

  use UnifiedExamples.Shared.Template,
    id: :label_example_screen,
    title: "Label Widget Example",
    summary: "Focused content-oriented example using the shared suite shell",
    widget: :label,
    notes: "Label examples keep the shared shell while foregrounding one primary label widget.",
    interaction_demo: %{
      trigger_label: "Highlight the label relationship",
      idle_prompt:
        "Use the shared trigger to call out how the label example frames authored relationships for reviewers.",
      outcome:
        "The label example should make the authored label relationship easy to understand in the browser without inspecting source."
    }

  example_panel do
    label :label_example_primary_label do
      value("Assigned owner")
      theme_ref(:example_suite_default)
      tone(:accent)
      variant(:body)
    end
  end
end
