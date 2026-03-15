defmodule UnifiedExamples.Image do
  @moduledoc """
  Standalone image example-app entrypoint for the shared examples suite.
  """

  use UnifiedExamples.Shared.App,
    app: :unified_example_image,
    directory: "examples/image"
end
