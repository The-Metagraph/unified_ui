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
      :advanced_widget_reuse,
      :layered_runtime_coordination,
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
      :viewport,
      :scroll_bar,
      :split_pane,
      :form,
      :field_group,
      :field,
      :table,
      :tree_view,
      :markdown_viewer,
      :log_viewer,
      :status,
      :progress,
      :inline_feedback,
      :gauge,
      :sparkline,
      :bar_chart,
      :line_chart,
      :canvas,
      :stream_widget,
      :process_monitor,
      :cluster_dashboard,
      :command_palette,
      :supervision_tree_viewer,
      :overlay,
      :dialog,
      :toast,
      :alert_dialog,
      :context_menu
    ]
  end

  @spec render(Element.t(), keyword()) :: {:ok, WebUi.Widget.t()} | {:error, Error.t()}
  def render(%Element{} = element, opts \\ []) do
    WebUi.Renderer.Canonical.render(element, opts)
  end
end
