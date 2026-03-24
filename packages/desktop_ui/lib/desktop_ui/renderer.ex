defmodule DesktopUi.Renderer do
  @moduledoc """
  Canonical renderer entrypoint for foundational `desktop_ui`.
  """

  alias DesktopUi.Renderer.Error
  alias DesktopUi.Renderer.Mapper
  alias UnifiedIUR.Element

  @spec accepts() :: module()
  def accepts, do: Element

  @spec responsibilities() :: [atom()]
  def responsibilities do
    [
      :accept_canonical_iur,
      :foundational_canonical_mapping,
      :reuse_native_runtime_model,
      :shared_runtime_realization
    ]
  end

  @spec supported_kinds() :: [atom()]
  def supported_kinds do
    [
      :breadcrumbs,
      :button,
      :checkbox,
      :column,
      :command,
      :content,
      :icon,
      :image,
      :label,
      :link,
      :list,
      :menu,
      :radio_group,
      :row,
      :select,
      :separator,
      :spacer,
      :stack,
      :tabs,
      :text,
      :text_input,
      :toggle
    ]
  end

  @spec validation_state() :: atom()
  def validation_state, do: :foundational_mapper_ready

  @spec render(Element.t(), keyword()) :: {:ok, DesktopUi.Widget.t()} | {:error, Error.t()}
  def render(%Element{} = element, _opts \\ []) do
    Mapper.map(element)
  end
end
