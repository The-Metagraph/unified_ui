defmodule UnifiedUi.Dsl.Sections.Widgets do
  @moduledoc """
  Canonical widgets section definition used by the UnifiedUi DSL.
  """

  @widgets_section %Spark.Dsl.Section{
    name: :widgets,
    describe: """
    Widget entity definitions.
    """,
    schema: [],
    entities: [
      UnifiedUi.Dsl.Entities.Widgets.button_entity(),
      UnifiedUi.Dsl.Entities.Widgets.text_entity(),
      UnifiedUi.Dsl.Entities.Widgets.label_entity(),
      UnifiedUi.Dsl.Entities.Widgets.text_input_entity(),
      UnifiedUi.Dsl.Entities.Layouts.grid_entity(),
      UnifiedUi.Dsl.Entities.Layouts.stack_entity(),
      UnifiedUi.Dsl.Entities.Layouts.zbox_entity(),
      UnifiedUi.Dsl.Entities.DataViz.gauge_entity(),
      UnifiedUi.Dsl.Entities.DataViz.sparkline_entity(),
      UnifiedUi.Dsl.Entities.DataViz.bar_chart_entity(),
      UnifiedUi.Dsl.Entities.DataViz.line_chart_entity(),
      UnifiedUi.Dsl.Entities.Tables.table_entity(),
      UnifiedUi.Dsl.Entities.Navigation.menu_entity(),
      UnifiedUi.Dsl.Entities.Navigation.context_menu_entity(),
      UnifiedUi.Dsl.Entities.Navigation.tabs_entity(),
      UnifiedUi.Dsl.Entities.Navigation.tree_view_entity(),
      UnifiedUi.Dsl.Entities.DialogFeedback.dialog_entity(),
      UnifiedUi.Dsl.Entities.DialogFeedback.alert_dialog_entity(),
      UnifiedUi.Dsl.Entities.DialogFeedback.toast_entity(),
      UnifiedUi.Dsl.Entities.InputWidgets.pick_list_entity(),
      UnifiedUi.Dsl.Entities.InputWidgets.form_builder_entity(),
      UnifiedUi.Dsl.Entities.Containers.viewport_entity(),
      UnifiedUi.Dsl.Entities.Containers.split_pane_entity(),
      UnifiedUi.Dsl.Entities.Specialized.canvas_entity(),
      UnifiedUi.Dsl.Entities.Specialized.command_palette_entity(),
      UnifiedUi.Dsl.Entities.Monitoring.log_viewer_entity(),
      UnifiedUi.Dsl.Entities.Monitoring.stream_widget_entity(),
      UnifiedUi.Dsl.Entities.Monitoring.process_monitor_entity()
    ]
  }

  @doc false
  @spec section() :: Spark.Dsl.Section.t()
  def section, do: @widgets_section

  @doc false
  @spec entities() :: [Spark.Dsl.Entity.t()]
  def entities, do: @widgets_section.entities

  @doc false
  @spec top_level?() :: boolean()
  def top_level?, do: false

  @doc false
  @spec name() :: atom()
  def name, do: @widgets_section.name
end
