defmodule UnifiedUi.Widgets do
  @moduledoc """
  Package-facing reference surface for authored widget kinds supported by `UnifiedUi`.
  """

  alias UnifiedUi.Dsl.Entities.Foundational

  @spec foundational_kinds() :: [atom()]
  def foundational_kinds do
    Foundational.kinds()
  end

  @spec kinds() :: [atom()]
  def kinds do
    foundational_kinds()
  end
end
