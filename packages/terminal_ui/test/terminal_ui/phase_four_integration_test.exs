defmodule TerminalUi.PhaseFourIntegrationTest do
  use ExUnit.Case, async: true

  alias TerminalUi.Runtime

  test "boundary-crossing interactions emit and consume canonical signals with cloud event semantics" do
    native_screen = TerminalUi.Examples.native_transport_screen()
    canonical_screen = TerminalUi.Examples.canonical_transport_screen()

    assert {:ok, native_state} = Runtime.mount_native_screen(native_screen, backend_mode: :raw)
    assert {:ok, canonical_state} = Runtime.mount_iur_screen(canonical_screen, backend_mode: :raw)

    assert {:ok, native_boundary_state, native_route} =
             Runtime.dispatch_native_event(native_state,
               input_family: :shortcut,
               shortcut: "ctrl-r",
               widget_id: "command-palette",
               intent: :reload_workspace
             )

    assert native_route.route == :canonical_boundary
    assert native_route.family == :command
    assert native_route.translation.signal.type == "terminal_ui.command.reload_workspace"
    assert native_route.translation.cloud_event.specversion == "1.0.2"

    assert native_route.translation.cloud_event.subject ==
             "native/transport-native/command-palette"

    assert native_boundary_state.event_loop.boundary_events == 1

    assert {:ok, inbound_state, inbound_route} =
             Runtime.handle_boundary_signal(
               native_boundary_state,
               native_route.translation.signal
             )

    assert inbound_route.route == :canonical_boundary
    assert inbound_route.family == :command
    assert inbound_route.input_family == :shortcut
    assert inbound_state.event_loop.boundary_events == 2

    assert {:ok, canonical_boundary_state, canonical_route} =
             Runtime.dispatch_widget_interaction(
               canonical_state,
               "command-palette",
               :command,
               intent: :reload_workspace,
               runtime_event: "command:reload_workspace",
               payload: %{command: :reload}
             )

    assert canonical_route.route == :canonical_boundary
    assert canonical_route.family == native_route.family
    assert canonical_route.translation.signal.type == native_route.translation.signal.type
    assert canonical_boundary_state.event_loop.boundary_events == 1
  end

  test "invalid canonical event payloads and leaked backend-local envelopes fail deterministically" do
    native_screen = TerminalUi.Examples.native_transport_screen()
    canonical_screen = TerminalUi.Examples.canonical_transport_screen()

    assert {:ok, native_state} = Runtime.mount_native_screen(native_screen, backend_mode: :raw)
    assert {:ok, canonical_state} = Runtime.mount_iur_screen(canonical_screen, backend_mode: :raw)

    assert {:error, %TerminalUi.Transport.Error{reason: :invalid_payload_mapping}} =
             Runtime.dispatch_widget_interaction(
               canonical_state,
               "command-palette",
               :command,
               intent: :reload_workspace,
               payload: "not-a-map"
             )

    assert {:error, %TerminalUi.Transport.Error{reason: :leaked_backend_detail}} =
             Runtime.dispatch_native_event(native_state,
               input_family: :key,
               key: "enter",
               widget_id: "command-input",
               intent: :submit_command,
               escape_sequence: "\\e[13~"
             )
  end

  test "local native handling and normalized input profiles stay bounded inside the shared runtime" do
    native_screen = TerminalUi.Examples.native_transport_screen()

    assert {:ok, native_raw} = Runtime.mount_native_screen(native_screen, backend_mode: :raw)
    assert {:ok, native_tty} = Runtime.mount_native_screen(native_screen, backend_mode: :tty)

    assert {:ok, focused_state, local_route} =
             Runtime.dispatch_native_event(native_raw,
               input_family: :focus,
               boundary: :local,
               focus_target: "scope-menu",
               widget_id: "scope-menu",
               intent: :focus_scope_menu
             )

    assert local_route.route == :local_runtime
    assert local_route.family == :focus
    assert local_route.translation.signal == nil
    assert focused_state.focus.current == "scope-menu"
    assert focused_state.event_loop.local_events == 1

    assert {:ok, resized_state, resize_route} =
             Runtime.dispatch_native_event(native_tty,
               input_family: :resize,
               width: 120,
               height: 40,
               boundary: :local
             )

    assert resize_route.route == :local_runtime
    assert resize_route.family == :navigation
    assert resize_route.local_handling == :paged_resize
    assert resized_state.event_loop.local_events == 1

    comparison = TerminalUi.Examples.normalized_input_comparison()
    reference = TerminalUi.reference()
    summary = TerminalUi.info()

    assert comparison.parity.shortcut_family_match?
    assert comparison.parity.resize_family_match?
    assert comparison.parity.boundary_local_split_visible?
    assert comparison.parity.tty_capability_handling_explicit?
    assert :native_transport_review in reference.examples.native_ids
    assert :canonical_transport_review in reference.examples.canonical_ids
    assert :transport_flow_review in reference.examples.comparison_ids
    assert :normalized_input_profiles in reference.examples.comparison_ids
    assert :canonical_boundary in reference.transport.modes
    assert :transport_review in summary.examples.workflows
    assert :transport in summary.examples.categories
  end
end
