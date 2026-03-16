defmodule UnifiedExamples.Button do
  @moduledoc """
  Standalone button example-app entrypoint for the shared examples suite.
  """

  use UnifiedExamples.Shared.App,
    app: :unified_example_button,
    directory: "examples/button"
end
