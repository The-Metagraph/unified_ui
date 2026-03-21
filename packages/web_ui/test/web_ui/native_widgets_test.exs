defmodule WebUi.NativeWidgetsTest do
  use ExUnit.Case, async: true

  test "foundational constructors build direct-use widget contracts" do
    text = WebUi.Widgets.text("workspace-title", "Workspace")
    button = WebUi.Widgets.button("save-button", "Save", on_click: %{intent: :save_workspace})

    content =
      WebUi.Widgets.content("workspace-header", [text, button],
        presentation: :hero,
        style_hooks: [:tone, :variant]
      )

    assert text.kind == :text
    assert text.family == :content
    assert button.events == %{click: %{intent: :save_workspace}}
    assert content.attributes.presentation == :hero
    assert content.slot_children.default == [text, button]
    assert content.styles.hooks == [:tone, :variant]
  end

  test "input, navigation, layout, and grouped form widgets compose deterministically" do
    input =
      WebUi.Widgets.text_input("name-input",
        name: :name,
        value: "Pascal",
        placeholder: "Name",
        on_change: %{intent: :rename_profile}
      )

    field =
      WebUi.Widgets.field("name-field", input,
        name: :name,
        label: "Display Name",
        help: "Shown in navigation"
      )

    group = WebUi.Widgets.field_group("identity-group", [field], legend: "Identity")
    form = WebUi.Widgets.form("profile-form", [group], on_submit: %{intent: :save_profile})

    tabs =
      WebUi.Widgets.tabs(
        "profile-tabs",
        [
          [id: :overview, label: "Overview", active: true],
          [id: :activity, label: "Activity"]
        ],
        active_item: :overview,
        on_navigate: %{intent: :switch_tab}
      )

    layout = WebUi.Widgets.column("profile-layout", [form, tabs], gap: :lg)

    assert input.events == %{change: %{intent: :rename_profile}}
    assert hd(field.slot_children.label).kind == :label
    assert hd(field.slot_children.help).kind == :text
    assert field.slot_children.control == [input]
    assert form.events == %{submit: %{intent: :save_profile}}
    assert tabs.attributes.active_item == :overview
    assert tabs.events == %{navigation: %{intent: :switch_tab}}
    assert layout.kind == :column
    assert Enum.map(layout.slot_children.default, & &1.id) == ["profile-form", "profile-tabs"]
  end

  test "widgets catalog exposes foundational families and constructor modules" do
    modules = WebUi.Widgets.modules()

    assert WebUi.Widgets.Foundational in modules
    assert WebUi.Widgets.Input in modules
    assert WebUi.Widgets.Navigation in modules
    assert WebUi.Widgets.Layout in modules
    assert WebUi.Widgets.Forms in modules

    assert :content in WebUi.Widgets.kinds()
    assert :form in WebUi.Widgets.kinds()
    assert :navigation in WebUi.Widgets.families()
    assert WebUi.Widgets.validation_state().form_composition == :ready
  end
end
