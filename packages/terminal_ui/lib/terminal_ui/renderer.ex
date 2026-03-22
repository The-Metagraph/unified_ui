defmodule TerminalUi.Renderer do
  @moduledoc """
  Canonical renderer entrypoint placeholder for `terminal_ui`.
  """

  alias UnifiedIUR.Element
  alias TerminalUi.Renderer.Error

  @spec accepts() :: module()
  def accepts, do: Element

  @spec responsibilities() :: [atom()]
  def responsibilities do
    [:accept_canonical_iur, :native_widget_reuse, :capability_aware_realization]
  end

  @spec render(Element.t(), keyword()) :: {:ok, term()} | {:error, Error.t()}
  def render(%Element{} = _element, _opts \\ []) do
    {:error, Error.new(:canonical_rendering_not_ready, %{phase: 1})}
  end
end
