defmodule UnifiedExamples.Checkbox do
  @moduledoc """
  Standalone checkbox example-app entrypoint for the shared examples suite.
  """

  use UnifiedExamples.Shared.App,
    app: :unified_example_checkbox,
    directory: "examples/checkbox"
end
