defmodule WebUi.Integration.Phase12BurstOrderingTest do
  use ExUnit.Case, async: true

  alias WebUi.Channel
  alias WebUi.Ui.Message
  alias WebUi.Ui.Runtime

  @moduletag :conformance

  defp model_with_session do
    {:ok, model, _commands} =
      Runtime.init(%{
        runtime_context: %{
          correlation_id: "corr-12",
          request_id: "req-12",
          session_id: "sess-12"
        }
      })

    model
  end

  defp dispatch_burst(model) do
    ["save", "save_as", "publish"]
    |> Enum.reduce({model, []}, fn action, {runtime_model, commands} ->
      {updated_model, [command]} =
        Runtime.update(
          runtime_model,
          Message.widget_event(%{
            type: "unified.button.clicked",
            widget_id: "save_button",
            widget_kind: "button",
            data: %{action: action}
          })
        )

      {updated_model, commands ++ [command]}
    end)
  end

  test "SCN-017 emits monotonic dispatch_sequence under burst interactions" do
    model = model_with_session()

    {updated_model, commands} = dispatch_burst(model)

    sequence_values =
      Enum.map(commands, fn command ->
        command.payload.event["data"]["dispatch_sequence"]
      end)

    assert sequence_values == [1, 2, 3]
    assert updated_model.slice_state.dispatch_sequence == 3
  end

  test "SCN-017 channel ingress and egress preserve burst dispatch sequence ordering" do
    model = model_with_session()
    {_updated_model, commands} = dispatch_burst(model)

    responses =
      Enum.map(commands, fn command ->
        assert {:ok, response} =
                 Channel.handle_client_message(
                   "webui:runtime:v1",
                   command.event_name,
                   command.payload
                 )

        response
      end)

    response_sequences =
      Enum.map(responses, fn response ->
        response.payload.event["data"]["dispatch_sequence"]
      end)

    assert response_sequences == [1, 2, 3]
    assert Enum.all?(responses, &(&1.payload.event["correlation_id"] == "corr-12"))
    assert Enum.all?(responses, &(&1.payload.event["request_id"] == "req-12"))
  end

  test "SCN-017 replay paths preserve original dispatch_sequence values" do
    model = model_with_session()

    {model, [initial_command]} =
      Runtime.update(
        model,
        Message.widget_event(%{
          type: "unified.form.submitted",
          widget_id: "prefs_form",
          widget_kind: "form",
          data: %{action: "submit", preference_key: "theme", value: "dark"}
        })
      )

    {model, []} =
      Runtime.update(
        model,
        Message.websocket_recv(%{
          result: %{
            service: "ui.preferences",
            operation: "save_preferences",
            outcome: "error",
            error: %{
              error_code: "first_slice.retryable_dependency_error",
              category: "dependency",
              retryable: true,
              correlation_id: "corr-12"
            },
            context: %{correlation_id: "corr-12", request_id: "req-12", session_id: "sess-12"}
          }
        })
      )

    {updated_model, [retry_command]} = Runtime.update(model, Message.retry_requested(%{}))

    assert retry_command == initial_command
    assert retry_command.payload.event["data"]["dispatch_sequence"] == 1
    assert hd(updated_model.inbound_history).event == :retry_requested
    assert hd(updated_model.inbound_history).payload.dispatch_sequence == 1
  end
end
