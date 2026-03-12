defmodule WebUi.Integration.Phase17PolicyAuthorizationTest do
  use ExUnit.Case, async: true

  alias WebUi.Ui.Message
  alias WebUi.Ui.Runtime

  @moduletag :conformance

  defp model_with_context(overrides) when is_map(overrides) do
    base_context = %{
      correlation_id: "corr-17",
      request_id: "req-17"
    }

    {:ok, model, _commands} =
      Runtime.init(%{
        runtime_context: Map.merge(base_context, overrides)
      })

    model
  end

  defp click_event_payload(action \\ "save") do
    %{
      type: "unified.button.clicked",
      widget_id: "save_button",
      widget_kind: "button",
      data: %{action: action}
    }
  end

  test "SCN-022 denied events do not dispatch and surface typed authorization errors" do
    model =
      model_with_context(%{
        policy: %{deny_event_types: ["unified.button.clicked"]}
      })

    {updated_model, commands} = Runtime.update(model, Message.widget_event(click_event_payload()))

    assert commands == []
    assert updated_model.outbound_queue == []
    assert updated_model.last_error.error_code == "policy.authorization.event_type_denied"

    assert hd(updated_model.view_state.notices) ==
             "policy:deny:save_button:unified.button.clicked:policy.authorization.event_type_denied"
  end

  test "SCN-022 allowed events dispatch when policy requirements are satisfied" do
    model =
      model_with_context(%{
        user_id: "user-17",
        policy: %{
          allow_event_types: ["unified.button.clicked"],
          require_user_for_event_types: ["unified.button.clicked"]
        }
      })

    {updated_model, [command]} =
      Runtime.update(model, Message.widget_event(click_event_payload("publish")))

    assert command.kind == :ws_push
    assert command.event_name == "runtime.event.send.v1"
    assert command.payload.event["type"] == "unified.button.clicked"
    assert command.payload.event["data"]["action"] == "publish"
    assert updated_model.last_error == nil
    assert updated_model.view_state.ui_error == nil
  end

  test "SCN-022 malformed policy shapes fail closed deterministically" do
    model =
      model_with_context(%{
        policy: "invalid-policy-document"
      })

    {updated_model_a, commands_a} =
      Runtime.update(model, Message.widget_event(click_event_payload()))

    {updated_model_b, commands_b} =
      Runtime.update(model, Message.widget_event(click_event_payload()))

    assert commands_a == []
    assert commands_b == []
    assert updated_model_a.last_error.error_code == "policy.authorization.invalid_policy"
    assert updated_model_b.last_error.error_code == "policy.authorization.invalid_policy"
    assert updated_model_a.view_state.ui_error.code == updated_model_b.view_state.ui_error.code
  end
end
