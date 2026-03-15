defmodule UnifiedExamples.SupervisionTreeViewer do
  @moduledoc """
  Standalone supervision-tree-viewer example-app entrypoint for the shared examples suite.
  """

  use UnifiedExamples.Shared.App,
    app: :unified_example_supervision_tree_viewer,
    directory: "examples/supervision_tree_viewer"
end
