defmodule UnifiedUi.Widgets.Semantic do
  @moduledoc """
  Package-facing reference surface for authored semantic and micro-interaction
  widget kinds.
  """

  alias UnifiedUi.Dsl.Entities.Semantic

  @spec kinds() :: [atom()]
  def kinds do
    Semantic.kinds()
  end
end
