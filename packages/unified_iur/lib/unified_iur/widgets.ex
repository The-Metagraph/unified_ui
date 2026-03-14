defmodule UnifiedIUR.Widgets do
  @moduledoc """
  Reference surface for canonical widget constructors exposed by `UnifiedIUR`.
  """

  alias UnifiedIUR.Widgets.{Foundational, Input}

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
  @input_kinds [
    :text_input,
    :numeric_input,
    :toggle,
    :checkbox,
    :radio_group,
    :select,
    :pick_list,
    :slider,
    :date_input,
    :time_input,
    :file_input
  ]

  @spec modules() :: %{foundational: module(), input: module()}
  def modules do
    %{foundational: Foundational, input: Input}
  end

  @spec foundational_kinds() :: [atom()]
  def foundational_kinds do
    @foundational_kinds
  end

  @spec input_kinds() :: [atom()]
  def input_kinds do
    @input_kinds
  end
end
