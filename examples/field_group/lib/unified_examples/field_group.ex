defmodule UnifiedExamples.FieldGroup do
  @moduledoc """
  Standalone field_group example-app entrypoint for the shared examples suite.
  """

  use UnifiedExamples.Shared.App,
    app: :unified_example_field_group,
    directory: "examples/field_group"
end
