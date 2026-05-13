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
      UnifiedIUR.Widgets.Semantic.kinds(),
      UnifiedIUR.Widgets.Workflow.kinds(),
      UnifiedIUR.Forms.kinds(),
      UnifiedIUR.Collection.kinds(),
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
      :artifact_row,
      :avatar,
      :badge,
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
      :code_block_syntax_highlighted,
      :date_input,
      :dialog,
      :disclosure,
      :event_callout,
      :field,
      :field_group,
      :file_input,
      :form_builder,
      :form_field,
      :gauge,
      :grid,
      :host_form_shell,
      :hero,
      :icon,
      :image,
      :inline_feedback,
      :info_list,
      :key_value,
      :kicker,
      :label,
      :line_chart,
      :link,
      :list,
      :list_item_multi_column,
      :log_viewer,
      :markdown_viewer,
      :meter_thin,
      :menu,
      :numeric_input,
      :overlay,
      :pick_list,
      :pipeline_stepper_horizontal,
      :presence_dot,
      :process_monitor,
      :progress,
      :radio_group,
      :redline_inline,
      :repeated_collection,
      :row,
      :scroll_bar,
      :scroll_region,
      :select,
      :separator,
      :segmented_button_group,
      :segmented_progress_bar,
      :slider,
      :slide_over_panel,
      :sparkline,
      :spacer,
      :split_pane,
      :stack,
      :stat,
      :status,
      :sticky_header,
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
      :viewport,
      :chat_composer,
      :workflow_stage_list_vertical
    ]
    |> Enum.uniq()
    |> Enum.sort()
  end

  @spec render(Element.t(), keyword()) :: {:ok, TerminalUi.Widget.t()} | {:error, Error.t()}
  def render(%Element{} = element, opts \\ []) do
    Mapper.map(element, opts)
  end
end
