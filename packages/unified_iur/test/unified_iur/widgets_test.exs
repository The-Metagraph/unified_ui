defmodule UnifiedIUR.WidgetsTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Widgets

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

  test "exposes the foundational widget constructor family" do
    assert %{
             advanced: Advanced,
             foundational: Foundational,
             input: Input,
             navigation: Navigation,
             semantic: Semantic,
             workflow: Workflow,
             data: Data,
             feedback: Feedback
           } = Widgets.modules()

    assert [
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
           ] ==
             Widgets.foundational_kinds()

    assert Widgets.foundational_kinds() == Foundational.kinds()
    assert [:menu, :tabs] == Widgets.navigation_kinds()
    assert Widgets.navigation_kinds() == Navigation.kinds()

    assert [:list, :table, :tree_view, :stat, :key_value, :info_list] ==
             Widgets.data_view_kinds()

    assert Widgets.data_view_kinds() == Data.kinds()
    assert [:status, :progress, :gauge, :inline_feedback] == Widgets.feedback_kinds()
    assert Widgets.feedback_kinds() == Feedback.kinds()

    assert [
             :stream_widget,
             :log_viewer,
             :process_monitor,
             :cluster_dashboard,
             :command_palette,
             :markdown_viewer,
             :supervision_tree_viewer
           ] == Widgets.advanced_kinds()

    assert Widgets.advanced_kinds() == Advanced.kinds()

    assert [
             :disclosure,
             :kicker,
             :avatar,
             :presence_dot,
             :segmented_button_group,
             :list_item_multi_column,
             :artifact_row,
             :sticky_header
           ] == Widgets.semantic_kinds()

    assert Widgets.semantic_kinds() == Semantic.kinds()

    assert [
             :pipeline_stepper_horizontal,
             :segmented_progress_bar,
             :workflow_stage_list_vertical,
             :meter_thin,
             :slide_over_panel,
             :event_callout,
             :redline_inline,
             :code_block_syntax_highlighted,
             :chat_composer
           ] == Widgets.workflow_kinds()

    assert Widgets.workflow_kinds() == Workflow.kinds()
  end
end
