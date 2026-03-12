defmodule WebUi.Ui.RuntimeRecoveryTest do
  use ExUnit.Case, async: true

  alias WebUi.Ui.Message
  alias WebUi.Ui.Runtime

  defp model_with_session do
    {:ok, model, _commands} =
      Runtime.init(%{
        runtime_context: %{
          correlation_id: "corr-r10",
          request_id: "req-r10",
          session_id: "sess-r10"
        }
      })

    model
  end

  test "service result success reconciles first-slice state into ready UI" do
    model = model_with_session()

    {updated_model, []} =
      Runtime.update(
        model,
        Message.websocket_recv(%{
          result: %{
            service: "ui.preferences",
            operation: "save_preferences",
            outcome: "ok",
            payload: %{
              ui_patch: %{notice: "Preference saved"},
              ui_hints: %{
                primary_notice: "Theme saved successfully",
                severity: "info",
                next_actions: ["continue_editing", "open_summary"],
                focus_field: "theme"
              }
            },
            context: %{correlation_id: "corr-r10", request_id: "req-r10", session_id: "sess-r10"}
          }
        })
      )

    assert updated_model.connection_state == :connected
    assert updated_model.view_state.screen == :ready
    assert updated_model.slice_state.status == :completed
    assert updated_model.slice_state.last_outcome == :ok
    assert hd(updated_model.view_state.notices) == "slice:ok:ui.preferences/save_preferences"
    assert updated_model.view_state.reconciliation_hints.primary_notice == "Theme saved successfully"
    assert updated_model.view_state.reconciliation_hints.severity == "info"
    assert updated_model.view_state.reconciliation_hints.next_actions == ["continue_editing", "open_summary"]
    assert updated_model.view_state.reconciliation_hints.focus_field == "theme"
  end

  test "service result error marks retry pending when runtime error is retryable" do
    base_model = model_with_session()

    model = %{
      base_model
      | view_state:
          Map.put(base_model.view_state, :reconciliation_hints, %{
            primary_notice: "stale",
            severity: "info",
            next_actions: ["noop"],
            focus_field: "theme"
          })
    }

    {updated_model, []} =
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
              correlation_id: "corr-r10"
            },
            context: %{correlation_id: "corr-r10", request_id: "req-r10", session_id: "sess-r10"}
          }
        })
      )

    assert updated_model.connection_state == :error
    assert updated_model.last_error.error_code == "first_slice.retryable_dependency_error"
    assert updated_model.recovery_state.retry_pending? == true

    assert updated_model.recovery_state.retryable_error.error_code ==
             "first_slice.retryable_dependency_error"

    assert updated_model.slice_state.status == :failed
    assert updated_model.view_state.reconciliation_hints == %{
             primary_notice: nil,
             severity: nil,
             next_actions: [],
             focus_field: nil
           }
  end

  test "disconnection transitions to reconnecting state and emits session-resume join command" do
    model = model_with_session()

    {updated_model, [command]} =
      Runtime.update(model, Message.websocket_disconnected(%{reason: "socket_lost"}))

    assert updated_model.connection_state == :connecting
    assert updated_model.view_state.screen == :reconnecting
    assert updated_model.recovery_state.reconnect_attempts == 1

    assert updated_model.recovery_state.session_resume_topic ==
             "webui:runtime:session:sess-r10:v1"

    assert updated_model.recovery_state.session_resume_cursor == 0

    assert command.kind == :ws_join
    assert command.topic == "webui:runtime:session:sess-r10:v1"
    assert command.payload.resume_from_sequence == 0
    assert command.payload.session_id == "sess-r10"
  end

  test "repeated disconnections dedupe identical resume-topic join commands" do
    model = model_with_session()

    {model, [first_command]} =
      Runtime.update(model, Message.websocket_disconnected(%{reason: "socket_lost"}))

    {updated_model, commands} =
      Runtime.update(model, Message.websocket_disconnected(%{reason: "socket_lost"}))

    assert commands == []
    assert updated_model.recovery_state.reconnect_attempts == 2
    assert updated_model.recovery_state.session_resume_topic == "webui:runtime:session:sess-r10:v1"
    assert updated_model.recovery_state.session_resume_cursor == 0

    join_commands =
      Enum.filter(updated_model.outbound_queue, fn command ->
        command.kind == :ws_join and command.topic == "webui:runtime:session:sess-r10:v1"
      end)

    assert length(join_commands) == 1
    assert first_command == hd(join_commands)
    assert hd(updated_model.view_state.notices) == "reconnect:deduped:socket_lost"
  end

  test "reconnect emits updated join command when resume cursor advances during reconnect" do
    model = model_with_session()

    {model, [first_reconnect]} =
      Runtime.update(model, Message.websocket_disconnected(%{reason: "socket_lost"}))

    model = %{model | slice_state: Map.put(model.slice_state, :dispatch_sequence, 2)}

    {updated_model, [second_reconnect]} =
      Runtime.update(model, Message.websocket_disconnected(%{reason: "socket_lost"}))

    assert first_reconnect.payload.resume_from_sequence == 0
    assert second_reconnect.payload.resume_from_sequence == 2
    assert updated_model.recovery_state.session_resume_cursor == 2

    join_commands =
      Enum.filter(updated_model.outbound_queue, fn command ->
        command.kind == :ws_join and command.topic == "webui:runtime:session:sess-r10:v1"
      end)

    assert length(join_commands) == 2
    assert Enum.map(join_commands, & &1.payload.resume_from_sequence) == [0, 2]
  end

  test "ws_joined resume acknowledgement updates recovery diagnostics deterministically" do
    model = model_with_session()

    {model, [reconnect_command]} =
      Runtime.update(model, Message.websocket_disconnected(%{reason: "socket_lost"}))

    assert reconnect_command.payload.resume_from_sequence == 0
    assert model.recovery_state.session_resume_cursor == 0

    {updated_model, []} =
      Runtime.update(
        model,
        Message.websocket_joined(%{
          topic: reconnect_command.topic,
          resumed_from_sequence: reconnect_command.payload.resume_from_sequence
        })
      )

    assert updated_model.connection_state == :connected
    assert updated_model.recovery_state.session_resume_cursor == nil
    assert updated_model.recovery_state.last_resumed_sequence == 0
    assert hd(updated_model.view_state.notices) == "resume:ack:0"
  end

  test "retry_requested replays last outbound command and updates slice to retrying" do
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
              correlation_id: "corr-r10"
            },
            context: %{correlation_id: "corr-r10", request_id: "req-r10", session_id: "sess-r10"}
          }
        })
      )

    assert model.recovery_state.retry_pending? == true

    {updated_model, [retry_command]} = Runtime.update(model, Message.retry_requested(%{}))

    assert retry_command == initial_command
    assert retry_command.payload.event["data"]["dispatch_sequence"] == 1
    assert updated_model.connection_state == :connecting
    assert updated_model.slice_state.status == :retrying
    assert updated_model.recovery_state.retry_pending? == false
    assert updated_model.recovery_state.retry_attempts == 1
    assert updated_model.recovery_state.retry_backoff_ms == 100
    assert hd(updated_model.view_state.notices) == "retry:requested:100ms:seq:1"
    assert hd(updated_model.inbound_history).payload.dispatch_sequence == 1
  end

  test "retry_requested fails closed when max retry attempts are exhausted" do
    model = model_with_session()

    retry_command = %{
      kind: :ws_push,
      event_name: "runtime.event.send.v1",
      payload: %{event: %{"id" => "evt-retry-001"}}
    }

    exhausted_model =
      put_in(model.recovery_state, %{
        reconnect_attempts: 0,
        session_resume_topic: nil,
        retry_pending?: true,
        retryable_error: %{error_code: "first_slice.retryable_dependency_error"},
        last_command: retry_command,
        retry_attempts: 3,
        retry_backoff_ms: 400
      })

    {updated_model, commands} = Runtime.update(exhausted_model, Message.retry_requested(%{}))

    assert commands == []
    assert updated_model.last_error.error_code == "ui.retry.exhausted"
    assert updated_model.recovery_state.retry_pending? == false
    assert updated_model.recovery_state.retry_backoff_ms == nil
    assert hd(updated_model.view_state.notices) == "retry:exhausted"
  end

  test "cancel_requested clears retry state and marks workflow cancelled" do
    model = model_with_session()

    model = %{
      model
      | recovery_state: Map.put(model.recovery_state, :retry_pending?, true),
        slice_state: Map.put(model.slice_state, :status, :failed)
    }

    {updated_model, []} =
      Runtime.update(model, Message.cancel_requested(%{reason: "user_cancelled"}))

    assert updated_model.connection_state == :connected
    assert updated_model.slice_state.status == :cancelled
    assert updated_model.recovery_state.retry_pending? == false
    assert updated_model.recovery_state.retry_attempts == 0
    assert updated_model.recovery_state.retry_backoff_ms == nil
    assert hd(updated_model.view_state.notices) == "cancel:user_cancelled"
  end
end
