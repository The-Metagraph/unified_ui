defmodule UnifiedExamples.TextInput do
  @moduledoc """
  Standalone text_input example-app entrypoint for the shared examples suite.
  """

  use UnifiedExamples.Shared.App,
    app: :unified_example_text_input,
    directory: "examples/text_input"
end
