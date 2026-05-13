defmodule UnifiedUi.Dsl.Entities.Semantic do
  @moduledoc false

  alias UnifiedUi.Dsl.EntitySchema
  alias UnifiedUi.Dsl.Node

  @spec entities() :: [Spark.Dsl.Entity.t()]
  def entities do
    [
      leaf(:disclosure,
        label: [type: :string, required: true],
        open?: [type: :boolean, required: false, default: false],
        content_label: [type: :string, required: false],
        summary: [type: :string, required: false]
      ),
      leaf(:kicker,
        value: [type: :string, required: true],
        icon: [type: :atom, required: false],
        role: [type: :atom, required: false, default: :eyebrow],
        summary: [type: :string, required: false]
      ),
      leaf(:avatar,
        label: [type: :string, required: true],
        initials: [type: :string, required: false],
        avatar_source: [type: :string, required: false],
        status: [type: :atom, required: false],
        summary: [type: :string, required: false]
      ),
      leaf(:presence_dot,
        status: [type: :atom, required: true],
        label: [type: :string, required: false],
        pulse?: [type: :boolean, required: false, default: false],
        summary: [type: :string, required: false]
      ),
      leaf(:segmented_button_group,
        items: [type: :keyword_list, required: true],
        active_item: [type: :atom, required: false],
        selection_mode: [
          type: {:in, [:single, :multiple, :none]},
          required: false,
          default: :single
        ],
        orientation: [
          type: {:in, [:horizontal, :vertical]},
          required: false,
          default: :horizontal
        ],
        summary: [type: :string, required: false]
      ),
      leaf(:list_item_multi_column,
        columns: [type: :any, required: true],
        label: [type: :string, required: false],
        value: [type: :any, required: false],
        status: [type: :atom, required: false],
        summary: [type: :string, required: false]
      ),
      leaf(:artifact_row,
        artifact: [type: :any, required: true],
        title: [type: :string, required: true],
        status: [type: :atom, required: false],
        timestamp: [type: :string, required: false],
        action_intent: [type: :atom, required: false],
        summary: [type: :string, required: false]
      ),
      leaf(:sticky_header,
        title: [type: :string, required: true],
        stuck?: [type: :boolean, required: false, default: false],
        elevation: [type: :atom, required: false],
        summary: [type: :string, required: false]
      )
    ]
  end

  @spec kinds() :: [atom()]
  def kinds do
    Enum.map(entities(), & &1.name)
  end

  defp leaf(name, extra_schema) do
    %Spark.Dsl.Entity{
      name: name,
      target: Node,
      args: [:id],
      identifier: :id,
      auto_set_fields: [family: :semantic, kind: name],
      schema: EntitySchema.widget(extra_schema)
    }
  end
end
