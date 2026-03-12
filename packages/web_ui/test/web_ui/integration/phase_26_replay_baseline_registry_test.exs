defmodule WebUi.Integration.Phase26ReplayBaselineRegistryTest do
  use ExUnit.Case, async: true

  alias WebUi.Ui.Message
  alias WebUi.Ui.Runtime

  @moduletag :conformance

  defp model_with_session do
    {:ok, model, _commands} =
      Runtime.init(%{
        runtime_context: %{
          correlation_id: "corr-26",
          request_id: "req-26",
          session_id: "sess-26"
        }
      })

    model
  end

  defp click_message(action) when is_binary(action) do
    Message.widget_event(%{
      type: "unified.button.clicked",
      widget_id: "save_button",
      widget_kind: "button",
      data: %{action: action}
    })
  end

  defp result_message(turn_id) when is_binary(turn_id) and turn_id != "" do
    Message.websocket_recv(%{
      result: %{
        service: "ui.preferences",
        operation: "save_preferences",
        outcome: "ok",
        payload: %{turn_id: turn_id},
        context: %{correlation_id: "corr-26", request_id: "req-26", session_id: "sess-26"}
      }
    })
  end

  defp model_with_replay_entries do
    model = model_with_session()

    {model, [first_dispatch]} = Runtime.update(model, click_message("save"))
    first_turn_id = first_dispatch.payload.event["data"]["turn_id"]
    {model, []} = Runtime.update(model, result_message(first_turn_id))

    {model, [second_dispatch]} = Runtime.update(model, click_message("publish"))
    second_turn_id = second_dispatch.payload.event["data"]["turn_id"]
    {model, []} = Runtime.update(model, result_message(second_turn_id))

    model
  end

  test "SCN-031 equivalent baseline capture flows produce deterministic registry ordering and active selection" do
    model = model_with_replay_entries()

    {model, []} =
      Runtime.update(
        model,
        Message.replay_baseline_capture_requested(%{
          metadata: %{label: "release-26-a"},
          retention_limit: 2,
          activate: true
        })
      )

    first_baseline = model.recovery_state.last_replay_baseline

    {model, [_command]} = Runtime.update(model, click_message("third-capture-step"))

    {updated_model, []} =
      Runtime.update(
        model,
        Message.replay_baseline_capture_requested(%{
          metadata: %{label: "release-26-b"},
          retention_limit: 2,
          activate: true
        })
      )

    second_baseline = updated_model.recovery_state.last_replay_baseline
    baseline_registry = updated_model.recovery_state.replay_baseline_registry

    assert first_baseline.baseline_id != second_baseline.baseline_id
    assert baseline_registry.order == [second_baseline.baseline_id, first_baseline.baseline_id]
    assert baseline_registry.active_baseline_id == second_baseline.baseline_id
  end

  test "SCN-031 baseline activation and gate-resolution paths produce deterministic pass/fail diagnostics" do
    model = model_with_replay_entries()

    {model, []} =
      Runtime.update(
        model,
        Message.replay_baseline_capture_requested(%{
          metadata: %{label: "release-26-a"},
          retention_limit: 2,
          activate: true
        })
      )

    first_baseline = model.recovery_state.last_replay_baseline
    {model, [_command]} = Runtime.update(model, click_message("third-capture-step"))

    {model, []} =
      Runtime.update(
        model,
        Message.replay_baseline_capture_requested(%{
          metadata: %{label: "release-26-b"},
          retention_limit: 2,
          activate: true
        })
      )

    second_baseline = model.recovery_state.last_replay_baseline

    {model, []} =
      Runtime.update(
        model,
        Message.replay_baseline_activate_requested(%{baseline_id: first_baseline.baseline_id})
      )

    {model, []} = Runtime.update(model, Message.replay_baseline_gate_requested(%{}))

    strict_gate = model.recovery_state.last_replay_baseline_gate
    strict_reason_codes = Enum.map(strict_gate.gate.reasons, & &1.code)

    assert strict_gate.status == "fail"
    assert strict_gate.gate.verification.status == "drift"
    assert strict_gate.gate.cursor_delta == 1
    assert strict_gate.gate.entry_count_delta == 1
    assert "status_not_allowed" in strict_reason_codes
    assert "cursor_delta_exceeded" in strict_reason_codes
    assert "entry_count_delta_exceeded" in strict_reason_codes

    {updated_model, []} =
      Runtime.update(
        model,
        Message.replay_baseline_gate_requested(%{
          baseline_id: second_baseline.baseline_id,
          policy: %{
            allowed_statuses: ["match"],
            max_cursor_delta: 0,
            max_entry_count_delta: 0,
            allow_entry_mismatch: false
          }
        })
      )

    pass_gate = updated_model.recovery_state.last_replay_baseline_gate

    assert pass_gate.status == "pass"
    assert pass_gate.gate.status == "pass"
    assert pass_gate.gate.reasons == []
    assert pass_gate.gate.verification.status == "match"
  end

  test "SCN-031 repeated equivalent registry flows produce equivalent baseline-registry traces" do
    flow_trace = fn ->
      model = model_with_replay_entries()

      {model, []} =
        Runtime.update(
          model,
          Message.replay_baseline_capture_requested(%{
            metadata: %{label: "release-26-a"},
            retention_limit: 2,
            activate: true
          })
        )

      first_baseline = model.recovery_state.last_replay_baseline
      {model, [_command]} = Runtime.update(model, click_message("third-capture-step"))

      {model, []} =
        Runtime.update(
          model,
          Message.replay_baseline_capture_requested(%{
            metadata: %{label: "release-26-b"},
            retention_limit: 2,
            activate: true
          })
        )

      second_baseline = model.recovery_state.last_replay_baseline

      {model, []} =
        Runtime.update(
          model,
          Message.replay_baseline_activate_requested(%{baseline_id: first_baseline.baseline_id})
        )

      {model, []} = Runtime.update(model, Message.replay_baseline_gate_requested(%{}))
      fail_gate = model.recovery_state.last_replay_baseline_gate

      {model, []} =
        Runtime.update(
          model,
          Message.replay_baseline_gate_requested(%{baseline_id: second_baseline.baseline_id})
        )

      pass_gate = model.recovery_state.last_replay_baseline_gate
      baseline_registry = model.recovery_state.replay_baseline_registry

      %{
        replay_cursor: model.recovery_state.replay_cursor,
        registry_order: baseline_registry.order,
        active_baseline_id: baseline_registry.active_baseline_id,
        fail_gate: %{status: fail_gate.status, reasons: fail_gate.gate.reasons},
        pass_gate: %{status: pass_gate.status, reasons: pass_gate.gate.reasons},
        notices: Enum.take(model.view_state.notices, 4)
      }
    end

    assert flow_trace.() == flow_trace.()
  end
end
