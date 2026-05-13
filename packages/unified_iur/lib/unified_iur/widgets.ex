defmodule UnifiedIUR.Widgets do
  @moduledoc """
  Reference surface for canonical widget constructors exposed by `UnifiedIUR`.
  """

  alias UnifiedIUR.Widgets.{
    Advanced,
    Data,
    Feedback,
    Foundational,
    Input,
    Navigation,
    Semantic,
    Workflow
  }

  @foundational_kinds [
    :text,
    :label,
    :icon,
    :image,
    :badge,
    :hero,
    :button,
    :link,
    :separator,
    :spacer,
    :content
  ]
  @input_kinds [
    :text_input,
    :numeric_input,
    :toggle,
    :checkbox,
    :radio_group,
    :select,
    :pick_list,
    :slider,
    :date_input,
    :time_input,
    :file_input
  ]
  @navigation_kinds [:menu, :tabs]
  @data_view_kinds [:list, :table, :tree_view, :stat, :key_value, :info_list]
  @feedback_kinds [:status, :progress, :gauge, :inline_feedback]
  @advanced_kinds [
    :stream_widget,
    :log_viewer,
    :process_monitor,
    :cluster_dashboard,
    :command_palette,
    :markdown_viewer,
    :supervision_tree_viewer
  ]
  @semantic_kinds [
    :disclosure,
    :kicker,
    :avatar,
    :presence_dot,
    :segmented_button_group,
    :list_item_multi_column,
    :artifact_row,
    :sticky_header
  ]
  @workflow_kinds [
    :pipeline_stepper_horizontal,
    :segmented_progress_bar,
    :workflow_stage_list_vertical,
    :meter_thin,
    :slide_over_panel,
    :event_callout,
    :redline_inline,
    :code_block_syntax_highlighted,
    :chat_composer
  ]

  @spec modules() :: %{
          advanced: module(),
          data: module(),
          feedback: module(),
          foundational: module(),
          input: module(),
          navigation: module(),
          semantic: module(),
          workflow: module()
        }
  def modules do
    %{
      advanced: Advanced,
      foundational: Foundational,
      input: Input,
      navigation: Navigation,
      data: Data,
      feedback: Feedback,
      semantic: Semantic,
      workflow: Workflow
    }
  end

  @spec foundational_kinds() :: [atom()]
  def foundational_kinds do
    @foundational_kinds
  end

  @spec input_kinds() :: [atom()]
  def input_kinds do
    @input_kinds
  end

  @spec navigation_kinds() :: [atom()]
  def navigation_kinds do
    @navigation_kinds
  end

  @spec data_view_kinds() :: [atom()]
  def data_view_kinds do
    @data_view_kinds
  end

  @spec feedback_kinds() :: [atom()]
  def feedback_kinds do
    @feedback_kinds
  end

  @spec advanced_kinds() :: [atom()]
  def advanced_kinds do
    @advanced_kinds
  end

  @spec semantic_kinds() :: [atom()]
  def semantic_kinds do
    @semantic_kinds
  end

  @spec workflow_kinds() :: [atom()]
  def workflow_kinds do
    @workflow_kinds
  end
end
