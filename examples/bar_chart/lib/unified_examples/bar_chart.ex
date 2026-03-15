defmodule UnifiedExamples.BarChart do
  @moduledoc """
  Standalone bar chart example-app entrypoint for the shared examples suite.
  """

  use UnifiedExamples.Shared.App,
    app: :unified_example_bar_chart,
    directory: "examples/bar_chart"
end
