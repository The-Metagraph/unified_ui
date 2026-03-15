defmodule UnifiedExamples.TreeView.Screen do
  @moduledoc """
  Shared-template tree-view proof for the standalone example-app suite.
  """

  alias UnifiedExamples.Shared.Fixtures

  use UnifiedExamples.Shared.Template,
    id: :tree_view_example_screen,
    title: "Tree View Widget Example",
    summary: "Focused data-oriented example using the shared suite shell",
    widget: :tree_view,
    notes: "Tree view examples foreground one canonical hierarchy inside the shared shell."

  example_panel do
    tree_view :tree_view_example_primary_tree do
      tree_nodes(Fixtures.service_tree_nodes())
      expanded?(true)
      empty_state("No service topology available")
      theme_ref(:example_suite_default)
      tone(:surface)
      variant(:quiet)
    end
  end
end
