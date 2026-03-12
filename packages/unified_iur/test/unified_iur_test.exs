defmodule UnifiedIURTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Element
  alias UnifiedIUR.Layouts
  alias UnifiedIUR.Widgets

  describe "dialog and feedback widgets" do
    test "dialog metadata and children include content and buttons" do
      dialog = %Widgets.Dialog{
        id: :confirm_delete,
        title: "Delete item",
        content: %Widgets.Text{content: "This cannot be undone"},
        buttons: [
          %Widgets.DialogButton{label: "Cancel", action: :cancel},
          %Widgets.DialogButton{label: "Delete", action: :confirm, role: :destructive}
        ],
        on_close: :close_dialog
      }

      assert [%Widgets.Text{}, %Widgets.DialogButton{}, %Widgets.DialogButton{}] =
               Element.children(dialog)

      metadata = Element.metadata(dialog)
      assert metadata.type == :dialog
      assert metadata.id == :confirm_delete
      assert metadata.on_close == :close_dialog
      assert metadata.modal == true
      assert metadata.closable == true
    end

    test "alert dialog and toast have expected defaults" do
      alert = %Widgets.AlertDialog{}
      toast = %Widgets.Toast{}

      assert alert.severity == :info
      assert alert.modal == true
      assert alert.closable == true
      assert toast.severity == :info
      assert toast.duration == 3000
      assert toast.visible == true
    end
  end

  describe "input widgets" do
    test "pick list children and metadata preserve interactive fields" do
      pick_list = %Widgets.PickList{
        id: :country,
        options: [
          %Widgets.PickListOption{value: "us", label: "United States"},
          %Widgets.PickListOption{value: "ca", label: "Canada"}
        ],
        selected: "ca",
        searchable: true,
        on_select: :country_selected,
        allow_clear: true
      }

      assert [%Widgets.PickListOption{}, %Widgets.PickListOption{}] = Element.children(pick_list)

      metadata = Element.metadata(pick_list)
      assert metadata.type == :pick_list
      assert metadata.id == :country
      assert metadata.selected == "ca"
      assert metadata.searchable == true
      assert metadata.on_select == :country_selected
      assert metadata.allow_clear == true
    end

    test "form builder children and metadata include field descriptors" do
      form_builder = %Widgets.FormBuilder{
        id: :profile_form,
        fields: [
          %Widgets.FormField{
            name: :email,
            type: :email,
            required: true,
            placeholder: "user@example.com"
          },
          %Widgets.FormField{name: :newsletter, type: :checkbox, default: true}
        ],
        action: :save_profile,
        on_submit: :profile_saved,
        submit_label: "Save Profile"
      }

      assert [%Widgets.FormField{}, %Widgets.FormField{}] = Element.children(form_builder)

      metadata = Element.metadata(form_builder)
      assert metadata.type == :form_builder
      assert metadata.id == :profile_form
      assert metadata.action == :save_profile
      assert metadata.on_submit == :profile_saved
      assert metadata.submit_label == "Save Profile"
    end
  end

  describe "layout child compatibility" do
    test "layouts accept new widget types in children" do
      ui = %Layouts.VBox{
        children: [
          %Widgets.Dialog{id: :d1, title: "Dialog"},
          %Widgets.PickList{id: :country}
        ]
      }

      assert length(ui.children) == 2
      assert [%Widgets.Dialog{}, %Widgets.PickList{}] = Element.children(ui)
    end
  end
end
