defmodule WebUi.Integration.Phase03RuntimeAuthorityTest do
  use ExUnit.Case, async: true

  alias WebUi.Agent
  alias WebUi.Channel

  defp event_payload(overrides \\ %{}) do
    base = %{
      specversion: "1.0",
      id: "evt-340",
      source: "webui.integration",
      type: "runtime.command",
      data: %{action: "save"},
      correlation_id: "corr-340",
      request_id: "req-340",
      session_id: "session-340",
      user_id: "user-340",
      trace_id: "trace-340"
    }

    %{event: Map.merge(base, overrides)}
  end

  defp build_agent(handler) do
    {:ok, agent} =
      Agent.new([
        %{event_type: "runtime.command", service: "ui.workflow", operation: "run_command", handler: handler}
      ])

    agent
  end

  @tag :conformance
  test "SCN-runtime-001 valid requests route to expected service/operation handlers" do
    agent = build_agent(fn _request -> {:ok, %{status: "ok"}} end)

    assert {:ok, response} =
             Channel.handle_client_message(
               "webui:runtime:v1",
               "runtime.event.send.v1",
               event_payload(),
               agent: agent
             )

    assert response.event_name == "runtime.event.recv.v1"
    assert response.payload.result.service == "ui.workflow"
    assert response.payload.result.operation == "run_command"
    assert response.payload.result.outcome == "ok"
  end

  @tag :conformance
  test "SCN-runtime-002 unknown handlers return typed runtime error envelopes" do
    {:ok, agent} =
      Agent.new([
        %{event_type: "runtime.other", service: "ui.workflow", operation: "other", handler: fn _ -> {:ok, %{}} end}
      ])

    assert {:ok, response} =
             Channel.handle_client_message(
               "webui:runtime:v1",
               "runtime.event.send.v1",
               event_payload(),
               agent: agent
             )

    assert response.event_name == "runtime.event.recv.v1"
    assert response.payload.result.outcome == "error"
    assert response.payload.result.error.error_code == "agent.unknown_event_type"
    assert response.payload.result.error.category == "protocol"
  end

  @tag :conformance
  test "SCN-runtime-003 timeout and dependency failures map to stable categories" do
    timeout_agent =
      build_agent(fn _request ->
        Process.sleep(30)
        {:ok, %{status: "late"}}
      end)

    dependency_agent = build_agent(fn _request -> {:error, {:dependency, :redis_down}} end)

    assert {:ok, timeout_response} =
             Channel.handle_client_message(
               "webui:runtime:v1",
               "runtime.event.send.v1",
               event_payload(%{id: "evt-340-timeout"}),
               agent: timeout_agent,
               timeout_ms: 5
             )

    assert timeout_response.payload.result.outcome == "error"
    assert timeout_response.payload.result.error.error_code == "agent.runtime_timeout"
    assert timeout_response.payload.result.error.category == "timeout"

    assert {:ok, dep_response} =
             Channel.handle_client_message(
               "webui:runtime:v1",
               "runtime.event.send.v1",
               event_payload(%{id: "evt-340-dep"}),
               agent: dependency_agent
             )

    assert dep_response.payload.result.outcome == "error"
    assert dep_response.payload.result.error.error_code == "agent.runtime_dependency_error"
    assert dep_response.payload.result.error.category == "dependency"
  end

  @tag :conformance
  test "SCN-runtime-004 mandatory context identifiers survive ingress to egress unchanged" do
    agent = build_agent(fn _request -> {:ok, %{status: "ok"}} end)

    assert {:ok, response} =
             Channel.handle_client_message(
               "webui:runtime:v1",
               "runtime.event.send.v1",
               event_payload(),
               agent: agent
             )

    result_context = response.payload.result.context

    assert result_context.correlation_id == "corr-340"
    assert result_context.request_id == "req-340"
    assert result_context.session_id == "session-340"
    assert result_context.user_id == "user-340"
    assert result_context.trace_id == "trace-340"
  end

  @tag :conformance
  test "SCN-runtime-005 missing context fails before runtime dispatch" do
    parent = self()

    agent =
      build_agent(fn _request ->
        send(parent, :handler_called)
        {:ok, %{status: "ok"}}
      end)

    bad_payload = event_payload() |> put_in([:event], Map.drop(event_payload().event, [:request_id]))

    assert {:ok, response} =
             Channel.handle_client_message(
               "webui:runtime:v1",
               "runtime.event.send.v1",
               bad_payload,
               agent: agent
             )

    assert response.event_name == "runtime.event.error.v1"
    assert response.payload.error.error_code == "cloudevent.missing_required_extensions"
    refute_received :handler_called
  end

  @tag :conformance
  test "SCN-runtime-006 error outcomes preserve correlation metadata" do
    agent = build_agent(fn _request -> {:error, {:dependency, :redis_down}} end)

    assert {:ok, response} =
             Channel.handle_client_message(
               "webui:runtime:v1",
               "runtime.event.send.v1",
               event_payload(),
               agent: agent
             )

    result = response.payload.result

    assert result.outcome == "error"
    assert result.error.correlation_id == "corr-340"
    assert result.context.correlation_id == "corr-340"
    assert result.context.request_id == "req-340"
  end
end
