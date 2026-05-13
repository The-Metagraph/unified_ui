defmodule UnifiedUi.Widgets.Workflow do
  @moduledoc """
  Package-facing reference surface for authored workflow, document, and
  composer widget kinds.
  """

  alias UnifiedUi.Dsl.Entities.Workflow

  @spec kinds() :: [atom()]
  def kinds do
    Workflow.kinds()
  end
end
