defmodule WebUi.Integration.Phase21ReplayRetentionExportTest do
  use ExUnit.Case, async: true

  alias WebUi.Ui.Message
  alias WebUi.Ui.Runtime

  @moduletag :conformance

  defp model_with_session do
    {:ok, model, _commands} =
      Runtime.init(%{
        runtime_context: %{
          correlation_id: "corr-21",
          request_id: "req-21",
          session_id: "sess-21"
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
        context: %{correlation_id: "corr-21", request_id: "req-21", session_id: "sess-21"}
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

  test "SCN-026 snapshot requests return deterministic cursor/checkpoint diagnostics" do
    model = model_with_replay_entries()

    {updated_model, []} =
      Runtime.update(model, Message.replay_snapshot_requested(%{from_cursor: 2, limit: 1}))

    snapshot = updated_model.recovery_state.last_replay_snapshot

    assert snapshot.cursor == 4
    assert snapshot.entry_count == 1
    assert Enum.map(snapshot.entries, & &1.cursor) == [3]
    assert String.starts_with?(snapshot.checkpoint_id, "replay-000004-")
  end

  test "SCN-026 compaction requests preserve cursor continuity with retained entries" do
    model = model_with_replay_entries()

    {updated_model, []} =
      Runtime.update(model, Message.replay_compaction_requested(%{keep_last: 2}))

    replay_log = updated_model.recovery_state.replay_log

    assert updated_model.recovery_state.replay_cursor == 4
    assert updated_model.recovery_state.replay_retention_limit == 2
    assert Enum.map(replay_log.entries, & &1.cursor) == [3, 4]
    assert Enum.map(replay_log.entries, & &1.direction) == [:outbound, :inbound]

    assert String.starts_with?(
             updated_model.recovery_state.last_replay_checkpoint_id,
             "replay-000004-"
           )
  end

  test "SCN-026 repeated equivalent replay-control flows produce equivalent export payloads" do
    flow_trace = fn ->
      model = model_with_replay_entries()

      {model, []} =
        Runtime.update(model, Message.replay_snapshot_requested(%{from_cursor: 2, limit: 1}))

      {model, []} = Runtime.update(model, Message.replay_compaction_requested(%{keep_last: 2}))
      {model, []} = Runtime.update(model, Message.replay_export_requested(%{}))

      replay_export = model.recovery_state.last_replay_export

      %{
        cursor: replay_export.cursor,
        checkpoint_id: replay_export.checkpoint_id,
        replay_cursor: model.recovery_state.replay_cursor,
        entries:
          Enum.map(replay_export.entries, fn entry ->
            %{
              cursor: entry.cursor,
              direction: entry.direction,
              event: entry.event,
              metadata: entry.metadata
            }
          end)
      }
    end

    assert flow_trace.() == flow_trace.()
  end
end
