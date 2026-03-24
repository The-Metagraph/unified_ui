defmodule DesktopUi.RuntimeTest do
  use ExUnit.Case, async: true

  alias DesktopUi.Runtime
  alias DesktopUi.Runtime.Error

  test "mounts a minimal native screen through the shared runtime backbone" do
    root =
      DesktopUi.Widgets.window("workspace-window", "Workspace", [
        DesktopUi.Widgets.text("workspace-title", "Workspace"),
        DesktopUi.Widgets.button("save-button", "Save", intent: :save_workspace)
      ])

    screen = %{id: "workspace", title: "Workspace", root: root}

    assert {:ok, state} = Runtime.mount_native_screen(screen, platform_target: :linux)
    assert state.runtime_id == "desktop-ui:workspace"
    assert state.screen_id == "workspace"
    assert state.source_kind == :native
    assert state.platform_target == :linux
    assert state.platform_adapter.target == :linux
    assert state.windows.primary == "window:workspace"
    assert state.redraw.status == :idle
    assert state.realization.validation_state == :phase_one_realization_ready
    assert state.event_loop.poller.source == :sdl_event_queue
    assert state.event_loop.input_dispatch.boundary_mode == :placeholder_ready
    assert state.focus.current == "workspace-window"
  end

  test "invalid screen input fails with deterministic diagnostics" do
    assert {:error, %Error{} = missing_root_error} =
             Runtime.mount_native_screen(%{id: "broken", title: "Broken"})

    assert missing_root_error.reason == :invalid_screen
    assert :root in missing_root_error.details.missing_keys

    assert {:error, %Error{} = invalid_root_error} =
             Runtime.mount_native_screen(%{id: "broken", title: "Broken", root: %{label: "oops"}})

    assert invalid_root_error.reason == :invalid_screen_root
    assert invalid_root_error.phase == :runtime_boot

    assert {:error, %Error{} = invalid_platform_error} =
             Runtime.mount_native_screen(
               %{
                 id: "broken",
                 title: "Broken",
                 root: %DesktopUi.Widget{id: "root", kind: :window}
               },
               platform_target: :android
             )

    assert invalid_platform_error.reason == :unsupported_platform_target
  end
end
