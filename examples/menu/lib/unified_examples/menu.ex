defmodule UnifiedExamples.Menu do
  @moduledoc """
  Standalone menu example-app entrypoint for the shared examples suite.
  """

  use UnifiedExamples.Shared.App,
    app: :unified_example_menu,
    directory: "examples/menu"
end
