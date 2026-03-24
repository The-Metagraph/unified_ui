defmodule DesktopUi.WidgetsTest do
  use ExUnit.Case, async: true

  test "builder helpers keep the widget contract renderer-native" do
    screen =
      DesktopUi.Widgets.window("workspace", "Workspace", [
        DesktopUi.Widgets.column("body", [
          DesktopUi.Widgets.text("title", "Workspace"),
          DesktopUi.Widgets.text_input("name", placeholder: "Name", binding: :workspace_name),
          DesktopUi.Widgets.button("save", "Save", intent: :save_workspace)
        ])
      ])

    assert screen.kind == :window
    assert screen.family == :window
    assert screen.attributes.window_title == "Workspace"
    assert Enum.any?(screen.children, &(&1.kind == :column))
    assert DesktopUi.Widgets.registration_model().direct_native_only
    refute DesktopUi.Widgets.registration_model().canonical_branching
    assert :value in DesktopUi.Widget.contract().bindings
    assert :window_title in DesktopUi.Widget.contract().attributes
  end
end
