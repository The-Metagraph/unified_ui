defmodule UnifiedExamples.Toast do
  @moduledoc """
  Standalone toast example-app entrypoint for the shared examples suite.
  """

  use UnifiedExamples.Shared.App,
    app: :unified_example_toast,
    directory: "examples/toast"
end
