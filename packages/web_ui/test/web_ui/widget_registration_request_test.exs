defmodule WebUi.WidgetRegistrationRequestTest do
  use ExUnit.Case, async: true

  alias WebUi.TypedError
  alias WebUi.WidgetRegistrationRequest

  defp valid_request(overrides \\ %{}) do
    base = %{
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
      context: %{correlation_id: "corr-601", request_id: "req-601"}
    }

    Map.merge(base, overrides)
  end

  test "valid registration request normalizes descriptor and context" do
    assert {:ok, request} = WidgetRegistrationRequest.validate(valid_request())
    assert request.descriptor.origin == "custom"
    assert request.implementation_ref == "WebUi.CustomWidgets.AcmeConsole"
    assert request.context.correlation_id == "corr-601"
  end

  test "invalid descriptor shape fails closed" do
    assert {:error, %TypedError{} = error} =
             WidgetRegistrationRequest.validate(valid_request(%{descriptor: "bad"}))

    assert error.error_code == "widget_registration_request.invalid_descriptor"
  end

  test "invalid implementation_ref fails closed" do
    assert {:error, %TypedError{} = error} =
             WidgetRegistrationRequest.validate(valid_request(%{implementation_ref: ""}))

    assert error.error_code == "widget_registration_request.invalid_implementation_ref"
  end

  test "missing runtime context identifiers fail closed" do
    assert {:error, %TypedError{} = error} =
             WidgetRegistrationRequest.validate(
               valid_request(%{context: %{correlation_id: "corr-601"}})
             )

    assert error.error_code == "runtime_context.missing_required_fields"
  end
end
