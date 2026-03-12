defmodule WebUi.Integration.Phase15SessionResumeContinuityTest do
  use ExUnit.Case, async: true

  alias WebUi.Ui.Message
  alias WebUi.Ui.Runtime

  @moduletag :conformance

  defp model_with_session do
    {:ok, model, _commands} =
      Runtime.init(%{
        runtime_context: %{
          correlation_id: "corr-15",
          request_id: "req-15",
          session_id: "sess-15"
        }
      })

    model
  end

  defp dispatch_button_click(model, action) when is_binary(action) do
    {updated_model, [_command]} =
      Runtime.update(
        model,
        Message.widget_event(%{
          type: "unified.button.clicked",
          widget_id: "save_button",
          widget_kind: "button",
          data: %{action: action}
        })
      )

    updated_model
  end

  test "SCN-020 reconnect commands include deterministic resume cursors" do
    model =
      model_with_session()
      |> dispatch_button_click("save")
      |> dispatch_button_click("publish")

    assert model.slice_state.dispatch_sequence == 2

    {updated_model, [reconnect_command]} =
      Runtime.update(model, Message.websocket_disconnected(%{reason: "socket_lost"}))

    assert reconnect_command.kind == :ws_join
    assert reconnect_command.topic == "webui:runtime:session:sess-15:v1"
    assert reconnect_command.payload.resume_from_sequence == 2
    assert reconnect_command.payload.session_id == "sess-15"
    assert updated_model.recovery_state.session_resume_cursor == 2
    assert hd(updated_model.inbound_history).event == :ws_disconnected
    assert hd(updated_model.inbound_history).payload.resume_from_sequence == 2
  end

  test "SCN-020 dedupe behavior emits new reconnect join when resume cursor changes" do
    model = model_with_session()

    {model, [first_reconnect]} =
      Runtime.update(model, Message.websocket_disconnected(%{reason: "socket_lost"}))

    model = put_in(model.slice_state.dispatch_sequence, 1)

    {updated_model, [second_reconnect]} =
      Runtime.update(model, Message.websocket_disconnected(%{reason: "socket_lost"}))

    assert first_reconnect.payload.resume_from_sequence == 0
    assert second_reconnect.payload.resume_from_sequence == 1
    assert hd(updated_model.view_state.notices) == "reconnect:socket_lost"

    join_commands =
      Enum.filter(updated_model.outbound_queue, fn command ->
        command.kind == :ws_join and command.topic == "webui:runtime:session:sess-15:v1"
      end)

    assert Enum.map(join_commands, & &1.payload.resume_from_sequence) == [0, 1]
    assert updated_model.recovery_state.session_resume_cursor == 1
  end

  test "SCN-020 resume acknowledgement updates recovery diagnostics deterministically" do
    model =
      model_with_session()
      |> dispatch_button_click("save")
      |> dispatch_button_click("save_as")
      |> dispatch_button_click("publish")

    {model, [reconnect_command]} =
      Runtime.update(model, Message.websocket_disconnected(%{reason: "socket_lost"}))

    resume_sequence = reconnect_command.payload.resume_from_sequence
    assert resume_sequence == 3

    {updated_model, []} =
      Runtime.update(
        model,
        Message.websocket_joined(%{
          topic: reconnect_command.topic,
          resumed_from_sequence: resume_sequence
        })
      )

    assert updated_model.connection_state == :connected
    assert updated_model.recovery_state.session_resume_cursor == nil
    assert updated_model.recovery_state.last_resumed_sequence == 3
    assert hd(updated_model.view_state.notices) == "resume:ack:3"
    assert hd(updated_model.inbound_history).event == :ws_joined
    assert hd(updated_model.inbound_history).payload.resumed_from_sequence == 3
  end
end
