defmodule UnifiedExamples.Demo do
  @moduledoc """
  Aggregate demo-app entrypoint for the unified examples suite.
  """

  use UnifiedExamples.Shared.App,
    app: :unified_example_demo,
    directory: "examples/demo",
    purpose: :aggregate_demo
end
