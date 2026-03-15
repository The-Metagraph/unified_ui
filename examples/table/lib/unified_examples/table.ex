defmodule UnifiedExamples.Table do
  @moduledoc """
  Standalone table example-app entrypoint for the shared examples suite.
  """

  use UnifiedExamples.Shared.App,
    app: :unified_example_table,
    directory: "examples/table"
end
