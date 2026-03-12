defmodule WebUi.Integration.Phase02ElmRuntimeTest do
  use ExUnit.Case, async: true

  alias WebUi.Ui.Message
  alias WebUi.Ui.Runtime

  @tag :conformance
  test "SCN-ui-001 first render state is deterministic across repeated boots" do
    input = %{runtime_context: %{correlation_id: "corr-240", request_id: "req-240"}}

    assert Runtime.init(input) == Runtime.init(input)

    {:ok, model, _commands} = Runtime.init(input)
    assert model.view_state.screen == :connecting
    assert model.connection_state == :connecting
  end

  @tag :conformance
  test "SCN-ui-002 websocket join and ping/pong handshake behavior" do
    {:ok, model, commands} =
      Runtime.init(%{runtime_context: %{correlation_id: "corr-241", request_id: "req-241"}})

    assert Enum.at(commands, 0).kind == :ws_join
    assert Enum.at(commands, 1).event_name == "runtime.event.ping.v1"

    joined_model = Runtime.handle_bootstrap_result(model, {:ok, %{topic: "webui:runtime:v1"}})
    {pong_model, []} = Runtime.update(joined_model, Message.websocket_pong(%{request_id: "req-241"}))

    assert joined_model.connection_state == :connected
    assert pong_model.transport.last_pong_at == "req-241"
  end

  @tag :conformance
  test "SCN-ui-003 join failure paths produce typed UI error state" do
    {:ok, model, _commands} = Runtime.init(%{runtime_context: %{correlation_id: "corr-242", request_id: "req-242"}})

    failed_model = Runtime.handle_bootstrap_result(model, {:error, :join_denied})

    assert failed_model.connection_state == :error
    assert failed_model.view_state.ui_error.code == "ui.bootstrap_join_failed"
    assert failed_model.last_error.error_code == "ui.bootstrap_join_failed"
  end

  @tag :conformance
  test "SCN-ui-004 widget interaction produces canonical outbound event payloads" do
    {:ok, model, _commands} = Runtime.init(%{runtime_context: %{correlation_id: "corr-243", request_id: "req-243"}})

    msg =
      Message.widget_event(%{
        type: "unified.button.clicked",
        widget_id: "confirm_button",
        widget_kind: "button",
        data: %{action: "confirm"}
      })

    {updated_model, [command]} = Runtime.update(model, msg)

    assert command.kind == :ws_push
    assert command.event_name == "runtime.event.send.v1"
    assert command.payload.event["type"] == "unified.button.clicked"
    assert command.payload.event["data"]["widget_id"] == "confirm_button"
    assert List.last(updated_model.outbound_queue) == command
  end

  @tag :conformance
  test "SCN-ui-005 inbound runtime events drive deterministic model transitions" do
    {:ok, model, _commands} = Runtime.init(%{runtime_context: %{correlation_id: "corr-244", request_id: "req-244"}})

    recv = fn current_model ->
      Runtime.update(
        current_model,
        Message.websocket_recv(%{
          event: %{
            specversion: "1.0",
            id: "evt-244",
            source: "webui.runtime",
            type: "runtime.result",
            data: %{ok: true},
            correlation_id: "corr-244",
            request_id: "req-244"
          }
        })
      )
    end

    assert recv.(model) == recv.(model)

    {updated_model, []} = recv.(model)
    assert updated_model.connection_state == :connected
    assert hd(updated_model.view_state.notices) == "recv:runtime.result"
  end

  @tag :conformance
  test "SCN-ui-006 invalid port payloads fail closed without state-authority leakage" do
    {:ok, model, _commands} = Runtime.init(%{runtime_context: %{correlation_id: "corr-245", request_id: "req-245"}})

    outbound_before = model.outbound_queue

    msg =
      Message.port_event(%{
        operation: "mutate_domain_state",
        data: %{field: "forbidden"},
        provenance: %{origin: "extension_port"}
      })

    {updated_model, commands} = Runtime.update(model, msg)

    assert commands == []
    assert updated_model.last_error.error_code == "ui.interop.denied_runtime_action"
    assert updated_model.outbound_queue == outbound_before
  end
end
