defmodule UnifiedUi.Dsl.Entities.WidgetComponents do
  @moduledoc false

  alias UnifiedUi.Dsl.Entities.Foundational
  alias UnifiedUi.Dsl.EntitySchema
  alias UnifiedUi.Dsl.Node

  @content_identity_family :content_identity_and_disclosure

  @spec entities() :: [Spark.Dsl.Entity.t()]
  def entities do
    [
      leaf(:inline_rich_text_heading,
        level: [type: {:in, [:h1, :h2, :h3, :h4, :h5, :h6]}, required: false, default: :h1],
        segments: [type: :any, required: true],
        summary: [type: :string, required: false]
      ),
      disclosure_entity(),
      leaf(:kicker,
        items: [type: :any, required: true],
        separator: [type: :string, required: false, default: "·"],
        summary: [type: :string, required: false]
      ),
      leaf(:avatar,
        initials: [type: :string, required: false],
        image_source: [type: :string, required: false],
        size: [type: {:in, [:small, :medium, :large]}, required: false, default: :medium],
        shape: [type: {:in, [:round, :square]}, required: false, default: :round],
        summary: [type: :string, required: false]
      ),
      leaf(:presence_dot,
        state: [type: :atom, required: false, default: :quiet],
        size: [type: {:in, [:small, :medium, :large]}, required: false, default: :medium],
        summary: [type: :string, required: false]
      )
    ]
  end

  @spec content_identity_kinds() :: [atom()]
  def content_identity_kinds do
    Enum.map(entities(), & &1.name)
  end

  @spec kinds() :: [atom()]
  def kinds do
    content_identity_kinds()
  end

  defp leaf(name, extra_schema) do
    %Spark.Dsl.Entity{
      name: name,
      target: Node,
      args: [:id],
      identifier: :id,
      auto_set_fields: [family: @content_identity_family, kind: name],
      schema: EntitySchema.widget(extra_schema)
    }
  end

  defp disclosure_entity do
    %Spark.Dsl.Entity{
      name: :disclosure,
      target: Node,
      args: [:id],
      identifier: :id,
      recursive_as: :children,
      auto_set_fields: [family: @content_identity_family, kind: :disclosure],
      entities: [children: Foundational.entities()],
      schema:
        EntitySchema.widget(
          summary: [type: :string, required: true],
          open?: [type: :boolean, required: false, default: false]
        )
    }
  end
end
