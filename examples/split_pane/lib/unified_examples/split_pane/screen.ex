defmodule UnifiedExamples.SplitPane.Screen do
  @moduledoc """
  Shared-template split-pane proof for the standalone example-app suite.
  """

  alias UnifiedExamples.Shared.Fixtures

  @split_pane_snapshot Fixtures.split_pane_snapshot()

  use UnifiedExamples.Shared.Template,
    id: :split_pane_example_screen,
    title: "Split Pane Widget Example",
    summary: "Focused display-system example using the shared suite shell",
    widget: :split_pane,
    notes:
      "Split-pane examples foreground one canonical dual-region layout inside the shared shell."

  example_panel do
    box :split_pane_example_primary_panel do
      theme_ref(:example_suite_default)
      tone(:surface)
      variant(:panel)

      text :split_pane_example_primary_heading do
        value(@split_pane_snapshot.primary_heading)
        theme_ref(:example_suite_default)
        tone(:accent)
        variant(:body)
      end
    end

    box :split_pane_example_secondary_panel do
      theme_ref(:example_suite_default)
      tone(:surface)
      variant(:panel)

      text :split_pane_example_secondary_heading do
        value(@split_pane_snapshot.secondary_heading)
        theme_ref(:example_suite_default)
        tone(:surface)
        variant(:body)
      end
    end

    split_pane :split_pane_example_primary_split_pane do
      primary_ref(:split_pane_example_primary_panel)
      secondary_ref(:split_pane_example_secondary_panel)
      ratio(@split_pane_snapshot.ratio)
      orientation(@split_pane_snapshot.orientation)
      divider_size(2)
      theme_ref(:example_suite_default)
      tone(:surface)
      variant(:quiet)
    end
  end
end
