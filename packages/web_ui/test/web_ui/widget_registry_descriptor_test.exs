defmodule WebUi.WidgetRegistryDescriptorTest do
  use ExUnit.Case, async: true

  alias WebUi.TypedError
  alias WebUi.WidgetRegistry

  test "all built-in descriptors include required metadata fields" do
    {:ok, registry} = WidgetRegistry.new()

    descriptors = WidgetRegistry.list_by_origin(registry, "builtin")

    assert length(descriptors) == 33

    for descriptor <- descriptors do
      assert is_binary(descriptor.widget_id) and descriptor.widget_id != ""
      assert descriptor.origin == "builtin"
      assert descriptor.category in WidgetRegistry.allowed_categories()
      assert descriptor.state_model in ["stateless", "stateful"]
      assert descriptor.version == "v1"
      assert is_map(descriptor.props_schema)
      assert descriptor.props_schema.type == "object"
      assert is_map(descriptor.event_schema)
      assert is_list(descriptor.event_schema.event_types)
      assert is_list(descriptor.event_schema.required_event_types)
      assert is_list(descriptor.event_schema.optional_event_types)
      assert is_map(descriptor.event_schema.route_key_requirements)
      assert is_map(descriptor.event_schema.event_contracts)
      assert descriptor.event_schema.interaction_mode in ["none", "interactive"]
      assert descriptor.event_schema.version == "v1"
    end
  end

  test "descriptor event schemas expose required/optional matrix declarations" do
    {:ok, registry} = WidgetRegistry.new()

    assert {:ok, bar_chart} = WidgetRegistry.descriptor(registry, "bar_chart")
    assert bar_chart.event_schema.required_event_types == []
    assert bar_chart.event_schema.optional_event_types == ["unified.chart.point_selected", "unified.chart.point_hovered"]

    assert {:ok, canvas} = WidgetRegistry.descriptor(registry, "canvas")
    assert canvas.event_schema.required_event_types == ["unified.canvas.pointer.changed"]
    assert canvas.event_schema.optional_event_types == ["unified.button.clicked"]
  end

  test "non-interactive widgets explicitly declare none interaction mode" do
    {:ok, registry} = WidgetRegistry.new()

    assert {:ok, block} = WidgetRegistry.descriptor(registry, "block")
    assert block.event_schema.interaction_mode == "none"
    assert block.event_schema.event_types == []
    assert block.event_schema.route_key_requirements == %{}
  end

  test "interactive descriptors include route-key requirements for click/change/submit families" do
    {:ok, registry} = WidgetRegistry.new()

    assert {:ok, button} = WidgetRegistry.descriptor(registry, "button")
    assert button.event_schema.route_key_requirements.click == ["action", "button_id", "widget_id", "id"]

    assert {:ok, text_input} = WidgetRegistry.descriptor(registry, "text_input")
    assert text_input.event_schema.route_key_requirements.change == ["input_id", "widget_id", "field", "action", "id"]
    assert text_input.event_schema.route_key_requirements.submit == ["form_id", "action", "id"]
  end

  test "descriptor lookup by widget ID is deterministic" do
    {:ok, registry} = WidgetRegistry.new()

    assert {:ok, descriptor_a} = WidgetRegistry.descriptor(registry, "button")
    assert {:ok, descriptor_b} = WidgetRegistry.descriptor(registry, "button")

    assert descriptor_a == descriptor_b
    assert "unified.button.clicked" in descriptor_a.event_schema.event_types
  end

  test "descriptor list filters by category and origin" do
    {:ok, registry} = WidgetRegistry.new()

    overlays = WidgetRegistry.list_by_category(registry, "overlay")
    builtins = WidgetRegistry.list_by_origin(registry, "builtin")

    assert overlays != []
    assert Enum.all?(overlays, &(&1.category == "overlay"))
    assert Enum.all?(builtins, &(&1.origin == "builtin"))
  end

  test "missing descriptor lookup returns typed error" do
    {:ok, registry} = WidgetRegistry.new()

    assert {:error, %TypedError{} = error} = WidgetRegistry.descriptor(registry, "unknown_widget")
    assert error.error_code == "widget_registry.descriptor_not_found"
    assert error.category == "validation"
  end
end
