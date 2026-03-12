defmodule WebUi.WidgetRegistryCatalogTest do
  use ExUnit.Case, async: true

  alias WebUi.TypedError
  alias WebUi.WidgetRegistry

  test "built-in widget IDs exactly match term_ui parity baseline" do
    expected_ids = [
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

    assert WidgetRegistry.builtin_widget_ids() == expected_ids
    assert :ok == WidgetRegistry.parity_check()
  end

  test "stable category policy validates all built-in entries" do
    assert :ok == WidgetRegistry.validate_categories()
    assert :ok == WidgetRegistry.validate_event_types()

    for entry <- WidgetRegistry.builtin_widget_entries() do
      assert entry.category in WidgetRegistry.allowed_categories()
    end
  end

  test "registry construction returns immutable mapping + stable fingerprint" do
    assert {:ok, registry} = WidgetRegistry.new()
    assert registry.catalog_fingerprint == WidgetRegistry.catalog_fingerprint()

    assert :ok == WidgetRegistry.validate_catalog_fingerprint(registry.catalog_fingerprint)

    assert {:error, %TypedError{} = error} =
             WidgetRegistry.validate_catalog_fingerprint(registry.catalog_fingerprint + 1)

    assert error.error_code == "widget_registry.catalog_fingerprint_mismatch"
  end

  test "entry lookup returns typed error for unknown IDs" do
    {:ok, registry} = WidgetRegistry.new()

    assert {:error, %TypedError{} = error} = WidgetRegistry.entry(registry, "not_a_widget")
    assert error.error_code == "widget_registry.unknown_widget"
  end
end
