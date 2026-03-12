defmodule WebUi.AgentMetricsTest do
  use ExUnit.Case, async: true

  alias WebUi.Agent
  alias WebUi.ServiceResultEnvelope

  defp event do
    %{
      specversion: "1.0",
      id: "evt-741",
      source: "webui.test",
      type: "runtime.command",
      data: %{action: "save"}
    }
  end

  defp context do
    %{correlation_id: "corr-741", request_id: "req-741"}
  end

  test "service operation latency histogram is emitted for successful operations" do
    parent = self()

    {:ok, agent} =
      Agent.new([
        %{event_type: "runtime.command", service: "ui.workflow", operation: "run_command", handler: fn _ -> {:ok, %{status: "ok"}} end}
      ])

    assert {:ok, %ServiceResultEnvelope{} = envelope} =
             Agent.dispatch_result(
               agent,
               event(),
               context(),
               metrics_fun: fn metric_record -> send(parent, {:metric, metric_record}) end
             )

    assert envelope.outcome == "ok"
    assert_received {:metric, metric}
    assert metric.metric_name == "webui_service_operation_latency"
    assert metric.labels["service"] == "ui.workflow"
    assert metric.labels["operation"] == "run_command"
    assert metric.labels["outcome"] == "ok"
  end

  test "service operation latency histogram includes error outcomes" do
    parent = self()

    {:ok, agent} =
      Agent.new([
        %{event_type: "runtime.command", service: "ui.workflow", operation: "run_command", handler: fn _ -> {:error, {:dependency, :redis_down}} end}
      ])

    assert {:ok, %ServiceResultEnvelope{} = envelope} =
             Agent.dispatch_result(
               agent,
               event(),
               context(),
               metrics_fun: fn metric_record -> send(parent, {:metric, metric_record}) end
             )

    assert envelope.outcome == "error"
    assert_received {:metric, metric}
    assert metric.metric_name == "webui_service_operation_latency"
    assert metric.labels["outcome"] == "error"
  end
end
