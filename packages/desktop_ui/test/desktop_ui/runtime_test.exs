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
    assert state.realization.validation_state == :foundational_ready
    assert state.event_loop.poller.source == :sdl_event_queue
    assert state.event_loop.input_dispatch.boundary_mode == :placeholder_ready
    assert state.focus.current == "workspace-window"
    assert state.focus.order == ["workspace-window", "save-button"]
    assert state.realization.binding_index == %{}
    assert state.realization.event_targets == %{"save-button" => [:click]}
    assert state.realization.diagnostics.layout_guards == :ready
    assert state.screen.composition.root_kind == :window
    assert state.screen.composition.shared_realization
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

  test "realization indexes bindings, focus order, and event targets for foundational screens" do
    screen = %{
      id: "workspace",
      title: "Workspace",
      root:
        DesktopUi.Widgets.window("workspace-window", "Workspace", [
          DesktopUi.Widgets.column("workspace-column", [
            DesktopUi.Widgets.text_input("query-input",
              value: "status:ok",
              binding: :query,
              on_submit: %{intent: :run_query}
            ),
            DesktopUi.Widgets.checkbox("alerts-checkbox", "Alerts",
              checked: true,
              binding: :alerts_enabled
            ),
            DesktopUi.Widgets.tabs(
              "workspace-tabs",
              [%{id: :overview, label: "Overview"}, %{id: :activity, label: "Activity"}],
              current: :overview,
              binding: :active_section
            )
          ])
        ])
    }

    assert {:ok, state} = Runtime.mount_native_screen(screen, platform_target: :linux)

    assert state.screen.bindings.names == [:active_section, :alerts_enabled, :query]

    assert state.focus.order == [
             "workspace-window",
             "query-input",
             "alerts-checkbox",
             "workspace-tabs"
           ]

    assert Map.has_key?(state.realization.binding_index, :query)
    assert Map.has_key?(state.realization.binding_index, :alerts_enabled)
    assert Map.has_key?(state.realization.event_targets, "query-input")
    assert Map.has_key?(state.realization.event_targets, "workspace-tabs")
    assert Enum.any?(state.realization.cell_surface, &(&1.kind == :checkbox))
  end
end
