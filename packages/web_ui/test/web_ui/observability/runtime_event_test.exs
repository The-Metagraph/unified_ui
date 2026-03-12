defmodule WebUi.Observability.RuntimeEventTest do
  use ExUnit.Case, async: true

  alias WebUi.Observability.RuntimeEvent
  alias WebUi.TypedError

  test "build produces valid runtime event envelopes with mandatory metadata" do
    context = %{correlation_id: "corr-701", request_id: "req-701", session_id: "session-701"}

    assert {:ok, event} =
             RuntimeEvent.build(
               %{
                 event_name: "runtime.transport.ingress.v1",
                 event_version: "v1",
                 service: "transport",
                 source: "WebUi.Channel",
                 outcome: "ok",
                 payload: %{topic: "webui:runtime:v1"}
               },
               context
             )

    assert :ok == RuntimeEvent.validate(event)
    assert event.event_name == "runtime.transport.ingress.v1"
    assert event.event_version == "v1"
    assert is_binary(event.timestamp)
    assert event.service == "transport"
    assert event.correlation_id == "corr-701"
    assert event.request_id == "req-701"
  end

  test "missing required fields fail with typed validation errors" do
    assert {:error, %TypedError{} = error} =
             RuntimeEvent.build(
               %{
                 event_version: "v1",
                 service: "transport",
                 source: "WebUi.Channel",
                 outcome: "ok",
                 payload: %{}
               },
               %{correlation_id: "corr-702", request_id: "req-702"}
             )

    assert error.error_code == "observability.missing_required_event_fields"
  end

  test "invalid event naming or timestamp fails conformance checks" do
    assert {:error, %TypedError{} = error} =
             RuntimeEvent.validate(%{
               event_name: "runtime.transport.ingress",
               event_version: "v1",
               timestamp: "not-a-timestamp",
               service: "transport",
               source: "WebUi.Channel",
               correlation_id: "corr-703",
               request_id: "req-703",
               outcome: "ok",
               payload: %{}
             })

    assert error.error_code in ["observability.invalid_event_name", "observability.invalid_event_timestamp"]
  end

  test "conformance failure event preserves typed error identity" do
    error = TypedError.new("example.invalid", "validation", false, %{field: :x}, "corr-704")

    event =
      RuntimeEvent.conformance_failure_event(
        error,
        %{correlation_id: "corr-704", request_id: "req-704"},
        %{component: "unit_test"}
      )

    assert event.event_name == "runtime.observability.conformance_failed.v1"
    assert event.outcome == "error"
    assert event.payload.error_code == "example.invalid"
    assert :ok == RuntimeEvent.validate(event)
  end
end
