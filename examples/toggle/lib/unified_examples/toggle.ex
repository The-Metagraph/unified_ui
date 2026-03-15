defmodule UnifiedExamples.Toggle do
  @moduledoc """
  Standalone toggle example-app entrypoint for the shared examples suite.
  """

  use UnifiedExamples.Shared.App,
    app: :unified_example_toggle,
    directory: "examples/toggle"
end
