defmodule TerminalUi.RuntimeEventRouterTest do
  use ExUnit.Case, async: true

  alias Jido.Signal
  alias TerminalUi.Runtime

  test "native shortcut interactions route through canonical boundary translation" do
    screen = %{
      id: "workspace",
      title: "Workspace",
      root:
        TerminalUi.Widgets.column("workspace-root", [
          TerminalUi.Widgets.button("save-button", "Save", on_press: %{intent: :save_workspace})
        ])
    }

    assert {:ok, state} = Runtime.mount_native_screen(screen, backend_mode: :raw)

    assert {:ok, updated_state, route_result} =
             Runtime.dispatch_native_event(state,
               input_family: :shortcut,
               shortcut: "ctrl-s",
               intent: :save_workspace,
               widget_id: "save-button"
             )

    assert route_result.route == :canonical_boundary
    assert route_result.family == :command
    assert match?(%Signal{}, route_result.translation.signal)
    assert updated_state.event_loop.boundary_events == 1
    assert List.last(updated_state.event_log).signal_type == "terminal_ui.command.save_workspace"
  end

  test "local focus events stay inside the runtime and update focus state" do
    screen = %{
      id: "workspace",
      title: "Workspace",
      root:
        TerminalUi.Widgets.column("workspace-root", [
          TerminalUi.Widgets.text_input("query", value: "status:ok"),
          TerminalUi.Widgets.button("save-button", "Save")
        ])
    }

    assert {:ok, state} = Runtime.mount_native_screen(screen, backend_mode: :tty)
    assert state.focus.current == "query"

    assert {:ok, updated_state, route_result} =
             Runtime.dispatch_native_event(state,
               input_family: :focus,
               boundary: :local,
               focus_target: "save-button",
               widget_id: "save-button",
               intent: :focus_save_button
             )

    assert route_result.route == :local_runtime
    assert route_result.local_handling == :focus_shift
    assert updated_state.focus.current == "save-button"
    assert updated_state.event_loop.local_events == 1
    assert List.last(updated_state.event_log).signal_type == nil
  end

  test "canonical-rendered screens share the same routing path for boundary events" do
    element = TerminalUi.Examples.canonical_advanced_operations_screen()

    assert {:ok, state} = Runtime.mount_iur_screen(element, backend_mode: :raw)

    assert {:ok, updated_state, route_result} =
             Runtime.dispatch_widget_interaction(
               state,
               "ops-palette",
               :command,
               intent: :run_command,
               runtime_event: "command:run_command",
               payload: %{query: "re"}
             )

    assert route_result.route == :canonical_boundary
    assert route_result.translation.source_kind == :canonical
    assert updated_state.event_loop.boundary_events == 1
    assert List.last(updated_state.event_log).widget_id == "ops-palette"
  end

  test "invalid routing decisions fail deterministically" do
    screen = %{
      id: "workspace",
      title: "Workspace",
      root: TerminalUi.Widgets.text("title", "Workspace")
    }

    assert {:ok, state} = Runtime.mount_native_screen(screen, backend_mode: :raw)

    assert {:error, %TerminalUi.Runtime.Error{reason: :missing_boundary_signal}} =
             TerminalUi.Runtime.EventRouter.route(state, %{
               boundary: :boundary,
               family: :command,
               runtime_event: "command:save",
               signal: nil
             })
  end
end
