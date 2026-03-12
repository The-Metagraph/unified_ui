defmodule WebUi.Integration.Phase20PersistenceReplayTest do
  use ExUnit.Case, async: true

  alias WebUi.Ui.Message
  alias WebUi.Ui.Runtime

  @moduletag :conformance

  defp model_with_session do
    {:ok, model, _commands} =
      Runtime.init(%{
        runtime_context: %{
          correlation_id: "corr-20",
          request_id: "req-20",
          session_id: "sess-20"
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
        context: %{correlation_id: "corr-20", request_id: "req-20", session_id: "sess-20"}
      }
    })
  end

  test "SCN-025 dispatch/result flows advance replay cursor deterministically" do
    model = model_with_session()
    assert model.recovery_state.replay_cursor == 0
    assert model.recovery_state.last_replay_checkpoint_id == nil

    {model, [command]} = Runtime.update(model, click_message("save"))
    turn_id = command.payload.event["data"]["turn_id"]

    assert model.recovery_state.replay_cursor == 1
    assert model.recovery_state.replay_log.cursor == 1
    assert Enum.map(model.recovery_state.replay_log.entries, & &1.direction) == [:outbound]

    {updated_model, []} = Runtime.update(model, result_message(turn_id))

    assert updated_model.recovery_state.replay_cursor == 2
    assert updated_model.recovery_state.replay_log.cursor == 2

    assert Enum.map(updated_model.recovery_state.replay_log.entries, & &1.direction) == [
             :outbound,
             :inbound
           ]
  end

  test "SCN-025 checkpoint identifiers evolve deterministically with replay appends" do
    model = model_with_session()

    {model, [command]} = Runtime.update(model, click_message("save"))
    first_checkpoint = model.recovery_state.last_replay_checkpoint_id
    turn_id = command.payload.event["data"]["turn_id"]

    assert String.starts_with?(first_checkpoint, "replay-000001-")

    {updated_model, []} = Runtime.update(model, result_message(turn_id))
    second_checkpoint = updated_model.recovery_state.last_replay_checkpoint_id

    assert String.starts_with?(second_checkpoint, "replay-000002-")
    refute second_checkpoint == first_checkpoint
  end

  test "SCN-025 repeated equivalent flows produce equivalent replay traces" do
    flow_trace = fn ->
      model = model_with_session()

      {model, [command]} = Runtime.update(model, click_message("save"))
      turn_id = command.payload.event["data"]["turn_id"]
      {updated_model, []} = Runtime.update(model, result_message(turn_id))
      replay_log = updated_model.recovery_state.replay_log

      %{
        replay_cursor: updated_model.recovery_state.replay_cursor,
        checkpoint_id: updated_model.recovery_state.last_replay_checkpoint_id,
        entries:
          Enum.map(replay_log.entries, fn entry ->
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
