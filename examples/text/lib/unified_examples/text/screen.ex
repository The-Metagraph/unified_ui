defmodule UnifiedExamples.Text.Screen do
  @moduledoc """
  Baseline shared-template screen used to prove the standalone example-app shape.
  """

  use UnifiedExamples.Shared.Template,
    id: :text_example_screen,
    title: "Example App Skeleton",
    summary: "Baseline standalone app proving the shared example runtime path",
    widget: :text,
    notes: "This skeleton is the baseline structure for standalone example apps."

  example_panel do
    text :text_example_placeholder do
      value("Skeleton ready")
      theme_ref(:example_suite_default)
      tone(:accent)
      variant(:headline)
    end
  end
end
