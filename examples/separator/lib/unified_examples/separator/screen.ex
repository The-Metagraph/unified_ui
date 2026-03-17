defmodule UnifiedExamples.Separator.Screen do
  @moduledoc """
  Shared-template separator proof for the standalone example-app suite.
  """

  use UnifiedExamples.Shared.Template,
    id: :separator_example_screen,
    title: "Separator Widget Example",
    summary: "Focused content-oriented example using the shared suite shell",
    widget: :separator,
    notes:
      "Separator examples keep the shared shell while foregrounding one primary separator widget.",
    interaction_demo: %{
      trigger_label: "Highlight the separator story",
      idle_prompt:
        "Use the shared trigger to call out how the separator organizes the reviewed content.",
      outcome:
        "The separator example should explain the authored visual boundary and why it matters in the surrounding composition."
    }

  example_panel do
    separator :separator_example_primary_separator do
      orientation(:horizontal)
      decorative?(false)
      theme_ref(:example_suite_default)
      tone(:muted)
      variant(:rule)
    end
  end
end
