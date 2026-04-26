defmodule TerminalUi.CanonicalNavigationTerminalRuntimeIntegrationTest do
  use ExUnit.Case, async: true

  alias TerminalUi.Runtime
  alias UnifiedIUR.Interactions.Transport, as: BoundaryTransport

  test "raw terminal runtime realizes canonical screen, modal, and history transitions through one shared navigation state" do
    navigate_fixture = BoundaryTransport.boundary_fixture!("screen_transition--settings_profile")
    modal_fixture = BoundaryTransport.boundary_fixture!("modal_transition--settings_dialog")
    history_fixture = BoundaryTransport.boundary_fixture!("history_transition--back")

    assert {:ok, runtime_state} = Runtime.mount_native_screen(base_screen(), backend_mode: :raw)

    assert Runtime.navigation_summary(runtime_state) == %{
             active_screen_id: "workspace",
             history_depth: 0,
             forward_depth: 0,
             modal_depth: 0,
             current_modal: nil,
             last_transition: nil,
             last_realization: %{
               action: :mount,
               backend_mode: :raw,
               transition_mode: :screen_replacement,
               degraded?: false,
               fallback: nil,
               intent_preserved?: true
             }
           }

    assert {:ok, after_navigate, navigate_route} =
             Runtime.dispatch_native_event(
               runtime_state,
               family: :navigation,
               intent: navigate_fixture.interaction.intent,
               widget_id: "settings-link",
               target: navigate_fixture.descriptor.target,
               payload: navigate_fixture.signal_data
             )

    assert navigate_route.route == :canonical_boundary
    assert after_navigate.screen_id == "settings"
    assert Runtime.navigation_summary(after_navigate).history_depth == 1
    assert Runtime.navigation_summary(after_navigate).last_realization.transition_mode ==
             :screen_replacement

    assert {:ok, with_modal, modal_route} =
             Runtime.dispatch_native_event(
               after_navigate,
               family: :navigation,
               intent: modal_fixture.interaction.intent,
               widget_id: "settings-dialog-button",
               target: modal_fixture.descriptor.target,
               payload: modal_fixture.signal_data
             )

    assert modal_route.translation.target == modal_fixture.descriptor.target

    assert Runtime.navigation_summary(with_modal).current_modal == %{
             modal: :settings_dialog,
             params: %{mode: :advanced},
             realization: :inline_overlay
           }

    assert {:ok, after_back, back_route} =
             Runtime.dispatch_native_event(
               with_modal,
               family: :navigation,
               intent: history_fixture.interaction.intent,
               widget_id: "back-button",
               target: history_fixture.descriptor.target,
               payload: history_fixture.signal_data
             )

    assert back_route.translation.target == history_fixture.descriptor.target
    assert after_back.screen_id == "workspace"
    assert Runtime.navigation_summary(after_back).forward_depth == 1
    assert Runtime.navigation_summary(after_back).last_realization.transition_mode ==
             :bounded_history
  end

  test "tty backend degrades modal transitions into focused-surface realizations without changing canonical intent" do
    modal_fixture = BoundaryTransport.boundary_fixture!("modal_transition--settings_dialog")

    assert {:ok, runtime_state} = Runtime.mount_native_screen(base_screen(), backend_mode: :tty)

    assert {:ok, with_modal, _route} =
             Runtime.dispatch_native_event(
               runtime_state,
               family: :navigation,
               intent: modal_fixture.interaction.intent,
               widget_id: "settings-dialog-button",
               target: modal_fixture.descriptor.target,
               payload: modal_fixture.signal_data
             )

    assert Runtime.navigation_summary(with_modal).current_modal == %{
             modal: :settings_dialog,
             params: %{mode: :advanced},
             realization: :focused_surface
           }

    assert Runtime.navigation_summary(with_modal).last_realization == %{
             action: :open_modal,
             backend_mode: :tty,
             transition_mode: :focused_surface,
             degraded?: true,
             fallback: :focused_surface,
             intent_preserved?: true
           }
  end

  test "terminal runtime rejects leaked route syntax and invalid modal transitions deterministically" do
    assert {:ok, runtime_state} = Runtime.mount_native_screen(base_screen(), backend_mode: :raw)

    assert {:error, %Runtime.Error{reason: :host_route_navigation_syntax}} =
             Runtime.dispatch_native_event(
               runtime_state,
               family: :navigation,
               intent: :open_settings_screen,
               widget_id: "settings-link",
               target: %{
                 navigation: %{action: :navigate_to, screen: :settings, route: "/settings"}
               }
             )

    assert {:error, %Runtime.Error{reason: :invalid_modal_transition}} =
             Runtime.dispatch_native_event(
               runtime_state,
               family: :navigation,
               intent: :close_settings_modal,
               widget_id: "close-settings-dialog",
               target: %{navigation: %{action: :close_modal, modal: :settings_dialog}}
             )
  end

  defp base_screen do
    %{
      id: "workspace",
      title: "Workspace",
      root:
        TerminalUi.Widgets.column("workspace-root", [
          TerminalUi.Widgets.text("workspace-title", "Workspace"),
          TerminalUi.Widgets.button("settings-link", "Settings", navigate_to: :settings)
        ])
    }
  end
end
