defmodule WebUi.Ui.RuntimeInteropTest do
  use ExUnit.Case, async: true

  alias WebUi.Ui.Message
  alias WebUi.Ui.Runtime

  defp booted_model do
    {:ok, model, _commands} =
      Runtime.init(%{runtime_context: %{correlation_id: "corr-231", request_id: "req-231"}})

    model
  end

  test "request_port_operation enqueues typed outbound interop command" do
    model = booted_model()

    {updated_model, [command]} =
      Runtime.request_port_operation(model, "copy_to_clipboard", %{text: "hello"})

    assert command.kind == :port_out
    assert command.payload.operation == "copy_to_clipboard"
    assert List.last(updated_model.outbound_queue) == command
  end

  test "request_port_operation fails closed on unsupported operation" do
    model = booted_model()

    {updated_model, commands} =
      Runtime.request_port_operation(model, "execute_runtime_command", %{command: "drop"})

    assert commands == []
    assert updated_model.last_error.error_code == "ui.interop.unsupported_operation"
    assert hd(updated_model.telemetry_events).event_name == "runtime.js_interop.error.v1"
  end

  test "port_event update accepts allowed inbound events" do
    model = booted_model()

    msg =
      Message.port_event(%{
        operation: "copy_to_clipboard",
        data: %{text: "hello"},
        provenance: %{origin: "extension_port"}
      })

    {updated_model, commands} = Runtime.update(model, msg)

    assert commands == []
    assert hd(updated_model.inbound_history).event == :port_event_received
    assert updated_model.view_state.ui_error == nil
  end

  test "port_event update denies blocked inbound runtime actions" do
    model = booted_model()

    msg =
      Message.port_event(%{
        operation: "mutate_domain_state",
        data: %{field: "danger"},
        provenance: %{origin: "extension_port"}
      })

    {updated_model, commands} = Runtime.update(model, msg)

    assert commands == []
    assert updated_model.last_error.error_code == "ui.interop.denied_runtime_action"
    assert hd(updated_model.telemetry_events).event_name == "runtime.js_interop.error.v1"
  end
end
