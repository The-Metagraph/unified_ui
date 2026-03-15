defmodule UnifiedExamples.Progress do
  @moduledoc """
  Standalone progress example-app entrypoint for the shared examples suite.
  """

  use UnifiedExamples.Shared.App,
    app: :unified_example_progress,
    directory: "examples/progress"
end
