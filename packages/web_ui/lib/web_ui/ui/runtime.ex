defmodule WebUi.Ui.Runtime do
  @moduledoc """
  UI runtime bootstrap contracts mirroring Elm init command flow.
  """

  alias WebUi.Events.EventCatalog
  alias WebUi.Persistence.ReplayBaselineRegistry
  alias WebUi.Persistence.ReplayLog
  alias WebUi.Policy.Authorizer
  alias WebUi.Scope.Resolver, as: ScopeResolver
  alias WebUi.Turn.Execution, as: TurnExecution
  alias WebUi.Transport.Naming
  alias WebUi.TypedError
  alias WebUi.CloudEvent
  alias WebUi.Ui.Interop
  alias WebUi.Ui.Message
  alias WebUi.Ui.Model

  @max_retry_attempts 3

  @spec init(map()) :: {:ok, Model.t(), [map()]}
  def init(opts \\ %{}) when is_map(opts) do
    model =
      opts
      |> Model.new()
      |> Map.put(:connection_state, :connecting)
      |> Map.update!(:view_state, &Map.put(&1, :screen, :connecting))

    commands = [join_command(model.transport.topic), ping_command(model.runtime_context)]

    {:ok, model, commands}
  end

  @spec update(Model.t(), Message.t()) :: {Model.t(), [map()]}
  def update(%Model{} = model, %Message{type: :widget_event, payload: payload}) do
    dispatch_widget_event(model, payload)
  end

  def update(%Model{} = model, %Message{type: :ws_event_received, payload: payload}) do
    apply_runtime_recv(model, payload)
  end

  def update(%Model{} = model, %Message{type: :ws_error_received, payload: payload}) do
    apply_runtime_error(model, payload)
  end

  def update(%Model{} = model, %Message{type: :ws_pong_received, payload: payload}) do
    apply_runtime_pong(model, payload)
  end

  def update(%Model{} = model, %Message{type: :ws_joined, payload: payload}) do
    {handle_bootstrap_result(model, {:ok, payload}), []}
  end

  def update(%Model{} = model, %Message{type: :ws_join_failed, payload: payload}) do
    {handle_bootstrap_result(model, {:error, payload}), []}
  end

  def update(%Model{} = model, %Message{type: :ws_disconnected, payload: payload}) do
    apply_transport_disconnected(model, payload)
  end

  def update(%Model{} = model, %Message{type: :port_event, payload: payload}) do
    apply_port_event(model, payload)
  end

  def update(%Model{} = model, %Message{type: :retry_requested, payload: payload}) do
    apply_retry_requested(model, payload)
  end

  def update(%Model{} = model, %Message{type: :cancel_requested, payload: payload}) do
    apply_cancel_requested(model, payload)
  end

  def update(%Model{} = model, %Message{type: :replay_snapshot_requested, payload: payload}) do
    apply_replay_snapshot_requested(model, payload)
  end

  def update(%Model{} = model, %Message{type: :replay_export_requested, payload: payload}) do
    apply_replay_export_requested(model, payload)
  end

  def update(%Model{} = model, %Message{type: :replay_compaction_requested, payload: payload}) do
    apply_replay_compaction_requested(model, payload)
  end

  def update(%Model{} = model, %Message{type: :replay_restore_requested, payload: payload}) do
    apply_replay_restore_requested(model, payload)
  end

  def update(%Model{} = model, %Message{type: :replay_verification_requested, payload: payload}) do
    apply_replay_verification_requested(model, payload)
  end

  def update(%Model{} = model, %Message{
        type: :replay_verification_gate_requested,
        payload: payload
      }) do
    apply_replay_verification_gate_requested(model, payload)
  end

  def update(%Model{} = model, %Message{
        type: :replay_baseline_capture_requested,
        payload: payload
      }) do
    apply_replay_baseline_capture_requested(model, payload)
  end

  def update(%Model{} = model, %Message{
        type: :replay_baseline_activate_requested,
        payload: payload
      }) do
    apply_replay_baseline_activate_requested(model, payload)
  end

  def update(%Model{} = model, %Message{
        type: :replay_baseline_gate_requested,
        payload: payload
      }) do
    apply_replay_baseline_gate_requested(model, payload)
  end

  def update(%Model{} = model, %Message{}) do
    {model, []}
  end

  @spec request_port_operation(Model.t(), String.t(), map()) :: {Model.t(), [map()]}
  def request_port_operation(%Model{} = model, operation, payload)
      when is_binary(operation) and is_map(payload) do
    with {:ok, command} <- Interop.build_port_command(operation, payload, model.runtime_context) do
      updated_model = Map.update!(model, :outbound_queue, fn queue -> queue ++ [command] end)
      {updated_model, [command]}
    else
      {:error, %TypedError{} = error} ->
        updated_model =
          model
          |> mark_ui_error(error)
          |> Map.update!(:telemetry_events, fn events ->
            [Interop.telemetry_error(error, payload) | events]
          end)

        {updated_model, []}
    end
  end

  @spec join_command(String.t()) :: map()
  def join_command(topic) when is_binary(topic) do
    %{
      kind: :ws_join,
      topic: topic,
      expected_events: Naming.server_events()
    }
  end

  @spec ping_command(map()) :: map()
  def ping_command(runtime_context) when is_map(runtime_context) do
    %{
      kind: :ws_push,
      event_name: "runtime.event.ping.v1",
      payload: %{
        correlation_id: Map.get(runtime_context, :correlation_id),
        request_id: Map.get(runtime_context, :request_id)
      }
    }
  end

  @spec handle_bootstrap_result(Model.t(), {:ok, map()} | {:error, term()}) :: Model.t()
  def handle_bootstrap_result(%Model{} = model, {:ok, payload}) when is_map(payload) do
    resume_ack_sequence = resume_ack_sequence(payload)

    model
    |> Map.put(:connection_state, :connected)
    |> Map.update!(:view_state, fn view_state ->
      notices = Map.get(view_state, :notices, [])

      ready_state =
        view_state
        |> Map.put(:screen, :ready)
        |> Map.put(:ui_error, nil)

      if is_integer(resume_ack_sequence) do
        Map.put(ready_state, :notices, ["resume:ack:#{resume_ack_sequence}" | notices])
      else
        ready_state
      end
    end)
    |> Map.update!(:transport, &Map.put(&1, :joined?, true))
    |> Map.update!(:recovery_state, fn recovery_state ->
      recovery_state
      |> Map.put(:retry_pending?, false)
      |> Map.put(:retryable_error, nil)
      |> Map.put(:retry_attempts, 0)
      |> Map.put(:retry_backoff_ms, nil)
      |> Map.put(:session_resume_cursor, nil)
      |> maybe_put_last_resumed_sequence(resume_ack_sequence)
    end)
    |> Map.update!(:inbound_history, fn history ->
      [%{event: :ws_joined, payload: payload} | history]
    end)
  end

  def handle_bootstrap_result(%Model{} = model, {:error, reason}) do
    typed_error = normalize_join_error(reason, model.runtime_context)

    model
    |> Map.put(:connection_state, :error)
    |> Map.update!(:view_state, fn view_state ->
      view_state
      |> Map.put(:screen, :error)
      |> Map.put(:ui_error, %{code: typed_error.error_code, message: "Channel bootstrap failed"})
    end)
    |> Map.put(:last_error, typed_error)
    |> Map.update!(:transport, &Map.put(&1, :joined?, false))
    |> Map.update!(:recovery_state, fn recovery_state ->
      recovery_state
      |> Map.put(:retry_pending?, typed_error.retryable)
      |> Map.put(:retryable_error, (typed_error.retryable && typed_error) || nil)
      |> Map.put(:retry_backoff_ms, nil)
    end)
    |> Map.update!(:inbound_history, fn history ->
      [%{event: :ws_join_failed, payload: %{error_code: typed_error.error_code}} | history]
    end)
  end

  defp dispatch_widget_event(%Model{} = model, payload) when is_map(payload) do
    dispatch_sequence = next_dispatch_sequence(model.slice_state)

    with {:ok, normalized_data} <- validate_widget_event(payload),
         :ok <- Authorizer.authorize_widget_event(payload, model.runtime_context),
         {:ok, resolved_scope} <-
           ScopeResolver.resolve_widget_scope(payload, model.runtime_context),
         scoped_data <- ScopeResolver.attach_scope_metadata(normalized_data, resolved_scope),
         sequence_data <- TurnExecution.attach_turn_metadata(scoped_data, dispatch_sequence),
         envelope <- widget_event_envelope(payload, sequence_data, model.runtime_context),
         {:ok, encoded} <- CloudEvent.encode(envelope),
         {:ok, replay_state} <-
           append_replay_entry(model.recovery_state, %{
             direction: :outbound,
             event: "runtime.event.send.v1",
             metadata: %{
               dispatch_sequence: dispatch_sequence,
               turn_id: Map.get(sequence_data, "turn_id"),
               widget_id: fetch_any(payload, :widget_id),
               widget_kind: fetch_any(payload, :widget_kind),
               event_type: fetch_any(payload, :type)
             }
           }) do
      command = %{
        kind: :ws_push,
        event_name: "runtime.event.send.v1",
        payload: %{event: encoded}
      }

      updated_model =
        model
        |> Map.update!(:outbound_queue, fn queue -> queue ++ [command] end)
        |> Map.update!(:view_state, fn view_state -> Map.put(view_state, :ui_error, nil) end)
        |> Map.update!(:slice_state, fn slice_state ->
          update_slice_for_outbound_event(slice_state, payload, sequence_data, dispatch_sequence)
        end)
        |> Map.update!(:recovery_state, fn _recovery_state ->
          replay_state
          |> Map.put(:last_command, command)
          |> Map.put(:retry_pending?, false)
          |> Map.put(:retryable_error, nil)
          |> Map.put(:retry_attempts, 0)
          |> Map.put(:retry_backoff_ms, nil)
        end)
        |> Map.put(:last_error, nil)

      {updated_model, [command]}
    else
      {:error, %TypedError{} = error} ->
        updated_model =
          model
          |> mark_ui_error(error)
          |> maybe_add_authorization_notice(error, payload)

        {updated_model, []}
    end
  end

  defp dispatch_widget_event(%Model{} = model, _payload) do
    error =
      TypedError.new(
        "ui.widget_event.invalid_payload",
        "validation",
        false,
        %{reason: "widget event payload must be a map"},
        model.runtime_context.correlation_id
      )

    {mark_ui_error(model, error), []}
  end

  defp maybe_add_authorization_notice(
         %Model{} = model,
         %TypedError{category: "authorization"} = error,
         payload
       )
       when is_map(payload) do
    widget_id = fetch_string(payload, :widget_id) || "unknown_widget"
    event_type = fetch_string(payload, :type) || "unknown_event"
    notice = "policy:deny:#{widget_id}:#{event_type}:#{error.error_code}"

    Map.update!(model, :view_state, fn view_state ->
      notices = Map.get(view_state, :notices, [])
      Map.put(view_state, :notices, [notice | notices])
    end)
  end

  defp maybe_add_authorization_notice(%Model{} = model, _error, _payload), do: model

  defp apply_runtime_recv(%Model{} = model, payload) when is_map(payload) do
    case fetch_payload_result(payload) do
      {:ok, result} ->
        apply_service_result(model, result)

      :error ->
        with {:ok, event} <- fetch_payload_event(payload),
             {:ok, decoded_event} <- CloudEvent.decode(event) do
          updated_model =
            model
            |> Map.put(:connection_state, :connected)
            |> Map.update!(:view_state, fn view_state ->
              notices = Map.get(view_state, :notices, [])
              Map.put(view_state, :notices, ["recv:" <> decoded_event.type | notices])
            end)
            |> Map.update!(:inbound_history, fn history ->
              [%{event: :ws_event_received, payload: decoded_event} | history]
            end)

          {updated_model, []}
        else
          {:error, %TypedError{} = error} ->
            {mark_ui_error(model, error), []}
        end
    end
  end

  defp apply_runtime_recv(%Model{} = model, _payload) do
    error =
      TypedError.new(
        "ui.runtime_recv.invalid_payload",
        "protocol",
        false,
        %{reason: "ws recv payload must be a map"},
        model.runtime_context.correlation_id
      )

    {mark_ui_error(model, error), []}
  end

  defp apply_runtime_error(%Model{} = model, payload) when is_map(payload) do
    error_map = fetch_map(payload, :error)

    typed_error =
      TypedError.new(
        fetch_string(error_map, :error_code) || "ui.runtime_error.unknown",
        fetch_string(error_map, :category) || "internal",
        fetch_boolean(error_map, :retryable, false),
        fetch_map(error_map, :details),
        fetch_string(error_map, :correlation_id) || model.runtime_context.correlation_id
      )

    updated_model =
      model
      |> Map.put(:connection_state, :error)
      |> mark_ui_error(typed_error)
      |> Map.update!(:slice_state, fn slice_state ->
        slice_state
        |> Map.put(:status, :failed)
        |> Map.put(:last_outcome, :error)
      end)
      |> Map.update!(:recovery_state, fn recovery_state ->
        recovery_state
        |> Map.put(:retry_pending?, typed_error.retryable)
        |> Map.put(:retryable_error, (typed_error.retryable && typed_error) || nil)
      end)
      |> Map.update!(:inbound_history, fn history ->
        [%{event: :ws_error_received, payload: error_map} | history]
      end)

    {updated_model, []}
  end

  defp apply_runtime_error(%Model{} = model, _payload) do
    error =
      TypedError.new(
        "ui.runtime_error.invalid_payload",
        "protocol",
        false,
        %{reason: "ws error payload must be a map"},
        model.runtime_context.correlation_id
      )

    {mark_ui_error(model, error), []}
  end

  defp apply_runtime_pong(%Model{} = model, payload) when is_map(payload) do
    pong_marker =
      fetch_string(payload, :timestamp) ||
        fetch_string(payload, :request_id) ||
        "pong-received"

    updated_model =
      model
      |> Map.put(:connection_state, :connected)
      |> Map.update!(:transport, &Map.put(&1, :last_pong_at, pong_marker))
      |> Map.update!(:inbound_history, fn history ->
        [%{event: :ws_pong_received, payload: payload} | history]
      end)

    {updated_model, []}
  end

  defp apply_runtime_pong(%Model{} = model, _payload) do
    error =
      TypedError.new(
        "ui.runtime_pong.invalid_payload",
        "protocol",
        false,
        %{reason: "ws pong payload must be a map"},
        model.runtime_context.correlation_id
      )

    {mark_ui_error(model, error), []}
  end

  defp apply_transport_disconnected(%Model{} = model, payload) when is_map(payload) do
    resume_cursor = current_dispatch_sequence(model)
    reconnect_command = reconnect_command(model.runtime_context, resume_cursor)
    reason = fetch_string(payload, :reason) || "transport_interrupted"
    session_id = Map.get(model.runtime_context, :session_id)
    resume_topic = reconnect_command.topic
    reconnect_pending? = reconnect_pending?(model, resume_topic, resume_cursor)

    updated_model =
      model
      |> Map.put(:connection_state, :connecting)
      |> Map.update!(:transport, fn transport ->
        transport
        |> Map.put(:joined?, false)
        |> Map.put(:topic, resume_topic)
      end)
      |> Map.update!(:view_state, fn view_state ->
        notices = Map.get(view_state, :notices, [])

        reconnect_notice =
          if reconnect_pending? do
            "reconnect:deduped:" <> reason
          else
            "reconnect:" <> reason
          end

        view_state
        |> Map.put(:screen, :reconnecting)
        |> Map.put(:ui_error, %{
          code: "ui.transport.disconnected",
          message: "Connection interrupted: " <> reason
        })
        |> Map.put(:notices, [reconnect_notice | notices])
      end)
      |> Map.update!(:recovery_state, fn recovery_state ->
        recovery_state
        |> Map.update(:reconnect_attempts, 1, &(&1 + 1))
        |> Map.put(:session_resume_topic, (session_id && resume_topic) || nil)
        |> Map.put(:session_resume_cursor, resume_cursor)
      end)
      |> Map.update!(:inbound_history, fn history ->
        [
          %{
            event: :ws_disconnected,
            payload: %{
              reason: reason,
              topic: resume_topic,
              deduped?: reconnect_pending?,
              resume_from_sequence: resume_cursor
            }
          }
          | history
        ]
      end)
      |> Map.update!(:outbound_queue, fn queue ->
        if reconnect_pending? do
          queue
        else
          queue ++ [reconnect_command]
        end
      end)

    if reconnect_pending? do
      {updated_model, []}
    else
      {updated_model, [reconnect_command]}
    end
  end

  defp apply_transport_disconnected(%Model{} = model, _payload) do
    apply_transport_disconnected(model, %{})
  end

  defp apply_retry_requested(%Model{} = model, payload) when is_map(payload) do
    retry_command =
      fetch_any(payload, :command) ||
        model.recovery_state.last_command

    retry_attempts = retry_attempts(model)

    cond do
      not is_map(retry_command) ->
        error =
          TypedError.new(
            "ui.retry.unavailable",
            "validation",
            false,
            %{reason: "no retry command is available"},
            model.runtime_context.correlation_id
          )

        {mark_ui_error(model, error), []}

      model.recovery_state.retry_pending? == false ->
        error =
          TypedError.new(
            "ui.retry.not_pending",
            "validation",
            false,
            %{reason: "retry requested without a pending retryable failure"},
            model.runtime_context.correlation_id
          )

        {mark_ui_error(model, error), []}

      retry_attempts >= @max_retry_attempts ->
        error =
          TypedError.new(
            "ui.retry.exhausted",
            "validation",
            false,
            %{max_retry_attempts: @max_retry_attempts},
            model.runtime_context.correlation_id
          )

        exhausted_model =
          model
          |> mark_ui_error(error)
          |> Map.update!(:view_state, fn view_state ->
            notices = Map.get(view_state, :notices, [])
            Map.put(view_state, :notices, ["retry:exhausted" | notices])
          end)
          |> Map.update!(:recovery_state, fn recovery_state ->
            recovery_state
            |> Map.put(:retry_pending?, false)
            |> Map.put(:retryable_error, nil)
            |> Map.put(:retry_backoff_ms, nil)
          end)

        {exhausted_model, []}

      true ->
        next_retry_attempt = retry_attempts + 1
        backoff_ms = retry_backoff_ms(next_retry_attempt)
        replay_sequence = retry_command_sequence(retry_command)
        replay_sequence_label = replay_sequence_label(replay_sequence)

        updated_model =
          model
          |> Map.put(:connection_state, :connecting)
          |> Map.put(:last_error, nil)
          |> Map.update!(:view_state, fn view_state ->
            notices = Map.get(view_state, :notices, [])

            view_state
            |> Map.put(:screen, :processing)
            |> Map.put(:ui_error, nil)
            |> Map.put(:notices, [
              "retry:requested:#{backoff_ms}ms:seq:#{replay_sequence_label}" | notices
            ])
          end)
          |> Map.update!(:slice_state, fn slice_state ->
            slice_state
            |> Map.put(:status, :retrying)
            |> Map.update(:attempts, 1, &(&1 + 1))
          end)
          |> Map.update!(:recovery_state, fn recovery_state ->
            recovery_state
            |> Map.put(:retry_pending?, false)
            |> Map.put(:retryable_error, nil)
            |> Map.put(:last_command, retry_command)
            |> Map.put(:retry_attempts, next_retry_attempt)
            |> Map.put(:retry_backoff_ms, backoff_ms)
          end)
          |> Map.update!(:outbound_queue, fn queue -> queue ++ [retry_command] end)
          |> Map.update!(:inbound_history, fn history ->
            [
              %{
                event: :retry_requested,
                payload: %{
                  event_name: fetch_any(retry_command, :event_name),
                  dispatch_sequence: replay_sequence
                }
              }
              | history
            ]
          end)

        {updated_model, [retry_command]}
    end
  end

  defp apply_retry_requested(%Model{} = model, _payload) do
    apply_retry_requested(model, %{})
  end

  defp apply_cancel_requested(%Model{} = model, payload) when is_map(payload) do
    reason = fetch_string(payload, :reason) || "user_cancelled"

    updated_model =
      model
      |> Map.put(:connection_state, :connected)
      |> Map.put(:last_error, nil)
      |> Map.update!(:view_state, fn view_state ->
        notices = Map.get(view_state, :notices, [])

        view_state
        |> Map.put(:screen, :ready)
        |> Map.put(:ui_error, nil)
        |> Map.put(:notices, ["cancel:" <> reason | notices])
      end)
      |> Map.update!(:slice_state, fn slice_state ->
        slice_state
        |> Map.put(:status, :cancelled)
        |> Map.put(:last_outcome, :cancelled)
        |> Map.put(:pending_action, nil)
      end)
      |> Map.update!(:recovery_state, fn recovery_state ->
        recovery_state
        |> Map.put(:retry_pending?, false)
        |> Map.put(:retryable_error, nil)
        |> Map.put(:retry_attempts, 0)
        |> Map.put(:retry_backoff_ms, nil)
      end)
      |> Map.update!(:inbound_history, fn history ->
        [%{event: :cancel_requested, payload: %{reason: reason}} | history]
      end)

    {updated_model, []}
  end

  defp apply_cancel_requested(%Model{} = model, _payload) do
    apply_cancel_requested(model, %{})
  end

  defp apply_replay_snapshot_requested(%Model{} = model, payload) when is_map(payload) do
    replay_log = replay_log_state(model.recovery_state)
    snapshot_opts = replay_snapshot_opts(payload)

    with {:ok, snapshot} <- ReplayLog.snapshot(replay_log, snapshot_opts) do
      updated_model =
        model
        |> Map.update!(:recovery_state, fn recovery_state ->
          Map.put(recovery_state, :last_replay_snapshot, snapshot)
        end)
        |> Map.update!(:view_state, fn view_state ->
          notices = Map.get(view_state, :notices, [])
          notice = "replay:snapshot:#{snapshot.entry_count}:#{snapshot.cursor}"
          Map.put(view_state, :notices, [notice | notices])
        end)
        |> Map.update!(:inbound_history, fn history ->
          [
            %{
              event: :replay_snapshot_requested,
              payload: %{
                from_cursor: Map.get(snapshot_opts, :from_cursor),
                limit: Map.get(snapshot_opts, :limit),
                cursor: snapshot.cursor,
                checkpoint_id: snapshot.checkpoint_id,
                entry_count: snapshot.entry_count
              }
            }
            | history
          ]
        end)

      {updated_model, []}
    else
      {:error, %TypedError{} = error} ->
        {mark_ui_error(model, error), []}
    end
  end

  defp apply_replay_snapshot_requested(%Model{} = model, _payload) do
    apply_replay_snapshot_requested(model, %{})
  end

  defp apply_replay_export_requested(%Model{} = model, payload) when is_map(payload) do
    replay_log = replay_log_state(model.recovery_state)

    with {:ok, export_payload} <- ReplayLog.export(replay_log) do
      entry_count = length(export_payload.entries)

      updated_model =
        model
        |> Map.update!(:recovery_state, fn recovery_state ->
          recovery_state
          |> Map.put(:last_replay_export, export_payload)
          |> maybe_put_replay_export_snapshot(payload, replay_log)
        end)
        |> Map.update!(:view_state, fn view_state ->
          notices = Map.get(view_state, :notices, [])
          notice = "replay:export:#{entry_count}:#{export_payload.cursor}"
          Map.put(view_state, :notices, [notice | notices])
        end)
        |> Map.update!(:inbound_history, fn history ->
          [
            %{
              event: :replay_export_requested,
              payload: %{
                cursor: export_payload.cursor,
                checkpoint_id: export_payload.checkpoint_id,
                entry_count: entry_count
              }
            }
            | history
          ]
        end)

      {updated_model, []}
    else
      {:error, %TypedError{} = error} ->
        {mark_ui_error(model, error), []}
    end
  end

  defp apply_replay_export_requested(%Model{} = model, _payload) do
    apply_replay_export_requested(model, %{})
  end

  defp apply_replay_compaction_requested(%Model{} = model, payload) when is_map(payload) do
    replay_log = replay_log_state(model.recovery_state)
    keep_last = compaction_keep_last(payload, replay_log)

    with {:ok, compacted_log} <- ReplayLog.compact(replay_log, %{keep_last: keep_last}) do
      checkpoint = ReplayLog.checkpoint(compacted_log)
      retained_entry_count = length(compacted_log.entries)

      updated_model =
        model
        |> Map.update!(:recovery_state, fn recovery_state ->
          recovery_state
          |> Map.put(:replay_log, compacted_log)
          |> Map.put(:replay_cursor, checkpoint.cursor)
          |> Map.put(:last_replay_checkpoint_id, checkpoint.checkpoint_id)
          |> Map.put(:replay_retention_limit, keep_last)
        end)
        |> Map.update!(:view_state, fn view_state ->
          notices = Map.get(view_state, :notices, [])
          notice = "replay:compact:#{keep_last}:#{retained_entry_count}"
          Map.put(view_state, :notices, [notice | notices])
        end)
        |> Map.update!(:inbound_history, fn history ->
          [
            %{
              event: :replay_compaction_requested,
              payload: %{
                keep_last: keep_last,
                cursor: checkpoint.cursor,
                checkpoint_id: checkpoint.checkpoint_id,
                retained_entry_count: retained_entry_count
              }
            }
            | history
          ]
        end)

      {updated_model, []}
    else
      {:error, %TypedError{} = error} ->
        {mark_ui_error(model, error), []}
    end
  end

  defp apply_replay_compaction_requested(%Model{} = model, _payload) do
    apply_replay_compaction_requested(model, %{})
  end

  defp apply_replay_restore_requested(%Model{} = model, payload) when is_map(payload) do
    export_payload = fetch_any(payload, :export)

    with {:ok, restored_log} <- ReplayLog.restore(export_payload) do
      checkpoint = ReplayLog.checkpoint(restored_log)
      restored_entry_count = length(ReplayLog.entries(restored_log))
      restore_summary = replay_restore_summary(checkpoint, restored_entry_count)

      updated_model =
        model
        |> Map.update!(:recovery_state, fn recovery_state ->
          recovery_state
          |> Map.put(:replay_log, restored_log)
          |> Map.put(:replay_cursor, checkpoint.cursor)
          |> Map.put(:last_replay_checkpoint_id, checkpoint.checkpoint_id)
          |> Map.put(:last_replay_restore, restore_summary)
        end)
        |> Map.update!(:view_state, fn view_state ->
          notices = Map.get(view_state, :notices, [])
          notice = "replay:restore:#{restored_entry_count}:#{checkpoint.cursor}"
          Map.put(view_state, :notices, [notice | notices])
        end)
        |> Map.update!(:inbound_history, fn history ->
          [
            %{
              event: :replay_restore_requested,
              payload: restore_summary
            }
            | history
          ]
        end)

      {updated_model, []}
    else
      {:error, %TypedError{} = error} ->
        {mark_ui_error(model, error), []}
    end
  end

  defp apply_replay_restore_requested(%Model{} = model, _payload) do
    apply_replay_restore_requested(model, %{})
  end

  defp apply_replay_verification_requested(%Model{} = model, payload) when is_map(payload) do
    replay_log = replay_log_state(model.recovery_state)
    expected_export = replay_verification_export_payload(payload)

    with {:ok, verification} <- ReplayLog.verify_export(replay_log, expected_export) do
      updated_model =
        model
        |> Map.update!(:recovery_state, fn recovery_state ->
          Map.put(recovery_state, :last_replay_verification, verification)
        end)
        |> Map.update!(:view_state, fn view_state ->
          notices = Map.get(view_state, :notices, [])
          notice = replay_verification_notice(verification)
          Map.put(view_state, :notices, [notice | notices])
        end)
        |> Map.update!(:inbound_history, fn history ->
          [
            %{
              event: :replay_verification_requested,
              payload: verification
            }
            | history
          ]
        end)

      {updated_model, []}
    else
      {:error, %TypedError{} = error} ->
        {mark_ui_error(model, error), []}
    end
  end

  defp apply_replay_verification_requested(%Model{} = model, _payload) do
    apply_replay_verification_requested(model, %{})
  end

  defp apply_replay_verification_gate_requested(%Model{} = model, payload) when is_map(payload) do
    replay_log = replay_log_state(model.recovery_state)
    expected_export = replay_verification_export_payload(payload)
    verification_policy = replay_verification_policy(payload)

    with {:ok, gate} <- ReplayLog.gate_export(replay_log, expected_export, verification_policy) do
      updated_model =
        model
        |> Map.update!(:recovery_state, fn recovery_state ->
          recovery_state
          |> Map.put(:last_replay_verification, gate.verification)
          |> Map.put(:last_replay_verification_gate, gate)
        end)
        |> Map.update!(:view_state, fn view_state ->
          notices = Map.get(view_state, :notices, [])
          notice = replay_verification_gate_notice(gate)
          Map.put(view_state, :notices, [notice | notices])
        end)
        |> Map.update!(:inbound_history, fn history ->
          [
            %{
              event: :replay_verification_gate_requested,
              payload: gate
            }
            | history
          ]
        end)

      {updated_model, []}
    else
      {:error, %TypedError{} = error} ->
        {mark_ui_error(model, error), []}
    end
  end

  defp apply_replay_verification_gate_requested(%Model{} = model, _payload) do
    apply_replay_verification_gate_requested(model, %{})
  end

  defp apply_replay_baseline_capture_requested(%Model{} = model, payload) when is_map(payload) do
    replay_log = replay_log_state(model.recovery_state)
    baseline_metadata = replay_baseline_metadata(payload)
    baseline_registry = replay_baseline_registry_state(model.recovery_state)
    baseline_registry_opts = replay_baseline_registry_upsert_opts(payload)

    with {:ok, baseline} <- ReplayLog.capture_baseline(replay_log, baseline_metadata),
         {:ok, updated_baseline_registry} <-
           ReplayBaselineRegistry.upsert(baseline_registry, baseline, baseline_registry_opts) do
      updated_model =
        model
        |> Map.update!(:recovery_state, fn recovery_state ->
          recovery_state
          |> Map.put(:replay_baseline_registry, updated_baseline_registry)
          |> Map.put(:last_replay_baseline, baseline)
        end)
        |> Map.update!(:view_state, fn view_state ->
          notices = Map.get(view_state, :notices, [])
          notice = replay_baseline_capture_notice(baseline)
          Map.put(view_state, :notices, [notice | notices])
        end)
        |> Map.update!(:inbound_history, fn history ->
          [
            %{
              event: :replay_baseline_capture_requested,
              payload: %{
                baseline_id: baseline.baseline_id,
                cursor: baseline.cursor,
                checkpoint_id: baseline.checkpoint_id,
                entry_count: baseline.entry_count,
                metadata: baseline.metadata
              }
            }
            | history
          ]
        end)

      {updated_model, []}
    else
      {:error, %TypedError{} = error} ->
        {mark_ui_error(model, error), []}
    end
  end

  defp apply_replay_baseline_capture_requested(%Model{} = model, _payload) do
    apply_replay_baseline_capture_requested(model, %{})
  end

  defp apply_replay_baseline_activate_requested(%Model{} = model, payload) when is_map(payload) do
    baseline_registry = replay_baseline_registry_state(model.recovery_state)

    with {:ok, baseline_id} <- replay_baseline_activate_id(payload),
         {:ok, updated_baseline_registry} <-
           ReplayBaselineRegistry.activate(baseline_registry, baseline_id),
         {:ok, baseline} <- ReplayBaselineRegistry.active(updated_baseline_registry) do
      updated_model =
        model
        |> Map.update!(:recovery_state, fn recovery_state ->
          recovery_state
          |> Map.put(:replay_baseline_registry, updated_baseline_registry)
          |> Map.put(:last_replay_baseline, baseline)
        end)
        |> Map.update!(:view_state, fn view_state ->
          notices = Map.get(view_state, :notices, [])
          notice = replay_baseline_activate_notice(baseline_id)
          Map.put(view_state, :notices, [notice | notices])
        end)
        |> Map.update!(:inbound_history, fn history ->
          [
            %{event: :replay_baseline_activate_requested, payload: %{baseline_id: baseline_id}}
            | history
          ]
        end)

      {updated_model, []}
    else
      {:error, %TypedError{} = error} ->
        {mark_ui_error(model, error), []}
    end
  end

  defp apply_replay_baseline_activate_requested(%Model{} = model, _payload) do
    apply_replay_baseline_activate_requested(model, %{})
  end

  defp apply_replay_baseline_gate_requested(%Model{} = model, payload) when is_map(payload) do
    replay_log = replay_log_state(model.recovery_state)
    verification_policy = replay_verification_policy(payload)

    with {:ok, baseline} <- replay_baseline_payload(payload, model.recovery_state),
         {:ok, baseline_gate} <-
           ReplayLog.gate_baseline(replay_log, baseline, verification_policy) do
      updated_model =
        model
        |> Map.update!(:recovery_state, fn recovery_state ->
          recovery_state
          |> Map.put(:last_replay_baseline, baseline)
          |> Map.put(:last_replay_baseline_gate, baseline_gate)
          |> Map.put(:last_replay_verification, baseline_gate.gate.verification)
          |> Map.put(:last_replay_verification_gate, baseline_gate.gate)
        end)
        |> Map.update!(:view_state, fn view_state ->
          notices = Map.get(view_state, :notices, [])
          notice = replay_baseline_gate_notice(baseline_gate)
          Map.put(view_state, :notices, [notice | notices])
        end)
        |> Map.update!(:inbound_history, fn history ->
          [
            %{
              event: :replay_baseline_gate_requested,
              payload: baseline_gate
            }
            | history
          ]
        end)

      {updated_model, []}
    else
      {:error, %TypedError{} = error} ->
        {mark_ui_error(model, error), []}
    end
  end

  defp apply_replay_baseline_gate_requested(%Model{} = model, _payload) do
    apply_replay_baseline_gate_requested(model, %{})
  end

  defp reconnect_command(runtime_context, resume_from_sequence)
       when is_map(runtime_context) and is_integer(resume_from_sequence) and
              resume_from_sequence >= 0 do
    session_id =
      runtime_context
      |> fetch_any(:session_id)
      |> case do
        value when is_binary(value) and value != "" -> value
        _ -> nil
      end

    topic =
      case session_id do
        nil -> Naming.default_topic()
        id -> "webui:runtime:session:" <> id <> ":v1"
      end

    payload =
      %{resume_from_sequence: resume_from_sequence}
      |> maybe_put_session_id(session_id)

    join_command(topic)
    |> Map.put(:payload, payload)
  end

  defp reconnect_pending?(%Model{} = model, resume_topic, resume_cursor)
       when is_binary(resume_topic) and is_integer(resume_cursor) do
    model.connection_state == :connecting and
      fetch_any(model.transport, :topic) == resume_topic and
      Enum.any?(model.outbound_queue, fn command ->
        is_map(command) and
          fetch_any(command, :kind) == :ws_join and
          fetch_any(command, :topic) == resume_topic and
          join_command_resume_sequence(command) == resume_cursor
      end)
  end

  defp current_dispatch_sequence(%Model{} = model) do
    case fetch_any(model.slice_state, :dispatch_sequence) do
      value when is_integer(value) and value >= 0 -> value
      _ -> 0
    end
  end

  defp join_command_resume_sequence(command) when is_map(command) do
    command
    |> fetch_map(:payload)
    |> fetch_any(:resume_from_sequence)
    |> case do
      value when is_integer(value) and value >= 0 -> value
      _ -> 0
    end
  end

  defp maybe_put_session_id(payload, session_id) when is_map(payload) do
    case session_id do
      value when is_binary(value) and value != "" -> Map.put(payload, :session_id, value)
      _ -> payload
    end
  end

  defp retry_attempts(%Model{} = model) do
    case fetch_any(model.recovery_state, :retry_attempts) do
      value when is_integer(value) and value >= 0 -> value
      _ -> 0
    end
  end

  defp retry_backoff_ms(attempt) when is_integer(attempt) and attempt > 0 do
    backoff = 100 * Integer.pow(2, attempt - 1)
    min(backoff, 1_600)
  end

  defp retry_command_sequence(command) when is_map(command) do
    data =
      command
      |> fetch_map(:payload)
      |> fetch_map(:event)
      |> fetch_map(:data)

    case fetch_any(data, :dispatch_sequence) do
      value when is_integer(value) and value > 0 -> value
      _ -> nil
    end
  end

  defp retry_command_sequence(_command), do: nil

  defp replay_sequence_label(value) when is_integer(value), do: Integer.to_string(value)
  defp replay_sequence_label(_value), do: "unknown"

  defp resume_ack_sequence(payload) when is_map(payload) do
    case fetch_any(payload, :resumed_from_sequence) do
      value when is_integer(value) and value >= 0 ->
        value

      value when is_binary(value) ->
        case Integer.parse(value) do
          {parsed, ""} when parsed >= 0 -> parsed
          _ -> nil
        end

      _ ->
        nil
    end
  end

  defp maybe_put_last_resumed_sequence(recovery_state, sequence)
       when is_map(recovery_state) and is_integer(sequence) and sequence >= 0 do
    Map.put(recovery_state, :last_resumed_sequence, sequence)
  end

  defp maybe_put_last_resumed_sequence(recovery_state, _sequence), do: recovery_state

  defp apply_port_event(%Model{} = model, payload) when is_map(payload) do
    with {:ok, decoded} <- Interop.decode_port_event(payload),
         :ok <- Interop.authorize_port_event(decoded, model.runtime_context) do
      updated_model =
        model
        |> Map.update!(:inbound_history, fn history ->
          [%{event: :port_event_received, payload: decoded} | history]
        end)
        |> Map.update!(:view_state, fn view_state -> Map.put(view_state, :ui_error, nil) end)

      {updated_model, []}
    else
      {:error, %TypedError{} = error} ->
        updated_model =
          model
          |> mark_ui_error(error)
          |> Map.update!(:telemetry_events, fn events ->
            [Interop.telemetry_error(error, payload) | events]
          end)

        {updated_model, []}
    end
  end

  defp apply_port_event(%Model{} = model, _payload) do
    error =
      TypedError.new(
        "ui.interop.invalid_event_shape",
        "protocol",
        false,
        %{reason: "port event payload must be a map"},
        model.runtime_context.correlation_id
      )

    updated_model =
      model
      |> mark_ui_error(error)
      |> Map.update!(:telemetry_events, fn events ->
        [Interop.telemetry_error(error, %{}) | events]
      end)

    {updated_model, []}
  end

  defp validate_widget_event(payload) do
    missing =
      [:type, :widget_id, :widget_kind, :data]
      |> Enum.filter(fn key ->
        case fetch_any(payload, key) do
          nil -> true
          "" -> true
          _ -> false
        end
      end)

    cond do
      missing != [] ->
        {:error,
         TypedError.new(
           "ui.widget_event.missing_fields",
           "validation",
           false,
           %{missing_fields: missing}
         )}

      not is_map(fetch_any(payload, :data)) ->
        {:error,
         TypedError.new(
           "ui.widget_event.invalid_data",
           "validation",
           false,
           %{required_field: :data, required_shape: "map"}
         )}

      true ->
        event_type = fetch_any(payload, :type)
        widget_id = fetch_any(payload, :widget_id)
        widget_kind = fetch_any(payload, :widget_kind)

        normalized_data =
          payload
          |> fetch_any(:data)
          |> stringify_map_keys()
          |> Map.put_new("widget_id", widget_id)
          |> Map.put_new("widget_kind", widget_kind)
          |> apply_route_key_defaults(event_type, widget_id)

        case EventCatalog.validate_event(event_type, normalized_data) do
          :ok -> {:ok, normalized_data}
          {:error, %TypedError{} = error} -> {:error, error}
        end
    end
  end

  defp widget_event_envelope(payload, normalized_data, runtime_context) do
    event_type = fetch_any(payload, :type)
    widget_id = fetch_any(payload, :widget_id)
    widget_kind = fetch_any(payload, :widget_kind)

    event_id =
      "ui-" <>
        Integer.to_string(:erlang.phash2({event_type, widget_id, widget_kind, normalized_data}))

    %{
      specversion: "1.0",
      id: event_id,
      source: "webui.ui_runtime",
      type: event_type,
      data: normalized_data,
      correlation_id: runtime_context.correlation_id,
      request_id: runtime_context.request_id
    }
  end

  defp apply_route_key_defaults(data, event_type, widget_id)
       when is_map(data) and is_binary(event_type) do
    case EventCatalog.route_family(event_type) do
      {:ok, :click} ->
        action = route_value(data, "action") || route_value(data, "action_id") || widget_id

        data
        |> put_route_value("action", action)
        |> put_route_value("button_id", widget_id)
        |> put_route_value("widget_id", widget_id)
        |> put_route_value("id", route_identifier(data, widget_id))

      {:ok, :change} ->
        input_id = route_value(data, "input_id") || widget_id

        data
        |> put_route_value("input_id", input_id)
        |> put_route_value("widget_id", widget_id)
        |> put_route_value("field", route_value(data, "field") || input_id)
        |> put_route_value("action", route_value(data, "action") || "change")
        |> put_route_value("id", route_identifier(data, input_id || widget_id))

      {:ok, :submit} ->
        form_id = route_value(data, "form_id") || widget_id

        data
        |> put_route_value("form_id", form_id)
        |> put_route_value("action", route_value(data, "action") || "submit")
        |> put_route_value("id", route_identifier(data, form_id || widget_id))

      _ ->
        data
    end
  end

  defp apply_route_key_defaults(data, _event_type, _widget_id), do: data

  defp put_route_value(data, key, value) do
    case route_value(data, key) do
      nil when is_binary(value) and value != "" -> Map.put(data, key, value)
      "" when is_binary(value) and value != "" -> Map.put(data, key, value)
      _ -> data
    end
  end

  defp route_identifier(data, fallback) do
    route_value(data, "id") || fallback
  end

  defp route_value(map, key) when is_map(map) and is_binary(key) do
    Map.get(map, key)
  end

  defp stringify_map_keys(map) when is_map(map) do
    map
    |> Enum.map(fn {key, value} -> {to_string(key), stringify_value(value)} end)
    |> Enum.into(%{})
  end

  defp stringify_value(value) when is_map(value), do: stringify_map_keys(value)
  defp stringify_value(value) when is_list(value), do: Enum.map(value, &stringify_value/1)
  defp stringify_value(value), do: value

  defp fetch_payload_event(payload) do
    case fetch_any(payload, :event) do
      event when is_map(event) ->
        {:ok, event}

      _ ->
        {:error,
         TypedError.new("ui.runtime_recv.missing_event", "protocol", false, %{
           required_key: :event
         })}
    end
  end

  defp fetch_payload_result(payload) do
    case fetch_any(payload, :result) do
      result when is_map(result) and map_size(result) > 0 -> {:ok, result}
      _ -> :error
    end
  end

  defp apply_service_result(%Model{} = model, result) when is_map(result) do
    service = fetch_string(result, :service) || "unknown_service"
    operation = fetch_string(result, :operation) || "unknown_operation"
    outcome = fetch_string(result, :outcome) || "error"
    context = fetch_map(result, :context)
    payload = fetch_map(result, :payload)

    with {:ok, replay_state} <-
           append_replay_entry(model.recovery_state, %{
             direction: :inbound,
             event: :ws_result_received,
             metadata: replay_result_metadata(result, service, operation, outcome)
           }) do
      case outcome do
        "ok" ->
          notice = "slice:ok:" <> service <> "/" <> operation
          patch_notice = fetch_string(fetch_map(payload, :ui_patch), :notice)
          hint_state = normalize_reconciliation_hints(fetch_map(payload, :ui_hints))
          hint_notice = hint_state.primary_notice

          updated_model =
            model
            |> Map.put(:connection_state, :connected)
            |> Map.put(:last_error, nil)
            |> Map.update!(:view_state, fn view_state ->
              notices =
                [notice, patch_notice, hint_notice]
                |> Enum.reject(&is_nil/1)
                |> Kernel.++(Map.get(view_state, :notices, []))

              view_state
              |> Map.put(:screen, :ready)
              |> Map.put(:ui_error, nil)
              |> Map.put(:notices, notices)
              |> Map.put(:reconciliation_hints, hint_state)
            end)
            |> Map.update!(:slice_state, fn slice_state ->
              completed_slice_state = TurnExecution.complete_turn(slice_state, result)

              completed_slice_state
              |> Map.put(:workflow, service <> "." <> operation)
              |> Map.put(:status, :completed)
              |> Map.put(:last_outcome, :ok)
              |> Map.put(:pending_action, nil)
            end)
            |> Map.update!(:recovery_state, fn _recovery_state ->
              replay_state
              |> Map.put(:retry_pending?, false)
              |> Map.put(:retryable_error, nil)
              |> Map.put(:retry_attempts, 0)
              |> Map.put(:retry_backoff_ms, nil)
            end)
            |> maybe_resume_runtime_context(context)
            |> Map.update!(:inbound_history, fn history ->
              [%{event: :ws_result_received, payload: result} | history]
            end)

          {updated_model, []}

        _ ->
          typed_error = typed_error_from_result(result, model.runtime_context)
          notice = "slice:error:" <> service <> "/" <> operation

          updated_model =
            model
            |> Map.put(:connection_state, :error)
            |> mark_ui_error(typed_error)
            |> Map.update!(:view_state, fn view_state ->
              notices = Map.get(view_state, :notices, [])

              view_state
              |> Map.put(:notices, [notice | notices])
              |> Map.put(:reconciliation_hints, empty_reconciliation_hints())
            end)
            |> Map.update!(:slice_state, fn slice_state ->
              completed_slice_state = TurnExecution.complete_turn(slice_state, result)

              completed_slice_state
              |> Map.put(:workflow, service <> "." <> operation)
              |> Map.put(:status, :failed)
              |> Map.put(:last_outcome, :error)
            end)
            |> Map.update!(:recovery_state, fn _recovery_state ->
              replay_state
              |> Map.put(:retry_pending?, typed_error.retryable)
              |> Map.put(:retryable_error, (typed_error.retryable && typed_error) || nil)
            end)
            |> maybe_resume_runtime_context(context)
            |> Map.update!(:inbound_history, fn history ->
              [%{event: :ws_result_received, payload: result} | history]
            end)

          {updated_model, []}
      end
    else
      {:error, %TypedError{} = error} ->
        {mark_ui_error(model, error), []}
    end
  end

  defp typed_error_from_result(result, runtime_context) do
    error_map = fetch_map(result, :error)

    TypedError.new(
      fetch_string(error_map, :error_code) || "ui.runtime_result.error",
      fetch_string(error_map, :category) || "internal",
      fetch_boolean(error_map, :retryable, false),
      fetch_map(error_map, :details),
      fetch_string(error_map, :correlation_id) ||
        Map.get(runtime_context, :correlation_id, "unknown")
    )
  end

  defp replay_result_metadata(result, service, operation, outcome)
       when is_map(result) and is_binary(service) and is_binary(operation) and is_binary(outcome) do
    error_map = fetch_map(result, :error)

    %{
      service: service,
      operation: operation,
      outcome: outcome,
      turn_id: TurnExecution.extract_turn_id(result),
      error_code: fetch_string(error_map, :error_code)
    }
  end

  defp maybe_resume_runtime_context(%Model{} = model, context) when is_map(context) do
    session_id =
      fetch_any(context, :session_id)
      |> case do
        value when is_binary(value) and value != "" -> value
        _ -> nil
      end

    if is_nil(session_id) do
      model
    else
      Map.update!(model, :runtime_context, &Map.put(&1, :session_id, session_id))
    end
  end

  defp mark_ui_error(%Model{} = model, %TypedError{} = error) do
    model
    |> Map.put(:last_error, error)
    |> Map.update!(:view_state, fn view_state ->
      Map.put(view_state, :ui_error, %{
        code: error.error_code,
        message: "UI runtime operation failed"
      })
    end)
    |> Map.update!(:telemetry_events, fn events ->
      [
        %{
          event_name: "runtime.ui.error.v1",
          correlation_id: error.correlation_id,
          error_code: error.error_code,
          category: error.category
        }
        | events
      ]
    end)
  end

  defp update_slice_for_outbound_event(slice_state, payload, normalized_data, dispatch_sequence) do
    event_type = fetch_any(payload, :type)
    action = route_value(normalized_data, "action")
    sequenced_state = TurnExecution.begin_turn(slice_state, dispatch_sequence)

    if event_type in ["unified.form.submitted", "unified.button.clicked"] do
      sequenced_state
      |> Map.put(:workflow, "ui.preferences.save")
      |> Map.put(:status, :in_flight)
      |> Map.put(:last_outcome, nil)
      |> Map.put(:pending_action, action || event_type)
      |> Map.update(:attempts, 1, &(&1 + 1))
    else
      sequenced_state
    end
  end

  defp next_dispatch_sequence(slice_state) when is_map(slice_state) do
    case Map.get(slice_state, :dispatch_sequence) do
      value when is_integer(value) and value >= 0 -> value + 1
      _ -> 1
    end
  end

  defp append_replay_entry(recovery_state, attrs) when is_map(recovery_state) and is_map(attrs) do
    replay_log = replay_log_state(recovery_state)

    with {:ok, updated_log} <- ReplayLog.append(replay_log, attrs) do
      checkpoint = ReplayLog.checkpoint(updated_log)

      {:ok,
       recovery_state
       |> Map.put(:replay_log, updated_log)
       |> Map.put(:replay_cursor, checkpoint.cursor)
       |> Map.put(:last_replay_checkpoint_id, checkpoint.checkpoint_id)}
    end
  end

  defp append_replay_entry(recovery_state, _attrs) do
    {:error,
     TypedError.new(
       "ui.replay.invalid_recovery_state",
       "validation",
       false,
       %{reason: "recovery state must be a map", recovery_state: recovery_state}
     )}
  end

  defp replay_log_state(recovery_state) when is_map(recovery_state) do
    case fetch_any(recovery_state, :replay_log) do
      nil -> ReplayLog.new()
      replay_log when is_map(replay_log) -> replay_log
      _ -> %{}
    end
  end

  defp replay_snapshot_opts(payload) when is_map(payload) do
    from_cursor =
      case fetch_any(payload, :from_cursor) do
        nil -> 0
        value -> value
      end

    %{from_cursor: from_cursor}
    |> maybe_put_snapshot_limit(fetch_any(payload, :limit))
  end

  defp maybe_put_snapshot_limit(opts, nil) when is_map(opts), do: opts

  defp maybe_put_snapshot_limit(opts, limit) when is_map(opts),
    do: Map.put(opts, :limit, limit)

  defp compaction_keep_last(payload, replay_log) when is_map(payload) and is_map(replay_log) do
    case fetch_any(payload, :keep_last) do
      nil -> length(ReplayLog.entries(replay_log))
      value -> value
    end
  end

  defp maybe_put_replay_export_snapshot(recovery_state, payload, replay_log)
       when is_map(recovery_state) and is_map(payload) and is_map(replay_log) do
    case fetch_boolean(payload, :include_snapshot, false) do
      true ->
        snapshot_opts = replay_snapshot_opts(payload)

        case ReplayLog.snapshot(replay_log, snapshot_opts) do
          {:ok, snapshot} -> Map.put(recovery_state, :last_replay_snapshot, snapshot)
          _ -> recovery_state
        end

      false ->
        recovery_state
    end
  end

  defp replay_restore_summary(checkpoint, restored_entry_count)
       when is_map(checkpoint) and is_integer(restored_entry_count) and restored_entry_count >= 0 do
    %{
      cursor: checkpoint.cursor,
      checkpoint_id: checkpoint.checkpoint_id,
      entry_count: restored_entry_count
    }
  end

  defp replay_verification_export_payload(payload) when is_map(payload) do
    case fetch_any(payload, :expected_export) do
      nil -> fetch_any(payload, :export)
      expected_export -> expected_export
    end
  end

  defp replay_verification_policy(payload) when is_map(payload) do
    case fetch_any(payload, :policy) do
      nil -> %{}
      policy -> policy
    end
  end

  defp replay_baseline_metadata(payload) when is_map(payload) do
    case fetch_any(payload, :metadata) do
      nil -> %{}
      metadata -> metadata
    end
  end

  defp replay_baseline_registry_upsert_opts(payload) when is_map(payload) do
    opts = %{}

    opts =
      case fetch_any(payload, :retention_limit) do
        nil -> opts
        retention_limit -> Map.put(opts, :retention_limit, retention_limit)
      end

    case fetch_any(payload, :activate) do
      nil -> opts
      activate? -> Map.put(opts, :activate, activate?)
    end
  end

  defp replay_baseline_activate_id(payload) when is_map(payload) do
    case fetch_any(payload, :baseline_id) do
      baseline_id when is_binary(baseline_id) and baseline_id != "" ->
        {:ok, baseline_id}

      baseline_id ->
        {:error,
         TypedError.new(
           "ui.replay_baseline.invalid_payload",
           "validation",
           false,
           %{reason: "baseline_id must be a non-empty string", baseline_id: baseline_id}
         )}
    end
  end

  defp replay_baseline_payload(payload, recovery_state)
       when is_map(payload) and is_map(recovery_state) do
    baseline_registry = replay_baseline_registry_state(recovery_state)

    case fetch_any(payload, :baseline) do
      nil ->
        case fetch_any(payload, :baseline_id) do
          baseline_id when is_binary(baseline_id) and baseline_id != "" ->
            ReplayBaselineRegistry.fetch(baseline_registry, baseline_id)

          _ ->
            case ReplayBaselineRegistry.active(baseline_registry) do
              {:ok, baseline} ->
                {:ok, baseline}

              {:error, _error} ->
                case fetch_any(recovery_state, :last_replay_baseline) do
                  baseline when is_map(baseline) ->
                    {:ok, baseline}

                  _ ->
                    {:error,
                     TypedError.new(
                       "ui.replay_baseline.missing_baseline",
                       "validation",
                       false,
                       %{
                         reason: "no replay baseline provided and no stored baseline is available"
                       }
                     )}
                end
            end
        end

      baseline when is_map(baseline) ->
        {:ok, baseline}

      baseline ->
        {:error,
         TypedError.new(
           "ui.replay_baseline.invalid_payload",
           "validation",
           false,
           %{reason: "baseline payload must be a map", baseline: baseline}
         )}
    end
  end

  defp replay_baseline_registry_state(recovery_state) when is_map(recovery_state) do
    case fetch_any(recovery_state, :replay_baseline_registry) do
      registry when is_map(registry) -> registry
      _ -> ReplayBaselineRegistry.new()
    end
  end

  defp replay_verification_notice(verification) when is_map(verification) do
    status = fetch_any(verification, :status) || "unknown"
    actual_cursor = fetch_any(verification, :actual_cursor) || "unknown"
    expected_cursor = fetch_any(verification, :expected_cursor) || "unknown"

    "replay:verify:#{status}:#{actual_cursor}:#{expected_cursor}"
  end

  defp replay_verification_gate_notice(gate) when is_map(gate) do
    status = fetch_any(gate, :status) || "unknown"
    cursor_delta = fetch_any(gate, :cursor_delta) || "unknown"
    entry_count_delta = fetch_any(gate, :entry_count_delta) || "unknown"

    "replay:gate:#{status}:#{cursor_delta}:#{entry_count_delta}"
  end

  defp replay_baseline_capture_notice(baseline) when is_map(baseline) do
    entry_count = fetch_any(baseline, :entry_count) || "unknown"
    cursor = fetch_any(baseline, :cursor) || "unknown"
    "replay:baseline:capture:#{entry_count}:#{cursor}"
  end

  defp replay_baseline_gate_notice(baseline_gate) when is_map(baseline_gate) do
    status = fetch_any(baseline_gate, :status) || "unknown"
    gate = fetch_any(baseline_gate, :gate) || %{}
    cursor_delta = fetch_any(gate, :cursor_delta) || "unknown"
    entry_count_delta = fetch_any(gate, :entry_count_delta) || "unknown"

    "replay:baseline:gate:#{status}:#{cursor_delta}:#{entry_count_delta}"
  end

  defp replay_baseline_activate_notice(baseline_id) when is_binary(baseline_id) do
    "replay:baseline:activate:#{baseline_id}"
  end

  defp normalize_reconciliation_hints(raw_hints) when is_map(raw_hints) do
    next_actions =
      raw_hints
      |> fetch_any(:next_actions)
      |> List.wrap()
      |> Enum.filter(&(is_binary(&1) and &1 != ""))

    severity =
      case fetch_any(raw_hints, :severity) do
        level when level in ["info", "warning", "error"] -> level
        _ -> nil
      end

    %{
      primary_notice: fetch_string(raw_hints, :primary_notice),
      severity: severity,
      next_actions: next_actions,
      focus_field: fetch_string(raw_hints, :focus_field)
    }
  end

  defp normalize_reconciliation_hints(_raw_hints), do: empty_reconciliation_hints()

  defp empty_reconciliation_hints do
    %{
      primary_notice: nil,
      severity: nil,
      next_actions: [],
      focus_field: nil
    }
  end

  defp fetch_any(map, key) when is_map(map) do
    Map.get(map, key) || Map.get(map, Atom.to_string(key))
  end

  defp fetch_string(map, key) when is_map(map) do
    case fetch_any(map, key) do
      value when is_binary(value) and value != "" -> value
      _ -> nil
    end
  end

  defp fetch_string(_map, _key), do: nil

  defp fetch_map(map, key) when is_map(map) do
    case fetch_any(map, key) do
      value when is_map(value) -> value
      _ -> %{}
    end
  end

  defp fetch_map(_map, _key), do: %{}

  defp fetch_boolean(map, key, default) when is_map(map) do
    case fetch_any(map, key) do
      value when is_boolean(value) -> value
      _ -> default
    end
  end

  defp fetch_boolean(_map, _key, default), do: default

  defp normalize_join_error(%TypedError{} = error, _runtime_context), do: error

  defp normalize_join_error(reason, runtime_context) do
    TypedError.new(
      "ui.bootstrap_join_failed",
      "protocol",
      true,
      %{reason: inspect(reason)},
      Map.get(runtime_context, :correlation_id, "unknown")
    )
  end
end
