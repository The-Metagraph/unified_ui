defmodule UnifiedExamples.PickList do
  @moduledoc """
  Standalone pick_list example-app entrypoint for the shared examples suite.
  """

  use UnifiedExamples.Shared.App,
    app: :unified_example_pick_list,
    directory: "examples/pick_list"
end
