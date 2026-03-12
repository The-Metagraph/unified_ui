defmodule WebUi.AgentContextContinuityTest do
  use ExUnit.Case, async: true

  alias WebUi.Agent
  alias WebUi.ServiceResultEnvelope

  defp context do
    %{
      correlation_id: "corr-330",
      request_id: "req-330",
      session_id: "session-330",
      user_id: "user-330",
      trace_id: "trace-330"
    }
  end

  defp event(type \\ "runtime.command") do
    %{
      specversion: "1.0",
      id: "evt-330",
      source: "webui.test",
      type: type,
      data: %{action: "save"}
    }
  end

  test "context identifiers and optional fields propagate across request/result lifecycle" do
    {:ok, agent} =
      Agent.new([
        %{event_type: "runtime.command", service: "ui.workflow", operation: "run", handler: fn _ -> {:ok, %{status: "ok"}} end}
      ])

    assert {:ok, %ServiceResultEnvelope{} = envelope} = Agent.dispatch_result(agent, event(), context())

    assert envelope.outcome == "ok"
    assert envelope.context.correlation_id == "corr-330"
    assert envelope.context.request_id == "req-330"
    assert envelope.context.session_id == "session-330"
    assert envelope.context.user_id == "user-330"
    assert envelope.context.trace_id == "trace-330"
  end

  test "context integrity mismatch fails closed with denied telemetry" do
    {:ok, agent} =
      Agent.new([
        %{event_type: "runtime.command", service: "ui.workflow", operation: "run", handler: fn _ -> {:ok, %{status: "ok"}} end}
      ])

    mismatched_event = Map.merge(event(), %{correlation_id: "corr-other", request_id: "req-330"})

    assert {:ok, %ServiceResultEnvelope{} = envelope} =
             Agent.dispatch_result(agent, mismatched_event, context())

    assert envelope.outcome == "error"
    assert envelope.error.error_code == "agent.context_integrity_mismatch"
    assert envelope.error.category == "validation"
    assert hd(envelope.events).event_name == "runtime.dispatch.denied.v1"
  end

  test "missing required context fails before handler invocation" do
    parent = self()

    handler = fn _ ->
      send(parent, :handler_called)
      {:ok, %{status: "ok"}}
    end

    {:ok, agent} =
      Agent.new([
        %{event_type: "runtime.command", service: "ui.workflow", operation: "run", handler: handler}
      ])

    assert {:ok, %ServiceResultEnvelope{} = envelope} =
             Agent.dispatch_result(agent, event(), %{correlation_id: "corr-330"})

    assert envelope.outcome == "error"
    assert envelope.error.error_code == "runtime_context.missing_required_fields"
    refute_received :handler_called
  end

  test "unknown handlers emit denied telemetry with correlation continuity" do
    {:ok, agent} =
      Agent.new([
        %{event_type: "runtime.known", service: "ui.workflow", operation: "known", handler: fn _ -> {:ok, %{}} end}
      ])

    assert {:ok, %ServiceResultEnvelope{} = envelope} =
             Agent.dispatch_result(agent, event("runtime.unknown"), context())

    denied = hd(envelope.events)

    assert envelope.outcome == "error"
    assert envelope.error.error_code == "agent.unknown_event_type"
    assert denied.event_name == "runtime.dispatch.denied.v1"
    assert denied.correlation_id == "corr-330"
    assert denied.request_id == "req-330"
  end
end
