defmodule WebUi.Observability.DiagnosticsTest do
  use ExUnit.Case, async: true

  alias WebUi.Observability.Diagnostics
  alias WebUi.Observability.RuntimeEvent
  alias WebUi.TypedError

  test "joinability report confirms event and metric records share correlation keys" do
    {:ok, event} =
      RuntimeEvent.build(
        %{
          event_name: "runtime.transport.egress.v1",
          event_version: "v1",
          service: "transport",
          source: "WebUi.Channel",
          outcome: "ok",
          payload: %{status: "ok"}
        },
        %{correlation_id: "corr-751", request_id: "req-751"}
      )

    metric_record = %{
      metric_name: "webui_event_egress_total",
      labels: %{"service" => "transport", "event_type" => "runtime.event.recv.v1", "outcome" => "ok"},
      value: 1,
      correlation_id: "corr-751",
      request_id: "req-751"
    }

    assert Diagnostics.joinable?(event, metric_record)
    assert {:ok, report} = Diagnostics.joinability_report([event], [metric_record])
    assert report.joinable_pairs != []
    assert report.missing_event_context_count == 0
    assert report.missing_metric_context_count == 0
  end

  test "joinability report fails when correlation context is missing" do
    assert {:error, error} =
             Diagnostics.joinability_report(
               [%{event_name: "runtime.transport.egress.v1"}],
               [%{metric_name: "webui_event_egress_total"}]
             )

    assert error.error_code == "observability.joinability_context_missing"
  end

  test "denied path events redact sensitive payload and include operator guidance" do
    error =
      TypedError.new(
        "widget.extension_action_denied",
        "authorization",
        false,
        %{prompt: "raw user prompt", reason: "blocked"},
        "corr-752"
      )

    event =
      Diagnostics.denied_path_event(
        "runtime.widget.extension_denied.v1",
        "WebUi.Widget",
        "widget_extension",
        %{correlation_id: "corr-752", request_id: "req-752"},
        error,
        %{password: "super-secret", action: "mutate_domain_state"}
      )

    assert event.event_name == "runtime.widget.extension_denied.v1"
    assert event.outcome == "error"
    assert event.payload.details["prompt"] == "[REDACTED]"
    assert event.payload.denied_payload["password"] == "[REDACTED]"
    assert is_binary(event.payload.guidance)
    assert :ok == RuntimeEvent.validate(event)
  end

  test "redact_payload recursively scrubs sensitive keys" do
    redacted =
      Diagnostics.redact_payload(%{
        token: "secret-token",
        nested: %{password: "p@ss", safe: "ok"},
        list: [%{secret: "x"}, %{normal: "y"}]
      })

    assert redacted["token"] == "[REDACTED]"
    assert redacted["nested"]["password"] == "[REDACTED]"
    assert redacted["nested"]["safe"] == "ok"
    assert Enum.at(redacted["list"], 0)["secret"] == "[REDACTED]"
  end
end
