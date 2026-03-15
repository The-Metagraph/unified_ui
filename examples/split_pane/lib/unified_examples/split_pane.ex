defmodule UnifiedExamples.SplitPane do
  @moduledoc """
  Standalone split-pane example-app entrypoint for the shared examples suite.
  """

  use UnifiedExamples.Shared.App,
    app: :unified_example_split_pane,
    directory: "examples/split_pane"
end
