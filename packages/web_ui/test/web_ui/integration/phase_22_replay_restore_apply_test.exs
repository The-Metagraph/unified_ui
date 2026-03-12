defmodule WebUi.Integration.Phase22ReplayRestoreApplyTest do
  use ExUnit.Case, async: true

  alias WebUi.Ui.Message
  alias WebUi.Ui.Runtime

  @moduletag :conformance

  defp model_with_session do
    {:ok, model, _commands} =
      Runtime.init(%{
        runtime_context: %{
          correlation_id: "corr-22",
          request_id: "req-22",
          session_id: "sess-22"
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
        context: %{correlation_id: "corr-22", request_id: "req-22", session_id: "sess-22"}
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

  test "SCN-027 replay restore requests rehydrate deterministic cursor/checkpoint diagnostics" do
    source_model = model_with_replay_entries()
    {source_model, []} = Runtime.update(source_model, Message.replay_export_requested(%{}))
    export_payload = source_model.recovery_state.last_replay_export
    target_model = model_with_session()

    {restored_model, []} =
      Runtime.update(target_model, Message.replay_restore_requested(%{export: export_payload}))

    assert restored_model.recovery_state.replay_cursor == 4
    assert restored_model.recovery_state.replay_log.cursor == 4
    assert restored_model.recovery_state.last_replay_restore.entry_count == 4

    assert String.starts_with?(
             restored_model.recovery_state.last_replay_checkpoint_id,
             "replay-000004-"
           )
  end

  test "SCN-027 post-restore dispatch/result flows preserve replay cursor continuity" do
    source_model = model_with_replay_entries()
    {source_model, []} = Runtime.update(source_model, Message.replay_export_requested(%{}))
    export_payload = source_model.recovery_state.last_replay_export
    target_model = model_with_session()

    {restored_model, []} =
      Runtime.update(target_model, Message.replay_restore_requested(%{export: export_payload}))

    {model, [command]} = Runtime.update(restored_model, click_message("save_after_restore"))
    turn_id = command.payload.event["data"]["turn_id"]
    {model, []} = Runtime.update(model, result_message(turn_id))

    replay_log = model.recovery_state.replay_log

    assert model.recovery_state.replay_cursor == 6
    assert replay_log.cursor == 6
    assert Enum.map(replay_log.entries, & &1.cursor) == [1, 2, 3, 4, 5, 6]

    assert Enum.slice(Enum.map(replay_log.entries, & &1.direction), -2, 2) == [
             :outbound,
             :inbound
           ]

    assert String.starts_with?(model.recovery_state.last_replay_checkpoint_id, "replay-000006-")
  end

  test "SCN-027 repeated equivalent restore/apply flows produce equivalent replay traces" do
    flow_trace = fn ->
      source_model = model_with_replay_entries()
      {source_model, []} = Runtime.update(source_model, Message.replay_export_requested(%{}))
      export_payload = source_model.recovery_state.last_replay_export
      target_model = model_with_session()

      {model, []} =
        Runtime.update(target_model, Message.replay_restore_requested(%{export: export_payload}))

      {model, [command]} = Runtime.update(model, click_message("save_after_restore"))
      turn_id = command.payload.event["data"]["turn_id"]
      {model, []} = Runtime.update(model, result_message(turn_id))
      {model, []} = Runtime.update(model, Message.replay_export_requested(%{}))

      replay_export = model.recovery_state.last_replay_export

      %{
        cursor: replay_export.cursor,
        checkpoint_id: replay_export.checkpoint_id,
        entry_count: length(replay_export.entries),
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
