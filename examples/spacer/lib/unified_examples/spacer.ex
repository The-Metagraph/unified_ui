defmodule UnifiedExamples.Spacer do
  @moduledoc """
  Standalone spacer example-app entrypoint for the shared examples suite.
  """

  use UnifiedExamples.Shared.App,
    app: :unified_example_spacer,
    directory: "examples/spacer"
end
