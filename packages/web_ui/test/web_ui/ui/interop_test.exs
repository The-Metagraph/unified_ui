defmodule WebUi.Ui.InteropTest do
  use ExUnit.Case, async: true

  alias WebUi.TypedError
  alias WebUi.Ui.Interop

  test "builds typed outbound port commands for supported operations" do
    context = %{correlation_id: "corr-230", request_id: "req-230"}

    assert {:ok, command} = Interop.build_port_command("copy_to_clipboard", %{text: "hello"}, context)

    assert command.kind == :port_out
    assert command.event_name == "ui.port.command.v1"
    assert command.payload.operation == "copy_to_clipboard"
    assert command.payload.provenance.origin == "extension_port"
    assert command.payload.provenance.correlation_id == "corr-230"
  end

  test "rejects unsupported outbound operations" do
    context = %{correlation_id: "corr-230", request_id: "req-230"}

    assert {:error, %TypedError{} = error} =
             Interop.build_port_command("mutate_domain_state", %{x: 1}, context)

    assert error.error_code == "ui.interop.unsupported_operation"
    assert error.category == "validation"
  end

  test "decodes valid inbound port events" do
    payload = %{
      operation: "copy_to_clipboard",
      data: %{text: "hello"},
      provenance: %{origin: "extension_port"}
    }

    assert {:ok, decoded} = Interop.decode_port_event(payload)
    assert decoded.operation == "copy_to_clipboard"
    assert decoded.data.text == "hello"
  end

  test "denies blocked runtime actions" do
    context = %{correlation_id: "corr-230", request_id: "req-230"}
    decoded = %{operation: "execute_runtime_command", data: %{command: "delete_all"}}

    assert {:error, %TypedError{} = error} = Interop.authorize_port_event(decoded, context)
    assert error.error_code == "ui.interop.denied_runtime_action"
    assert error.category == "authorization"
  end

  test "telemetry_error includes js interop metric record with stable labels" do
    error = TypedError.new("ui.interop.denied_runtime_action", "authorization", false, %{operation: "blocked"}, "corr-230")
    telemetry = Interop.telemetry_error(error, %{request_id: "req-230"})

    assert telemetry.event_name == "runtime.js_interop.error.v1"
    assert telemetry.metric.metric_name == "webui_js_interop_error_total"
    assert telemetry.metric.labels["bridge"] == "extension_port"
    assert telemetry.metric.labels["error_code"] == "ui.interop.denied_runtime_action"
  end
end
