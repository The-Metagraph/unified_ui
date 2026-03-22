defmodule TerminalUi.LayoutLayerRuntimeTest do
  use ExUnit.Case, async: true

  alias TerminalUi.Runtime

  test "advanced display systems realize layered and viewport state through the shared runtime" do
    screen = %{
      id: "advanced-workspace",
      title: "Advanced Workspace",
      root:
        TerminalUi.Layer.overlay(
          "workspace-overlay",
          TerminalUi.Layout.split_pane(
            "workspace-split",
            TerminalUi.Layout.viewport(
              "workspace-viewport",
              TerminalUi.Widgets.column("viewport-content", [
                TerminalUi.Widgets.text("viewport-title", "Events"),
                TerminalUi.Widgets.list(
                  "event-list",
                  [%{id: :one, label: "Deploy"}, %{id: :two, label: "Restart"}],
                  binding: :selected_event
                )
              ]),
              offset_binding: :event_offset
            ),
            TerminalUi.Layout.canvas_surface(
              "workspace-canvas",
              [
                TerminalUi.Layout.positioned(
                  "canvas-node",
                  TerminalUi.Widgets.status("node-status", "Healthy", intent: :success),
                  x: 4,
                  y: 2
                )
              ],
              width: 40,
              height: 12
            )
          ),
          [
            TerminalUi.Widgets.dialog(
              "health-dialog",
              [
                TerminalUi.Widgets.text("dialog-title", "Cluster Health"),
                TerminalUi.Widgets.button("close-dialog", "Close",
                  on_press: %{intent: :close_health_dialog}
                )
              ],
              open: true
            )
          ]
        )
    }

    assert {:ok, runtime_state} = Runtime.mount_native_screen(screen, backend_mode: :raw)

    assert runtime_state.screen.layout.composition == :advanced_shared_runtime
    assert runtime_state.screen.metadata.layered_runtime
    refute runtime_state.screen.metadata.advanced_display
    assert runtime_state.validation_state == :advanced_runtime_ready
    assert runtime_state.realization.validation_state == :advanced_ready
    assert runtime_state.realization.diagnostics.capability_profile == :rich_terminal

    assert Enum.any?(runtime_state.realization.layers, fn layer ->
             layer.widget_id == "workspace-overlay" and layer.role == :overlay
           end)

    assert Enum.any?(runtime_state.realization.layers, fn layer ->
             layer.widget_id == "health-dialog" and layer.role == :dialog
           end)

    assert Enum.any?(runtime_state.realization.viewport_regions, fn region ->
             region.widget_id == "workspace-viewport" and region.viewport
           end)

    assert Enum.any?(runtime_state.realization.viewport_regions, fn region ->
             region.widget_id == "workspace-canvas" and region.positioned
           end)

    assert runtime_state.realization.binding_index[:event_offset] == [
             %{widget_id: "workspace-viewport", slot: :current}
           ]

    assert runtime_state.realization.binding_index[:selected_event] == [
             %{widget_id: "event-list", slot: :current}
           ]
  end

  test "tty capability fallbacks stay explicit for overlays scrolling and positioned content" do
    screen = %{
      id: "tty-advanced",
      title: "TTY Advanced",
      root:
        TerminalUi.Layer.overlay(
          "tty-overlay",
          TerminalUi.Layout.scroll_region(
            "tty-scroll",
            TerminalUi.Layout.canvas_surface(
              "tty-canvas",
              [
                TerminalUi.Layer.absolute(
                  "tty-absolute",
                  TerminalUi.Widgets.text("absolute-text", "Pinned"),
                  x: 10,
                  y: 1
                )
              ]
            )
          ),
          [
            TerminalUi.Layer.context_menu(
              "tty-menu",
              TerminalUi.Widgets.button("menu-anchor", "Menu"),
              [%{id: :retry, label: "Retry"}]
            )
          ]
        )
    }

    assert {:ok, runtime_state} = Runtime.mount_native_screen(screen, backend_mode: :tty)

    assert runtime_state.validation_state == :advanced_runtime_ready
    assert runtime_state.realization.validation_state == :advanced_ready
    assert runtime_state.realization.diagnostics.capability_profile == :fallback_terminal
    assert runtime_state.realization.diagnostics.capability_fallbacks.overlay == :inline_overlay
    assert runtime_state.realization.diagnostics.capability_fallbacks.scroll == :paged_scroll
    assert :context_menu_presentation in runtime_state.realization.diagnostics.allowed_variation

    assert Enum.any?(runtime_state.realization.fallbacks, fn fallback ->
             fallback.widget_id == "tty-overlay" and fallback.fallback == :inline_overlay
           end)

    assert Enum.any?(runtime_state.realization.fallbacks, fn fallback ->
             fallback.widget_id == "tty-scroll" and fallback.fallback == :paged_scroll
           end)

    assert Enum.any?(runtime_state.realization.fallbacks, fn fallback ->
             fallback.widget_id == "tty-canvas" and fallback.fallback == :ascii_canvas
           end)

    assert Enum.any?(runtime_state.realization.fallbacks, fn fallback ->
             fallback.widget_id == "tty-absolute" and
               fallback.fallback == :linearized_positioning
           end)

    assert Enum.any?(runtime_state.realization.fallbacks, fn fallback ->
             fallback.widget_id == "tty-menu" and fallback.fallback == :inline_menu_selection
           end)
  end

  test "package-facing layout and layer helpers stay visible in reference and summary surfaces" do
    reference = TerminalUi.reference()
    summary = TerminalUi.info()

    assert reference.layout.kinds == [
             :viewport,
             :split_pane,
             :scroll_region,
             :canvas_surface,
             :positioned
           ]

    assert reference.layer.kinds == [:overlay, :popover, :context_menu, :absolute]
    assert reference.capabilities.diagnostics.profile == :rich_terminal
    assert reference.capabilities.diagnostics.fallback_modes == %{}

    assert summary.layout.kinds == reference.layout.kinds
    assert summary.layer.kinds == reference.layer.kinds
    assert summary.capabilities.diagnostics.profile == :rich_terminal
  end
end
