defmodule WebUi.NativeWidgetsTest do
  use ExUnit.Case, async: true

  alias WebUi.Widgets.{Forms, Foundational, Input, Layout, Navigation}

  test "foundational constructors build direct-use widget contracts" do
    text = Foundational.text("Workspace", id: "workspace-title")
    button = Foundational.button("Save", id: "save-button", click: "save_workspace")

    content =
      Foundational.content([text, button],
        id: "workspace-header",
        presentation: :hero,
        style_hooks: [:tone, :variant]
      )

    assert text.kind == :text
    assert text.family == :foundational
    assert button.events == %{click: "save_workspace"}
    assert content.props.presentation == :hero
    assert content.slots.default == [text, button]
    assert content.style_hooks == [:tone, :variant]
  end

  test "input, navigation, layout, and grouped form widgets compose deterministically" do
    input =
      Input.text_input(
        id: "name-input",
        name: :name,
        value: "Pascal",
        placeholder: "Name",
        change: "rename_profile"
      )

    field =
      Forms.field(input,
        id: "name-field",
        name: :name,
        label: "Display Name",
        help: "Shown in navigation"
      )

    group = Forms.field_group([field], id: "identity-group", legend: "Identity")
    form = Forms.form_builder([group], id: "profile-form", submit: "save_profile")

    tabs =
      Navigation.tabs(
        [
          [id: :overview, label: "Overview", active?: true],
          [id: :activity, label: "Activity"]
        ],
        id: "profile-tabs",
        active_item: :overview,
        navigation: "switch_tab"
      )

    layout = Layout.column([form, tabs], id: "profile-layout", gap: :lg)

    assert input.events == %{change: "rename_profile"}

    assert [%WebUi.Widget{kind: :label}, %WebUi.Widget{kind: :text}] = [
             hd(field.slots.label),
             hd(field.slots.help)
           ]

    assert field.slots.control == [input]
    assert form.events == %{submit: "save_profile"}
    assert tabs.props.active_item == :overview
    assert tabs.events == %{navigation: "switch_tab"}
    assert layout.kind == :column
    assert Enum.map(layout.slots.default, & &1.id) == ["profile-form", "profile-tabs"]
  end

  test "widgets catalog exposes foundational families and public constructor modules" do
    modules = WebUi.Widgets.modules()

    assert Foundational in modules
    assert Input in modules
    assert Navigation in modules
    assert Layout in modules
    assert Forms in modules

    assert :content in WebUi.Widgets.kinds()
    assert :form_builder in WebUi.Widgets.kinds()
    assert :navigation in WebUi.Widgets.families()
    assert WebUi.Widgets.validation_state().form_composition == :ready
  end
end
