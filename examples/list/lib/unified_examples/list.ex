defmodule UnifiedExamples.List do
  @moduledoc """
  Standalone list example-app entrypoint for the shared examples suite.
  """

  use UnifiedExamples.Shared.App,
    app: :unified_example_list,
    directory: "examples/list"
end
