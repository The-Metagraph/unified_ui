defmodule WebUi.ServiceRequestEnvelopeTest do
  use ExUnit.Case, async: true

  alias WebUi.ServiceRequestEnvelope
  alias WebUi.TypedError

  test "builds service request envelope from event" do
    event = %{
      specversion: "1.0",
      id: "evt-302",
      source: "webui.test",
      type: "runtime.command",
      data: %{action: "save"}
    }

    context = %{correlation_id: "corr-302", request_id: "req-302"}

    assert {:ok, request} =
             ServiceRequestEnvelope.from_event("ui.workflow", "handle_command", event, context)

    assert request.service == "ui.workflow"
    assert request.operation == "handle_command"
    assert request.payload.data.action == "save"
    assert request.metadata.event_type == "runtime.command"
    assert request.context.correlation_id == "corr-302"
  end

  test "rejects invalid service/operation names" do
    context = %{correlation_id: "corr-302", request_id: "req-302"}

    assert {:error, %TypedError{} = error} = ServiceRequestEnvelope.new("", "op", context, %{})
    assert error.error_code == "service_request.invalid_service"
  end

  test "rejects invalid event envelope shape" do
    context = %{correlation_id: "corr-302", request_id: "req-302"}

    assert {:error, %TypedError{} = error} =
             ServiceRequestEnvelope.from_event("svc", "op", :bad_event, context)

    assert error.error_code == "service_request.invalid_event_shape"
  end
end
