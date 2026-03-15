defmodule UnifiedExamples.LineChart do
  @moduledoc """
  Standalone line chart example-app entrypoint for the shared examples suite.
  """

  use UnifiedExamples.Shared.App,
    app: :unified_example_line_chart,
    directory: "examples/line_chart"
end
