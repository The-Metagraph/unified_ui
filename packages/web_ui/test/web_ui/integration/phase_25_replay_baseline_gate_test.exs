defmodule WebUi.Integration.Phase25ReplayBaselineGateTest do
  use ExUnit.Case, async: true

  alias WebUi.Persistence.ReplayLog
  alias WebUi.Ui.Message
  alias WebUi.Ui.Runtime

  @moduletag :conformance

  defp model_with_session do
    {:ok, model, _commands} =
      Runtime.init(%{
        runtime_context: %{
          correlation_id: "corr-25",
          request_id: "req-25",
          session_id: "sess-25"
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
        context: %{correlation_id: "corr-25", request_id: "req-25", session_id: "sess-25"}
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

  test "SCN-030 equivalent replay flows produce deterministic baseline capture envelopes" do
    model = model_with_replay_entries()

    {updated_model, []} =
      Runtime.update(
        model,
        Message.replay_baseline_capture_requested(%{metadata: %{label: "release-25"}})
      )

    baseline = updated_model.recovery_state.last_replay_baseline

    assert baseline.format == "web_ui.replay_baseline.v1"
    assert baseline.cursor == 4
    assert baseline.entry_count == 4
    assert baseline.metadata == %{label: "release-25"}
    assert baseline.export.cursor == 4
    assert length(baseline.export.entries) == 4
    assert baseline.checkpoint_id == baseline.export.checkpoint_id
  end

  test "SCN-030 baseline drift inputs produce deterministic baseline gate fail reason sets" do
    model = model_with_replay_entries()
    {:ok, compacted_log} = ReplayLog.compact(model.recovery_state.replay_log, %{keep_last: 1})
    {:ok, drift_baseline} = ReplayLog.capture_baseline(compacted_log, %{label: "release-24"})

    {updated_model, []} =
      Runtime.update(
        model,
        Message.replay_baseline_gate_requested(%{baseline: drift_baseline})
      )

    baseline_gate = updated_model.recovery_state.last_replay_baseline_gate
    reason_codes = Enum.map(baseline_gate.gate.reasons, & &1.code)

    assert baseline_gate.status == "fail"
    assert baseline_gate.gate.status == "fail"
    assert baseline_gate.gate.verification.status == "drift"
    assert baseline_gate.gate.cursor_delta == 0
    assert baseline_gate.gate.entry_count_delta == 3
    assert "status_not_allowed" in reason_codes
    assert "entry_count_delta_exceeded" in reason_codes
    assert "entry_mismatch_not_allowed" in reason_codes
  end

  test "SCN-030 repeated equivalent baseline gate evaluations produce equivalent baseline gate traces" do
    flow_trace = fn ->
      model = model_with_replay_entries()

      {model, []} =
        Runtime.update(
          model,
          Message.replay_baseline_capture_requested(%{metadata: %{label: "release-25"}})
        )

      baseline = model.recovery_state.last_replay_baseline

      {model, []} = Runtime.update(model, Message.replay_baseline_gate_requested(%{}))
      pass_gate = model.recovery_state.last_replay_baseline_gate

      {:ok, compacted_log} = ReplayLog.compact(model.recovery_state.replay_log, %{keep_last: 1})
      {:ok, drift_baseline} = ReplayLog.capture_baseline(compacted_log, %{label: "release-24"})

      {model, []} =
        Runtime.update(
          model,
          Message.replay_baseline_gate_requested(%{baseline: drift_baseline})
        )

      fail_gate = model.recovery_state.last_replay_baseline_gate

      %{
        replay_cursor: model.recovery_state.replay_cursor,
        baseline: %{
          cursor: baseline.cursor,
          checkpoint_id: baseline.checkpoint_id,
          entry_count: baseline.entry_count
        },
        pass_gate: %{status: pass_gate.status, reasons: pass_gate.gate.reasons},
        fail_gate: %{status: fail_gate.status, reasons: fail_gate.gate.reasons},
        notices: Enum.take(model.view_state.notices, 3)
      }
    end

    assert flow_trace.() == flow_trace.()
  end
end
