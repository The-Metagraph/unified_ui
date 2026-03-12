defmodule WebUi.Events.EventCatalogTest do
  use ExUnit.Case, async: true

  alias WebUi.Events.EventCatalog
  alias WebUi.TypedError

  test "standard event types match the six unified baseline signals" do
    assert EventCatalog.standard_event_types() == [
             "unified.button.clicked",
             "unified.input.changed",
             "unified.form.submitted",
             "unified.element.focused",
             "unified.element.blurred",
             "unified.item.selected"
           ]
  end

  test "extended event types include complex widget interaction signals" do
    extended = EventCatalog.extended_event_types()

    assert "unified.chart.point_selected" in extended
    assert "unified.chart.point_hovered" in extended
    assert "unified.overlay.confirmed" in extended
    assert "unified.tree.node_selected" in extended
    assert "unified.split.resized" in extended
    assert "unified.viewport.resized" in extended
  end

  test "unknown event type lookup returns typed error" do
    assert {:error, %TypedError{} = error} = EventCatalog.event_spec("unified.unknown")
    assert error.error_code == "event_catalog.unknown_event_type"
    assert error.category == "validation"
  end

  test "validate_event enforces standard event key requirements" do
    assert :ok == EventCatalog.validate_event("unified.button.clicked", %{action: "save"})
    assert :ok == EventCatalog.validate_event("unified.button.clicked", %{button_id: "save_btn"})
    assert :ok == EventCatalog.validate_event("unified.input.changed", %{value: "x", input_id: "name"})
    assert :ok == EventCatalog.validate_event("unified.form.submitted", %{widget_id: "login_form"})

    assert {:error, %TypedError{} = error} =
             EventCatalog.validate_event("unified.button.clicked", %{id: "only-id"})

    assert error.error_code == "event_catalog.missing_required_keys"
    assert error.details.missing_any_of_groups == [["action", "button_id", "widget_id"]]
  end

  test "validate_event enforces extended event key requirements" do
    assert :ok ==
             EventCatalog.validate_event(
               "unified.canvas.pointer.changed",
               %{widget_id: "canvas-1", x: 12, y: 24, phase: "move"}
             )

    assert {:error, %TypedError{} = error} =
             EventCatalog.validate_event(
               "unified.canvas.pointer.changed",
               %{widget_id: "canvas-1", x: 12, y: 24}
             )

    assert error.error_code == "event_catalog.missing_required_keys"
    assert error.details.missing_all_of == ["phase"]
  end

  test "route family and required key specs are available for known events" do
    assert {:ok, :click} = EventCatalog.route_family("unified.button.clicked")

    assert {:ok, key_spec} = EventCatalog.required_key_spec("unified.form.submitted")
    assert key_spec.required_all_of == []
    assert key_spec.required_any_of == [["form_id", "widget_id"]]
  end
end
