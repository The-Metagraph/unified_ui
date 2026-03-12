defmodule WebUi.Integration.Phase01TransportTest do
  use ExUnit.Case, async: true

  alias WebUi.Channel

  @tag :conformance
  test "SCN-002 admits canonical websocket topic and rejects invalid topic" do
    valid_payload = %{
      event: %{
        specversion: "1.0",
        id: "evt-100",
        source: "webui.integration",
        type: "runtime.command",
        data: %{action: "save"},
        correlation_id: "corr-100",
        request_id: "req-100"
      }
    }

    assert {:ok, ok_response} =
             Channel.handle_client_message("webui:runtime:v1", "runtime.event.send.v1", valid_payload)

    assert ok_response.event_name == "runtime.event.recv.v1"

    assert {:ok, denied_response} =
             Channel.handle_client_message("webui:runtime:v2", "runtime.event.send.v1", valid_payload)

    assert denied_response.event_name == "runtime.event.error.v1"
    assert denied_response.payload.error.error_code == "transport.invalid_topic"
  end

  @tag :conformance
  test "SCN-003 malformed envelopes fail with typed protocol errors" do
    malformed_payload = %{
      event: %{
        specversion: "1.0",
        id: "evt-101",
        correlation_id: "corr-101",
        request_id: "req-101"
      }
    }

    assert {:ok, response} =
             Channel.handle_client_message("webui:runtime:v1", "runtime.event.send.v1", malformed_payload)

    assert response.event_name == "runtime.event.error.v1"
    assert response.payload.error.error_code == "cloudevent.missing_required_fields"
    assert response.payload.error.category == "protocol"
  end

  @tag :conformance
  test "SCN-003 unknown client event names return deterministic error envelopes" do
    assert {:ok, response} =
             Channel.handle_client_message("webui:runtime:v1", "runtime.event.unknown.v1", %{})

    assert response.event_name == "runtime.event.error.v1"
    assert response.payload.error.error_code == "transport.unknown_client_event"
    assert response.payload.error.category == "protocol"
    assert response.payload.error.retryable == false
  end

  @tag :conformance
  test "SCN-002 accepted ingress emits runtime.event.recv.v1 with valid envelope shape" do
    payload = %{
      event: %{
        specversion: "1.0",
        id: "evt-102",
        source: "webui.integration",
        type: "runtime.command",
        data: %{action: "preview"},
        correlation_id: "corr-102",
        request_id: "req-102"
      }
    }

    assert {:ok, response} =
             Channel.handle_client_message("webui:runtime:v1", "runtime.event.send.v1", payload)

    assert response.event_name == "runtime.event.recv.v1"
    assert response.payload.event["specversion"] == "1.0"
    assert response.payload.event["id"] == "evt-102"
    assert response.payload.event["type"] == "runtime.command"
    assert is_map(response.payload.event["data"])
  end

  @tag :conformance
  test "SCN-005 failures emit runtime.event.error.v1 with stable typed-error fields" do
    payload = %{
      event: %{
        specversion: "1.0",
        id: "evt-103",
        source: "webui.integration",
        type: "runtime.command",
        data: %{},
        correlation_id: "corr-103"
      }
    }

    assert {:ok, response} =
             Channel.handle_client_message("webui:runtime:v1", "runtime.event.send.v1", payload)

    assert response.event_name == "runtime.event.error.v1"
    assert response.payload.error.error_code == "cloudevent.missing_required_extensions"
    assert response.payload.error.category == "protocol"
    assert response.payload.error.retryable == false
  end

  @tag :conformance
  test "SCN-004 preserves correlation and request continuity from ingress to egress" do
    payload = %{
      event: %{
        specversion: "1.0",
        id: "evt-104",
        source: "webui.integration",
        type: "runtime.command",
        data: %{operation: "save"},
        correlation_id: "corr-104",
        request_id: "req-104"
      }
    }

    assert {:ok, response} =
             Channel.handle_client_message("webui:runtime:v1", "runtime.event.send.v1", payload)

    assert response.event_name == "runtime.event.recv.v1"
    assert response.payload.context.correlation_id == "corr-104"
    assert response.payload.context.request_id == "req-104"
    assert response.payload.event["correlation_id"] == "corr-104"
    assert response.payload.event["request_id"] == "req-104"
  end
end
