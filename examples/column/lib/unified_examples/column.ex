defmodule UnifiedExamples.Column do
  @moduledoc """
  Standalone column example-app entrypoint for the shared examples suite.
  """

  use UnifiedExamples.Shared.App,
    app: :unified_example_column,
    directory: "examples/column"
end
