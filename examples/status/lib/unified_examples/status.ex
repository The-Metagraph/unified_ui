defmodule UnifiedExamples.Status do
  @moduledoc """
  Standalone status example-app entrypoint for the shared examples suite.
  """

  use UnifiedExamples.Shared.App,
    app: :unified_example_status,
    directory: "examples/status"
end
