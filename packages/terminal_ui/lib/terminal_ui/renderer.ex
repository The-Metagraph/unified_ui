defmodule TerminalUi.Renderer do
  @moduledoc """
  Canonical renderer entrypoint placeholder for `terminal_ui`.
  """

  alias UnifiedIUR.Element

  @spec accepts() :: module()
  def accepts, do: Element

  @spec responsibilities() :: [atom()]
  def responsibilities do
    [:accept_canonical_iur, :native_widget_reuse, :capability_aware_realization]
  end
end
