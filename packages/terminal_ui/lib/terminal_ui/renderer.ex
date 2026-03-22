defmodule TerminalUi.Renderer do
  @moduledoc """
  Canonical renderer entrypoint placeholder for `terminal_ui`.
  """

  alias UnifiedIUR.Element
  alias TerminalUi.Renderer.{Error, Mapper}

  @spec accepts() :: module()
  def accepts, do: Element

  @spec responsibilities() :: [atom()]
  def responsibilities do
    [
      :accept_canonical_iur,
      :foundational_canonical_mapping,
      :advanced_canonical_mapping,
      :native_widget_reuse,
      :capability_aware_realization,
      :layered_meaning_preservation
    ]
  end

  @spec render(Element.t(), keyword()) :: {:ok, TerminalUi.Widget.t()} | {:error, Error.t()}
  def render(%Element{} = element, opts \\ []) do
    Mapper.map(element, opts)
  end
end
