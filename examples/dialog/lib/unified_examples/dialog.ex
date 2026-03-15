defmodule UnifiedExamples.Dialog do
  @moduledoc """
  Standalone dialog example-app entrypoint for the shared examples suite.
  """

  use UnifiedExamples.Shared.App,
    app: :unified_example_dialog,
    directory: "examples/dialog"
end
