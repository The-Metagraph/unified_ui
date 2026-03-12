defmodule UnifiedUi.Dsl.Entities.InputWidgetsTest do
  @moduledoc """
  Tests for advanced input widget DSL entities.
  """

  use ExUnit.Case, async: true

  alias UnifiedIUR.Widgets
  alias UnifiedUi.Dsl.Entities.InputWidgets

  describe "pick_list_option_entity/0" do
    test "returns a valid Spark.Dsl.Entity" do
      entity = InputWidgets.pick_list_option_entity()

      assert %Spark.Dsl.Entity{name: :pick_list_option} = entity
      assert entity.target == Widgets.PickListOption
      assert entity.args == [:value, :label]
    end

    test "has required value and label" do
      entity = InputWidgets.pick_list_option_entity()

      value_schema = Keyword.get(entity.schema, :value)
      label_schema = Keyword.get(entity.schema, :label)

      assert Keyword.get(value_schema, :required) == true
      assert Keyword.get(label_schema, :required) == true
    end
  end

  describe "pick_list_entity/0" do
    test "returns a valid Spark.Dsl.Entity" do
      entity = InputWidgets.pick_list_entity()

      assert %Spark.Dsl.Entity{name: :pick_list} = entity
      assert entity.target == Widgets.PickList
      assert entity.args == [:id, :options]
    end

    test "has select options and nested pick_list_option entities" do
      entity = InputWidgets.pick_list_entity()

      selected_schema = Keyword.get(entity.schema, :selected)
      searchable_schema = Keyword.get(entity.schema, :searchable)
      on_select_schema = Keyword.get(entity.schema, :on_select)
      allow_clear_schema = Keyword.get(entity.schema, :allow_clear)

      assert selected_schema != nil
      assert Keyword.get(searchable_schema, :default) == false
      assert on_select_schema != nil
      assert Keyword.get(allow_clear_schema, :default) == false

      options_entities = Keyword.get(entity.entities, :opts)
      assert [%Spark.Dsl.Entity{name: :pick_list_option}] = options_entities
    end
  end

  describe "form_field_entity/0" do
    test "returns a valid Spark.Dsl.Entity" do
      entity = InputWidgets.form_field_entity()

      assert %Spark.Dsl.Entity{name: :form_field} = entity
      assert entity.target == Widgets.FormField
      assert entity.args == [:name, :type]
    end

    test "restricts field type to supported values" do
      entity = InputWidgets.form_field_entity()
      type_schema = Keyword.get(entity.schema, :type)

      assert {:one_of, field_types} = Keyword.get(type_schema, :type)
      assert :text in field_types
      assert :password in field_types
      assert :email in field_types
      assert :number in field_types
      assert :select in field_types
      assert :checkbox in field_types
    end
  end

  describe "form_builder_entity/0" do
    test "returns a valid Spark.Dsl.Entity" do
      entity = InputWidgets.form_builder_entity()

      assert %Spark.Dsl.Entity{name: :form_builder} = entity
      assert entity.target == Widgets.FormBuilder
      assert entity.args == [:id, :fields]
    end

    test "has submit options and nested form_field entities" do
      entity = InputWidgets.form_builder_entity()

      action_schema = Keyword.get(entity.schema, :action)
      on_submit_schema = Keyword.get(entity.schema, :on_submit)
      submit_label_schema = Keyword.get(entity.schema, :submit_label)

      assert action_schema != nil
      assert on_submit_schema != nil
      assert Keyword.get(submit_label_schema, :default) == "Submit"

      fields_entities = Keyword.get(entity.entities, :flds)
      assert [%Spark.Dsl.Entity{name: :form_field}] = fields_entities
    end
  end

  describe "IUR input widget structs" do
    test "pick_list and form_builder structs expose defaults" do
      pick_list = %Widgets.PickList{}
      form_builder = %Widgets.FormBuilder{}

      assert pick_list.searchable == false
      assert pick_list.allow_clear == false
      assert pick_list.visible == true

      assert form_builder.submit_label == "Submit"
      assert form_builder.visible == true
    end

    test "element metadata includes interactive handlers" do
      pick_list = %Widgets.PickList{id: :country, on_select: :country_selected}
      form_builder = %Widgets.FormBuilder{id: :profile, on_submit: :save_profile}

      pick_list_meta = UnifiedIUR.Element.metadata(pick_list)
      form_builder_meta = UnifiedIUR.Element.metadata(form_builder)

      assert pick_list_meta.type == :pick_list
      assert pick_list_meta.on_select == :country_selected

      assert form_builder_meta.type == :form_builder
      assert form_builder_meta.on_submit == :save_profile
    end
  end
end
