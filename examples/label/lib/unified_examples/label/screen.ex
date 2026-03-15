defmodule UnifiedExamples.Label.Screen do
  @moduledoc """
  Shared-template label proof for the standalone example-app suite.
  """

  use UnifiedExamples.Shared.Template,
    id: :label_example_screen,
    title: "Label Widget Example",
    summary: "Focused content-oriented example using the shared suite shell",
    widget: :label,
    notes: "Label examples keep the shared shell while foregrounding one primary label widget."

  example_panel do
    label :label_example_primary_label do
      value("Assigned owner")
      theme_ref(:example_suite_default)
      tone(:accent)
      variant(:body)
    end
  end
end
