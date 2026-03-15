defmodule UnifiedExamples.TimeInput do
  @moduledoc """
  Standalone time_input example-app entrypoint for the shared examples suite.
  """

  use UnifiedExamples.Shared.App,
    app: :unified_example_time_input,
    directory: "examples/time_input"
end
