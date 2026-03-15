defmodule UnifiedExamples.LogViewer do
  @moduledoc """
  Standalone log viewer example-app entrypoint for the shared examples suite.
  """

  use UnifiedExamples.Shared.App,
    app: :unified_example_log_viewer,
    directory: "examples/log_viewer"
end
