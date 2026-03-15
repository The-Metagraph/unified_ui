defmodule UnifiedExamples.DateInput do
  @moduledoc """
  Standalone date_input example-app entrypoint for the shared examples suite.
  """

  use UnifiedExamples.Shared.App,
    app: :unified_example_date_input,
    directory: "examples/date_input"
end
