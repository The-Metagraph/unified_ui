defmodule WebUi.RuntimeTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Element
  alias WebUi.FrontendRuntime
  alias WebUi.Runtime

  test "runtime mounts native screens and hydrates the shared frontend model" do
    screen = WebUi.Examples.native_counter_screen()

    assert {:ok, runtime_state} =
             Runtime.mount_native_screen(screen, runtime_id: "native-runtime")

    assert runtime_state.source_kind == :native
    assert runtime_state.boundary_mode == :native_local

    assert {:ok, frontend_model} = Runtime.hydrate_frontend(runtime_state)
    assert frontend_model.runtime_id == "native-runtime"
    assert frontend_model.title == "Native Counter"
    assert frontend_model.boundary_mode == :native_local
  end

  test "runtime mounts canonical iur screens through the same runtime boundary" do
    element =
      Element.new(:widget, :button,
        id: :canonical_button,
        attributes: %{label: "Save"}
      )

    assert {:ok, runtime_state} =
             Runtime.mount_iur_screen(element, runtime_id: "canonical-runtime")

    assert runtime_state.source_kind == :canonical
    assert runtime_state.boundary_mode == :canonical_boundary
    assert runtime_state.rendered_tree.kind == :button

    assert {:ok, frontend_model} = Runtime.hydrate_frontend(runtime_state)
    assert frontend_model.runtime_id == "canonical-runtime"
    assert frontend_model.source_kind == :canonical
  end

  test "runtime handles local and boundary events deterministically" do
    assert {:ok, runtime_state} =
             Runtime.mount_native_screen(WebUi.Examples.native_counter_screen())

    assert {:ok, local_state} =
             Runtime.handle_native_event(runtime_state,
               family: :click,
               intent: :increment,
               widget_id: :increment,
               boundary: :local
             )

    assert Enum.at(local_state.event_log, -1).mode == :local

    assert {:ok, boundary_state} =
             Runtime.handle_native_event(local_state,
               family: :click,
               intent: :submit,
               widget_id: :increment,
               boundary: :boundary,
               payload: %{step: 1},
               screen: "native-counter"
             )

    assert Enum.at(boundary_state.event_log, -1).mode == :boundary
    assert boundary_state.last_boundary_signal.type == "web_ui.click.submit"
  end

  test "runtime infers canonical-boundary translation for canonical command events" do
    element =
      Element.new(:widget, :command_palette,
        id: :ops_command_palette,
        attributes: %{commands: [%{id: :deploy, label: "Deploy"}]}
      )

    assert {:ok, runtime_state} =
             Runtime.mount_iur_screen(element, runtime_id: "canonical-runtime")

    assert {:ok, next_state} =
             Runtime.handle_native_event(runtime_state,
               family: :command,
               intent: :run,
               widget_id: :ops_command_palette,
               payload: %{command: :deploy}
             )

    assert Enum.at(next_state.event_log, -1).mode == :boundary
    assert next_state.last_boundary_signal.type == "web_ui.command.run"
  end

  test "frontend runtime returns deterministic hydration diagnostics" do
    assert {:error, %FrontendRuntime.Error{reason: :invalid_hydration_payload}} =
             FrontendRuntime.hydrate(%{runtime_id: "missing-fields"})
  end
end
