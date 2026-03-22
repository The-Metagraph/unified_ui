defmodule TerminalUi.RuntimeRealizationTest do
  use ExUnit.Case, async: true

  alias TerminalUi.Runtime

  test "shared runtime realizes foundational layout, focus, binding, and event targeting" do
    screen = %{
      id: "workspace",
      title: "Workspace",
      root:
        TerminalUi.Widgets.column("workspace-root", [
          TerminalUi.Widgets.text("title", "Workspace"),
          TerminalUi.Widgets.text_input("query", binding: :query, value: "status:ok"),
          TerminalUi.Widgets.button("save", "Save", on_press: %{intent: :save_workspace}),
          TerminalUi.Widgets.list("results", [%{id: :a, label: "Alpha"}],
            binding: :selected_result,
            on_select: %{intent: :select_result}
          )
        ])
    }

    assert {:ok, runtime_state} = Runtime.mount_native_screen(screen, backend_mode: :raw)

    assert runtime_state.screen.bindings == %{count: 2, names: [:query, :selected_result]}
    assert runtime_state.realization.focus_order == ["query", "save", "results"]
    assert runtime_state.realization.current_focus == "query"

    assert runtime_state.realization.binding_index[:query] == [
             %{widget_id: "query", slot: :value}
           ]

    assert runtime_state.realization.binding_index[:selected_result] == [
             %{widget_id: "results", slot: :current}
           ]

    assert runtime_state.realization.event_targets["save"] == [:keypress]
    assert runtime_state.realization.event_targets["results"] == [:select]
  end

  test "unsupported foundational widgets fail with deterministic realization diagnostics" do
    unsupported_root =
      TerminalUi.Widget.new(:unknown_widget,
        id: "unsupported-table",
        metadata: %{label: "Unsupported Table", native_surface: true}
      )

    screen = %{id: "unsupported", title: "Unsupported", root: unsupported_root}

    assert {:error, %TerminalUi.Runtime.Error{} = error} =
             Runtime.mount_native_screen(screen, backend_mode: :raw)

    assert error.reason == :unsupported_foundational_widget
    assert error.phase == :realization
    assert error.details == %{kind: :unknown_widget, widget_id: "unsupported-table"}
  end
end
