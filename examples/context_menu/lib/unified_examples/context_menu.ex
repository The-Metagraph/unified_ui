defmodule UnifiedExamples.ContextMenu do
  @moduledoc """
  Standalone context-menu example-app entrypoint for the shared examples suite.
  """

  use UnifiedExamples.Shared.App,
    app: :unified_example_context_menu,
    directory: "examples/context_menu"
end
