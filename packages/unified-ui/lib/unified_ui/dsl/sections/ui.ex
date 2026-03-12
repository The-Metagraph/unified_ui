defmodule UnifiedUi.Dsl.Sections.Ui do
  @moduledoc """
  Canonical UI section definition used by the UnifiedUi DSL.
  """

  @state_entity %Spark.Dsl.Entity{
    name: :state,
    target: UnifiedUi.Dsl.State,
    args: [:attrs],
    schema: [
      attrs: [
        type: :keyword_list,
        doc: "Initial state as keyword list with atom keys",
        required: true
      ]
    ],
    describe: "Define initial component state"
  }

  @ui_section %Spark.Dsl.Section{
    name: :ui,
    describe: """
    Top-level UI definition section.
    """,
    schema: [
      id: [
        type: :atom,
        doc: "Optional unique identifier for this UI component.",
        required: false
      ],
      theme: [
        type: :atom,
        doc: "Optional theme to apply to this UI component.",
        required: false
      ]
    ],
    entities: [
      @state_entity,
      UnifiedUi.Dsl.Entities.Layouts.vbox_entity(),
      UnifiedUi.Dsl.Entities.Layouts.hbox_entity(),
      UnifiedUi.Dsl.Entities.Layouts.grid_entity(),
      UnifiedUi.Dsl.Entities.Layouts.stack_entity(),
      UnifiedUi.Dsl.Entities.Layouts.zbox_entity(),
      UnifiedUi.Dsl.Entities.Widgets.text_entity(),
      UnifiedUi.Dsl.Entities.Widgets.button_entity(),
      UnifiedUi.Dsl.Entities.Widgets.label_entity(),
      UnifiedUi.Dsl.Entities.Widgets.text_input_entity(),
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
      UnifiedUi.Dsl.Entities.InputWidgets.form_builder_entity()
    ],
    top_level?: true
  }

  @doc false
  @spec section() :: Spark.Dsl.Section.t()
  def section, do: @ui_section

  @doc false
  @spec entities() :: [Spark.Dsl.Entity.t()]
  def entities, do: @ui_section.entities

  @doc false
  @spec top_level?() :: boolean()
  def top_level?, do: true

  @doc false
  @spec name() :: atom()
  def name, do: @ui_section.name
end
