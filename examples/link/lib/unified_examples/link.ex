defmodule UnifiedExamples.Link do
  @moduledoc """
  Standalone link example-app entrypoint for the shared examples suite.
  """

  use UnifiedExamples.Shared.App,
    app: :unified_example_link,
    directory: "examples/link"
end
