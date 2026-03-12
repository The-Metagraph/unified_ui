defmodule WebUi.Integration.Phase19ScopeResolutionTest do
  use ExUnit.Case, async: true

  alias WebUi.Ui.Message
  alias WebUi.Ui.Runtime

  @moduletag :conformance

  defp model_with_context(overrides) when is_map(overrides) do
    {:ok, model, _commands} =
      Runtime.init(%{
        runtime_context:
          Map.merge(
            %{
              correlation_id: "corr-19",
              request_id: "req-19",
              session_id: "sess-19"
            },
            overrides
          )
      })

    model
  end

  defp click_message(data_overrides \\ %{}) do
    Message.widget_event(%{
      type: "unified.button.clicked",
      widget_id: "save_button",
      widget_kind: "button",
      data: Map.merge(%{action: "save"}, data_overrides)
    })
  end

  test "SCN-024 outbound dispatch includes deterministic scope metadata" do
    model =
      model_with_context(%{
        scope_id: "workspace-a",
        scope_type: "workspace"
      })

    {_, [context_scoped_command]} = Runtime.update(model, click_message())
    context_scoped_data = context_scoped_command.payload.event["data"]

    assert context_scoped_data["scope_id"] == "workspace-a"
    assert context_scoped_data["scope_type"] == "workspace"
    assert context_scoped_data["scope_source"] == "runtime_context"

    {_, [event_scoped_command]} =
      Runtime.update(model, click_message(%{scope_id: "workspace-b", scope_type: "workspace"}))

    event_scoped_data = event_scoped_command.payload.event["data"]

    assert event_scoped_data["scope_id"] == "workspace-b"
    assert event_scoped_data["scope_type"] == "workspace"
    assert event_scoped_data["scope_source"] == "event_data"
  end

  test "SCN-024 denied scopes do not dispatch and emit typed authorization errors" do
    model =
      model_with_context(%{
        scope_policy: %{allow_scope_ids: ["workspace-1"]}
      })

    {updated_model, commands} = Runtime.update(model, click_message(%{scope_id: "workspace-2"}))

    assert commands == []
    assert updated_model.outbound_queue == []
    assert updated_model.last_error.error_code == "scope.resolution.scope_not_allowed"

    assert hd(updated_model.view_state.notices) ==
             "policy:deny:save_button:unified.button.clicked:scope.resolution.scope_not_allowed"
  end

  test "SCN-024 repeated equivalent scope flows produce equivalent traces" do
    flow_trace = fn ->
      model =
        model_with_context(%{
          scope_id: "workspace-trace",
          scope_type: "workspace"
        })

      {model, [command]} = Runtime.update(model, click_message())
      data = command.payload.event["data"]
      turn_id = data["turn_id"]

      {final_model, []} =
        Runtime.update(
          model,
          Message.websocket_recv(%{
            result: %{
              service: "ui.preferences",
              operation: "save_preferences",
              outcome: "ok",
              payload: %{turn_id: turn_id},
              context: %{correlation_id: "corr-19", request_id: "req-19", session_id: "sess-19"}
            }
          })
        )

      %{
        scope_id: data["scope_id"],
        scope_type: data["scope_type"],
        scope_source: data["scope_source"],
        dispatch_sequence: data["dispatch_sequence"],
        turn_id: turn_id,
        active_turn_after_dispatch: model.slice_state.active_turn_id,
        completed_turn_after_result: final_model.slice_state.last_completed_turn_id
      }
    end

    assert flow_trace.() == flow_trace.()
  end
end
