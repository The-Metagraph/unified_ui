defmodule WebUi.AgentTest do
  use ExUnit.Case, async: true

  alias WebUi.Agent
  alias WebUi.TypedError

  defp valid_event(type \\ "runtime.command") do
    %{
      specversion: "1.0",
      id: "evt-303",
      source: "webui.test",
      type: type,
      data: %{action: "save"}
    }
  end

  defp valid_context do
    %{correlation_id: "corr-303", request_id: "req-303", session_id: "session-303"}
  end

  test "dispatch routes event types to handlers" do
    handler = fn request ->
      {:ok, %{handled: true, service: request.service, operation: request.operation}}
    end

    {:ok, agent} =
      Agent.new([
        %{event_type: "runtime.command", service: "ui.workflow", operation: "run_command", handler: handler}
      ])

    assert {:ok, result} = Agent.dispatch(agent, valid_event(), valid_context())

    assert result.service == "ui.workflow"
    assert result.operation == "run_command"
    assert result.payload.handled == true
    assert result.context.correlation_id == "corr-303"
  end

  test "dispatch fails with typed protocol errors for unknown event types" do
    {:ok, agent} =
      Agent.new([
        %{event_type: "runtime.known", service: "ui.workflow", operation: "known", handler: fn _ -> {:ok, %{}} end}
      ])

    assert {:error, %TypedError{} = error} = Agent.dispatch(agent, valid_event("runtime.unknown"), valid_context())
    assert error.error_code == "agent.unknown_event_type"
    assert error.category == "protocol"
  end

  test "dispatch admission fails for missing context fields" do
    {:ok, agent} =
      Agent.new([
        %{event_type: "runtime.command", service: "ui.workflow", operation: "run_command", handler: fn _ -> {:ok, %{}} end}
      ])

    assert {:error, %TypedError{} = error} = Agent.dispatch(agent, valid_event(), %{correlation_id: "corr-303"})
    assert error.error_code == "runtime_context.missing_required_fields"
    assert error.category == "validation"
  end

  test "timeout failures map to typed timeout category" do
    slow_handler = fn _request ->
      Process.sleep(50)
      {:ok, %{handled: true}}
    end

    {:ok, agent} =
      Agent.new([
        %{event_type: "runtime.command", service: "ui.workflow", operation: "slow", handler: slow_handler}
      ])

    assert {:error, %TypedError{} = error} =
             Agent.dispatch(agent, valid_event(), valid_context(), timeout_ms: 10)

    assert error.error_code == "agent.runtime_timeout"
    assert error.category == "timeout"
    assert error.retryable == true
  end

  test "dependency failures map to typed dependency category" do
    dep_handler = fn _request -> {:error, {:dependency, :redis_down}} end

    {:ok, agent} =
      Agent.new([
        %{event_type: "runtime.command", service: "ui.workflow", operation: "dep", handler: dep_handler}
      ])

    assert {:error, %TypedError{} = error} = Agent.dispatch(agent, valid_event(), valid_context())

    assert error.error_code == "agent.runtime_dependency_error"
    assert error.category == "dependency"
    assert error.retryable == true
  end

  test "unexpected exceptions map to typed internal category" do
    bad_handler = fn _request -> raise "boom" end

    {:ok, agent} =
      Agent.new([
        %{event_type: "runtime.command", service: "ui.workflow", operation: "bad", handler: bad_handler}
      ])

    assert {:error, %TypedError{} = error} = Agent.dispatch(agent, valid_event(), valid_context())

    assert error.error_code == "agent.runtime_internal_error"
    assert error.category == "internal"
    assert error.retryable == false
  end
end
