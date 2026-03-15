defmodule UnifiedExamples.Tabs do
  @moduledoc """
  Standalone tabs example-app entrypoint for the shared examples suite.
  """

  use UnifiedExamples.Shared.App,
    app: :unified_example_tabs,
    directory: "examples/tabs"
end
