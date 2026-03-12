defmodule WebUi.Ui.RuntimeUpdateTest do
  use ExUnit.Case, async: true

  alias WebUi.Ui.Message
  alias WebUi.Ui.Runtime

  defp booted_model do
    {:ok, model, _commands} =
      Runtime.init(%{runtime_context: %{correlation_id: "corr-220", request_id: "req-220"}})

    model
  end

  test "widget events map to canonical runtime.event.send.v1 commands" do
    model = booted_model()

    widget_msg =
      Message.widget_event(%{
        type: "unified.button.clicked",
        widget_id: "save_button",
        widget_kind: "button",
        data: %{action: "save"}
      })

    {updated_model, [command]} = Runtime.update(model, widget_msg)

    assert command.kind == :ws_push
    assert command.event_name == "runtime.event.send.v1"
    assert command.payload.event["type"] == "unified.button.clicked"
    assert command.payload.event["correlation_id"] == "corr-220"
    assert command.payload.event["request_id"] == "req-220"
    assert List.last(updated_model.outbound_queue) == command
    assert updated_model.recovery_state.replay_cursor == 1
    assert updated_model.recovery_state.replay_log.cursor == 1
    assert hd(updated_model.recovery_state.replay_log.entries).direction == :outbound

    assert String.starts_with?(
             updated_model.recovery_state.last_replay_checkpoint_id,
             "replay-000001-"
           )
  end

  test "click, change, and submit events populate route-key compatibility fields" do
    model = booted_model()

    {_, [click_command]} =
      Runtime.update(
        model,
        Message.widget_event(%{
          type: "unified.button.clicked",
          widget_id: "save_button",
          widget_kind: "button",
          data: %{action: "save"}
        })
      )

    click_data = click_command.payload.event["data"]
    assert click_data["action"] == "save"
    assert click_data["button_id"] == "save_button"
    assert click_data["widget_id"] == "save_button"
    assert click_data["id"] == "save_button"

    {_, [change_command]} =
      Runtime.update(
        model,
        Message.widget_event(%{
          type: "unified.input.changed",
          widget_id: "email_input",
          widget_kind: "text_input",
          data: %{value: "person@example.com"}
        })
      )

    change_data = change_command.payload.event["data"]
    assert change_data["input_id"] == "email_input"
    assert change_data["widget_id"] == "email_input"
    assert change_data["field"] == "email_input"
    assert change_data["action"] == "change"
    assert change_data["id"] == "email_input"

    {_, [submit_command]} =
      Runtime.update(
        model,
        Message.widget_event(%{
          type: "unified.form.submitted",
          widget_id: "login_form",
          widget_kind: "form",
          data: %{}
        })
      )

    submit_data = submit_command.payload.event["data"]
    assert submit_data["form_id"] == "login_form"
    assert submit_data["action"] == "submit"
    assert submit_data["id"] == "login_form"
  end

  test "resolved scope metadata is attached to outbound dispatch payloads deterministically" do
    {:ok, model, _commands} =
      Runtime.init(%{
        runtime_context: %{
          correlation_id: "corr-scope-prop",
          request_id: "req-scope-prop",
          scope_id: "tenant-42",
          scope_type: "tenant"
        }
      })

    {_, [context_scoped_command]} =
      Runtime.update(
        model,
        Message.widget_event(%{
          type: "unified.button.clicked",
          widget_id: "save_button",
          widget_kind: "button",
          data: %{action: "save"}
        })
      )

    context_scoped_data = context_scoped_command.payload.event["data"]
    assert context_scoped_data["scope_id"] == "tenant-42"
    assert context_scoped_data["scope_type"] == "tenant"
    assert context_scoped_data["scope_source"] == "runtime_context"

    {_, [event_scoped_command]} =
      Runtime.update(
        model,
        Message.widget_event(%{
          type: "unified.button.clicked",
          widget_id: "save_button",
          widget_kind: "button",
          data: %{action: "save", scope_id: "workspace-alpha", scope_type: "workspace"}
        })
      )

    event_scoped_data = event_scoped_command.payload.event["data"]
    assert event_scoped_data["scope_id"] == "workspace-alpha"
    assert event_scoped_data["scope_type"] == "workspace"
    assert event_scoped_data["scope_source"] == "event_data"
  end

  test "burst widget events preserve deterministic dispatch sequence ordering" do
    model = booted_model()

    {model, [first]} =
      Runtime.update(
        model,
        Message.widget_event(%{
          type: "unified.button.clicked",
          widget_id: "save_button",
          widget_kind: "button",
          data: %{action: "save"}
        })
      )

    {model, [second]} =
      Runtime.update(
        model,
        Message.widget_event(%{
          type: "unified.button.clicked",
          widget_id: "save_button",
          widget_kind: "button",
          data: %{action: "save_as"}
        })
      )

    {model, [third]} =
      Runtime.update(
        model,
        Message.widget_event(%{
          type: "unified.button.clicked",
          widget_id: "save_button",
          widget_kind: "button",
          data: %{action: "publish"}
        })
      )

    sequence_values =
      [first, second, third]
      |> Enum.map(fn command -> command.payload.event["data"]["dispatch_sequence"] end)

    turn_ids =
      [first, second, third]
      |> Enum.map(fn command -> command.payload.event["data"]["turn_id"] end)

    assert sequence_values == [1, 2, 3]
    assert turn_ids == ["turn-000001", "turn-000002", "turn-000003"]

    queue_sequence_values =
      model.outbound_queue
      |> Enum.map(fn command -> command.payload.event["data"]["dispatch_sequence"] end)

    assert queue_sequence_values == [1, 2, 3]
    assert model.slice_state.dispatch_sequence == 3
    assert model.slice_state.active_turn_id == "turn-000003"
    assert first.payload.event["id"] != second.payload.event["id"]
    assert second.payload.event["id"] != third.payload.event["id"]
  end

  test "service results reconcile active turns into completed turn tracking deterministically" do
    model = booted_model()

    {model, [command]} =
      Runtime.update(
        model,
        Message.widget_event(%{
          type: "unified.button.clicked",
          widget_id: "save_button",
          widget_kind: "button",
          data: %{action: "save"}
        })
      )

    turn_id = command.payload.event["data"]["turn_id"]
    assert turn_id == "turn-000001"
    assert model.slice_state.active_turn_id == turn_id
    assert model.recovery_state.replay_cursor == 1
    assert model.recovery_state.replay_log.cursor == 1
    assert String.starts_with?(model.recovery_state.last_replay_checkpoint_id, "replay-000001-")

    {updated_model, []} =
      Runtime.update(
        model,
        Message.websocket_recv(%{
          result: %{
            service: "ui.preferences",
            operation: "save_preferences",
            outcome: "ok",
            payload: %{turn_id: turn_id},
            context: %{correlation_id: "corr-220", request_id: "req-220"}
          }
        })
      )

    assert updated_model.slice_state.active_turn_id == nil
    assert updated_model.slice_state.last_completed_turn_id == turn_id
    assert updated_model.slice_state.last_outcome == :ok
    assert updated_model.recovery_state.replay_cursor == 2
    assert updated_model.recovery_state.replay_log.cursor == 2

    assert Enum.map(updated_model.recovery_state.replay_log.entries, & &1.direction) == [
             :outbound,
             :inbound
           ]

    assert String.starts_with?(
             updated_model.recovery_state.last_replay_checkpoint_id,
             "replay-000002-"
           )
  end

  test "unknown widget event types fail closed before dispatch" do
    model = booted_model()

    widget_msg =
      Message.widget_event(%{
        type: "unified.not_supported",
        widget_id: "save_button",
        widget_kind: "button",
        data: %{action: "save"}
      })

    {updated_model, commands} = Runtime.update(model, widget_msg)

    assert commands == []
    assert updated_model.last_error.error_code == "event_catalog.unknown_event_type"
  end

  test "policy-denied widget events fail closed and emit deterministic denial notices" do
    {:ok, model, _commands} =
      Runtime.init(%{
        runtime_context: %{
          correlation_id: "corr-policy-deny",
          request_id: "req-policy-deny",
          policy: %{deny_event_types: ["unified.button.clicked"]}
        }
      })

    widget_msg =
      Message.widget_event(%{
        type: "unified.button.clicked",
        widget_id: "save_button",
        widget_kind: "button",
        data: %{action: "save"}
      })

    {updated_model, commands} = Runtime.update(model, widget_msg)

    assert commands == []
    assert updated_model.last_error.error_code == "policy.authorization.event_type_denied"

    assert hd(updated_model.view_state.notices) ==
             "policy:deny:save_button:unified.button.clicked:policy.authorization.event_type_denied"

    assert updated_model.slice_state.dispatch_sequence == 0
    assert updated_model.outbound_queue == []
  end

  test "scope-policy-denied widget events fail closed and emit deterministic denial notices" do
    {:ok, model, _commands} =
      Runtime.init(%{
        runtime_context: %{
          correlation_id: "corr-scope-deny",
          request_id: "req-scope-deny",
          scope_policy: %{allow_scope_ids: ["workspace-1"]}
        }
      })

    widget_msg =
      Message.widget_event(%{
        type: "unified.button.clicked",
        widget_id: "save_button",
        widget_kind: "button",
        data: %{action: "save", scope_id: "workspace-2"}
      })

    {updated_model, commands} = Runtime.update(model, widget_msg)

    assert commands == []
    assert updated_model.last_error.error_code == "scope.resolution.scope_not_allowed"

    assert hd(updated_model.view_state.notices) ==
             "policy:deny:save_button:unified.button.clicked:scope.resolution.scope_not_allowed"

    assert updated_model.slice_state.dispatch_sequence == 0
    assert updated_model.outbound_queue == []
  end

  test "policy-allowed widget events dispatch when requirements are satisfied" do
    {:ok, model, _commands} =
      Runtime.init(%{
        runtime_context: %{
          correlation_id: "corr-policy-allow",
          request_id: "req-policy-allow",
          user_id: "user-42",
          policy: %{
            allow_event_types: ["unified.button.clicked"],
            require_user_for_event_types: ["unified.button.clicked"]
          }
        }
      })

    widget_msg =
      Message.widget_event(%{
        type: "unified.button.clicked",
        widget_id: "save_button",
        widget_kind: "button",
        data: %{action: "save"}
      })

    {updated_model, [command]} = Runtime.update(model, widget_msg)

    assert command.kind == :ws_push
    assert command.event_name == "runtime.event.send.v1"
    assert command.payload.event["type"] == "unified.button.clicked"
    assert updated_model.last_error == nil
    assert updated_model.view_state.ui_error == nil
    assert updated_model.slice_state.dispatch_sequence == 1
  end

  test "invalid widget events fail closed with typed ui error state" do
    model = booted_model()

    widget_msg =
      Message.widget_event(%{
        type: "unified.button.clicked",
        widget_kind: "button",
        data: "invalid"
      })

    {updated_model, commands} = Runtime.update(model, widget_msg)

    assert commands == []

    assert updated_model.last_error.error_code in [
             "ui.widget_event.missing_fields",
             "ui.widget_event.invalid_data"
           ]

    assert updated_model.view_state.ui_error.code == updated_model.last_error.error_code
  end

  test "inbound runtime.recv updates model deterministically" do
    model = booted_model()

    recv_msg =
      Message.websocket_recv(%{
        event: %{
          specversion: "1.0",
          id: "evt-220",
          source: "webui.runtime",
          type: "runtime.result",
          data: %{status: "ok"},
          correlation_id: "corr-220",
          request_id: "req-220"
        }
      })

    {updated_model, commands} = Runtime.update(model, recv_msg)

    assert commands == []
    assert updated_model.connection_state == :connected
    assert hd(updated_model.inbound_history).event == :ws_event_received
    assert hd(updated_model.view_state.notices) == "recv:runtime.result"
  end

  test "inbound runtime.error sets typed ui-visible error" do
    model = booted_model()

    error_msg =
      Message.websocket_error(%{
        error: %{
          error_code: "runtime.validation_failed",
          category: "validation",
          retryable: false,
          correlation_id: "corr-220"
        }
      })

    {updated_model, commands} = Runtime.update(model, error_msg)

    assert commands == []
    assert updated_model.connection_state == :error
    assert updated_model.last_error.error_code == "runtime.validation_failed"
    assert updated_model.view_state.ui_error.code == "runtime.validation_failed"
  end

  test "inbound runtime.pong updates keepalive marker" do
    model = booted_model()

    pong_msg = Message.websocket_pong(%{request_id: "req-220"})
    {updated_model, commands} = Runtime.update(model, pong_msg)

    assert commands == []
    assert updated_model.connection_state == :connected
    assert updated_model.transport.last_pong_at == "req-220"
    assert hd(updated_model.inbound_history).event == :ws_pong_received
  end
end
