defmodule UnifiedUi.Dsl.Entities.WidgetComponents do
  @moduledoc false

  alias UnifiedUi.Dsl.Entities.Foundational
  alias UnifiedUi.Dsl.EntitySchema
  alias UnifiedUi.Dsl.Node

  @content_identity_family :content_identity_and_disclosure
  @form_control_family :form_control_and_composer

  @spec entities() :: [Spark.Dsl.Entity.t()]
  def entities do
    content_identity_entities() ++ form_control_entities()
  end

  @spec content_identity_entities() :: [Spark.Dsl.Entity.t()]
  def content_identity_entities do
    [
      leaf(
        :inline_rich_text_heading,
        @content_identity_family,
        level: [type: {:in, [:h1, :h2, :h3, :h4, :h5, :h6]}, required: false, default: :h1],
        segments: [type: :any, required: true],
        summary: [type: :string, required: false]
      ),
      disclosure_entity(),
      leaf(
        :kicker,
        @content_identity_family,
        items: [type: :any, required: true],
        separator: [type: :string, required: false, default: "·"],
        summary: [type: :string, required: false]
      ),
      leaf(
        :avatar,
        @content_identity_family,
        initials: [type: :string, required: false],
        image_source: [type: :string, required: false],
        size: [type: {:in, [:small, :medium, :large]}, required: false, default: :medium],
        shape: [type: {:in, [:round, :square]}, required: false, default: :round],
        summary: [type: :string, required: false]
      ),
      leaf(
        :presence_dot,
        @content_identity_family,
        state: [type: :atom, required: false, default: :quiet],
        size: [type: {:in, [:small, :medium, :large]}, required: false, default: :medium],
        summary: [type: :string, required: false]
      )
    ]
  end

  @spec form_control_entities() :: [Spark.Dsl.Entity.t()]
  def form_control_entities do
    [
      leaf(
        :segmented_button_group,
        @form_control_family,
        options: [type: :any, required: true],
        active_value: [type: :any, required: false],
        selection_intent: [type: :atom, required: false],
        summary: [type: :string, required: false]
      ),
      leaf(
        :runtime_form_shell,
        @form_control_family,
        fields: [type: :any, required: true],
        submit_label: [type: :string, required: false],
        submit_intent: [type: :atom, required: false],
        change_intent: [type: :atom, required: false],
        validation_state: [type: :atom, required: false],
        summary: [type: :string, required: false]
      ),
      chat_composer_entity()
    ]
  end

  @spec content_identity_kinds() :: [atom()]
  def content_identity_kinds do
    Enum.map(content_identity_entities(), & &1.name)
  end

  @spec form_control_kinds() :: [atom()]
  def form_control_kinds do
    Enum.map(form_control_entities(), & &1.name)
  end

  @spec kinds() :: [atom()]
  def kinds do
    content_identity_kinds() ++ form_control_kinds()
  end

  defp leaf(name, family, extra_schema) do
    %Spark.Dsl.Entity{
      name: name,
      target: Node,
      args: [:id],
      identifier: :id,
      auto_set_fields: [family: family, kind: name],
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

  defp chat_composer_entity do
    %Spark.Dsl.Entity{
      name: :chat_composer,
      target: Node,
      args: [:id],
      identifier: :id,
      recursive_as: :children,
      auto_set_fields: [family: @form_control_family, kind: :chat_composer],
      entities: [children: Foundational.entities()],
      schema:
        EntitySchema.widget(
          name: [type: :atom, required: false],
          value: [type: :string, required: false],
          placeholder: [type: :string, required: false],
          rows: [type: :integer, required: false, default: 3],
          send_label: [type: :string, required: false, default: "Send"],
          send_intent: [type: :atom, required: true],
          change_intent: [type: :atom, required: false],
          summary: [type: :string, required: false]
        )
    }
  end
end
