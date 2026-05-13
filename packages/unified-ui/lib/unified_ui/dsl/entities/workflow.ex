defmodule UnifiedUi.Dsl.Entities.Workflow do
  @moduledoc false

  alias UnifiedUi.Dsl.EntitySchema
  alias UnifiedUi.Dsl.Node

  @spec entities() :: [Spark.Dsl.Entity.t()]
  def entities do
    [
      leaf(:pipeline_stepper_horizontal,
        steps: [type: :any, required: true],
        active_item: [type: :atom, required: false],
        status: [type: :atom, required: false],
        summary: [type: :string, required: false]
      ),
      leaf(:segmented_progress_bar,
        segments: [type: :any, required: true],
        current: [type: :integer, required: false],
        maximum: [type: :integer, required: false, default: 100],
        label: [type: :string, required: false],
        summary: [type: :string, required: false]
      ),
      leaf(:workflow_stage_list_vertical,
        stages: [type: :any, required: true],
        active_item: [type: :atom, required: false],
        status: [type: :atom, required: false],
        summary: [type: :string, required: false]
      ),
      leaf(:meter_thin,
        current: [type: :integer, required: true],
        minimum: [type: :integer, required: false, default: 0],
        maximum: [type: :integer, required: false, default: 100],
        label: [type: :string, required: false],
        severity: [type: :atom, required: false],
        summary: [type: :string, required: false]
      ),
      leaf(:slide_over_panel,
        title: [type: :string, required: false],
        placement: [
          type: {:in, [:start, :end, :top, :bottom]},
          required: false,
          default: :end
        ],
        visible?: [type: :boolean, required: false, default: false],
        modal?: [type: :boolean, required: false, default: true],
        summary: [type: :string, required: false]
      ),
      leaf(:event_callout,
        title: [type: :string, required: false],
        message: [type: :string, required: true],
        severity: [type: :atom, required: false, default: :info],
        timestamp: [type: :string, required: false],
        summary: [type: :string, required: false]
      ),
      leaf(:redline_inline,
        before_text: [type: :string, required: true],
        after_text: [type: :string, required: true],
        label: [type: :string, required: false],
        summary: [type: :string, required: false]
      ),
      leaf(:code_block_syntax_highlighted,
        code: [type: :string, required: true],
        language: [type: :atom, required: false],
        label: [type: :string, required: false],
        wrap?: [type: :boolean, required: false, default: false],
        summary: [type: :string, required: false]
      ),
      leaf(:chat_composer,
        placeholder: [type: :string, required: false],
        submit_intent: [type: :atom, required: false],
        actions: [type: :keyword_list, required: false, default: []],
        multiline?: [type: :boolean, required: false, default: true],
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
      auto_set_fields: [family: :workflow, kind: name],
      schema: EntitySchema.widget(extra_schema)
    }
  end
end
