defmodule UnifiedExamples.Box do
  @moduledoc """
  Standalone box example-app entrypoint for the shared examples suite.
  """

  use UnifiedExamples.Shared.App,
    app: :unified_example_box,
    directory: "examples/box"
end
