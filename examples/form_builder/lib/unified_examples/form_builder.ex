defmodule UnifiedExamples.FormBuilder do
  @moduledoc """
  Standalone form_builder example-app entrypoint for the shared examples suite.
  """

  use UnifiedExamples.Shared.App,
    app: :unified_example_form_builder,
    directory: "examples/form_builder"
end
