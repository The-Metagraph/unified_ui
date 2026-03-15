defmodule UnifiedExamples.InlineFeedback do
  @moduledoc """
  Standalone inline feedback example-app entrypoint for the shared examples suite.
  """

  use UnifiedExamples.Shared.App,
    app: :unified_example_inline_feedback,
    directory: "examples/inline_feedback"
end
