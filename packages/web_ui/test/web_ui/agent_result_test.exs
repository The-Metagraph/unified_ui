defmodule WebUi.AgentResultTest do
  use ExUnit.Case, async: true

  alias WebUi.Agent
  alias WebUi.ServiceResultEnvelope

  defp valid_event(type \\ "runtime.command") do
    %{
      specversion: "1.0",
      id: "evt-321",
      source: "webui.test",
      type: type,
      data: %{action: "save"}
    }
  end

  defp valid_context do
    %{correlation_id: "corr-321", request_id: "req-321"}
  end

  test "dispatch_result returns normalized success envelopes" do
    handler = fn _request ->
      {:ok,
       %{
         status: "ok",
         events: [%{event_name: "runtime.service.completed.v1"}]
       }}
    end

    {:ok, agent} =
      Agent.new([
        %{event_type: "runtime.command", service: "ui.workflow", operation: "run_command", handler: handler}
      ])

    assert {:ok, %ServiceResultEnvelope{} = envelope} =
             Agent.dispatch_result(agent, valid_event(), valid_context())

    assert envelope.outcome == "ok"
    assert envelope.service == "ui.workflow"
    assert envelope.operation == "run_command"
    assert envelope.payload.status == "ok"
    assert envelope.error == nil
    assert length(envelope.events) == 2
    assert Enum.any?(envelope.events, &(&1.event_name == "runtime.service.operation.terminal.v1"))
    assert Enum.any?(envelope.events, &(&1.event_name == "runtime.observability.conformance_failed.v1"))
  end

  test "dispatch_result returns normalized error envelopes" do
    {:ok, agent} =
      Agent.new([
        %{
          event_type: "runtime.command",
          service: "ui.workflow",
          operation: "run_command",
          handler: fn _ -> {:error, {:dependency, :redis_down}} end
        }
      ])

    assert {:ok, %ServiceResultEnvelope{} = envelope} =
             Agent.dispatch_result(agent, valid_event(), valid_context())

    assert envelope.outcome == "error"
    assert envelope.service == "ui.workflow"
    assert envelope.operation == "run_command"
    assert envelope.error.error_code == "agent.runtime_dependency_error"
    assert envelope.error.category == "dependency"
  end

  test "dispatch_result preserves correlation in unknown handler path" do
    {:ok, agent} =
      Agent.new([
        %{event_type: "runtime.known", service: "ui.workflow", operation: "known", handler: fn _ -> {:ok, %{}} end}
      ])

    assert {:ok, %ServiceResultEnvelope{} = envelope} =
             Agent.dispatch_result(agent, valid_event("runtime.unknown"), valid_context())

    assert envelope.outcome == "error"
    assert envelope.service == "unknown_service"
    assert envelope.operation == "unknown_operation"
    assert envelope.error.error_code == "agent.unknown_event_type"
    assert envelope.error.correlation_id == "corr-321"
  end
end
