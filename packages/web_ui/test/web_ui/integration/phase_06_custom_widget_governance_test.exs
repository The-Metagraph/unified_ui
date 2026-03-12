defmodule WebUi.Integration.Phase06CustomWidgetGovernanceTest do
  use ExUnit.Case, async: true

  alias WebUi.Widget
  alias WebUi.WidgetRegistry

  defp base_registration_request(overrides \\ %{}) do
    base = %{
      descriptor: %{
        widget_id: "custom.integration.console",
        origin: "custom",
        category: "runtime",
        state_model: "stateful",
        props_schema: %{type: "object", additional_properties: true},
        event_schema: %{version: "v1", event_types: ["custom.integration.console.selected"]},
        version: "v1",
        capabilities: ["emit_widget_events@1"]
      },
      implementation_ref: "WebUi.CustomWidgets.IntegrationConsole",
      requested_by: "integration-suite",
      context: %{correlation_id: "corr-640", request_id: "req-640"}
    }

    Map.merge(base, overrides)
  end

  defp custom_render_request(overrides \\ %{}) do
    base = %{
      widget_id: "custom.integration.console",
      props: %{mode: "full"},
      state: %{selected: "root"},
      context: %{correlation_id: "corr-641", request_id: "req-641"}
    }

    Map.merge(base, overrides)
  end

  @tag :conformance
  test "SCN-wgt-016 valid custom registrations are accepted and queryable" do
    {:ok, registry} = WidgetRegistry.new()

    assert {:ok, updated_registry, [event]} =
             WidgetRegistry.register_custom_with_events(registry, base_registration_request())

    assert event.event_name == "runtime.widget.registered.v1"
    assert {:ok, descriptor} = WidgetRegistry.descriptor(updated_registry, "custom.integration.console")
    assert descriptor.origin == "custom"
  end

  @tag :conformance
  test "SCN-wgt-017 duplicate and reserved IDs fail with typed errors" do
    {:ok, registry} = WidgetRegistry.new()
    assert {:ok, registry} = WidgetRegistry.register_custom(registry, base_registration_request())

    assert {:error, duplicate_error} =
             WidgetRegistry.register_custom(registry, base_registration_request())

    assert duplicate_error.error_code == "widget_registry.duplicate_custom_widget_id"
    assert duplicate_error.category == "conflict"

    reserved_request =
      base_registration_request()
      |> put_in([:descriptor, :widget_id], "button")

    assert {:error, reserved_error} = WidgetRegistry.register_custom(registry, reserved_request)
    assert reserved_error.error_code == "widget_registry.reserved_widget_id"
  end

  @tag :conformance
  test "SCN-wgt-018 invalid descriptor schemas fail closed before activation" do
    {:ok, registry} = WidgetRegistry.new()

    invalid_request =
      base_registration_request()
      |> put_in([:descriptor, :props_schema], %{type: "array"})

    assert {:error, error} = WidgetRegistry.register_custom(registry, invalid_request)
    assert error.error_code == "widget_registry.invalid_custom_props_schema"
    assert {:error, lookup_error} = WidgetRegistry.descriptor(registry, "custom.integration.console")
    assert lookup_error.error_code == "widget_registry.descriptor_not_found"
  end

  @tag :conformance
  test "SCN-wgt-019 extension actions cannot bypass runtime authority boundaries" do
    {:ok, registry} = WidgetRegistry.new()
    {:ok, registry} = WidgetRegistry.register_custom(registry, base_registration_request())

    parent = self()

    result =
      Widget.render(
        registry,
        custom_render_request(%{props: %{action: "mutate_domain_state"}}),
        extension_dispatch_fun: fn _implementation_ref, _payload ->
          send(parent, :dispatch_called)
          {:ok, %{node: %{status: "unexpected"}}}
        end
      )

    assert result.outcome == "error"
    assert result.error.error_code == "widget.extension_action_denied"
    refute_received :dispatch_called
  end

  @tag :conformance
  test "SCN-wgt-020 denied extension operations emit deterministic telemetry" do
    {:ok, registry} = WidgetRegistry.new()
    {:ok, registry} = WidgetRegistry.register_custom(registry, base_registration_request())

    render = fn ->
      Widget.render(
        registry,
        custom_render_request(%{props: %{action: "execute_runtime_command"}}),
        extension_dispatch_fun: fn _implementation_ref, _payload ->
          {:ok, %{node: %{status: "unexpected"}}}
        end
      )
    end

    assert render.() == render.()

    denied_event = Enum.at(render.().events, 1)
    assert denied_event.event_name == "runtime.widget.extension_denied.v1"
    assert denied_event.denied_action == "execute_runtime_command"
  end

  @tag :conformance
  test "SCN-wgt-021 registration and render lifecycle events preserve correlation metadata" do
    {:ok, registry} = WidgetRegistry.new()

    assert {:ok, registry, [registered_event]} =
             WidgetRegistry.register_custom_with_events(registry, base_registration_request())

    assert registered_event.correlation_id == "corr-640"
    assert registered_event.request_id == "req-640"

    result =
      Widget.render(
        registry,
        custom_render_request(),
        extension_dispatch_fun: fn implementation_ref, payload ->
          {:ok, %{node: %{implementation_ref: implementation_ref, widget_id: payload.widget_id}}}
        end
      )

    assert result.outcome == "ok"
    lifecycle_event = hd(result.events)
    assert lifecycle_event.event_name == "runtime.widget.rendered.v1"
    assert lifecycle_event.correlation_id == "corr-641"
    assert lifecycle_event.request_id == "req-641"
  end
end
