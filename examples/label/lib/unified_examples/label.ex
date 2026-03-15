defmodule UnifiedExamples.Label do
  @moduledoc """
  Standalone label example-app entrypoint for the shared examples suite.
  """

  use UnifiedExamples.Shared.App,
    app: :unified_example_label,
    directory: "examples/label"
end
