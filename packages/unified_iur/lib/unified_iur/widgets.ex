defmodule UnifiedIUR.Widgets do
  @moduledoc """
  Reference surface for canonical widget constructors exposed by `UnifiedIUR`.
  """

  alias UnifiedIUR.Widgets.Foundational

  @foundational_kinds [
    :text,
    :label,
    :icon,
    :image,
    :button,
    :link,
    :separator,
    :spacer,
    :content
  ]

  @spec modules() :: %{foundational: module()}
  def modules do
    %{foundational: Foundational}
  end

  @spec foundational_kinds() :: [atom()]
  def foundational_kinds do
    @foundational_kinds
  end
end
