defmodule UnifiedExamples.CommandPalette do
  @moduledoc """
  Standalone command palette example-app entrypoint for the shared examples suite.
  """

  use UnifiedExamples.Shared.App,
    app: :unified_example_command_palette,
    directory: "examples/command_palette"
end
