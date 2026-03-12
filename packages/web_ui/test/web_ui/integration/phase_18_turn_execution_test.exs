defmodule WebUi.Integration.Phase18TurnExecutionTest do
  use ExUnit.Case, async: true

  alias WebUi.Ui.Message
  alias WebUi.Ui.Runtime

  @moduletag :conformance

  defp model_with_session do
    {:ok, model, _commands} =
      Runtime.init(%{
        runtime_context: %{
          correlation_id: "corr-18",
          request_id: "req-18",
          session_id: "sess-18"
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

  test "SCN-023 outbound dispatch includes deterministic turn_id metadata" do
    model = model_with_session()

    {model, [first]} = Runtime.update(model, click_message("save"))
    {model, [second]} = Runtime.update(model, click_message("save_as"))
    {_model, [third]} = Runtime.update(model, click_message("publish"))

    assert first.payload.event["data"]["dispatch_sequence"] == 1
    assert second.payload.event["data"]["dispatch_sequence"] == 2
    assert third.payload.event["data"]["dispatch_sequence"] == 3

    assert first.payload.event["data"]["turn_id"] == "turn-000001"
    assert second.payload.event["data"]["turn_id"] == "turn-000002"
    assert third.payload.event["data"]["turn_id"] == "turn-000003"
  end

  test "SCN-023 result reconciliation clears active turn and records completed turn deterministically" do
    model = model_with_session()

    {model, [command]} = Runtime.update(model, click_message("save"))
    turn_id = command.payload.event["data"]["turn_id"]

    assert model.slice_state.active_turn_id == turn_id
    assert model.slice_state.last_completed_turn_id == nil

    {updated_model, []} =
      Runtime.update(
        model,
        Message.websocket_recv(%{
          result: %{
            service: "ui.preferences",
            operation: "save_preferences",
            outcome: "ok",
            payload: %{turn_id: turn_id},
            context: %{correlation_id: "corr-18", request_id: "req-18", session_id: "sess-18"}
          }
        })
      )

    assert updated_model.slice_state.active_turn_id == nil
    assert updated_model.slice_state.last_completed_turn_id == turn_id
    assert updated_model.slice_state.last_outcome == :ok
  end

  test "SCN-023 repeated equivalent flows produce equivalent turn progression traces" do
    flow_trace = fn ->
      model = model_with_session()

      {model, [command]} = Runtime.update(model, click_message("save"))
      turn_id = command.payload.event["data"]["turn_id"]
      dispatch_sequence = command.payload.event["data"]["dispatch_sequence"]

      {final_model, []} =
        Runtime.update(
          model,
          Message.websocket_recv(%{
            result: %{
              service: "ui.preferences",
              operation: "save_preferences",
              outcome: "ok",
              payload: %{turn_id: turn_id},
              context: %{correlation_id: "corr-18", request_id: "req-18", session_id: "sess-18"}
            }
          })
        )

      %{
        dispatch_sequence: dispatch_sequence,
        emitted_turn_id: turn_id,
        active_turn_after_dispatch: model.slice_state.active_turn_id,
        active_turn_after_result: final_model.slice_state.active_turn_id,
        completed_turn_after_result: final_model.slice_state.last_completed_turn_id
      }
    end

    assert flow_trace.() == flow_trace.()
  end
end
