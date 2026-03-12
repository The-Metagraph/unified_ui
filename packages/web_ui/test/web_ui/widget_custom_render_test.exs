defmodule WebUi.WidgetCustomRenderTest do
  use ExUnit.Case, async: true

  alias WebUi.Widget
  alias WebUi.WidgetRegistry

  defp custom_registration_request do
    %{
      descriptor: %{
        widget_id: "custom.acme.console",
        origin: "custom",
        category: "runtime",
        state_model: "stateful",
        props_schema: %{type: "object", additional_properties: true},
        event_schema: %{version: "v1", event_types: ["custom.acme.console.selected"]},
        version: "v1",
        capabilities: ["emit_widget_events@1"]
      },
      implementation_ref: "WebUi.CustomWidgets.AcmeConsole",
      requested_by: "acme-team",
      context: %{correlation_id: "corr-621", request_id: "req-621"}
    }
  end

  defp custom_registry do
    {:ok, registry} = WidgetRegistry.new()
    {:ok, registry} = WidgetRegistry.register_custom(registry, custom_registration_request())
    registry
  end

  defp custom_render_request(props \\ %{}) do
    %{
      widget_id: "custom.acme.console",
      props: Map.merge(%{mode: "expanded"}, props),
      state: %{selection: "root"},
      context: %{correlation_id: "corr-622", request_id: "req-622"}
    }
  end

  test "custom widgets render via controlled registry dispatch only" do
    parent = self()

    result =
      Widget.render(
        custom_registry(),
        custom_render_request(),
        extension_dispatch_fun: fn implementation_ref, payload ->
          send(parent, {:extension_dispatch, implementation_ref, payload.widget_id})

          {:ok,
           %{
             node: %{widget_id: payload.widget_id, rendered_by: implementation_ref},
             events: [%{event_name: "runtime.widget.custom_rendered.v1", outcome: "ok"}]
           }}
        end
      )

    assert result.outcome == "ok"
    assert result.node["rendered_by"] == "WebUi.CustomWidgets.AcmeConsole"
    assert hd(result.events).event_name == "runtime.widget.rendered.v1"
    assert Enum.at(result.events, 1)["event_name"] == "runtime.widget.custom_rendered.v1"
    assert_received {:extension_dispatch, "WebUi.CustomWidgets.AcmeConsole", "custom.acme.console"}
  end

  test "custom render without controlled dispatch fails closed" do
    result = Widget.render(custom_registry(), custom_render_request())

    assert result.outcome == "error"
    assert result.error.error_code == "widget.extension_dispatch_unavailable"
    assert hd(result.events).event_name == "runtime.widget.render_failed.v1"
  end

  test "blocked extension actions are denied with deterministic telemetry" do
    parent = self()

    result =
      Widget.render(
        custom_registry(),
        custom_render_request(%{action: "mutate_domain_state"}),
        extension_dispatch_fun: fn _implementation_ref, _payload ->
          send(parent, :dispatch_called)
          {:ok, %{node: %{status: "should-not-happen"}}}
        end
      )

    assert result.outcome == "error"
    assert result.error.error_code == "widget.extension_action_denied"
    refute_received :dispatch_called

    denied_event = Enum.at(result.events, 1)
    assert denied_event.event_name == "runtime.widget.extension_denied.v1"
    assert denied_event.denied_action == "mutate_domain_state"
    assert denied_event.payload.guidance != nil
    assert denied_event.payload.denied_payload["denied_action"] == "mutate_domain_state"
  end

  test "invalid extension event lists fail closed" do
    result =
      Widget.render(
        custom_registry(),
        custom_render_request(),
        extension_dispatch_fun: fn _implementation_ref, _payload ->
          {:ok, %{node: %{status: "ok"}, events: "invalid"}}
        end
      )

    assert result.outcome == "error"
    assert result.error.error_code == "widget.extension_invalid_events"
  end

  test "custom dispatch CloudEvent envelopes are validated and normalized" do
    result =
      Widget.render(
        custom_registry(),
        custom_render_request(),
        extension_dispatch_fun: fn _implementation_ref, _payload ->
          {:ok,
           %{
             node: %{status: "ok"},
             events: [
               %{
                 specversion: "1.0",
                 id: "evt-631",
                 source: "custom.acme.console",
                 type: "custom.acme.console.selected",
                 data: %{item_id: "n-1"},
                 correlation_id: "corr-622",
                 request_id: "req-622"
               }
             ]
           }}
        end
      )

    assert result.outcome == "ok"
    normalized_event = Enum.at(result.events, 1)
    assert normalized_event["event_name"] == "runtime.widget.extension_event.v1"
    assert normalized_event["envelope_type"] == "custom.acme.console.selected"
  end

  test "invalid custom dispatch envelope types fail closed" do
    result =
      Widget.render(
        custom_registry(),
        custom_render_request(),
        extension_dispatch_fun: fn _implementation_ref, _payload ->
          {:ok,
           %{
             node: %{status: "ok"},
             events: [
               %{
                 specversion: "1.0",
                 id: "evt-632",
                 source: "custom.acme.console",
                 type: "runtime.bad",
                 data: %{item_id: "n-1"},
                 correlation_id: "corr-622",
                 request_id: "req-622"
               }
             ]
           }}
        end
      )

    assert result.outcome == "error"
    assert result.error.error_code == "widget.extension_invalid_event_type"
  end
end
