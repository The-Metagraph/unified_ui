defmodule UnifiedExamples.ProcessMonitor do
  @moduledoc """
  Standalone process-monitor example-app entrypoint for the shared examples suite.
  """

  use UnifiedExamples.Shared.App,
    app: :unified_example_process_monitor,
    directory: "examples/process_monitor"
end
