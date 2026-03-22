defmodule TerminalUi.NativeWidgetsTest do
  use ExUnit.Case, async: true

  test "widget constructors build direct-use widget contracts deterministically" do
    title = TerminalUi.Widgets.text("workspace-title", "Workspace", fg: :cyan, attrs: [:bold])

    save =
      TerminalUi.Widgets.button("save-button", "Save",
        on_press: %{intent: :save_workspace},
        semantic_role: :primary_action
      )

    layout = TerminalUi.Widgets.column("workspace-layout", [title, save], gap: :md)

    assert title.kind == :text
    assert title.family == :content
    assert title.styles.fg == :cyan
    assert save.events == %{keypress: %{intent: :save_workspace}}
    assert save.styles.semantic_role == :primary_action
    assert layout.kind == :column
    assert Enum.map(layout.slot_children.default, & &1.id) == ["workspace-title", "save-button"]
  end

  test "widget catalog exposes the phase one families, kinds, and contract" do
    assert TerminalUi.Widgets.modules() == [TerminalUi.Widgets, TerminalUi.Widget]
    assert :feedback in TerminalUi.Widgets.families()
    assert :dialog in TerminalUi.Widgets.kinds()
    assert TerminalUi.Widgets.validation_state().widget_contract == :ready

    assert TerminalUi.Widget.contract().metadata == [
             :label,
             :description,
             :role,
             :variant,
             :native_surface,
             :degradation
           ]
  end

  test "reference helpers and package info expose runtime, capability, and widget boundaries" do
    reference = TerminalUi.reference()

    widget =
      TerminalUi.Widgets.text_input("query-input", value: "status:ok", placeholder: "Query")

    assert TerminalUi.Backend.RawMode in reference.backend.modules
    assert TerminalUi.Runtime.EventLoop in reference.runtime.modules
    assert :renderer_entrypoint_placeholder in reference.runtime.capabilities
    assert :rich_terminal in reference.capabilities.profiles
    assert "guides/runtime_backbone.md" in reference.documentation.guides
    assert TerminalUi.Info.widget_summary(widget).event_keys == []
  end
end
