defmodule WebUi.WidgetRenderRequestTest do
  use ExUnit.Case, async: true

  alias WebUi.TypedError
  alias WebUi.WidgetRenderRequest

  test "validates normalized render requests" do
    request = %{
      widget_id: "button",
      props: %{label: "Save"},
      state: %{pressed: false},
      context: %{correlation_id: "corr-410", request_id: "req-410"}
    }

    assert {:ok, normalized} = WidgetRenderRequest.validate(request)
    assert normalized.widget_id == "button"
    assert normalized.props.label == "Save"
    assert normalized.state.pressed == false
    assert normalized.context.correlation_id == "corr-410"
  end

  test "fails closed on invalid request fields" do
    bad_request = %{widget_id: "", props: "not_map", context: %{correlation_id: "corr-410"}}

    assert {:error, %TypedError{} = error} = WidgetRenderRequest.validate(bad_request)

    assert error.error_code in [
             "widget_render_request.invalid_widget_id",
             "widget_render_request.invalid_props",
             "runtime_context.missing_required_fields"
           ]
  end
end
