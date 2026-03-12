defmodule LiveUi.Widgets.WidgetRegistryTest do
  use ExUnit.Case, async: true

  alias LiveUi.WidgetRegistry

  test "covers the current canonical and extension widget catalog" do
    required_kinds = [
      "button",
      "canvas",
      "chart",
      "command_palette",
      "dialog",
      "hbox",
      "label",
      "pick_list",
      "split_pane",
      "table",
      "tabs",
      "text",
      "text_input",
      "toast",
      "tree_view",
      "vbox",
      "viewport"
    ]

    Enum.each(required_kinds, fn kind ->
      assert WidgetRegistry.supported_kind?(kind), "expected #{kind} to be in the registry"
      assert {:ok, _module} = WidgetRegistry.renderer_for(kind)
    end)
  end
end
