defmodule UnifiedUi.Dsl.Entities.DialogFeedbackTest do
  @moduledoc """
  Tests for dialog and feedback DSL entities.
  """

  use ExUnit.Case, async: true

  alias UnifiedIUR.Widgets
  alias UnifiedUi.Dsl.Entities.DialogFeedback, as: DialogEntities

  describe "dialog_button_entity/0" do
    test "returns a valid Spark.Dsl.Entity" do
      entity = DialogEntities.dialog_button_entity()

      assert %Spark.Dsl.Entity{name: :dialog_button} = entity
      assert entity.target == Widgets.DialogButton
    end

    test "has required label and optional action/role" do
      entity = DialogEntities.dialog_button_entity()

      label_schema = Keyword.get(entity.schema, :label)
      assert Keyword.get(label_schema, :required) == true

      action_schema = Keyword.get(entity.schema, :action)
      assert Keyword.get(action_schema, :required) == false

      role_schema = Keyword.get(entity.schema, :role)
      assert Keyword.get(role_schema, :default) == :default
    end
  end

  describe "dialog_entity/0" do
    test "returns a valid Spark.Dsl.Entity" do
      entity = DialogEntities.dialog_entity()

      assert %Spark.Dsl.Entity{name: :dialog} = entity
      assert entity.target == Widgets.Dialog
    end

    test "has required args and nested content/buttons" do
      entity = DialogEntities.dialog_entity()

      id_schema = Keyword.get(entity.schema, :id)
      title_schema = Keyword.get(entity.schema, :title)
      content_schema = Keyword.get(entity.schema, :content)

      assert Keyword.get(id_schema, :required) == true
      assert Keyword.get(title_schema, :required) == true
      assert Keyword.get(content_schema, :required) == true

      assert Keyword.has_key?(entity.entities, :content)
      assert Keyword.has_key?(entity.entities, :buttons)
      assert is_list(Keyword.get(entity.entities, :buttons))
    end

    test "has close and size options" do
      entity = DialogEntities.dialog_entity()

      on_close_schema = Keyword.get(entity.schema, :on_close)
      width_schema = Keyword.get(entity.schema, :width)
      height_schema = Keyword.get(entity.schema, :height)
      closable_schema = Keyword.get(entity.schema, :closable)

      assert on_close_schema != nil
      assert Keyword.get(width_schema, :type) == :integer
      assert Keyword.get(height_schema, :type) == :integer
      assert Keyword.get(closable_schema, :default) == true
    end
  end

  describe "alert_dialog_entity/0" do
    test "returns a valid Spark.Dsl.Entity" do
      entity = DialogEntities.alert_dialog_entity()

      assert %Spark.Dsl.Entity{name: :alert_dialog} = entity
      assert entity.target == Widgets.AlertDialog
    end

    test "has severity and confirm/cancel handlers" do
      entity = DialogEntities.alert_dialog_entity()

      severity_schema = Keyword.get(entity.schema, :severity)
      assert Keyword.get(severity_schema, :default) == :info
      assert {:one_of, severities} = Keyword.get(severity_schema, :type)
      assert :warning in severities
      assert :error in severities

      confirm_schema = Keyword.get(entity.schema, :on_confirm)
      cancel_schema = Keyword.get(entity.schema, :on_cancel)

      assert confirm_schema != nil
      assert cancel_schema != nil
    end
  end

  describe "toast_entity/0" do
    test "returns a valid Spark.Dsl.Entity" do
      entity = DialogEntities.toast_entity()

      assert %Spark.Dsl.Entity{name: :toast} = entity
      assert entity.target == Widgets.Toast
    end

    test "has duration and dismiss handler" do
      entity = DialogEntities.toast_entity()

      duration_schema = Keyword.get(entity.schema, :duration)
      dismiss_schema = Keyword.get(entity.schema, :on_dismiss)

      assert Keyword.get(duration_schema, :default) == 3000
      assert dismiss_schema != nil
    end
  end

  describe "IUR dialog structs" do
    test "dialog struct supports content and buttons" do
      dialog = %Widgets.Dialog{
        id: :settings_dialog,
        title: "Settings",
        content: %Widgets.Text{content: "Body"},
        buttons: [%Widgets.DialogButton{label: "Close", action: :close_settings}],
        on_close: :close_settings,
        width: 60,
        height: 20
      }

      assert dialog.id == :settings_dialog
      assert dialog.on_close == :close_settings
      assert length(dialog.buttons) == 1
    end

    test "alert dialog and toast defaults are available" do
      alert = %Widgets.AlertDialog{}
      toast = %Widgets.Toast{}

      assert alert.severity == :info
      assert alert.modal == true
      assert toast.severity == :info
      assert toast.duration == 3000
    end
  end
end
