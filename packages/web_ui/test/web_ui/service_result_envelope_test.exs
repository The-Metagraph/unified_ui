defmodule WebUi.ServiceResultEnvelopeTest do
  use ExUnit.Case, async: true

  alias WebUi.ServiceRequestEnvelope
  alias WebUi.ServiceResultEnvelope

  defp request_envelope do
    event = %{
      specversion: "1.0",
      id: "evt-320",
      source: "webui.test",
      type: "runtime.command",
      data: %{action: "save"}
    }

    context = %{correlation_id: "corr-320", request_id: "req-320"}

    {:ok, request} =
      ServiceRequestEnvelope.from_event("ui.workflow", "run_command", event, context)

    request
  end

  test "builds success result envelopes" do
    request = request_envelope()

    envelope =
      ServiceResultEnvelope.success(
        request,
        %{
          status: "ok",
          ui_hints: %{
            primary_notice: "Saved successfully",
            severity: "warning",
            next_actions: ["retry", "retry", "open_settings", ""],
            focus_field: "theme"
          }
        },
        [
          %{event_name: "runtime.service.completed.v1"}
        ]
      )

    assert envelope.outcome == "ok"
    assert envelope.service == "ui.workflow"
    assert envelope.operation == "run_command"
    assert envelope.payload.status == "ok"
    assert envelope.payload.ui_hints.primary_notice == "Saved successfully"
    assert envelope.payload.ui_hints.severity == "warning"
    assert envelope.payload.ui_hints.next_actions == ["retry", "open_settings"]
    assert envelope.payload.ui_hints.focus_field == "theme"
    assert envelope.error == nil
    assert length(envelope.events) == 1
  end

  test "normalizes invalid ui_hints fields to deterministic defaults" do
    request = request_envelope()

    envelope =
      ServiceResultEnvelope.success(
        request,
        %{
          status: "ok",
          ui_hints: %{
            primary_notice: "",
            severity: "critical",
            next_actions: ["resume", 1, nil, ""],
            focus_field: nil
          }
        }
      )

    assert envelope.payload.ui_hints.primary_notice == nil
    assert envelope.payload.ui_hints.severity == "info"
    assert envelope.payload.ui_hints.next_actions == ["resume"]
    assert envelope.payload.ui_hints.focus_field == nil
  end

  test "builds error result envelopes for validation/auth/conflict mappings" do
    request = request_envelope()

    validation = ServiceResultEnvelope.error(request, {:validation, "service.validation_failed", %{field: "data"}})
    authz = ServiceResultEnvelope.error(request, {:authorization, "service.authorization_denied", %{scope: "admin"}})
    conflict = ServiceResultEnvelope.error(request, {:conflict, "service.conflict", %{id: "item-1"}})

    assert validation.error.category == "validation"
    assert authz.error.category == "authorization"
    assert conflict.error.category == "conflict"
    assert validation.error.correlation_id == "corr-320"
  end

  test "maps timeout/dependency/internal errors with retryability" do
    request = request_envelope()

    timeout = ServiceResultEnvelope.error(request, {:timeout, :upstream_timeout})
    dependency = ServiceResultEnvelope.error(request, {:dependency, :redis_down})
    internal = ServiceResultEnvelope.error(request, :unexpected)

    assert timeout.error.category == "timeout"
    assert timeout.error.retryable == true

    assert dependency.error.category == "dependency"
    assert dependency.error.retryable == true

    assert internal.error.category == "internal"
    assert internal.error.retryable == false
  end

  test "error_for preserves fallback context and service identity" do
    envelope =
      ServiceResultEnvelope.error_for(
        "ui.workflow",
        "run_command",
        %{correlation_id: "corr-320", request_id: "req-320"},
        {:validation, "service.validation_failed", %{field: "x"}}
      )

    assert envelope.service == "ui.workflow"
    assert envelope.operation == "run_command"
    assert envelope.context.correlation_id == "corr-320"
    assert envelope.error.error_code == "service.validation_failed"
  end
end
