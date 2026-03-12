defmodule WebUi.Integration.ScenarioCatalogConformanceTest do
  use ExUnit.Case, async: true

  alias WebUi.Agent
  alias WebUi.Channel
  alias WebUi.Widget
  alias WebUi.WidgetRegistry

  @ownership_matrix_path "/Users/Pascal/code/unified/web_ui/specs/contracts/control_plane_ownership_matrix.md"

  defp runtime_event(overrides) do
    base = %{
      specversion: "1.0",
      id: "evt-scn",
      source: "webui.scenario",
      type: "runtime.command",
      data: %{action: "save"},
      correlation_id: "corr-scn",
      request_id: "req-scn"
    }

    Map.merge(base, overrides)
  end

  defp runtime_payload(overrides \\ %{}) do
    %{event: runtime_event(overrides)}
  end

  defp build_agent(handler) do
    {:ok, agent} =
      Agent.new([
        %{event_type: "runtime.command", service: "ui.workflow", operation: "run_command", handler: handler}
      ])

    agent
  end

  defp registry do
    {:ok, registry} = WidgetRegistry.new()
    registry
  end

  @tag :conformance
  test "SCN-001 control-plane ownership consistency" do
    ownership_rows =
      @ownership_matrix_path
      |> File.read!()
      |> String.split("\n")
      |> Enum.filter(&String.starts_with?(&1, "| `WebUi."))
      |> Enum.map(fn row ->
        [module_cell, plane_cell] =
          row
          |> String.trim("|")
          |> String.split("|")
          |> Enum.map(&String.trim/1)
          |> Enum.take(2)

        module_name = String.trim(module_cell, "`")
        plane = String.trim(plane_cell, "`")
        {module_name, plane}
      end)

    modules = Enum.map(ownership_rows, &elem(&1, 0))
    planes = Enum.map(ownership_rows, &elem(&1, 1))

    assert length(modules) == length(Enum.uniq(modules))
    assert Enum.all?(planes, &(&1 in ["Product Plane", "UI Runtime Plane", "Transport Plane", "Runtime Authority Plane", "Data Plane", "Extension Plane"]))
  end

  @tag :conformance
  test "SCN-002 transport boundary authority" do
    payload = runtime_payload()

    assert Channel.handle_client_message("webui:runtime:v1", "runtime.event.send.v1", payload) ==
             Channel.handle_client_message("webui:runtime:v1", "runtime.event.send.v1", payload)
  end

  @tag :conformance
  test "SCN-003 CloudEvent envelope validation" do
    malformed = %{event: %{specversion: "1.0", id: "evt-scn-003"}}

    assert {:ok, response} =
             Channel.handle_client_message("webui:runtime:v1", "runtime.event.send.v1", malformed)

    assert response.event_name == "runtime.event.error.v1"
    assert response.payload.error.error_code == "cloudevent.missing_required_fields"
  end

  @tag :conformance
  test "SCN-004 correlation continuity" do
    agent = build_agent(fn _request -> {:ok, %{status: "ok"}} end)

    assert {:ok, response} =
             Channel.handle_client_message(
               "webui:runtime:v1",
               "runtime.event.send.v1",
               runtime_payload(%{
                 correlation_id: "corr-scn-004",
                 request_id: "req-scn-004",
                 session_id: "session-scn-004"
               }),
               agent: agent
             )

    assert response.payload.result.context.correlation_id == "corr-scn-004"
    assert response.payload.result.context.request_id == "req-scn-004"
    assert response.payload.result.context.session_id == "session-scn-004"
  end

  @tag :conformance
  test "SCN-005 typed service outcome normalization" do
    timeout_agent =
      build_agent(fn _request ->
        Process.sleep(20)
        {:ok, %{status: "late"}}
      end)

    assert {:ok, response} =
             Channel.handle_client_message(
               "webui:runtime:v1",
               "runtime.event.send.v1",
               runtime_payload(%{id: "evt-scn-005"}),
               agent: timeout_agent,
               timeout_ms: 5
             )

    assert response.payload.result.outcome == "error"
    assert response.payload.result.error.error_code == "agent.runtime_timeout"
    assert response.payload.result.error.category == "timeout"
  end

  @tag :conformance
  test "SCN-007 built-in widget catalog parity" do
    expected = [
      "block",
      "button",
      "label",
      "list",
      "pick_list",
      "progress",
      "text_input_primitive",
      "alert_dialog",
      "bar_chart",
      "canvas",
      "cluster_dashboard",
      "command_palette",
      "context_menu",
      "dialog",
      "form_builder",
      "gauge",
      "line_chart",
      "log_viewer",
      "markdown_viewer",
      "menu",
      "process_monitor",
      "scroll_bar",
      "sparkline",
      "split_pane",
      "stream_widget",
      "supervision_tree_viewer",
      "table",
      "tabs",
      "text_input",
      "toast",
      "toast_manager",
      "tree_view",
      "viewport"
    ]

    assert WidgetRegistry.builtin_widget_ids() == expected
  end

  @tag :conformance
  test "SCN-008 widget descriptor completeness" do
    descriptors = WidgetRegistry.builtin_widget_descriptors()

    assert length(descriptors) == 33
    assert Enum.all?(descriptors, fn descriptor ->
             is_binary(descriptor.widget_id) and descriptor.widget_id != "" and
               descriptor.origin == "builtin" and
               is_map(descriptor.props_schema) and
               is_map(descriptor.event_schema) and
               is_list(descriptor.event_schema.event_types)
           end)
  end

  @tag :conformance
  test "SCN-009 custom widget registration validation" do
    reg = registry()

    invalid_request = %{
      descriptor: %{
        widget_id: "invalid-widget-id",
        origin: "custom",
        category: "runtime",
        state_model: "stateful",
        props_schema: %{type: "object", additional_properties: true},
        event_schema: %{version: "v1", event_types: ["custom.invalid.selected"]},
        version: "v1",
        capabilities: ["emit_widget_events@1"]
      },
      implementation_ref: "WebUi.Custom.Invalid",
      requested_by: "tests",
      context: %{correlation_id: "corr-scn-009", request_id: "req-scn-009"}
    }

    assert {:error, error} = WidgetRegistry.register_custom(reg, invalid_request)
    assert error.error_code == "widget_registry.invalid_custom_widget_id"
  end

  @tag :conformance
  test "SCN-010 built-in override protection" do
    reg = registry()

    request =
      %{
        descriptor: %{
          widget_id: "button",
          origin: "custom",
          category: "runtime",
          state_model: "stateful",
          props_schema: %{type: "object", additional_properties: true},
          event_schema: %{version: "v1", event_types: ["custom.override.clicked"]},
          version: "v1",
          capabilities: ["emit_widget_events@1"]
        },
        implementation_ref: "WebUi.Custom.OverrideButton",
        requested_by: "tests",
        context: %{correlation_id: "corr-scn-010", request_id: "req-scn-010"}
      }

    assert {:error, error} = WidgetRegistry.register_custom(reg, request)
    assert error.error_code == "widget_registry.reserved_widget_id"
  end

  @tag :conformance
  test "SCN-011 widget event correlation continuity" do
    result =
      Widget.render(registry(), %{
        widget_id: "button",
        props: %{label: "Save"},
        state: %{},
        context: %{correlation_id: "corr-scn-011", request_id: "req-scn-011"}
      })

    event = hd(result.events)

    assert result.outcome == "ok"
    assert event.correlation_id == "corr-scn-011"
    assert event.request_id == "req-scn-011"
  end

  @tag :conformance
  test "SCN-012 deterministic widget render behavior" do
    request = %{
      widget_id: "button",
      props: %{label: "Deterministic"},
      state: %{pressed: false},
      context: %{correlation_id: "corr-scn-012", request_id: "req-scn-012"}
    }

    assert Widget.render(registry(), request) == Widget.render(registry(), request)
  end
end
