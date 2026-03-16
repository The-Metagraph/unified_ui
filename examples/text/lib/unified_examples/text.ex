defmodule UnifiedExamples.Text do
  @moduledoc """
  Baseline standalone example-app entrypoint for the shared examples suite.
  """

  use UnifiedExamples.Shared.App,
    app: :unified_example_text,
    directory: "examples/text"
end
