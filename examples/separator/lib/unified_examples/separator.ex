defmodule UnifiedExamples.Separator do
  @moduledoc """
  Standalone separator example-app entrypoint for the shared examples suite.
  """

  use UnifiedExamples.Shared.App,
    app: :unified_example_separator,
    directory: "examples/separator"
end
