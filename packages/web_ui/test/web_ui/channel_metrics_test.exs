defmodule WebUi.ChannelMetricsTest do
  use ExUnit.Case, async: true

  alias WebUi.Channel

  defp valid_payload do
    %{
      event: %{
        specversion: "1.0",
        id: "evt-731",
        source: "webui.test",
        type: "runtime.command",
        data: %{action: "save"},
        correlation_id: "corr-731",
        request_id: "req-731"
      }
    }
  end

  test "ingress and egress counters are emitted for successful transport messages" do
    parent = self()

    assert {:ok, _response} =
             Channel.handle_client_message(
               "webui:runtime:v1",
               "runtime.event.send.v1",
               valid_payload(),
               metrics_fun: fn metric_record -> send(parent, {:metric, metric_record}) end
             )

    metrics =
      Stream.repeatedly(fn ->
        receive do
          {:metric, metric} -> metric
        after
          20 -> :done
        end
      end)
      |> Enum.take_while(&(&1 != :done))

    assert Enum.any?(metrics, &(&1.metric_name == "webui_event_ingress_total"))
    assert Enum.any?(metrics, &(&1.metric_name == "webui_event_egress_total"))
  end

  test "decode errors emit webui_event_decode_error_total" do
    parent = self()

    assert {:ok, _response} =
             Channel.handle_client_message(
               "webui:runtime:v1",
               "runtime.event.send.v1",
               %{event: %{specversion: "1.0", id: "evt-732"}},
               metrics_fun: fn metric_record -> send(parent, {:metric, metric_record}) end
             )

    metrics =
      Stream.repeatedly(fn ->
        receive do
          {:metric, metric} -> metric
        after
          20 -> :done
        end
      end)
      |> Enum.take_while(&(&1 != :done))

    assert Enum.any?(metrics, &(&1.metric_name == "webui_event_ingress_total"))
    assert Enum.any?(metrics, &(&1.metric_name == "webui_event_decode_error_total"))
  end

  test "connection and disconnect helpers emit mandatory websocket metric families" do
    parent = self()

    assert :ok =
             Channel.observe_ws_connection(
               "webui:runtime:v1",
               "ok",
               metrics_fun: fn metric_record -> send(parent, {:metric, metric_record}) end
             )

    assert :ok =
             Channel.observe_ws_disconnect(
               "webui:runtime:v1",
               "channel_closed",
               metrics_fun: fn metric_record -> send(parent, {:metric, metric_record}) end
             )

    assert_receive {:metric, connected_metric}
    assert connected_metric.metric_name == "webui_ws_connection_total"
    assert connected_metric.labels["endpoint"] == "webui:runtime:v1"

    assert_receive {:metric, disconnected_metric}
    assert disconnected_metric.metric_name == "webui_ws_disconnect_total"
    assert disconnected_metric.labels["reason"] == "channel_closed"
  end

  test "encode failures emit webui_event_encode_error_total" do
    parent = self()

    assert {:ok, response} =
             Channel.handle_client_message(
               "webui:runtime:v1",
               "runtime.event.send.v1",
               valid_payload(),
               dispatch_fun: fn _event, _context -> {:ok, %{not_cloudevent: true}} end,
               metrics_fun: fn metric_record -> send(parent, {:metric, metric_record}) end
             )

    assert response.event_name == "runtime.event.error.v1"

    metrics =
      Stream.repeatedly(fn ->
        receive do
          {:metric, metric} -> metric
        after
          20 -> :done
        end
      end)
      |> Enum.take_while(&(&1 != :done))

    assert Enum.any?(metrics, &(&1.metric_name == "webui_event_encode_error_total"))
  end
end
