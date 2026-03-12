defmodule WebUi.WidgetDescriptorTest do
  use ExUnit.Case, async: true

  alias WebUi.TypedError
  alias WebUi.WidgetDescriptor

  test "validates complete descriptor maps" do
    descriptor = %{
      widget_id: "button",
      origin: "builtin",
      category: "primitive",
      state_model: "stateful",
      props_schema: %{type: "object"},
      event_schema: %{version: "v1", event_types: ["unified.button.clicked"]},
      version: "v1",
      capabilities: []
    }

    assert {:ok, normalized} = WidgetDescriptor.validate(descriptor)
    assert normalized.widget_id == "button"
    assert normalized.category == "primitive"
  end

  test "fails for invalid categories" do
    descriptor = %{
      widget_id: "button",
      origin: "builtin",
      category: "unknown",
      state_model: "stateful",
      props_schema: %{type: "object"},
      event_schema: %{version: "v1", event_types: []},
      version: "v1"
    }

    assert {:error, %TypedError{} = error} = WidgetDescriptor.validate(descriptor)
    assert error.error_code == "widget_descriptor.invalid_category"
  end
end
