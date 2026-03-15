defmodule UnifiedExamples.Viewport do
  @moduledoc """
  Standalone viewport example-app entrypoint for the shared examples suite.
  """

  use UnifiedExamples.Shared.App,
    app: :unified_example_viewport,
    directory: "examples/viewport"
end
