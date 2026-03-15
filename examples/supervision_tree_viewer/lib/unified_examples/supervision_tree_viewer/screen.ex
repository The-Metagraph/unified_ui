defmodule UnifiedExamples.SupervisionTreeViewer.Screen do
  @moduledoc """
  Shared-template supervision-tree-viewer proof for the standalone example-app suite.
  """

  alias UnifiedExamples.Shared.Fixtures

  @supervision_snapshot Fixtures.supervision_tree_snapshot()

  use UnifiedExamples.Shared.Template,
    id: :supervision_tree_viewer_example_screen,
    title: "Supervision Tree Viewer Example",
    summary: "Focused operational example using the shared suite shell",
    widget: :supervision_tree_viewer,
    notes:
      "Supervision-tree examples foreground one canonical supervision hierarchy inside the shared shell."

  example_panel do
    supervision_tree_viewer :supervision_tree_viewer_example_primary_supervision_tree_viewer do
      topology(@supervision_snapshot.topology)
      expanded?(@supervision_snapshot.expanded?)
      theme_ref(:example_suite_default)
      tone(:surface)
      variant(:quiet)
    end
  end
end
