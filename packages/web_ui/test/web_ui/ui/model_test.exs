defmodule WebUi.Ui.ModelTest do
  use ExUnit.Case, async: true

  alias WebUi.Ui.Model

  test "builds deterministic defaults" do
    model_a = Model.new()
    model_b = Model.new()

    assert model_a == model_b
    assert model_a.connection_state == :disconnected
    assert model_a.runtime_context.correlation_id == "bootstrap-correlation"
    assert model_a.runtime_context.request_id == "bootstrap-request"
    assert model_a.transport.topic == "webui:runtime:v1"
    assert model_a.view_state.screen == :booting

    assert model_a.view_state.reconciliation_hints == %{
             primary_notice: nil,
             severity: nil,
             next_actions: [],
             focus_field: nil
           }

    assert model_a.slice_state.dispatch_sequence == 0
    assert model_a.slice_state.active_turn_id == nil
    assert model_a.slice_state.last_completed_turn_id == nil
    assert model_a.recovery_state.session_resume_cursor == nil
    assert model_a.recovery_state.last_resumed_sequence == nil
    assert model_a.recovery_state.replay_cursor == 0
    assert model_a.recovery_state.last_replay_checkpoint_id == nil
    assert model_a.recovery_state.replay_log == %{cursor: 0, entries: [], last_checkpoint_id: nil}
    assert model_a.recovery_state.replay_retention_limit == nil
    assert model_a.recovery_state.last_replay_snapshot == nil
    assert model_a.recovery_state.last_replay_export == nil
    assert model_a.recovery_state.last_replay_restore == nil

    assert model_a.recovery_state.replay_baseline_registry == %{
             baselines: %{},
             order: [],
             active_baseline_id: nil,
             retention_limit: nil
           }

    assert model_a.recovery_state.last_replay_baseline == nil
    assert model_a.recovery_state.last_replay_baseline_gate == nil
    assert model_a.recovery_state.last_replay_verification == nil
    assert model_a.recovery_state.last_replay_verification_gate == nil
  end

  test "accepts explicit overrides" do
    model =
      Model.new(%{
        connection_state: :connecting,
        runtime_context: %{correlation_id: "corr-201", request_id: "req-201"},
        view_state: %{screen: :custom}
      })

    assert model.connection_state == :connecting
    assert model.runtime_context.correlation_id == "corr-201"
    assert model.runtime_context.request_id == "req-201"
    assert model.view_state.screen == :custom
  end
end
