defmodule WebUi.Persistence.ReplayLogTest do
  use ExUnit.Case, async: true

  alias WebUi.Persistence.ReplayLog
  alias WebUi.TypedError

  test "append builds deterministic cursor progression and checkpoints" do
    assert ReplayLog.new() == %{cursor: 0, entries: [], last_checkpoint_id: nil}

    {:ok, log} =
      ReplayLog.new()
      |> ReplayLog.append(%{
        direction: :outbound,
        event: "runtime.event.send.v1",
        metadata: %{dispatch_sequence: 1, turn_id: "turn-000001"}
      })

    assert log.cursor == 1
    assert length(log.entries) == 1
    assert hd(log.entries).cursor == 1
    assert hd(log.entries).direction == :outbound
    assert hd(log.entries).event == "runtime.event.send.v1"
    assert is_binary(log.last_checkpoint_id)
    assert String.starts_with?(log.last_checkpoint_id, "replay-000001-")

    {:ok, log2} =
      ReplayLog.append(log, %{
        direction: :inbound,
        event: :ws_result_received,
        metadata: %{outcome: "ok", turn_id: "turn-000001"}
      })

    assert log2.cursor == 2
    assert Enum.map(log2.entries, & &1.cursor) == [1, 2]
    assert String.starts_with?(log2.last_checkpoint_id, "replay-000002-")
  end

  test "entries_since returns deterministic slices from a cursor" do
    {:ok, log1} =
      ReplayLog.new()
      |> ReplayLog.append(%{direction: :outbound, event: "a", metadata: %{n: 1}})

    {:ok, log2} =
      ReplayLog.append(log1, %{direction: :inbound, event: "b", metadata: %{n: 2}})

    {:ok, log3} =
      ReplayLog.append(log2, %{direction: :outbound, event: "c", metadata: %{n: 3}})

    assert Enum.map(ReplayLog.entries_since(log3, 0), & &1.event) == ["a", "b", "c"]
    assert Enum.map(ReplayLog.entries_since(log3, 1), & &1.event) == ["b", "c"]
    assert Enum.map(ReplayLog.entries_since(log3, 2), & &1.event) == ["c"]
    assert ReplayLog.entries_since(log3, 3) == []
  end

  test "fails closed for invalid logs and malformed entries" do
    assert {:error, %TypedError{} = invalid_log_error} =
             ReplayLog.append(%{cursor: -1, entries: []}, %{direction: :outbound, event: "x"})

    assert invalid_log_error.error_code == "replay_log.invalid_log_state"

    assert {:error, %TypedError{} = invalid_entry_error} =
             ReplayLog.append(ReplayLog.new(), %{direction: :sideways, event: ""})

    assert invalid_entry_error.error_code == "replay_log.invalid_entry_shape"
  end

  test "snapshot and export provide deterministic replay slices" do
    {:ok, log1} =
      ReplayLog.new()
      |> ReplayLog.append(%{direction: :outbound, event: "dispatch", metadata: %{seq: 1}})

    {:ok, log2} =
      ReplayLog.append(log1, %{direction: :inbound, event: "result", metadata: %{seq: 1}})

    {:ok, snapshot} = ReplayLog.snapshot(log2, %{from_cursor: 0, limit: 1})

    assert snapshot.cursor == 2
    assert snapshot.entry_count == 1
    assert Enum.map(snapshot.entries, & &1.event) == ["dispatch"]
    assert String.starts_with?(snapshot.checkpoint_id, "replay-000002-")

    {:ok, export_payload} = ReplayLog.export(log2)

    assert export_payload.format == "web_ui.replay_log.export.v1"
    assert export_payload.cursor == 2
    assert length(export_payload.entries) == 2
    assert String.starts_with?(export_payload.checkpoint_id, "replay-000002-")
  end

  test "compaction retains deterministic trailing entries and fails closed on invalid options" do
    {:ok, log1} =
      ReplayLog.new()
      |> ReplayLog.append(%{direction: :outbound, event: "a", metadata: %{seq: 1}})

    {:ok, log2} =
      ReplayLog.append(log1, %{direction: :inbound, event: "b", metadata: %{seq: 1}})

    {:ok, log3} =
      ReplayLog.append(log2, %{direction: :outbound, event: "c", metadata: %{seq: 2}})

    {:ok, compacted} = ReplayLog.compact(log3, %{keep_last: 2})

    assert compacted.cursor == 3
    assert Enum.map(compacted.entries, & &1.event) == ["b", "c"]
    assert Enum.map(compacted.entries, & &1.cursor) == [2, 3]
    assert String.starts_with?(compacted.last_checkpoint_id, "replay-000003-")

    assert {:error, %TypedError{} = compaction_error} = ReplayLog.compact(log3, %{keep_last: -1})
    assert compaction_error.error_code == "replay_log.invalid_compaction_options"
  end

  test "restore rehydrates replay logs deterministically from export payloads" do
    {:ok, log1} =
      ReplayLog.new()
      |> ReplayLog.append(%{direction: :outbound, event: "dispatch", metadata: %{seq: 1}})

    {:ok, log2} =
      ReplayLog.append(log1, %{direction: :inbound, event: "result", metadata: %{seq: 1}})

    {:ok, export_payload} = ReplayLog.export(log2)
    {:ok, restored} = ReplayLog.restore(export_payload)

    assert restored == log2

    {:ok, log3} =
      ReplayLog.append(restored, %{direction: :outbound, event: "dispatch", metadata: %{seq: 2}})

    assert log3.cursor == 3
    assert Enum.map(log3.entries, & &1.cursor) == [1, 2, 3]
    assert String.starts_with?(log3.last_checkpoint_id, "replay-000003-")
  end

  test "restore fails closed for malformed payloads and mismatched checkpoints" do
    {:ok, log1} =
      ReplayLog.new()
      |> ReplayLog.append(%{direction: :outbound, event: "dispatch", metadata: %{seq: 1}})

    {:ok, export_payload} = ReplayLog.export(log1)

    assert {:error, %TypedError{} = invalid_format_error} =
             ReplayLog.restore(Map.put(export_payload, :format, "other.format"))

    assert invalid_format_error.error_code == "replay_log.invalid_export_format"

    assert {:error, %TypedError{} = mismatch_error} =
             ReplayLog.restore(
               Map.put(export_payload, :checkpoint_id, "replay-000001-badbadbad0")
             )

    assert mismatch_error.error_code == "replay_log.restore_checkpoint_mismatch"

    assert {:error, %TypedError{} = invalid_cursor_error} =
             ReplayLog.restore(
               Map.put(export_payload, :entries, [
                 %{cursor: 2, direction: :outbound, event: "dispatch", metadata: %{seq: 1}}
               ])
             )

    assert invalid_cursor_error.error_code == "replay_log.invalid_restore_payload"
  end

  test "compare reports deterministic match summary for equivalent replay logs" do
    {:ok, log1} =
      ReplayLog.new()
      |> ReplayLog.append(%{direction: :outbound, event: "dispatch", metadata: %{seq: 1}})

    {:ok, log2} =
      ReplayLog.append(log1, %{direction: :inbound, event: "result", metadata: %{seq: 1}})

    {:ok, comparison} = ReplayLog.compare(log2, log2)

    assert comparison.status == "match"
    assert comparison.actual_cursor == 2
    assert comparison.expected_cursor == 2
    assert comparison.first_drift == nil
    assert String.starts_with?(comparison.actual_checkpoint_id, "replay-000002-")
    assert comparison.actual_checkpoint_id == comparison.expected_checkpoint_id
  end

  test "verify_export reports deterministic drift summaries for mismatched exports" do
    {:ok, log1} =
      ReplayLog.new()
      |> ReplayLog.append(%{direction: :outbound, event: "dispatch", metadata: %{seq: 1}})

    {:ok, log2} =
      ReplayLog.append(log1, %{direction: :inbound, event: "result", metadata: %{seq: 1}})

    {:ok, mismatched_export} = ReplayLog.export(log1)

    {:ok, verification} = ReplayLog.verify_export(log2, mismatched_export)

    assert verification.status == "drift"
    assert verification.expected_source == "export"
    assert verification.actual_cursor == 2
    assert verification.expected_cursor == 1
    assert verification.first_drift.reason == "entry_count_mismatch"
    assert verification.first_drift.cursor == 2
  end

  test "gate_export returns pass for deterministic match verification under default policy" do
    {:ok, log1} =
      ReplayLog.new()
      |> ReplayLog.append(%{direction: :outbound, event: "dispatch", metadata: %{seq: 1}})

    {:ok, log2} =
      ReplayLog.append(log1, %{direction: :inbound, event: "result", metadata: %{seq: 1}})

    {:ok, expected_export} = ReplayLog.export(log2)
    {:ok, gate} = ReplayLog.gate_export(log2, expected_export)

    assert gate.status == "pass"
    assert gate.reasons == []
    assert gate.cursor_delta == 0
    assert gate.entry_count_delta == 0
    assert gate.verification.status == "match"
  end

  test "gate_export returns deterministic failure reasons for drift under strict policy" do
    {:ok, log1} =
      ReplayLog.new()
      |> ReplayLog.append(%{direction: :outbound, event: "dispatch", metadata: %{seq: 1}})

    {:ok, log2} =
      ReplayLog.append(log1, %{direction: :inbound, event: "result", metadata: %{seq: 1}})

    {:ok, mismatched_export} = ReplayLog.export(log1)
    {:ok, gate} = ReplayLog.gate_export(log2, mismatched_export)
    reason_codes = Enum.map(gate.reasons, & &1.code)

    assert gate.status == "fail"
    assert gate.verification.status == "drift"
    assert gate.cursor_delta == 1
    assert gate.entry_count_delta == 1
    assert "status_not_allowed" in reason_codes
    assert "cursor_delta_exceeded" in reason_codes
    assert "entry_count_delta_exceeded" in reason_codes
  end

  test "gate_export supports relaxed policies for controlled drift acceptance" do
    {:ok, log1} =
      ReplayLog.new()
      |> ReplayLog.append(%{direction: :outbound, event: "dispatch", metadata: %{seq: 1}})

    {:ok, log2} =
      ReplayLog.append(log1, %{direction: :inbound, event: "result", metadata: %{seq: 1}})

    {:ok, mismatched_export} = ReplayLog.export(log1)

    {:ok, gate} =
      ReplayLog.gate_export(log2, mismatched_export, %{
        allowed_statuses: ["match", "drift"],
        max_cursor_delta: 1,
        max_entry_count_delta: 1,
        allow_entry_mismatch: true
      })

    assert gate.status == "pass"
    assert gate.reasons == []
    assert gate.verification.status == "drift"
  end

  test "capture_baseline returns deterministic baseline envelopes with metadata" do
    {:ok, log1} =
      ReplayLog.new()
      |> ReplayLog.append(%{direction: :outbound, event: "dispatch", metadata: %{seq: 1}})

    {:ok, log2} =
      ReplayLog.append(log1, %{direction: :inbound, event: "result", metadata: %{seq: 1}})

    {:ok, baseline} = ReplayLog.capture_baseline(log2, %{label: "release-25"})

    assert baseline.format == "web_ui.replay_baseline.v1"
    assert String.starts_with?(baseline.baseline_id, "baseline-000002-")
    assert baseline.cursor == 2
    assert baseline.entry_count == 2
    assert baseline.metadata == %{label: "release-25"}
    assert baseline.export.format == "web_ui.replay_log.export.v1"
    assert baseline.export.cursor == 2
    assert length(baseline.export.entries) == 2
    assert String.starts_with?(baseline.checkpoint_id, "replay-000002-")
    assert baseline.checkpoint_id == baseline.export.checkpoint_id
  end

  test "gate_baseline returns deterministic pass summaries for equivalent replay logs" do
    {:ok, log1} =
      ReplayLog.new()
      |> ReplayLog.append(%{direction: :outbound, event: "dispatch", metadata: %{seq: 1}})

    {:ok, log2} =
      ReplayLog.append(log1, %{direction: :inbound, event: "result", metadata: %{seq: 1}})

    {:ok, baseline} = ReplayLog.capture_baseline(log2, %{label: "release-25"})
    {:ok, baseline_gate} = ReplayLog.gate_baseline(log2, baseline)

    assert baseline_gate.status == "pass"
    assert baseline_gate.baseline.baseline_id == baseline.baseline_id
    assert baseline_gate.baseline.cursor == 2
    assert baseline_gate.baseline.entry_count == 2
    assert baseline_gate.baseline.metadata == %{label: "release-25"}
    assert baseline_gate.gate.status == "pass"
    assert baseline_gate.gate.reasons == []
    assert baseline_gate.gate.verification.status == "match"
  end

  test "gate_baseline returns deterministic failure reasons for drift under strict policy" do
    {:ok, log1} =
      ReplayLog.new()
      |> ReplayLog.append(%{direction: :outbound, event: "dispatch", metadata: %{seq: 1}})

    {:ok, log2} =
      ReplayLog.append(log1, %{direction: :inbound, event: "result", metadata: %{seq: 1}})

    {:ok, baseline} = ReplayLog.capture_baseline(log1, %{label: "release-25"})
    {:ok, baseline_gate} = ReplayLog.gate_baseline(log2, baseline)
    reason_codes = Enum.map(baseline_gate.gate.reasons, & &1.code)

    assert baseline_gate.status == "fail"
    assert baseline_gate.baseline.cursor == 1
    assert baseline_gate.gate.status == "fail"
    assert baseline_gate.gate.verification.status == "drift"
    assert baseline_gate.gate.cursor_delta == 1
    assert baseline_gate.gate.entry_count_delta == 1
    assert "status_not_allowed" in reason_codes
    assert "cursor_delta_exceeded" in reason_codes
    assert "entry_count_delta_exceeded" in reason_codes
  end

  test "gate_baseline fails closed for malformed baseline payloads" do
    {:ok, log} =
      ReplayLog.new()
      |> ReplayLog.append(%{direction: :outbound, event: "dispatch", metadata: %{seq: 1}})

    {:ok, baseline} = ReplayLog.capture_baseline(log, %{label: "release-25"})

    assert {:error, %TypedError{} = invalid_format_error} =
             ReplayLog.gate_baseline(log, Map.put(baseline, :format, "invalid.replay.baseline"))

    assert invalid_format_error.error_code == "replay_log.invalid_baseline_format"

    assert {:error, %TypedError{} = mismatch_error} =
             ReplayLog.gate_baseline(log, Map.put(baseline, :entry_count, 7))

    assert mismatch_error.error_code == "replay_log.baseline_export_mismatch"

    assert {:error, %TypedError{} = baseline_id_mismatch_error} =
             ReplayLog.gate_baseline(
               log,
               Map.put(baseline, :baseline_id, "baseline-000001-badbadbad0")
             )

    assert baseline_id_mismatch_error.error_code == "replay_log.baseline_export_mismatch"

    legacy_baseline = Map.delete(baseline, :baseline_id)
    assert {:ok, legacy_gate} = ReplayLog.gate_baseline(log, legacy_baseline)
    assert legacy_gate.status == "pass"
    assert legacy_gate.baseline.baseline_id == baseline.baseline_id

    assert {:error, %TypedError{} = invalid_baseline_error} =
             ReplayLog.capture_baseline(log, "release-25")

    assert invalid_baseline_error.error_code == "replay_log.invalid_baseline_payload"
  end
end
