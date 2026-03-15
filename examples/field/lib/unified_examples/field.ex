defmodule UnifiedExamples.Field do
  @moduledoc """
  Standalone field example-app entrypoint for the shared examples suite.
  """

  use UnifiedExamples.Shared.App,
    app: :unified_example_field,
    directory: "examples/field"
end
