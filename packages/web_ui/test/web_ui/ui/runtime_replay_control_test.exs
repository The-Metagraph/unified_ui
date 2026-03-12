defmodule WebUi.Ui.RuntimeReplayControlTest do
  use ExUnit.Case, async: true

  alias WebUi.Persistence.ReplayLog
  alias WebUi.Ui.Message
  alias WebUi.Ui.Runtime

  defp model_with_session do
    {:ok, model, _commands} =
      Runtime.init(%{
        runtime_context: %{
          correlation_id: "corr-replay-ctl",
          request_id: "req-replay-ctl",
          session_id: "sess-replay-ctl"
        }
      })

    model
  end

  defp model_with_replay_entries do
    model = model_with_session()

    {model, [first_dispatch]} =
      Runtime.update(
        model,
        Message.widget_event(%{
          type: "unified.button.clicked",
          widget_id: "save_button",
          widget_kind: "button",
          data: %{action: "save"}
        })
      )

    first_turn_id = first_dispatch.payload.event["data"]["turn_id"]

    {model, []} =
      Runtime.update(
        model,
        Message.websocket_recv(%{
          result: %{
            service: "ui.preferences",
            operation: "save_preferences",
            outcome: "ok",
            payload: %{turn_id: first_turn_id},
            context: %{
              correlation_id: "corr-replay-ctl",
              request_id: "req-replay-ctl",
              session_id: "sess-replay-ctl"
            }
          }
        })
      )

    {model, [second_dispatch]} =
      Runtime.update(
        model,
        Message.widget_event(%{
          type: "unified.button.clicked",
          widget_id: "save_button",
          widget_kind: "button",
          data: %{action: "publish"}
        })
      )

    second_turn_id = second_dispatch.payload.event["data"]["turn_id"]

    {model, []} =
      Runtime.update(
        model,
        Message.websocket_recv(%{
          result: %{
            service: "ui.preferences",
            operation: "save_preferences",
            outcome: "ok",
            payload: %{turn_id: second_turn_id},
            context: %{
              correlation_id: "corr-replay-ctl",
              request_id: "req-replay-ctl",
              session_id: "sess-replay-ctl"
            }
          }
        })
      )

    model
  end

  test "replay_snapshot_requested stores deterministic snapshot diagnostics" do
    model = model_with_replay_entries()

    assert model.recovery_state.replay_cursor == 4
    assert length(model.recovery_state.replay_log.entries) == 4

    {updated_model, []} =
      Runtime.update(model, Message.replay_snapshot_requested(%{from_cursor: 2}))

    snapshot = updated_model.recovery_state.last_replay_snapshot

    assert snapshot.cursor == 4
    assert snapshot.entry_count == 2
    assert Enum.map(snapshot.entries, & &1.cursor) == [3, 4]
    assert hd(updated_model.view_state.notices) == "replay:snapshot:2:4"
    assert hd(updated_model.inbound_history).event == :replay_snapshot_requested
  end

  test "replay_export_requested stores deterministic export payloads" do
    model = model_with_replay_entries()

    {updated_model, []} =
      Runtime.update(
        model,
        Message.replay_export_requested(%{include_snapshot: true, from_cursor: 2, limit: 1})
      )

    replay_export = updated_model.recovery_state.last_replay_export
    replay_snapshot = updated_model.recovery_state.last_replay_snapshot

    assert replay_export.format == "web_ui.replay_log.export.v1"
    assert replay_export.cursor == 4
    assert length(replay_export.entries) == 4
    assert replay_snapshot.entry_count == 1
    assert Enum.map(replay_snapshot.entries, & &1.cursor) == [3]
    assert hd(updated_model.view_state.notices) == "replay:export:4:4"
    assert hd(updated_model.inbound_history).event == :replay_export_requested
  end

  test "replay_compaction_requested preserves cursor continuity while retaining trailing entries" do
    model = model_with_replay_entries()

    {updated_model, []} =
      Runtime.update(model, Message.replay_compaction_requested(%{keep_last: 2}))

    replay_log = updated_model.recovery_state.replay_log

    assert updated_model.recovery_state.replay_cursor == 4
    assert updated_model.recovery_state.replay_retention_limit == 2
    assert Enum.map(replay_log.entries, & &1.cursor) == [3, 4]
    assert Enum.map(replay_log.entries, & &1.direction) == [:outbound, :inbound]

    assert String.starts_with?(
             updated_model.recovery_state.last_replay_checkpoint_id,
             "replay-000004-"
           )

    assert hd(updated_model.view_state.notices) == "replay:compact:2:2"
    assert hd(updated_model.inbound_history).event == :replay_compaction_requested
  end

  test "replay_compaction_requested fails closed on invalid keep_last options" do
    model = model_with_replay_entries()

    {updated_model, commands} =
      Runtime.update(model, Message.replay_compaction_requested(%{keep_last: -1}))

    assert commands == []
    assert updated_model.last_error.error_code == "replay_log.invalid_compaction_options"
  end

  test "replay_restore_requested rehydrates deterministic replay diagnostics from export payloads" do
    model = model_with_replay_entries()
    {model, []} = Runtime.update(model, Message.replay_export_requested(%{}))
    export_payload = model.recovery_state.last_replay_export
    restored_base = model_with_session()

    {restored_model, []} =
      Runtime.update(restored_base, Message.replay_restore_requested(%{export: export_payload}))

    assert restored_model.recovery_state.replay_cursor == 4
    assert restored_model.recovery_state.replay_log.cursor == 4

    assert String.starts_with?(
             restored_model.recovery_state.last_replay_checkpoint_id,
             "replay-000004-"
           )

    assert restored_model.recovery_state.last_replay_restore == %{
             cursor: 4,
             checkpoint_id: restored_model.recovery_state.last_replay_checkpoint_id,
             entry_count: 4
           }

    assert hd(restored_model.view_state.notices) == "replay:restore:4:4"
    assert hd(restored_model.inbound_history).event == :replay_restore_requested
  end

  test "replay_restore_requested preserves cursor continuity for subsequent replay appends" do
    model = model_with_replay_entries()
    {model, []} = Runtime.update(model, Message.replay_export_requested(%{}))
    export_payload = model.recovery_state.last_replay_export
    restored_base = model_with_session()

    {restored_model, []} =
      Runtime.update(restored_base, Message.replay_restore_requested(%{export: export_payload}))

    {updated_model, [_command]} =
      Runtime.update(
        restored_model,
        Message.widget_event(%{
          type: "unified.button.clicked",
          widget_id: "save_button",
          widget_kind: "button",
          data: %{action: "save_after_restore"}
        })
      )

    last_entry = List.last(updated_model.recovery_state.replay_log.entries)

    assert updated_model.recovery_state.replay_cursor == 5
    assert updated_model.recovery_state.replay_log.cursor == 5
    assert last_entry.cursor == 5
    assert last_entry.direction == :outbound
    assert last_entry.event == "runtime.event.send.v1"

    assert String.starts_with?(
             updated_model.recovery_state.last_replay_checkpoint_id,
             "replay-000005-"
           )
  end

  test "replay_restore_requested fails closed for malformed restore payloads" do
    model = model_with_session()

    {updated_model, commands} =
      Runtime.update(
        model,
        Message.replay_restore_requested(%{
          export: %{
            format: "invalid.replay.export.v1",
            cursor: 0,
            checkpoint_id: nil,
            entries: []
          }
        })
      )

    assert commands == []
    assert updated_model.last_error.error_code == "replay_log.invalid_export_format"
  end

  test "replay_verification_requested stores deterministic match diagnostics for equivalent exports" do
    model = model_with_replay_entries()
    {model, []} = Runtime.update(model, Message.replay_export_requested(%{}))
    expected_export = model.recovery_state.last_replay_export

    {updated_model, []} =
      Runtime.update(
        model,
        Message.replay_verification_requested(%{expected_export: expected_export})
      )

    verification = updated_model.recovery_state.last_replay_verification

    assert verification.status == "match"
    assert verification.expected_source == "export"
    assert verification.actual_cursor == 4
    assert verification.expected_cursor == 4
    assert verification.first_drift == nil
    assert hd(updated_model.view_state.notices) == "replay:verify:match:4:4"
    assert hd(updated_model.inbound_history).event == :replay_verification_requested
  end

  test "replay_verification_requested stores deterministic drift diagnostics for mismatched exports" do
    model = model_with_replay_entries()
    {:ok, compacted_log} = ReplayLog.compact(model.recovery_state.replay_log, %{keep_last: 1})
    {:ok, drift_export} = ReplayLog.export(compacted_log)

    {updated_model, []} =
      Runtime.update(
        model,
        Message.replay_verification_requested(%{expected_export: drift_export})
      )

    verification = updated_model.recovery_state.last_replay_verification

    assert verification.status == "drift"
    assert verification.actual_cursor == 4
    assert verification.expected_cursor == 4
    assert verification.first_drift.reason == "entry_mismatch"
    assert verification.first_drift.cursor == 1
    assert hd(updated_model.view_state.notices) == "replay:verify:drift:4:4"
    assert hd(updated_model.inbound_history).event == :replay_verification_requested
  end

  test "replay_verification_requested fails closed for malformed expected exports" do
    model = model_with_session()

    {updated_model, commands} =
      Runtime.update(
        model,
        Message.replay_verification_requested(%{
          expected_export: %{
            format: "invalid.replay.export.v1",
            cursor: 0,
            checkpoint_id: nil,
            entries: []
          }
        })
      )

    assert commands == []
    assert updated_model.last_error.error_code == "replay_log.invalid_export_format"
  end

  test "replay_verification_gate_requested stores deterministic pass diagnostics for equivalent exports" do
    model = model_with_replay_entries()
    {model, []} = Runtime.update(model, Message.replay_export_requested(%{}))
    expected_export = model.recovery_state.last_replay_export

    {updated_model, []} =
      Runtime.update(
        model,
        Message.replay_verification_gate_requested(%{expected_export: expected_export})
      )

    gate = updated_model.recovery_state.last_replay_verification_gate

    assert gate.status == "pass"
    assert gate.reasons == []
    assert gate.cursor_delta == 0
    assert gate.entry_count_delta == 0
    assert gate.verification.status == "match"
    assert hd(updated_model.view_state.notices) == "replay:gate:pass:0:0"
    assert hd(updated_model.inbound_history).event == :replay_verification_gate_requested
  end

  test "replay_verification_gate_requested stores deterministic fail reasons under strict policy" do
    model = model_with_replay_entries()
    {:ok, compacted_log} = ReplayLog.compact(model.recovery_state.replay_log, %{keep_last: 1})
    {:ok, drift_export} = ReplayLog.export(compacted_log)

    {updated_model, []} =
      Runtime.update(
        model,
        Message.replay_verification_gate_requested(%{expected_export: drift_export})
      )

    gate = updated_model.recovery_state.last_replay_verification_gate
    reason_codes = Enum.map(gate.reasons, & &1.code)

    assert gate.status == "fail"
    assert gate.cursor_delta == 0
    assert gate.entry_count_delta == 3
    assert gate.verification.status == "drift"
    assert "status_not_allowed" in reason_codes
    assert "entry_count_delta_exceeded" in reason_codes
    assert "entry_mismatch_not_allowed" in reason_codes
    assert hd(updated_model.view_state.notices) == "replay:gate:fail:0:3"
    assert hd(updated_model.inbound_history).event == :replay_verification_gate_requested
  end

  test "replay_verification_gate_requested accepts deterministic drift with relaxed policy" do
    model = model_with_replay_entries()
    {:ok, compacted_log} = ReplayLog.compact(model.recovery_state.replay_log, %{keep_last: 1})
    {:ok, drift_export} = ReplayLog.export(compacted_log)

    {updated_model, []} =
      Runtime.update(
        model,
        Message.replay_verification_gate_requested(%{
          expected_export: drift_export,
          policy: %{
            allowed_statuses: ["match", "drift"],
            max_cursor_delta: 0,
            max_entry_count_delta: 3,
            allow_entry_mismatch: true
          }
        })
      )

    gate = updated_model.recovery_state.last_replay_verification_gate

    assert gate.status == "pass"
    assert gate.reasons == []
    assert gate.verification.status == "drift"
    assert hd(updated_model.view_state.notices) == "replay:gate:pass:0:3"
    assert hd(updated_model.inbound_history).event == :replay_verification_gate_requested
  end

  test "replay_verification_gate_requested fails closed for malformed policy payloads" do
    model = model_with_replay_entries()
    {model, []} = Runtime.update(model, Message.replay_export_requested(%{}))
    expected_export = model.recovery_state.last_replay_export

    {updated_model, commands} =
      Runtime.update(
        model,
        Message.replay_verification_gate_requested(%{
          expected_export: expected_export,
          policy: %{max_cursor_delta: -1}
        })
      )

    assert commands == []
    assert updated_model.last_error.error_code == "replay_log.invalid_verification_policy"
  end

  test "replay_baseline_capture_requested stores deterministic baseline diagnostics" do
    model = model_with_replay_entries()

    {updated_model, []} =
      Runtime.update(
        model,
        Message.replay_baseline_capture_requested(%{metadata: %{label: "release-25"}})
      )

    baseline = updated_model.recovery_state.last_replay_baseline
    baseline_registry = updated_model.recovery_state.replay_baseline_registry

    assert baseline.format == "web_ui.replay_baseline.v1"
    assert String.starts_with?(baseline.baseline_id, "baseline-000004-")
    assert baseline.cursor == 4
    assert baseline.entry_count == 4
    assert baseline.metadata == %{label: "release-25"}
    assert baseline.export.cursor == 4
    assert length(baseline.export.entries) == 4
    assert baseline_registry.order == [baseline.baseline_id]
    assert baseline_registry.active_baseline_id == baseline.baseline_id
    assert hd(updated_model.view_state.notices) == "replay:baseline:capture:4:4"
    assert hd(updated_model.inbound_history).event == :replay_baseline_capture_requested
  end

  test "replay_baseline_capture_requested supports retention and explicit activation controls" do
    model = model_with_replay_entries()

    {model, []} =
      Runtime.update(
        model,
        Message.replay_baseline_capture_requested(%{
          metadata: %{label: "release-25-a"},
          retention_limit: 1,
          activate: true
        })
      )

    first_baseline = model.recovery_state.last_replay_baseline

    {model, [_command]} =
      Runtime.update(
        model,
        Message.widget_event(%{
          type: "unified.button.clicked",
          widget_id: "save_button",
          widget_kind: "button",
          data: %{action: "release-25-second-capture"}
        })
      )

    {updated_model, []} =
      Runtime.update(
        model,
        Message.replay_baseline_capture_requested(%{
          metadata: %{label: "release-25-b"},
          retention_limit: 1,
          activate: false
        })
      )

    baseline_registry = updated_model.recovery_state.replay_baseline_registry
    second_baseline = updated_model.recovery_state.last_replay_baseline

    assert second_baseline.baseline_id != first_baseline.baseline_id
    assert baseline_registry.retention_limit == 1
    assert baseline_registry.order == [second_baseline.baseline_id]
    assert baseline_registry.active_baseline_id == second_baseline.baseline_id
  end

  test "replay_baseline_capture_requested fails closed for malformed metadata payloads" do
    model = model_with_replay_entries()

    {updated_model, commands} =
      Runtime.update(
        model,
        Message.replay_baseline_capture_requested(%{metadata: "release-25"})
      )

    assert commands == []
    assert updated_model.last_error.error_code == "replay_log.invalid_baseline_payload"
  end

  test "replay_baseline_gate_requested stores deterministic pass diagnostics for equivalent baselines" do
    model = model_with_replay_entries()
    {model, []} = Runtime.update(model, Message.replay_baseline_capture_requested(%{}))

    {updated_model, []} =
      Runtime.update(model, Message.replay_baseline_gate_requested(%{}))

    baseline_gate = updated_model.recovery_state.last_replay_baseline_gate

    assert baseline_gate.status == "pass"
    assert baseline_gate.gate.status == "pass"
    assert baseline_gate.gate.reasons == []
    assert baseline_gate.gate.cursor_delta == 0
    assert baseline_gate.gate.entry_count_delta == 0
    assert baseline_gate.gate.verification.status == "match"
    assert updated_model.recovery_state.last_replay_verification.status == "match"
    assert updated_model.recovery_state.last_replay_verification_gate.status == "pass"
    assert hd(updated_model.view_state.notices) == "replay:baseline:gate:pass:0:0"
    assert hd(updated_model.inbound_history).event == :replay_baseline_gate_requested
  end

  test "replay_baseline_activate_requested selects deterministic active baseline from registry" do
    model = model_with_replay_entries()

    {model, []} =
      Runtime.update(
        model,
        Message.replay_baseline_capture_requested(%{
          metadata: %{label: "release-25-a"},
          retention_limit: 2,
          activate: true
        })
      )

    first_baseline = model.recovery_state.last_replay_baseline

    {model, [_command]} =
      Runtime.update(
        model,
        Message.widget_event(%{
          type: "unified.button.clicked",
          widget_id: "save_button",
          widget_kind: "button",
          data: %{action: "release-25-second-capture"}
        })
      )

    {model, []} =
      Runtime.update(
        model,
        Message.replay_baseline_capture_requested(%{
          metadata: %{label: "release-25-b"},
          retention_limit: 2,
          activate: true
        })
      )

    second_baseline = model.recovery_state.last_replay_baseline
    assert second_baseline.baseline_id != first_baseline.baseline_id

    {updated_model, []} =
      Runtime.update(
        model,
        Message.replay_baseline_activate_requested(%{baseline_id: first_baseline.baseline_id})
      )

    baseline_registry = updated_model.recovery_state.replay_baseline_registry

    assert baseline_registry.active_baseline_id == first_baseline.baseline_id

    assert updated_model.recovery_state.last_replay_baseline.baseline_id ==
             first_baseline.baseline_id

    assert hd(updated_model.view_state.notices) ==
             "replay:baseline:activate:#{first_baseline.baseline_id}"

    assert hd(updated_model.inbound_history).event == :replay_baseline_activate_requested
  end

  test "replay_baseline_activate_requested fails closed for missing baseline IDs" do
    model = model_with_replay_entries()

    {updated_model, commands} =
      Runtime.update(model, Message.replay_baseline_activate_requested(%{}))

    assert commands == []
    assert updated_model.last_error.error_code == "ui.replay_baseline.invalid_payload"
  end

  test "replay_baseline_gate_requested resolves explicit baseline_id from registry" do
    model = model_with_replay_entries()

    {model, []} =
      Runtime.update(
        model,
        Message.replay_baseline_capture_requested(%{
          metadata: %{label: "release-25-a"},
          retention_limit: 2,
          activate: true
        })
      )

    first_baseline = model.recovery_state.last_replay_baseline

    {model, [_command]} =
      Runtime.update(
        model,
        Message.widget_event(%{
          type: "unified.button.clicked",
          widget_id: "save_button",
          widget_kind: "button",
          data: %{action: "release-25-second-capture"}
        })
      )

    {model, []} =
      Runtime.update(
        model,
        Message.replay_baseline_capture_requested(%{
          metadata: %{label: "release-25-b"},
          retention_limit: 2,
          activate: true
        })
      )

    {updated_model, []} =
      Runtime.update(
        model,
        Message.replay_baseline_gate_requested(%{
          baseline_id: first_baseline.baseline_id,
          policy: %{
            allowed_statuses: ["match", "drift"],
            max_cursor_delta: 1,
            max_entry_count_delta: 1,
            allow_entry_mismatch: true
          }
        })
      )

    baseline_gate = updated_model.recovery_state.last_replay_baseline_gate

    assert baseline_gate.status == "pass"
    assert baseline_gate.baseline.baseline_id == first_baseline.baseline_id
    assert baseline_gate.gate.verification.status == "drift"
    assert baseline_gate.gate.cursor_delta == 1
    assert baseline_gate.gate.entry_count_delta == 1
  end

  test "replay_baseline_gate_requested stores deterministic fail reasons under strict policy" do
    model = model_with_replay_entries()
    {:ok, compacted_log} = ReplayLog.compact(model.recovery_state.replay_log, %{keep_last: 1})
    {:ok, drift_baseline} = ReplayLog.capture_baseline(compacted_log, %{label: "release-24"})

    {updated_model, []} =
      Runtime.update(
        model,
        Message.replay_baseline_gate_requested(%{baseline: drift_baseline})
      )

    baseline_gate = updated_model.recovery_state.last_replay_baseline_gate
    reason_codes = Enum.map(baseline_gate.gate.reasons, & &1.code)

    assert baseline_gate.status == "fail"
    assert baseline_gate.gate.status == "fail"
    assert baseline_gate.gate.verification.status == "drift"
    assert baseline_gate.gate.cursor_delta == 0
    assert baseline_gate.gate.entry_count_delta == 3
    assert "status_not_allowed" in reason_codes
    assert "entry_count_delta_exceeded" in reason_codes
    assert "entry_mismatch_not_allowed" in reason_codes
    assert hd(updated_model.view_state.notices) == "replay:baseline:gate:fail:0:3"
    assert hd(updated_model.inbound_history).event == :replay_baseline_gate_requested
  end

  test "replay_baseline_gate_requested fails closed when no baseline is available" do
    model = model_with_replay_entries()

    {updated_model, commands} =
      Runtime.update(model, Message.replay_baseline_gate_requested(%{}))

    assert commands == []
    assert updated_model.last_error.error_code == "ui.replay_baseline.missing_baseline"
  end

  test "replay_baseline_gate_requested fails closed for unknown baseline IDs" do
    model = model_with_replay_entries()
    {model, []} = Runtime.update(model, Message.replay_baseline_capture_requested(%{}))

    {updated_model, commands} =
      Runtime.update(
        model,
        Message.replay_baseline_gate_requested(%{baseline_id: "baseline-000999-0000000000"})
      )

    assert commands == []
    assert updated_model.last_error.error_code == "replay_baseline_registry.baseline_not_found"
  end
end
