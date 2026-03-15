defmodule UnifiedExamples.Icon do
  @moduledoc """
  Standalone icon example-app entrypoint for the shared examples suite.
  """

  use UnifiedExamples.Shared.App,
    app: :unified_example_icon,
    directory: "examples/icon"
end
