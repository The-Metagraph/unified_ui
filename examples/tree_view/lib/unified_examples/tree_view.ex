defmodule UnifiedExamples.TreeView do
  @moduledoc """
  Standalone tree view example-app entrypoint for the shared examples suite.
  """

  use UnifiedExamples.Shared.App,
    app: :unified_example_tree_view,
    directory: "examples/tree_view"
end
