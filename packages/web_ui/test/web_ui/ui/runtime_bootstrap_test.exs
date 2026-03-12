defmodule WebUi.Ui.RuntimeBootstrapTest do
  use ExUnit.Case, async: true

  alias WebUi.TypedError
  alias WebUi.Ui.Runtime

  test "init returns deterministic connecting model and bootstrap commands" do
    {:ok, model, commands} =
      Runtime.init(%{runtime_context: %{correlation_id: "corr-202", request_id: "req-202"}})

    assert model.connection_state == :connecting
    assert model.view_state.screen == :connecting
    assert model.transport.topic == "webui:runtime:v1"

    assert [%{kind: :ws_join, topic: "webui:runtime:v1"}, %{kind: :ws_push, event_name: "runtime.event.ping.v1"} = ping] =
             commands

    assert ping.payload.correlation_id == "corr-202"
    assert ping.payload.request_id == "req-202"
  end

  test "init is deterministic for same input" do
    assert Runtime.init(%{runtime_context: %{correlation_id: "corr-203", request_id: "req-203"}}) ==
             Runtime.init(%{runtime_context: %{correlation_id: "corr-203", request_id: "req-203"}})
  end

  test "successful bootstrap marks model connected" do
    {:ok, model, _commands} = Runtime.init()

    updated = Runtime.handle_bootstrap_result(model, {:ok, %{topic: "webui:runtime:v1"}})

    assert updated.connection_state == :connected
    assert updated.view_state.screen == :ready
    assert updated.transport.joined? == true
    assert hd(updated.inbound_history).event == :ws_joined
  end

  test "bootstrap success applies resume acknowledgement continuity markers" do
    {:ok, base_model, _commands} = Runtime.init()

    model = %{base_model | recovery_state: Map.put(base_model.recovery_state, :session_resume_cursor, 4)}

    updated =
      Runtime.handle_bootstrap_result(
        model,
        {:ok, %{topic: "webui:runtime:session:sess-201:v1", resumed_from_sequence: 4}}
      )

    assert updated.connection_state == :connected
    assert updated.recovery_state.session_resume_cursor == nil
    assert updated.recovery_state.last_resumed_sequence == 4
    assert hd(updated.view_state.notices) == "resume:ack:4"
  end

  test "failed bootstrap sets typed ui-visible error state" do
    {:ok, model, _commands} = Runtime.init(%{runtime_context: %{correlation_id: "corr-204", request_id: "req-204"}})

    updated = Runtime.handle_bootstrap_result(model, {:error, :join_denied})

    assert updated.connection_state == :error
    assert updated.view_state.screen == :error
    assert updated.view_state.ui_error.code == "ui.bootstrap_join_failed"
    assert %TypedError{} = updated.last_error
    assert updated.last_error.correlation_id == "corr-204"
    assert hd(updated.inbound_history).event == :ws_join_failed
  end
end
