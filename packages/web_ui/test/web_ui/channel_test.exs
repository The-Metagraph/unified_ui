defmodule WebUi.ChannelTest do
  use ExUnit.Case, async: true

  alias WebUi.Channel

  test "normalizes valid runtime.event.send.v1 ingress to runtime.event.recv.v1" do
    payload = %{
      event: %{
        specversion: "1.0",
        id: "evt-1",
        source: "webui.test",
        type: "runtime.command",
        data: %{action: "save"},
        correlation_id: "corr-1",
        request_id: "req-1"
      }
    }

    assert {:ok, response} =
             Channel.handle_client_message("webui:runtime:v1", "runtime.event.send.v1", payload)

    assert response.event_name == "runtime.event.recv.v1"
    assert response.payload.context.correlation_id == "corr-1"
    assert response.payload.context.request_id == "req-1"
    assert response.payload.event["type"] == "runtime.command"
    assert response.payload.event["correlation_id"] == "corr-1"
  end

  test "returns runtime.event.error.v1 for invalid topics" do
    payload = %{event: %{}}

    assert {:ok, response} =
             Channel.handle_client_message("invalid:topic", "runtime.event.send.v1", payload)

    assert response.event_name == "runtime.event.error.v1"
    assert response.payload.error.error_code == "transport.invalid_topic"
  end

  test "returns runtime.event.error.v1 for malformed cloud events" do
    payload = %{event: %{specversion: "1.0", id: "evt-1"}}

    assert {:ok, response} =
             Channel.handle_client_message("webui:runtime:v1", "runtime.event.send.v1", payload)

    assert response.event_name == "runtime.event.error.v1"
    assert response.payload.error.error_code == "cloudevent.missing_required_fields"
  end

  test "returns runtime.event.error.v1 for unknown client events" do
    assert {:ok, response} =
             Channel.handle_client_message("webui:runtime:v1", "runtime.event.recv.v1", %{})

    assert response.event_name == "runtime.event.error.v1"
    assert response.payload.error.error_code == "transport.unknown_client_event"
  end

  test "normalizes runtime.event.ping.v1 to runtime.event.pong.v1" do
    payload = %{correlation_id: "corr-ping", request_id: "req-ping"}

    assert {:ok, response} =
             Channel.handle_client_message("webui:runtime:v1", "runtime.event.ping.v1", payload)

    assert response.event_name == "runtime.event.pong.v1"
    assert response.payload.correlation_id == "corr-ping"
    assert response.payload.request_id == "req-ping"
  end

  test "normalizes timeout dispatch errors to typed timeout envelopes" do
    response =
      Channel.normalize_dispatch_result(%{correlation_id: "corr-1", request_id: "req-1"}, {:error, {:timeout, 2500}})

    assert response.event_name == "runtime.event.error.v1"
    assert response.payload.error.error_code == "channel.runtime_timeout"
    assert response.payload.error.category == "timeout"
    assert response.payload.error.retryable == true
  end

  test "normalizes dependency dispatch errors to typed dependency envelopes" do
    response =
      Channel.normalize_dispatch_result(%{correlation_id: "corr-1", request_id: "req-1"}, {:error, {:dependency, :redis_down}})

    assert response.event_name == "runtime.event.error.v1"
    assert response.payload.error.error_code == "channel.runtime_dependency_error"
    assert response.payload.error.category == "dependency"
    assert response.payload.error.retryable == true
  end

  test "normalizes unknown dispatch errors to typed internal envelopes" do
    response =
      Channel.normalize_dispatch_result(%{correlation_id: "corr-1", request_id: "req-1"}, {:error, :boom})

    assert response.event_name == "runtime.event.error.v1"
    assert response.payload.error.error_code == "channel.runtime_internal_error"
    assert response.payload.error.category == "internal"
    assert response.payload.error.retryable == false
  end
end
