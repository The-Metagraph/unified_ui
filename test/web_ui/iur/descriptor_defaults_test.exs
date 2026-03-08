defmodule WebUi.Iur.DescriptorDefaultsTest do
  use ExUnit.Case, async: true

  alias WebUi.Iur.DescriptorDefaults

  test "removes nil and known default values for covered widget kinds" do
    props = %{
      label: "Open",
      visible: true,
      disabled: false,
      icon: nil,
      shortcut: nil
    }

    assert DescriptorDefaults.canonicalize_widget_props(props, "menu_item") == %{label: "Open"}
  end

  test "removes known default values for table and tree-view fields" do
    table_props = %{
      data: [],
      columns: [],
      sort_direction: :asc,
      sort_column: nil,
      visible: true
    }

    tree_view_props = %{
      show_root: true,
      selected_node: nil,
      visible: true
    }

    assert DescriptorDefaults.canonicalize_widget_props(table_props, "table") == %{
             data: [],
             columns: []
           }

    assert DescriptorDefaults.canonicalize_widget_props(tree_view_props, "tree_view") == %{}
  end

  test "preserves non-default values" do
    props = %{
      visible: false,
      disabled: true,
      sort_direction: :desc,
      expanded: true,
      label: "Node 1"
    }

    assert DescriptorDefaults.canonicalize_widget_props(props, "tree_node") == props
  end

  test "unknown widget kinds still prune nil values" do
    props = %{
      visible: true,
      mode: "compact",
      optional: nil
    }

    assert DescriptorDefaults.canonicalize_widget_props(props, "custom.example.widget") == %{
             mode: "compact"
           }
  end
end
