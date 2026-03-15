defmodule UnifiedExamples.Sparkline do
  @moduledoc """
  Standalone sparkline example-app entrypoint for the shared examples suite.
  """

  use UnifiedExamples.Shared.App,
    app: :unified_example_sparkline,
    directory: "examples/sparkline"
end
