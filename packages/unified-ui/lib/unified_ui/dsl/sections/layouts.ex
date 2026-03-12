defmodule UnifiedUi.Dsl.Sections.Layouts do
  @moduledoc """
  Canonical layouts section definition used by the UnifiedUi DSL.
  """

  @layouts_section %Spark.Dsl.Section{
    name: :layouts,
    describe: """
    Layout entity definitions.
    """,
    schema: [],
    entities: [
      UnifiedUi.Dsl.Entities.Layouts.vbox_entity(),
      UnifiedUi.Dsl.Entities.Layouts.hbox_entity(),
      UnifiedUi.Dsl.Entities.Layouts.grid_entity(),
      UnifiedUi.Dsl.Entities.Layouts.stack_entity(),
      UnifiedUi.Dsl.Entities.Layouts.zbox_entity(),
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
  def section, do: @layouts_section

  @doc false
  @spec entities() :: [Spark.Dsl.Entity.t()]
  def entities, do: @layouts_section.entities

  @doc false
  @spec top_level?() :: boolean()
  def top_level?, do: false

  @doc false
  @spec name() :: atom()
  def name, do: @layouts_section.name
end
