defmodule UnifiedExamples.Row do
  @moduledoc """
  Standalone row example-app entrypoint for the shared examples suite.
  """

  use UnifiedExamples.Shared.App,
    app: :unified_example_row,
    directory: "examples/row"
end
