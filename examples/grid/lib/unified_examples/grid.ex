defmodule UnifiedExamples.Grid do
  @moduledoc """
  Standalone grid example-app entrypoint for the shared examples suite.
  """

  use UnifiedExamples.Shared.App,
    app: :unified_example_grid,
    directory: "examples/grid"
end
