defmodule WebUi.Integration.Phase07ObservabilityBaselineTest do
  use ExUnit.Case, async: true

  alias WebUi.Agent
  alias WebUi.Channel
  alias WebUi.Observability.Diagnostics
  alias WebUi.Observability.Metrics
  alias WebUi.Observability.RuntimeEvent
  alias WebUi.Widget
  alias WebUi.WidgetRegistry

  defp valid_payload(type \\ "runtime.command") do
    %{
      event: %{
        specversion: "1.0",
        id: "evt-770",
        source: "webui.integration",
        type: type,
        data: %{action: "save"},
        correlation_id: "corr-770",
        request_id: "req-770"
      }
    }
  end

  defp custom_registry do
    {:ok, registry} = WidgetRegistry.new()

    {:ok, registry} =
      WidgetRegistry.register_custom(
        registry,
        %{
          descriptor: %{
            widget_id: "custom.integration.observer",
            origin: "custom",
            category: "runtime",
            state_model: "stateful",
            props_schema: %{type: "object", additional_properties: true},
            event_schema: %{version: "v1", event_types: ["custom.integration.observer.selected"]},
            version: "v1",
            capabilities: ["emit_widget_events@1"]
          },
          implementation_ref: "WebUi.CustomWidgets.Observer",
          requested_by: "integration-suite",
          context: %{correlation_id: "corr-770", request_id: "req-770"}
        }
      )

    registry
  end

  @tag :conformance
  test "SCN-obs-001 success/failure/timeout paths emit terminal runtime observability events" do
    parent = self()

    {:ok, runtime_agent} =
      Agent.new([
        %{
          event_type: "runtime.command",
          service: "ui.workflow",
          operation: "run_command",
          handler: fn _request ->
            Process.sleep(15)
            {:ok, %{status: "ok"}}
          end
        }
      ])

    assert {:ok, _response} =
             Channel.handle_client_message(
               "webui:runtime:v1",
               "runtime.event.send.v1",
               valid_payload(),
               agent: runtime_agent,
               timeout_ms: 5,
               observability_fun: fn event -> send(parent, {:obs_event, event}) end
             )

    observed_events =
      Stream.repeatedly(fn ->
        receive do
          {:obs_event, event} -> event
        after
          25 -> :done
        end
      end)
      |> Enum.take_while(&(&1 != :done))

    assert Enum.any?(observed_events, &(&1.event_name == "runtime.transport.ingress.v1"))
    assert Enum.any?(observed_events, &(&1.event_name == "runtime.transport.egress.v1"))
    assert Enum.all?(observed_events, &(RuntimeEvent.validate(&1) == :ok))
  end

  @tag :conformance
  test "SCN-obs-002 missing mandatory runtime event envelope fields fail conformance checks" do
    assert {:error, error} =
             RuntimeEvent.validate(%{
               event_version: "v1",
               timestamp: DateTime.utc_now() |> DateTime.to_iso8601(),
               service: "transport",
               source: "WebUi.Channel",
               correlation_id: "corr-771",
               request_id: "req-771",
               outcome: "ok",
               payload: %{}
             })

    assert error.error_code == "observability.missing_required_event_fields"
  end

  @tag :conformance
  test "SCN-obs-003 denied paths emit typed observability diagnostics events" do
    result =
      Widget.render(
        custom_registry(),
        %{
          widget_id: "custom.integration.observer",
          props: %{action: "mutate_domain_state"},
          state: %{},
          context: %{correlation_id: "corr-772", request_id: "req-772"}
        },
        extension_dispatch_fun: fn _implementation_ref, _payload -> {:ok, %{node: %{status: "unexpected"}}} end
      )

    denied_event = Enum.at(result.events, 1)

    assert result.outcome == "error"
    assert denied_event.event_name == "runtime.widget.extension_denied.v1"
    assert denied_event.payload.error_code == "widget.extension_action_denied"
    assert denied_event.payload.guidance != nil
  end

  @tag :conformance
  test "SCN-obs-004 required metric families emit records and increment deterministically" do
    state = Metrics.new()

    {:ok, state, _} =
      Metrics.record(
        state,
        "webui_event_ingress_total",
        %{service: "transport", event_type: "runtime.event.send.v1", outcome: "ok"},
        1,
        %{correlation_id: "corr-773", request_id: "req-773"}
      )

    {:ok, state, _} =
      Metrics.record(
        state,
        "webui_service_operation_latency",
        %{service: "ui.workflow", operation: "run_command", outcome: "ok"},
        11,
        %{correlation_id: "corr-773", request_id: "req-773"}
      )

    assert Metrics.counter_value(
             state,
             "webui_event_ingress_total",
             %{"service" => "transport", "event_type" => "runtime.event.send.v1", "outcome" => "ok"}
           ) == 1

    assert Metrics.histogram_samples(
             state,
             "webui_service_operation_latency",
             %{"service" => "ui.workflow", "operation" => "run_command", "outcome" => "ok"}
           ) == [11]
  end

  @tag :conformance
  test "SCN-obs-005 metric label policy rejects unsafe labels and values" do
    assert {:error, error} =
             Metrics.metric_record(
               "webui_event_ingress_total",
               %{service: "transport", event_type: "runtime.event.send.v1", outcome: "ok", prompt: "unsafe"},
               1
             )

    assert error.error_code == "observability.metric_invalid_labels"
  end

  @tag :conformance
  test "SCN-006 event and metric records are joinable by correlation identifiers" do
    parent = self()

    assert {:ok, _response} =
             Channel.handle_client_message(
               "webui:runtime:v1",
               "runtime.event.send.v1",
               valid_payload(),
               observability_fun: fn event -> send(parent, {:obs_event, event}) end,
               metrics_fun: fn metric_record -> send(parent, {:metric, metric_record}) end
             )

    events =
      Stream.repeatedly(fn ->
        receive do
          {:obs_event, event} -> event
        after
          25 -> :done
        end
      end)
      |> Enum.take_while(&(&1 != :done))

    metrics =
      Stream.repeatedly(fn ->
        receive do
          {:metric, metric} -> metric
        after
          25 -> :done
        end
      end)
      |> Enum.take_while(&(&1 != :done))

    assert {:ok, report} = Diagnostics.joinability_report(events, metrics)
    assert report.joinable_pairs != []
    assert report.missing_event_context_count == 0
    assert report.missing_metric_context_count == 0
  end
end
