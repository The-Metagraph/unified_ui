defmodule WebUi.Renderer do
  @moduledoc """
  Canonical `UnifiedIUR` renderer entrypoint for `web_ui`.
  """

  alias UnifiedIUR.Element

  @spec accepts() :: module()
  def accepts, do: Element

  @spec responsibilities() :: [atom()]
  def responsibilities do
    [:accept_canonical_iur, :deterministic_native_mapping, :native_widget_reuse]
  end

  @spec supported_kinds() :: [atom()]
  def supported_kinds do
    [:text, :button, :container, :stack, :column]
  end

  @spec render(Element.t(), keyword()) :: WebUi.Widget.t()
  def render(%Element{} = element, opts \\ []) do
    WebUi.Renderer.Canonical.render(element, opts)
  end
end
