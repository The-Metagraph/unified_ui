defmodule UnifiedExamples.CatalogTest do
  use ExUnit.Case, async: true

  alias UnifiedExamples.Shared.Catalog

  test "tracks the implemented phase 1 through phase 4 example apps with stable metadata" do
    assert Catalog.directories() == [
             "alert_dialog",
             "bar_chart",
             "box",
             "button",
             "canvas",
             "checkbox",
             "cluster_dashboard",
             "column",
             "command_palette",
             "content",
             "context_menu",
             "date_input",
             "dialog",
             "field",
             "field_group",
             "file_input",
             "form_builder",
             "gauge",
             "grid",
             "icon",
             "image",
             "inline_feedback",
             "label",
             "line_chart",
             "link",
             "list",
             "log_viewer",
             "markdown_viewer",
             "menu",
             "numeric_input",
             "overlay",
             "pick_list",
             "process_monitor",
             "progress",
             "radio_group",
             "row",
             "scroll_bar",
             "select",
             "separator",
             "spacer",
             "sparkline",
             "split_pane",
             "status",
             "stream_widget",
             "supervision_tree_viewer",
             "table",
             "tabs",
             "text",
             "text_input",
             "time_input",
             "toast",
             "toggle",
             "tree_view",
             "viewport"
           ]

    assert Enum.map(Catalog.by_phase(1), & &1.directory) == ["button", "text", "text_input"]

    assert Enum.map(Catalog.by_phase(2), & &1.directory) == [
             "box",
             "content",
             "icon",
             "image",
             "label",
             "link",
             "separator",
             "spacer",
             "checkbox",
             "date_input",
             "field",
             "field_group",
             "file_input",
             "form_builder",
             "numeric_input",
             "pick_list",
             "radio_group",
             "select",
             "time_input",
             "toggle"
           ]

    assert Enum.map(Catalog.by_phase(3), & &1.directory) == [
             "row",
             "column",
             "grid",
             "menu",
             "tabs",
             "command_palette",
             "list",
             "table",
             "tree_view",
             "markdown_viewer",
             "log_viewer",
             "status",
             "progress",
             "gauge",
             "inline_feedback",
             "sparkline",
             "bar_chart",
             "line_chart"
           ]

    assert Enum.map(Catalog.by_phase(4), & &1.directory) == [
             "viewport",
             "scroll_bar",
             "split_pane",
             "canvas",
             "overlay",
             "dialog",
             "alert_dialog",
             "context_menu",
             "toast",
             "stream_widget",
             "process_monitor",
             "supervision_tree_viewer",
             "cluster_dashboard"
           ]

    # Check core catalog fields (interaction_demo is optional metadata)
    assert_catalog_fields(Catalog.entry!("numeric_input"), %{
      directory: "numeric_input",
      widget: :numeric_input,
      family: :input,
      phase: 2,
      shell_kind: :form_builder
    })

    assert_catalog_fields(Catalog.entry!("grid"), %{
      directory: "grid",
      widget: :grid,
      family: :layout,
      phase: 3,
      shell_kind: :box
    })

    assert_catalog_fields(Catalog.entry!("command_palette"), %{
      directory: "command_palette",
      widget: :command_palette,
      family: :navigation,
      phase: 3,
      shell_kind: :box
    })

    assert_catalog_fields(Catalog.entry!("table"), %{
      directory: "table",
      widget: :table,
      family: :data,
      phase: 3,
      shell_kind: :box
    })

    assert_catalog_fields(Catalog.entry!("status"), %{
      directory: "status",
      widget: :status,
      family: :feedback,
      phase: 3,
      shell_kind: :box
    })

    assert_catalog_fields(Catalog.entry!("viewport"), %{
      directory: "viewport",
      widget: :viewport,
      family: :display,
      phase: 4,
      shell_kind: :box
    })

    assert_catalog_fields(Catalog.entry!("dialog"), %{
      directory: "dialog",
      widget: :dialog,
      family: :overlay,
      phase: 4,
      shell_kind: :box
    })

    assert_catalog_fields(Catalog.entry!("stream_widget"), %{
      directory: "stream_widget",
      widget: :stream_widget,
      family: :operational,
      phase: 4,
      shell_kind: :box
    })
  end

  defp assert_catalog_fields(entry, expected) do
    for {key, value} <- expected do
      assert Map.get(entry, key) == value,
             "Expected #{key}: #{inspect(value)}, got #{inspect(Map.get(entry, key))} for #{entry.directory}"
    end
  end

  test "derives app modules, screen modules, and source files from directory names" do
    assert Catalog.app_module("radio_group") == UnifiedExamples.RadioGroup
    assert Catalog.app_module(:text_input) == UnifiedExamples.TextInput
    assert Catalog.screen_module("radio_group") == UnifiedExamples.RadioGroup.Screen

    assert Catalog.source_files("radio_group") == [
             "/Users/Pascal/code/unified/examples/radio_group/lib/unified_examples/radio_group/screen.ex",
             "/Users/Pascal/code/unified/examples/radio_group/lib/unified_examples/radio_group.ex"
           ]
  end
end
