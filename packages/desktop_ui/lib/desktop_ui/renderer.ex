defmodule DesktopUi.Renderer do
  @moduledoc """
  Canonical renderer entrypoint for `desktop_ui`.
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
      :advanced_canonical_mapping,
      :reuse_native_runtime_model,
      :shared_runtime_realization,
      :layered_meaning_preservation
    ]
  end

  @spec supported_kinds() :: [atom()]
  def supported_kinds do
    [
      :breadcrumbs,
      :button,
      :canvas,
      :canvas_surface,
      :checkbox,
      :cluster_dashboard,
      :column,
      :command,
      :command_palette,
      :context_menu,
      :content,
      :dialog,
      :gauge,
      :icon,
      :image,
      :inspector,
      :label,
      :line_chart,
      :link,
      :list,
      :log_viewer,
      :markdown_viewer,
      :menu,
      :multi_window,
      :overlay,
      :popover,
      :process_monitor,
      :progress,
      :radio_group,
      :row,
      :scroll_region,
      :select,
      :separator,
      :split_pane,
      :spacer,
      :stack,
      :table,
      :tabs,
      :text,
      :text_input,
      :timeline,
      :toast,
      :toggle,
      :tree_view,
      :viewport,
      :window,
      :window_command
    ]
  end

  @spec validation_state() :: atom()
  def validation_state, do: :advanced_mapper_ready

  @spec render(Element.t(), keyword()) :: {:ok, DesktopUi.Widget.t()} | {:error, Error.t()}
  def render(%Element{} = element, _opts \\ []) do
    Mapper.map(element)
  end
end
