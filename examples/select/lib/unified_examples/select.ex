defmodule UnifiedExamples.Select do
  @moduledoc """
  Standalone select example-app entrypoint for the shared examples suite.
  """

  use UnifiedExamples.Shared.App,
    app: :unified_example_select,
    directory: "examples/select"
end
