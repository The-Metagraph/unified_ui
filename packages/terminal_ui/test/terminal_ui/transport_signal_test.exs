defmodule TerminalUi.TransportSignalTest do
  use ExUnit.Case, async: true

  alias Jido.Signal
  alias TerminalUi.Transport
  alias UnifiedIUR.Interaction

  test "native terminal input normalizes before canonical boundary translation" do
    assert {:ok, normalized} =
             Transport.normalize_native_event(
               backend_mode: :raw,
               input_family: :shortcut,
               shortcut: "ctrl-r",
               intent: :reload_workspace,
               widget_id: "ops-palette",
               runtime_id: "terminal-ui:ops",
               screen: "operations"
             )

    assert normalized.input_family == :shortcut
    assert normalized.family == :command
    assert normalized.boundary == :boundary
    assert normalized.normalized_input.shortcut == "ctrl-r"

    assert {:ok, translation} =
             Transport.from_native_event(
               backend_mode: :raw,
               input_family: :shortcut,
               shortcut: "ctrl-r",
               intent: :reload_workspace,
               widget_id: "ops-palette",
               runtime_id: "terminal-ui:ops",
               screen: "operations"
             )

    assert translation.family == :command
    assert translation.boundary == :boundary
    assert match?(%Signal{}, translation.signal)
    assert translation.cloud_event.type == "terminal_ui.command.reload_workspace"
    assert translation.cloud_event.extensions.terminal_ui_input_family == :shortcut
  end

  test "local native focus handling can remain inside the runtime without a signal" do
    assert {:ok, translation} =
             Transport.from_native_event(
               backend_mode: :tty,
               input_family: :focus,
               focus_target: "service-table",
               intent: :focus_service_table,
               widget_id: "service-table",
               boundary: :local
             )

    assert translation.family == :focus
    assert translation.boundary == :local
    assert translation.signal == nil
    assert translation.local_handling == :focus_shift
  end

  test "canonical interactions translate into canonical boundary signals" do
    interaction = Interaction.command(intent: :run_command, command: :reload)

    assert {:ok, translation} =
             Transport.from_interaction(
               interaction,
               widget_id: "ops-palette",
               runtime_id: "terminal-ui:ops",
               screen: "operations",
               payload: %{query: "re"}
             )

    assert translation.family == :command
    assert translation.source_kind == :canonical
    assert match?(%Signal{}, translation.signal)
    assert translation.payload == %{command: :reload, query: "re"}
  end

  test "boundary signals decode back into shared terminal transport translations" do
    assert {:ok, outbound} =
             Transport.from_native_event(
               backend_mode: :raw,
               input_family: :mouse,
               mouse_action: :select,
               widget_id: "services-table",
               runtime_id: "terminal-ui:ops",
               screen: "operations"
             )

    assert {:ok, inbound} = Transport.from_boundary_signal(outbound.signal)

    assert inbound.boundary == :boundary
    assert inbound.family == :selection
    assert inbound.screen == "operations"
    assert inbound.widget_id == outbound.signal.subject
  end

  test "invalid native payloads and leaked backend details fail deterministically" do
    assert {:error, %TerminalUi.Transport.Error{reason: :invalid_payload_mapping}} =
             Transport.from_native_event(
               backend_mode: :raw,
               input_family: :paste,
               paste_text: "hello",
               payload: "not-a-map"
             )

    assert {:error, %TerminalUi.Transport.Error{reason: :leaked_backend_detail}} =
             Transport.normalize_native_event(
               backend_mode: :raw,
               input_family: :key,
               key: "enter",
               escape_sequence: "\\e[13~"
             )
  end
end
