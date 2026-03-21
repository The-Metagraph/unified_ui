defmodule WebUi.Renderer do
  @moduledoc """
  Canonical `UnifiedIUR` renderer entrypoint for `web_ui`.
  """

  alias UnifiedIUR.Element
  alias WebUi.Renderer.Error

  @spec accepts() :: module()
  def accepts, do: Element

  @spec responsibilities() :: [atom()]
  def responsibilities do
    [
      :accept_canonical_iur,
      :deterministic_native_mapping,
      :native_widget_reuse,
      :coverage_oriented_diagnostics
    ]
  end

  @spec supported_kinds() :: [atom()]
  def supported_kinds do
    [
      :text,
      :label,
      :icon,
      :image,
      :button,
      :link,
      :separator,
      :spacer,
      :content,
      :text_input,
      :checkbox,
      :select,
      :menu,
      :tabs,
      :row,
      :column,
      :container,
      :stack,
      :form,
      :field_group,
      :field
    ]
  end

  @spec render(Element.t(), keyword()) :: {:ok, WebUi.Widget.t()} | {:error, Error.t()}
  def render(%Element{} = element, opts \\ []) do
    WebUi.Renderer.Canonical.render(element, opts)
  end
end
