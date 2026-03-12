defmodule WebUi.Integration.Phase23ReplayVerificationTest do
  use ExUnit.Case, async: true

  alias WebUi.Persistence.ReplayLog
  alias WebUi.Ui.Message
  alias WebUi.Ui.Runtime

  @moduletag :conformance

  defp model_with_session do
    {:ok, model, _commands} =
      Runtime.init(%{
        runtime_context: %{
          correlation_id: "corr-23",
          request_id: "req-23",
          session_id: "sess-23"
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
        context: %{correlation_id: "corr-23", request_id: "req-23", session_id: "sess-23"}
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

  test "SCN-028 equivalent replay logs produce deterministic verification match summaries" do
    model = model_with_replay_entries()
    {model, []} = Runtime.update(model, Message.replay_export_requested(%{}))
    expected_export = model.recovery_state.last_replay_export

    {updated_model, []} =
      Runtime.update(
        model,
        Message.replay_verification_requested(%{expected_export: expected_export})
      )

    verification = updated_model.recovery_state.last_replay_verification

    assert verification.status == "match"
    assert verification.actual_cursor == 4
    assert verification.expected_cursor == 4
    assert verification.first_drift == nil
  end

  test "SCN-028 replay drift paths produce deterministic first-drift diagnostics" do
    model = model_with_replay_entries()
    {:ok, compacted_log} = ReplayLog.compact(model.recovery_state.replay_log, %{keep_last: 1})
    {:ok, drift_export} = ReplayLog.export(compacted_log)

    {updated_model, []} =
      Runtime.update(
        model,
        Message.replay_verification_requested(%{expected_export: drift_export})
      )

    verification = updated_model.recovery_state.last_replay_verification

    assert verification.status == "drift"
    assert verification.actual_cursor == 4
    assert verification.expected_cursor == 4
    assert verification.first_drift.reason == "entry_mismatch"
    assert verification.first_drift.cursor == 1
  end

  test "SCN-028 repeated equivalent verification flows produce equivalent traces" do
    flow_trace = fn ->
      model = model_with_replay_entries()
      {model, []} = Runtime.update(model, Message.replay_export_requested(%{}))
      expected_export = model.recovery_state.last_replay_export

      {model, []} =
        Runtime.update(
          model,
          Message.replay_verification_requested(%{expected_export: expected_export})
        )

      {:ok, compacted_log} = ReplayLog.compact(model.recovery_state.replay_log, %{keep_last: 1})
      {:ok, drift_export} = ReplayLog.export(compacted_log)

      {model, []} =
        Runtime.update(
          model,
          Message.replay_verification_requested(%{expected_export: drift_export})
        )

      %{
        replay_cursor: model.recovery_state.replay_cursor,
        last_verification: model.recovery_state.last_replay_verification,
        notices: Enum.take(model.view_state.notices, 2),
        verification_events:
          model.inbound_history
          |> Enum.filter(&(&1.event == :replay_verification_requested))
          |> Enum.take(2)
      }
    end

    assert flow_trace.() == flow_trace.()
  end
end
