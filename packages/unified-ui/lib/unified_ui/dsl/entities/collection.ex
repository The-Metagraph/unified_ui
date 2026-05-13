defmodule UnifiedUi.Dsl.Entities.Collection do
  @moduledoc false

  alias UnifiedUi.Dsl.Entities.{
    Advanced,
    Data,
    Feedback,
    Foundational,
    Semantic,
    Workflow
  }

  alias UnifiedUi.Dsl.EntitySchema
  alias UnifiedUi.Dsl.Node

  @spec entities() :: [Spark.Dsl.Entity.t()]
  def entities do
    [
      repeated_collection_entity(template_entities())
    ]
  end

  @spec kinds() :: [atom()]
  def kinds do
    Enum.map(entities(), & &1.name)
  end

  defp repeated_collection_entity(children) do
    %Spark.Dsl.Entity{
      name: :repeated_collection,
      target: Node,
      args: [:id],
      identifier: :id,
      recursive_as: :children,
      auto_set_fields: [family: :collection, kind: :repeated_collection],
      entities: [children: children],
      schema:
        EntitySchema.widget(
          collection_source: [type: :any, required: true],
          item_alias: [type: :atom, required: false, default: :item],
          index_alias: [type: :atom, required: false, default: :index],
          key_path: [type: {:list, :atom}, required: true],
          empty_state: [type: :string, required: false],
          summary: [type: :string, required: false]
        )
    }
  end

  defp template_entities do
    widgets = template_widget_entities()

    widgets ++ template_layout_entities()
  end

  defp template_widget_entities do
    select_entities(Foundational.entities(), [:text, :label, :icon, :badge, :button, :link]) ++
      select_entities(Data.entities(), [:stat, :key_value, :info_list]) ++
      select_entities(Feedback.entities(), [:status, :progress, :inline_feedback]) ++
      Semantic.entities() ++
      Workflow.entities() ++
      Advanced.entities()
  end

  defp template_layout_entities do
    [
      layout(:box_template, :box,
        summary: [type: :string, required: false],
        gap: [type: :atom, required: false]
      ),
      layout(:row_template, :row,
        summary: [type: :string, required: false],
        gap: [type: :atom, required: false],
        align: [type: :atom, required: false],
        justify: [type: :atom, required: false]
      ),
      layout(:column_template, :column,
        summary: [type: :string, required: false],
        gap: [type: :atom, required: false],
        align: [type: :atom, required: false],
        justify: [type: :atom, required: false]
      ),
      layout(:grid_template, :grid,
        summary: [type: :string, required: false],
        gap: [type: :atom, required: false],
        columns: [type: :integer, required: false],
        rows: [type: :integer, required: false]
      ),
      layout(:stack_template, :stack,
        summary: [type: :string, required: false],
        gap: [type: :atom, required: false],
        align: [type: :atom, required: false]
      )
    ]
  end

  defp layout(name, kind, extra_schema) do
    %Spark.Dsl.Entity{
      name: name,
      target: Node,
      args: [:id],
      identifier: :id,
      auto_set_fields: [family: :layout, kind: kind],
      schema:
        EntitySchema.widget(
          Keyword.merge(
            [template_children: [type: :any, required: false, default: []]],
            extra_schema
          )
        )
    }
  end

  defp select_entities(entities, names) do
    Enum.filter(entities, &(&1.name in names))
  end
end
