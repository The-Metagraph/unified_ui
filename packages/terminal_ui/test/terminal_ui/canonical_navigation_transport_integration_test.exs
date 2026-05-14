defmodule TerminalUi.CanonicalNavigationTransportIntegrationTest do
  use ExUnit.Case, async: true

  alias Jido.Signal
  alias TerminalUi.Runtime
  alias TerminalUi.Transport
  alias UnifiedIUR.Interactions.Transport, as: BoundaryTransport

  test "consumes shared history-transition fixtures without fake screen identifiers" do
    fixture = BoundaryTransport.boundary_fixture!("history_transition--back")

    assert {:ok, translation} =
             Transport.from_interaction(
               fixture.interaction,
               backend_mode: :raw,
               input_family: :key,
               widget_id: "history-button",
               runtime_id: "terminal-ui:workspace",
               screen: "workspace",
               payload: fixture.signal_data
             )

    assert :ok = BoundaryTransport.validate_boundary_fixture(fixture)
    assert translation.target == fixture.descriptor.target
    assert %Signal{} = translation.signal
    assert translation.signal.data == fixture.signal_data
    assert translation.signal.extensions.terminal_ui_target == fixture.descriptor.target
    refute Map.has_key?(translation.target.navigation, :screen)
    refute Map.has_key?(translation.target.navigation, :modal)
  end

  test "preserves modal stack meaning with terminal fallback metadata" do
    first_modal = BoundaryTransport.boundary_fixture!("modal_transition--settings_dialog")
    second_modal = BoundaryTransport.boundary_fixture!("modal_stack--open_confirm_dialog")
    close_top = BoundaryTransport.boundary_fixture!("modal_stack--close_top")
    close_named = BoundaryTransport.boundary_fixture!("modal_stack--close_named_settings")

    assert {:ok, state} = Runtime.mount_native_screen(screen(), backend_mode: :tty)

    assert {:ok, with_first_modal, _route_result} =
             Runtime.handle_boundary_signal(state, boundary_signal(first_modal))

    assert {:ok, with_second_modal, _route_result} =
             Runtime.handle_boundary_signal(with_first_modal, boundary_signal(second_modal))

    assert with_second_modal.navigation.modals == [
             %{
               modal: :settings_dialog,
               params: %{mode: :advanced},
               metadata: %{surface: :workspace},
               degradation: %{presentation: :inline_overlay, bounded?: true}
             },
             %{
               modal: :settings_confirm_dialog,
               params: %{from: :settings_dialog},
               metadata: %{previous_modal: :settings_dialog},
               degradation: %{presentation: :inline_overlay, bounded?: true}
             }
           ]

    assert with_second_modal.navigation.current_modal.modal == :settings_confirm_dialog
    assert with_second_modal.navigation.last_transition.modal_stack.stack_effect == :push_modal

    snapshot = TerminalUi.Inspection.runtime_snapshot(with_second_modal)
    assert snapshot.navigation.current_modal.modal == :settings_confirm_dialog

    assert {:ok, after_named_close, _route_result} =
             Runtime.handle_boundary_signal(with_second_modal, boundary_signal(close_named))

    assert Enum.map(after_named_close.navigation.modals, & &1.modal) == [
             :settings_confirm_dialog
           ]

    assert {:ok, after_top_close, _route_result} =
             Runtime.handle_boundary_signal(after_named_close, boundary_signal(close_top))

    assert after_top_close.navigation.modals == []
    assert after_top_close.navigation.current_modal == nil
  end

  test "reports missing modal diagnostics without losing canonical transition meaning" do
    close_named = BoundaryTransport.boundary_fixture!("modal_stack--close_named_settings")

    assert {:ok, state} = Runtime.mount_native_screen(screen(), backend_mode: :raw)

    assert {:ok, updated_state, _route_result} =
             Runtime.handle_boundary_signal(state, boundary_signal(close_named))

    assert updated_state.navigation.diagnostics == [
             %{reason: :missing_modal, modal: :settings_dialog, action: :close_modal}
           ]

    assert updated_state.navigation.last_transition.modal == :settings_dialog
  end

  defp boundary_signal(fixture) do
    assert {:ok, translation} =
             Transport.from_interaction(
               fixture.interaction,
               backend_mode: :tty,
               input_family: :key,
               widget_id: fixture.interaction.source.element_id,
               runtime_id: "terminal-ui:workspace",
               screen: "workspace",
               payload: fixture.signal_data
             )

    translation.signal
  end

  defp screen do
    %{
      id: "workspace",
      title: "Workspace",
      root:
        TerminalUi.Widgets.column("workspace-root", [
          TerminalUi.Widgets.text("title", "Workspace")
        ])
    }
  end
end
