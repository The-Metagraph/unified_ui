defmodule WebUi.Integration.Phase24ReplayVerificationGateTest do
  use ExUnit.Case, async: true

  alias WebUi.Persistence.ReplayLog
  alias WebUi.Ui.Message
  alias WebUi.Ui.Runtime

  @moduletag :conformance

  defp model_with_session do
    {:ok, model, _commands} =
      Runtime.init(%{
        runtime_context: %{
          correlation_id: "corr-24",
          request_id: "req-24",
          session_id: "sess-24"
        }
      })

    model
  end

  defp click_message(action) when is_binary(action) do
    Message.widget_event(%{
      type: "unified.button.clicked",
      widget_id: "save_button",
      widget_kind: "button",
      data: %{action: action}
    })
  end

  defp result_message(turn_id) when is_binary(turn_id) and turn_id != "" do
    Message.websocket_recv(%{
      result: %{
        service: "ui.preferences",
        operation: "save_preferences",
        outcome: "ok",
        payload: %{turn_id: turn_id},
        context: %{correlation_id: "corr-24", request_id: "req-24", session_id: "sess-24"}
      }
    })
  end

  defp model_with_replay_entries do
    model = model_with_session()

    {model, [first_dispatch]} = Runtime.update(model, click_message("save"))
    first_turn_id = first_dispatch.payload.event["data"]["turn_id"]
    {model, []} = Runtime.update(model, result_message(first_turn_id))

    {model, [second_dispatch]} = Runtime.update(model, click_message("publish"))
    second_turn_id = second_dispatch.payload.event["data"]["turn_id"]
    {model, []} = Runtime.update(model, result_message(second_turn_id))

    model
  end

  test "SCN-029 equivalent replay verification inputs produce deterministic gate pass diagnostics" do
    model = model_with_replay_entries()
    {model, []} = Runtime.update(model, Message.replay_export_requested(%{}))
    expected_export = model.recovery_state.last_replay_export

    {updated_model, []} =
      Runtime.update(
        model,
        Message.replay_verification_gate_requested(%{expected_export: expected_export})
      )

    gate = updated_model.recovery_state.last_replay_verification_gate

    assert gate.status == "pass"
    assert gate.reasons == []
    assert gate.cursor_delta == 0
    assert gate.entry_count_delta == 0
    assert gate.verification.status == "match"
  end

  test "SCN-029 drift verification paths produce deterministic gate fail reason sets" do
    model = model_with_replay_entries()
    {:ok, compacted_log} = ReplayLog.compact(model.recovery_state.replay_log, %{keep_last: 1})
    {:ok, drift_export} = ReplayLog.export(compacted_log)

    {updated_model, []} =
      Runtime.update(
        model,
        Message.replay_verification_gate_requested(%{expected_export: drift_export})
      )

    gate = updated_model.recovery_state.last_replay_verification_gate
    reason_codes = Enum.map(gate.reasons, & &1.code)

    assert gate.status == "fail"
    assert gate.verification.status == "drift"
    assert gate.cursor_delta == 0
    assert gate.entry_count_delta == 3
    assert "status_not_allowed" in reason_codes
    assert "entry_count_delta_exceeded" in reason_codes
    assert "entry_mismatch_not_allowed" in reason_codes
  end

  test "SCN-029 repeated equivalent gate evaluations produce equivalent gate traces" do
    flow_trace = fn ->
      model = model_with_replay_entries()
      {model, []} = Runtime.update(model, Message.replay_export_requested(%{}))
      expected_export = model.recovery_state.last_replay_export

      {model, []} =
        Runtime.update(
          model,
          Message.replay_verification_gate_requested(%{expected_export: expected_export})
        )

      pass_gate = model.recovery_state.last_replay_verification_gate
      {:ok, compacted_log} = ReplayLog.compact(model.recovery_state.replay_log, %{keep_last: 1})
      {:ok, drift_export} = ReplayLog.export(compacted_log)

      {model, []} =
        Runtime.update(
          model,
          Message.replay_verification_gate_requested(%{expected_export: drift_export})
        )

      fail_gate = model.recovery_state.last_replay_verification_gate

      %{
        replay_cursor: model.recovery_state.replay_cursor,
        pass_gate: %{status: pass_gate.status, reasons: pass_gate.reasons},
        fail_gate: %{status: fail_gate.status, reasons: fail_gate.reasons},
        notices: Enum.take(model.view_state.notices, 2)
      }
    end

    assert flow_trace.() == flow_trace.()
  end
end
