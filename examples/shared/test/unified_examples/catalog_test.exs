defmodule UnifiedExamples.CatalogTest do
  use ExUnit.Case, async: true

  alias UnifiedExamples.Shared.Catalog

  test "tracks the implemented phase 1 and phase 2 example apps with stable metadata" do
    assert Catalog.directories() == [
             "box",
             "button",
             "checkbox",
             "content",
             "date_input",
             "field",
             "field_group",
             "file_input",
             "form_builder",
             "icon",
             "image",
             "label",
             "link",
             "numeric_input",
             "pick_list",
             "radio_group",
             "select",
             "separator",
             "spacer",
             "text",
             "text_input",
             "time_input",
             "toggle"
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

    assert Catalog.entry!("numeric_input") == %{
             directory: "numeric_input",
             widget: :numeric_input,
             family: :input,
             phase: 2,
             shell_kind: :form_builder
           }
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
