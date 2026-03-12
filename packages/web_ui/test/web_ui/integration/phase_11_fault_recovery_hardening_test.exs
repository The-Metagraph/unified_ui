defmodule WebUi.Integration.Phase11FaultRecoveryHardeningTest do
  use ExUnit.Case, async: true

  alias WebUi.Channel
  alias WebUi.Observability.RuntimeEvent
  alias WebUi.Ui.Message
  alias WebUi.Ui.Runtime

  @moduletag :conformance

  defp model_with_session do
    {:ok, model, _commands} =
      Runtime.init(%{
        runtime_context: %{
          correlation_id: "corr-11",
          request_id: "req-11",
          session_id: "sess-11"
        }
      })

    model
  end

  test "SCN-013 reconnect loop idempotency preserves session-resume topic continuity" do
    model = model_with_session()

    {model, [first_join]} =
      Runtime.update(model, Message.websocket_disconnected(%{reason: "socket_lost"}))

    {updated_model, commands} =
      Runtime.update(model, Message.websocket_disconnected(%{reason: "socket_lost"}))

    assert commands == []
    assert updated_model.recovery_state.reconnect_attempts == 2

    assert updated_model.recovery_state.session_resume_topic ==
             "webui:runtime:session:sess-11:v1"

    join_commands =
      Enum.filter(updated_model.outbound_queue, fn command ->
        command.kind == :ws_join and command.topic == "webui:runtime:session:sess-11:v1"
      end)

    assert join_commands == [first_join]
    assert hd(updated_model.view_state.notices) == "reconnect:deduped:socket_lost"
  end

  test "SCN-014 retry storms are bounded with deterministic backoff progression and exhaustion" do
    model = model_with_session()

    retry_command = %{
      kind: :ws_push,
      event_name: "runtime.event.send.v1",
      payload: %{event: %{"id" => "evt-retry-11"}}
    }

    base_model =
      put_in(model.recovery_state, %{
        reconnect_attempts: 0,
        session_resume_topic: nil,
        retry_pending?: true,
        retryable_error: %{error_code: "first_slice.retryable_dependency_error"},
        last_command: retry_command,
        retry_attempts: 0,
        retry_backoff_ms: nil
      })

    {model, [^retry_command]} = Runtime.update(base_model, Message.retry_requested(%{}))
    assert model.recovery_state.retry_attempts == 1
    assert model.recovery_state.retry_backoff_ms == 100

    model = put_in(model.recovery_state.retry_pending?, true)
    {model, [^retry_command]} = Runtime.update(model, Message.retry_requested(%{}))
    assert model.recovery_state.retry_attempts == 2
    assert model.recovery_state.retry_backoff_ms == 200

    model = put_in(model.recovery_state.retry_pending?, true)
    {model, [^retry_command]} = Runtime.update(model, Message.retry_requested(%{}))
    assert model.recovery_state.retry_attempts == 3
    assert model.recovery_state.retry_backoff_ms == 400

    model = put_in(model.recovery_state.retry_pending?, true)
    {exhausted_model, commands} = Runtime.update(model, Message.retry_requested(%{}))

    assert commands == []
    assert exhausted_model.last_error.error_code == "ui.retry.exhausted"
    assert exhausted_model.recovery_state.retry_pending? == false
    assert exhausted_model.recovery_state.retry_backoff_ms == nil
  end

  test "SCN-015 metric rejection events preserve joinability context and runtime event validity" do
    parent = self()

    :ok =
      Channel.observe_ws_connection(
        "invalid endpoint value",
        "ok",
        observability_fun: fn event -> send(parent, {:obs_event, event}) end
      )

    events =
      Stream.repeatedly(fn ->
        receive do
          {:obs_event, event} -> event
        after
          20 -> :done
        end
      end)
      |> Enum.take_while(&(&1 != :done))

    metric_rejected =
      Enum.find(events, fn event ->
        event.event_name == "runtime.observability.metric_rejected.v1"
      end)

    assert metric_rejected
    assert metric_rejected.payload.joinability_context.correlation_id == "transport"
    assert metric_rejected.payload.joinability_context.request_id == "transport"
    assert :ok == RuntimeEvent.validate(metric_rejected)

    assert Enum.any?(events, fn event ->
             event.event_name == "runtime.transport.connection.v1"
           end)
  end

  test "SCN-016 timeout retry cancel chains converge to deterministic terminal UI state" do
    model = model_with_session()

    {model, [_command]} =
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
              correlation_id: "corr-11"
            },
            context: %{correlation_id: "corr-11", request_id: "req-11", session_id: "sess-11"}
          }
        })
      )

    assert model.recovery_state.retry_pending? == true

    {model, [_retry]} = Runtime.update(model, Message.retry_requested(%{}))
    {terminal_model, []} = Runtime.update(model, Message.cancel_requested(%{reason: "user_cancelled"}))

    assert terminal_model.connection_state == :connected
    assert terminal_model.slice_state.status == :cancelled
    assert terminal_model.recovery_state.retry_pending? == false
    assert terminal_model.recovery_state.retry_attempts == 0
    assert terminal_model.recovery_state.retry_backoff_ms == nil
    assert hd(terminal_model.view_state.notices) == "cancel:user_cancelled"

    assert Enum.take(terminal_model.inbound_history, 3)
           |> Enum.map(& &1.event) == [:cancel_requested, :retry_requested, :ws_result_received]
  end
end
