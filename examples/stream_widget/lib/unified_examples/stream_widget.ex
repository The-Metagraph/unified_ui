defmodule UnifiedExamples.StreamWidget do
  @moduledoc """
  Standalone stream-widget example-app entrypoint for the shared examples suite.
  """

  use UnifiedExamples.Shared.App,
    app: :unified_example_stream_widget,
    directory: "examples/stream_widget"
end
