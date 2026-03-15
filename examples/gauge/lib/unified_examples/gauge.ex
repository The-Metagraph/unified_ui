defmodule UnifiedExamples.Gauge do
  @moduledoc """
  Standalone gauge example-app entrypoint for the shared examples suite.
  """

  use UnifiedExamples.Shared.App,
    app: :unified_example_gauge,
    directory: "examples/gauge"
end
