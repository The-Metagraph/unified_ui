defmodule UnifiedExamples.Overlay do
  @moduledoc """
  Standalone overlay example-app entrypoint for the shared examples suite.
  """

  use UnifiedExamples.Shared.App,
    app: :unified_example_overlay,
    directory: "examples/overlay"
end
