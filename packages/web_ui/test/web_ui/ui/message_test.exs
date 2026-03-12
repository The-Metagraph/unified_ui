defmodule WebUi.Ui.MessageTest do
  use ExUnit.Case, async: true

  alias WebUi.Ui.Message

  test "builds baseline websocket message variants" do
    assert Message.websocket_recv(%{event: "recv"}).type == :ws_event_received
    assert Message.websocket_error(%{error: "boom"}).type == :ws_error_received
    assert Message.websocket_pong(%{request_id: "req"}).type == :ws_pong_received
  end

  test "builds join and interaction message variants" do
    assert Message.websocket_joined(%{topic: "webui:runtime:v1"}).type == :ws_joined
    assert Message.websocket_join_failed(%{reason: "denied"}).type == :ws_join_failed
    assert Message.websocket_disconnected(%{reason: "socket_lost"}).type == :ws_disconnected
    assert Message.widget_event(%{type: "unified.button.clicked"}).type == :widget_event
    assert Message.port_event(%{kind: "interop"}).type == :port_event
    assert Message.retry_requested(%{}).type == :retry_requested
    assert Message.cancel_requested(%{}).type == :cancel_requested
  end

  test "builds replay control message variants" do
    assert Message.replay_snapshot_requested(%{}).type == :replay_snapshot_requested
    assert Message.replay_export_requested(%{}).type == :replay_export_requested
    assert Message.replay_compaction_requested(%{}).type == :replay_compaction_requested
    assert Message.replay_restore_requested(%{}).type == :replay_restore_requested
    assert Message.replay_verification_requested(%{}).type == :replay_verification_requested

    assert Message.replay_verification_gate_requested(%{}).type ==
             :replay_verification_gate_requested

    assert Message.replay_baseline_capture_requested(%{}).type ==
             :replay_baseline_capture_requested

    assert Message.replay_baseline_activate_requested(%{}).type ==
             :replay_baseline_activate_requested

    assert Message.replay_baseline_gate_requested(%{}).type == :replay_baseline_gate_requested
  end
end
