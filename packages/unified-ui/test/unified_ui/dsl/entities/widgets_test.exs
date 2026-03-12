defmodule UnifiedUi.Dsl.Entities.WidgetsTest do
  @moduledoc """
  Tests for the widget DSL entities.

  These tests verify that:
  - All widget entities are defined correctly
  - Widget entities create the correct target structs
  - Widget options are validated properly
  - Required arguments are enforced
  """

  use ExUnit.Case, async: true

  alias UnifiedUi.Dsl.Entities.Widgets, as: WidgetEntities
  alias UnifiedIUR.Widgets

  describe "button_entity/0" do
    test "returns a valid Spark.Dsl.Entity" do
      entity = WidgetEntities.button_entity()

      assert %Spark.Dsl.Entity{name: :button} = entity
      assert entity.target == Widgets.Button
    end

    test "has correct schema with required label" do
      entity = WidgetEntities.button_entity()

      label_schema = Keyword.get(entity.schema, :label)
      assert label_schema != nil
      assert Keyword.get(label_schema, :required) == true
    end

    test "has optional id option" do
      entity = WidgetEntities.button_entity()

      id_schema = Keyword.get(entity.schema, :id)
      assert id_schema != nil
      assert Keyword.get(id_schema, :required) == false
    end

    test "has optional on_click option" do
      entity = WidgetEntities.button_entity()

      on_click_schema = Keyword.get(entity.schema, :on_click)
      assert on_click_schema != nil
      assert Keyword.get(on_click_schema, :required) == false
    end

    test "has optional disabled option with default" do
      entity = WidgetEntities.button_entity()

      disabled_schema = Keyword.get(entity.schema, :disabled)
      assert disabled_schema != nil
      assert Keyword.get(disabled_schema, :default) == false
    end

    test "has optional style option" do
      entity = WidgetEntities.button_entity()

      style_schema = Keyword.get(entity.schema, :style)
      assert style_schema != nil
      assert Keyword.get(style_schema, :type) == :keyword_list
    end

    test "has optional visible option with default" do
      entity = WidgetEntities.button_entity()

      visible_schema = Keyword.get(entity.schema, :visible)
      assert visible_schema != nil
      assert Keyword.get(visible_schema, :default) == true
    end

    test "supports state references for label, disabled, and visible" do
      entity = WidgetEntities.button_entity()

      assert {:or, [:string, {:tuple, [:atom, :atom]}]} ==
               entity.schema |> Keyword.fetch!(:label) |> Keyword.fetch!(:type)

      assert {:or, [:boolean, {:tuple, [:atom, :atom]}]} ==
               entity.schema |> Keyword.fetch!(:disabled) |> Keyword.fetch!(:type)

      assert {:or, [:boolean, {:tuple, [:atom, :atom]}]} ==
               entity.schema |> Keyword.fetch!(:visible) |> Keyword.fetch!(:type)
    end
  end

  describe "text_entity/0" do
    test "returns a valid Spark.Dsl.Entity" do
      entity = WidgetEntities.text_entity()

      assert %Spark.Dsl.Entity{name: :text} = entity
      assert entity.target == Widgets.Text
    end

    test "has correct schema with required content" do
      entity = WidgetEntities.text_entity()

      content_schema = Keyword.get(entity.schema, :content)
      assert content_schema != nil
      assert Keyword.get(content_schema, :required) == true
    end

    test "has optional id option" do
      entity = WidgetEntities.text_entity()

      id_schema = Keyword.get(entity.schema, :id)
      assert id_schema != nil
      assert Keyword.get(id_schema, :required) == false
    end

    test "has optional style option" do
      entity = WidgetEntities.text_entity()

      style_schema = Keyword.get(entity.schema, :style)
      assert style_schema != nil
      assert Keyword.get(style_schema, :type) == :keyword_list
    end

    test "has optional visible option with default" do
      entity = WidgetEntities.text_entity()

      visible_schema = Keyword.get(entity.schema, :visible)
      assert visible_schema != nil
      assert Keyword.get(visible_schema, :default) == true
    end

    test "supports state references for content and visible" do
      entity = WidgetEntities.text_entity()

      assert {:or, [:string, {:tuple, [:atom, :atom]}]} ==
               entity.schema |> Keyword.fetch!(:content) |> Keyword.fetch!(:type)

      assert {:or, [:boolean, {:tuple, [:atom, :atom]}]} ==
               entity.schema |> Keyword.fetch!(:visible) |> Keyword.fetch!(:type)
    end
  end

  describe "label_entity/0" do
    test "returns a valid Spark.Dsl.Entity" do
      entity = WidgetEntities.label_entity()

      assert %Spark.Dsl.Entity{name: :label} = entity
      assert entity.target == Widgets.Label
    end

    test "has correct schema with required for and text" do
      entity = WidgetEntities.label_entity()

      for_schema = Keyword.get(entity.schema, :for)
      assert for_schema != nil
      assert Keyword.get(for_schema, :required) == true

      text_schema = Keyword.get(entity.schema, :text)
      assert text_schema != nil
      assert Keyword.get(text_schema, :required) == true
    end

    test "has optional id option" do
      entity = WidgetEntities.label_entity()

      id_schema = Keyword.get(entity.schema, :id)
      assert id_schema != nil
      assert Keyword.get(id_schema, :required) == false
    end

    test "has optional style option" do
      entity = WidgetEntities.label_entity()

      style_schema = Keyword.get(entity.schema, :style)
      assert style_schema != nil
      assert Keyword.get(style_schema, :type) == :keyword_list
    end

    test "has optional visible option with default" do
      entity = WidgetEntities.label_entity()

      visible_schema = Keyword.get(entity.schema, :visible)
      assert visible_schema != nil
      assert Keyword.get(visible_schema, :default) == true
    end

    test "supports state references for text and visible" do
      entity = WidgetEntities.label_entity()

      assert {:or, [:string, {:tuple, [:atom, :atom]}]} ==
               entity.schema |> Keyword.fetch!(:text) |> Keyword.fetch!(:type)

      assert {:or, [:boolean, {:tuple, [:atom, :atom]}]} ==
               entity.schema |> Keyword.fetch!(:visible) |> Keyword.fetch!(:type)
    end
  end

  describe "text_input_entity/0" do
    test "returns a valid Spark.Dsl.Entity" do
      entity = WidgetEntities.text_input_entity()

      assert %Spark.Dsl.Entity{name: :text_input} = entity
      assert entity.target == Widgets.TextInput
    end

    test "has correct schema with required id" do
      entity = WidgetEntities.text_input_entity()

      id_schema = Keyword.get(entity.schema, :id)
      assert id_schema != nil
      assert Keyword.get(id_schema, :required) == true
    end

    test "has optional value option" do
      entity = WidgetEntities.text_input_entity()

      value_schema = Keyword.get(entity.schema, :value)
      assert value_schema != nil
      assert Keyword.get(value_schema, :required) == false
    end

    test "has optional placeholder option" do
      entity = WidgetEntities.text_input_entity()

      placeholder_schema = Keyword.get(entity.schema, :placeholder)
      assert placeholder_schema != nil
      assert Keyword.get(placeholder_schema, :required) == false
    end

    test "has type option with correct values" do
      entity = WidgetEntities.text_input_entity()

      type_schema = Keyword.get(entity.schema, :type)
      assert type_schema != nil
      assert Keyword.get(type_schema, :default) == :text

      assert {:one_of, [:text, :password, :email, :number, :tel]} =
               Keyword.get(type_schema, :type)
    end

    test "has optional on_change option" do
      entity = WidgetEntities.text_input_entity()

      on_change_schema = Keyword.get(entity.schema, :on_change)
      assert on_change_schema != nil
      assert Keyword.get(on_change_schema, :required) == false
    end

    test "has optional on_submit option" do
      entity = WidgetEntities.text_input_entity()

      on_submit_schema = Keyword.get(entity.schema, :on_submit)
      assert on_submit_schema != nil
      assert Keyword.get(on_submit_schema, :required) == false
    end

    test "has optional disabled option with default" do
      entity = WidgetEntities.text_input_entity()

      disabled_schema = Keyword.get(entity.schema, :disabled)
      assert disabled_schema != nil
      assert Keyword.get(disabled_schema, :default) == false
    end

    test "has optional style option" do
      entity = WidgetEntities.text_input_entity()

      style_schema = Keyword.get(entity.schema, :style)
      assert style_schema != nil
      assert Keyword.get(style_schema, :type) == :keyword_list
    end

    test "has optional visible option with default" do
      entity = WidgetEntities.text_input_entity()

      visible_schema = Keyword.get(entity.schema, :visible)
      assert visible_schema != nil
      assert Keyword.get(visible_schema, :default) == true
    end

    test "supports state references for value, disabled, and visible" do
      entity = WidgetEntities.text_input_entity()

      assert {:or, [:string, {:tuple, [:atom, :atom]}]} ==
               entity.schema |> Keyword.fetch!(:value) |> Keyword.fetch!(:type)

      assert {:or, [:boolean, {:tuple, [:atom, :atom]}]} ==
               entity.schema |> Keyword.fetch!(:disabled) |> Keyword.fetch!(:type)

      assert {:or, [:boolean, {:tuple, [:atom, :atom]}]} ==
               entity.schema |> Keyword.fetch!(:visible) |> Keyword.fetch!(:type)
    end
  end

  describe "IUR Widget Structs" do
    test "Button struct can be created with all fields" do
      button = %Widgets.Button{
        label: "Submit",
        id: :submit_btn,
        on_click: :submit,
        disabled: false,
        visible: true
      }

      assert button.label == "Submit"
      assert button.id == :submit_btn
      assert button.on_click == :submit
      assert button.disabled == false
      assert button.visible == true
    end

    test "Button struct has correct defaults" do
      button = %Widgets.Button{}

      assert button.disabled == false
      assert button.visible == true
      assert button.label == nil
      assert button.on_click == nil
      assert button.id == nil
    end

    test "Text struct can be created with all fields" do
      text = %Widgets.Text{
        content: "Hello",
        id: :greeting,
        visible: true
      }

      assert text.content == "Hello"
      assert text.id == :greeting
      assert text.visible == true
    end

    test "Text struct has correct defaults" do
      text = %Widgets.Text{}

      assert text.content == nil
      assert text.id == nil
      assert text.visible == true
      assert text.style == nil
    end

    test "Label struct can be created with all fields" do
      label = %Widgets.Label{
        for: :email_input,
        text: "Email:",
        id: :email_label
      }

      assert label.for == :email_input
      assert label.text == "Email:"
      assert label.id == :email_label
      assert label.visible == true
    end

    test "Label struct has correct defaults" do
      label = %Widgets.Label{for: :test, text: "Test"}

      assert label.for == :test
      assert label.text == "Test"
      assert label.id == nil
      assert label.style == nil
      assert label.visible == true
    end

    test "TextInput struct can be created with all fields" do
      input = %Widgets.TextInput{
        id: :email,
        value: "test@example.com",
        placeholder: "user@example.com",
        type: :email,
        on_change: :email_changed,
        on_submit: :form_submit,
        disabled: false,
        visible: true
      }

      assert input.id == :email
      assert input.value == "test@example.com"
      assert input.placeholder == "user@example.com"
      assert input.type == :email
      assert input.on_change == :email_changed
      assert input.on_submit == :form_submit
      assert input.disabled == false
      assert input.visible == true
    end

    test "TextInput struct has correct defaults" do
      input = %Widgets.TextInput{id: :test}

      assert input.id == :test
      assert input.value == nil
      assert input.placeholder == nil
      assert input.type == nil
      assert input.on_change == nil
      assert input.on_submit == nil
      assert input.disabled == nil
      assert input.style == nil
      assert input.visible == true
    end

    test "TextInput struct accepts different input types" do
      for type <- [:text, :password, :email, :number, :tel] do
        input = %Widgets.TextInput{id: :test, type: type}
        assert input.type == type
      end
    end
  end

  describe "Entity Descriptions" do
    test "button_entity has a description" do
      entity = WidgetEntities.button_entity()
      assert is_binary(entity.describe)
      assert String.length(entity.describe) > 0
    end

    test "text_entity has a description" do
      entity = WidgetEntities.text_entity()
      assert is_binary(entity.describe)
      assert String.length(entity.describe) > 0
    end

    test "label_entity has a description" do
      entity = WidgetEntities.label_entity()
      assert is_binary(entity.describe)
      assert String.length(entity.describe) > 0
    end

    test "text_input_entity has a description" do
      entity = WidgetEntities.text_input_entity()
      assert is_binary(entity.describe)
      assert String.length(entity.describe) > 0
    end
  end

  describe "Entity Args" do
    test "button_entity has label as required arg" do
      entity = WidgetEntities.button_entity()
      assert entity.args == [:label]
    end

    test "text_entity has content as required arg" do
      entity = WidgetEntities.text_entity()
      assert entity.args == [:content]
    end

    test "label_entity has for and text as required args" do
      entity = WidgetEntities.label_entity()
      assert entity.args == [:for, :text]
    end

    test "text_input_entity has id as required arg" do
      entity = WidgetEntities.text_input_entity()
      assert entity.args == [:id]
    end
  end
end
