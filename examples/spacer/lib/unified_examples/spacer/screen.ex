defmodule UnifiedExamples.Spacer.Screen do
  @moduledoc """
  Shared-template spacer proof for the standalone example-app suite.
  """

  use UnifiedExamples.Shared.Template,
    id: :spacer_example_screen,
    title: "Spacer Widget Example",
    summary: "Focused content-oriented example using the shared suite shell",
    widget: :spacer,
    notes: "Spacer examples keep the shared shell while foregrounding one primary spacer widget."

  example_panel do
    spacer :spacer_example_primary_spacer do
      size(:lg)
      grow(1)
      theme_ref(:example_suite_default)
      tone(:surface)
      variant(:body)
    end
  end
end
