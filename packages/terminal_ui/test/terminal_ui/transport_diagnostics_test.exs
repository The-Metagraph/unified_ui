defmodule TerminalUi.TransportDiagnosticsTest do
  use ExUnit.Case, async: true

  alias Jido.Signal
  alias TerminalUi.Transport

  test "diagnostics expose canonical-to-native mappings and normalized input families" do
    summary = TerminalUi.Transport.Diagnostics.mapping_summary()

    assert :command in summary.families
    assert :shortcut in summary.input_families
    assert :focus in summary.local_default_families
    assert :selection in summary.boundary_crossing_families

    assert Transport.diagnostics().normalized_event_families == [
             :key,
             :mouse,
             :paste,
             :resize,
             :focus,
             :shortcut
           ]
  end

  test "transport validation catches boundary leakage and missing boundary context" do
    assert {:ok, local_translation} =
             Transport.from_native_event(
               backend_mode: :tty,
               input_family: :focus,
               boundary: :local,
               focus_target: "query",
               widget_id: "query"
             )

    assert :ok = Transport.validate_translation(local_translation)

    assert {:error, %TerminalUi.Transport.Error{reason: :leaked_backend_detail}} =
             Transport.validate_translation(%{
               boundary: :local,
               family: :change,
               runtime_event: "key:change",
               payload: %{escape_sequence: "\\e[13~"}
             })

    assert {:ok, boundary_translation} =
             Transport.from_native_event(
               backend_mode: :raw,
               input_family: :shortcut,
               shortcut: "ctrl-r",
               widget_id: "ops-palette",
               runtime_id: "terminal-ui:ops",
               screen: "operations"
             )

    assert :ok = Transport.validate_translation(boundary_translation)

    assert {:error, %TerminalUi.Transport.Error{reason: :missing_boundary_context}} =
             Transport.validate_translation(%{
               boundary: :boundary,
               family: :command,
               runtime_event: "shortcut:command",
               payload: %{},
               signal:
                 Signal.new!(
                   "terminal_ui.command.reload",
                   %{},
                   source: "/terminal_ui/native/unknown",
                   subject: "native/unknown/ops-palette",
                   extensions: %{terminal_ui_family: :command}
                 )
             })
  end

  test "reference and summary surfaces expose transport-focused contract summaries" do
    reference = TerminalUi.reference()
    summary = TerminalUi.info()

    assert :command in reference.transport.families
    assert :shortcut in reference.transport.input_families
    assert :focus in reference.transport.local_default_families
    assert :selection in reference.transport.boundary_crossing_families
    assert TerminalUi.Transport.Diagnostics in reference.transport.modules
    assert :shortcut in reference.transport.diagnostics.normalized_event_families

    assert :command in summary.transport.families
    assert :mouse in summary.transport.input_families
    assert :selection in summary.transport.diagnostics.mapping_summary.boundary_crossing_families
  end
end
