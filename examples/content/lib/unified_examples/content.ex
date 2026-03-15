defmodule UnifiedExamples.Content do
  @moduledoc """
  Standalone content example-app entrypoint for the shared examples suite.
  """

  use UnifiedExamples.Shared.App,
    app: :unified_example_content,
    directory: "examples/content"
end
