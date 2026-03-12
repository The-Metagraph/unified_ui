defmodule WebUi.Observability.MetricsTest do
  use ExUnit.Case, async: true

  alias WebUi.Observability.Metrics
  alias WebUi.TypedError

  test "mandatory metric families are registered" do
    assert Metrics.required_metric_names() == [
             "webui_event_decode_error_total",
             "webui_event_egress_total",
             "webui_event_encode_error_total",
             "webui_event_ingress_total",
             "webui_js_interop_error_total",
             "webui_service_operation_latency",
             "webui_ws_connection_total",
             "webui_ws_disconnect_total"
           ]
  end

  test "counter and histogram records are captured with bounded labels" do
    state = Metrics.new()

    assert {:ok, state, ingress_record} =
             Metrics.record(
               state,
               "webui_event_ingress_total",
               %{service: "transport", event_type: "runtime.event.send.v1", outcome: "ok"},
               1,
               %{correlation_id: "corr-721", request_id: "req-721"}
             )

    assert ingress_record.metric_type == :counter
    assert ingress_record.correlation_id == "corr-721"
    assert Metrics.counter_value(state, "webui_event_ingress_total", ingress_record.labels) == 1

    assert {:ok, state, latency_record} =
             Metrics.record(
               state,
               "webui_service_operation_latency",
               %{service: "ui.workflow", operation: "run_command", outcome: "ok"},
               12,
               %{correlation_id: "corr-721", request_id: "req-721"}
             )

    assert latency_record.metric_type == :histogram
    assert Metrics.histogram_samples(state, "webui_service_operation_latency", latency_record.labels) == [12]
  end

  test "label policy rejects missing, extra, and high-cardinality labels" do
    assert {:error, %TypedError{} = missing_labels_error} =
             Metrics.metric_record(
               "webui_event_ingress_total",
               %{service: "transport", event_type: "runtime.event.send.v1"},
               1
             )

    assert missing_labels_error.error_code == "observability.metric_invalid_labels"

    assert {:error, %TypedError{} = high_card_error} =
             Metrics.metric_record(
               "webui_event_ingress_total",
               %{service: "transport", event_type: "runtime.event.send.v1", outcome: "ok", correlation_id: "corr-x"},
               1
             )

    assert high_card_error.error_code == "observability.metric_invalid_labels"

    assert {:error, %TypedError{} = invalid_value_error} =
             Metrics.metric_record(
               "webui_event_ingress_total",
               %{service: "transport", event_type: "runtime event send", outcome: "ok"},
               1
             )

    assert invalid_value_error.error_code == "observability.metric_invalid_label_value"
  end
end
