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

  @spec required_canonical_kinds() :: [atom()]
  def required_canonical_kinds do
    [
      UnifiedIUR.Widgets.Foundational.kinds(),
      UnifiedIUR.Widgets.Input.kinds(),
      UnifiedIUR.Widgets.Navigation.kinds(),
      UnifiedIUR.Forms.kinds(),
      UnifiedIUR.Layout.kinds(),
      UnifiedIUR.Viewport.kinds(),
      UnifiedIUR.Widgets.Data.kinds(),
      UnifiedIUR.Widgets.Feedback.kinds(),
      UnifiedIUR.Canvas.kinds(),
      UnifiedIUR.Widgets.Advanced.kinds(),
      UnifiedIUR.Layer.kinds()
    ]
    |> List.flatten()
    |> Enum.uniq()
    |> Enum.sort()
  end

  @spec supported_kinds() :: [atom()]
  def supported_kinds do
    [
      :absolute,
      :alert_dialog,
      :bar_chart,
      :box,
      :button,
      :canvas,
      :checkbox,
      :cluster_dashboard,
      :column,
      :command_palette,
      :content,
      :context_menu,
      :date_input,
      :dialog,
      :field,
      :field_group,
      :file_input,
      :form_builder,
      :gauge,
      :grid,
      :icon,
      :image,
      :inline_feedback,
      :label,
      :line_chart,
      :link,
      :list,
      :log_viewer,
      :markdown_viewer,
      :menu,
      :numeric_input,
      :overlay,
      :pick_list,
      :process_monitor,
      :progress,
      :radio_group,
      :row,
      :scroll_bar,
      :scroll_region,
      :select,
      :separator,
      :slider,
      :sparkline,
      :spacer,
      :split_pane,
      :stack,
      :status,
      :stream_widget,
      :supervision_tree_viewer,
      :table,
      :tabs,
      :text,
      :text_input,
      :time_input,
      :toast,
      :toggle,
      :tree_view,
      :viewport
    ]
    |> Enum.uniq()
    |> Enum.sort()
  end

  @spec render(Element.t(), keyword()) :: {:ok, TerminalUi.Widget.t()} | {:error, Error.t()}
  def render(%Element{} = element, opts \\ []) do
    Mapper.map(element, opts)
  end
end
