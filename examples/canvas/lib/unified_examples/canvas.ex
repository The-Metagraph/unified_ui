defmodule UnifiedExamples.Canvas do
  @moduledoc """
  Standalone canvas example-app entrypoint for the shared examples suite.
  """

  use UnifiedExamples.Shared.App,
    app: :unified_example_canvas,
    directory: "examples/canvas"
end
