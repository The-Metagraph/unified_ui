defmodule UnifiedExamples.FileInput do
  @moduledoc """
  Standalone file_input example-app entrypoint for the shared examples suite.
  """

  use UnifiedExamples.Shared.App,
    app: :unified_example_file_input,
    directory: "examples/file_input"
end
