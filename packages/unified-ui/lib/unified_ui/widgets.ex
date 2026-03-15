defmodule UnifiedUi.Widgets do
  @moduledoc """
  Package-facing reference surface for authored widget kinds supported by `UnifiedUi`.
  """

  alias UnifiedUi.Dsl.Entities.{Foundational, Input, Navigation}

  @spec foundational_kinds() :: [atom()]
  def foundational_kinds do
    Foundational.kinds()
  end

  @spec input_kinds() :: [atom()]
  def input_kinds do
    Input.kinds()
  end

  @spec navigation_kinds() :: [atom()]
  def navigation_kinds do
    Navigation.kinds()
  end

  @spec kinds() :: [atom()]
  def kinds do
    foundational_kinds() ++ input_kinds() ++ navigation_kinds()
  end
end
