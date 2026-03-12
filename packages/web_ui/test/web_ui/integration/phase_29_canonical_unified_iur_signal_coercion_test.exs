defmodule WebUi.Integration.Phase29CanonicalUnifiedIurSignalCoercionTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Layouts
  alias UnifiedIUR.Widgets
  alias WebUi.Iur.Interpreter
  alias WebUi.TypedError

  @moduletag :conformance

  defp canonical_struct_input do
    %Layouts.VBox{
      id: :coercion_root,
      children: [
        %Widgets.Menu{
          id: :main_menu,
          items: [
            %Widgets.MenuItem{id: :open_item, label: "Open", action: :open_file}
          ]
        },
        %Widgets.Table{
          id: :orders_table,
          data: [],
          columns: [],
          on_row_select: {:row_selected, %{index: 2}},
          on_sort: {:sorted, %{column: :price, direction: :desc}}
        },
        %Widgets.Tabs{
          id: :main_tabs,
          active_tab: :overview,
          on_change: {:tab_changed, %{tab_id: :details}},
          tabs: [
            %Widgets.Tab{id: :overview, label: "Overview"},
            %Widgets.Tab{id: :details, label: "Details"}
          ]
        },
        %Widgets.TreeView{
          id: :nav_tree,
          root_nodes: [
            %Widgets.TreeNode{id: :node_1, label: "Node 1", expanded: false}
          ],
          on_select: {:node_selected, %{node_id: :node_1}},
          on_toggle: {:node_toggled, %{node_id: :node_1, expanded: :true}}
        }
      ]
    }
  end

  defp canonical_map_input do
    %{
      type: :vbox,
      id: :coercion_root,
      children: [
        %{
          type: :menu,
          id: :main_menu,
          children: [
            %{type: :menu_item, id: :open_item, label: "Open", action: "open_file"}
          ]
        },
        %{
          type: :table,
          id: :orders_table,
          data: [],
          columns: [],
          on_row_select: %{index: "2", action: "row_selected"},
          on_sort: %{column: "price", direction: "DESC", action: "sorted"}
        },
        %{
          type: :tabs,
          id: :main_tabs,
          active_tab: :overview,
          on_change: %{tab_id: :details, action: "tab_changed"},
          children: [
            %{type: :tab, id: :overview, label: "Overview"},
            %{type: :tab, id: :details, label: "Details"}
          ]
        },
        %{
          type: :tree_view,
          id: :nav_tree,
          on_select: %{node_id: :node_1, action: "node_selected"},
          on_toggle: %{node_id: :node_1, expanded: "true", action: "node_toggled"},
          children: [
            %{type: :tree_node, id: :node_1, label: "Node 1", expanded: false}
          ]
        }
      ]
    }
  end

  defp find_widget(children, id) do
    Enum.find(children, &(&1.id == id))
  end

  defp assert_signal_props_stripped(interpreted) do
    menu_node = find_widget(interpreted.root.children, "main_menu")
    open_item_node = find_widget(menu_node.children, "open_item")
    table_node = find_widget(interpreted.root.children, "orders_table")
    tabs_node = find_widget(interpreted.root.children, "main_tabs")
    tree_node = find_widget(interpreted.root.children, "nav_tree")

    refute Map.has_key?(open_item_node.props, :action)
    refute Map.has_key?(table_node.props, :on_row_select)
    refute Map.has_key?(table_node.props, :on_sort)
    refute Map.has_key?(tabs_node.props, :on_change)
    refute Map.has_key?(tree_node.props, :on_select)
    refute Map.has_key?(tree_node.props, :on_toggle)
  end

  test "SCN-034 equivalent canonical inputs with atom/string signal primitives produce deterministic event traces" do
    assert {:ok, interpreted_struct} = Interpreter.interpret(canonical_struct_input())
    assert {:ok, interpreted_map} = Interpreter.interpret(canonical_map_input())

    struct_trace =
      interpreted_struct.events
      |> Enum.map(fn event -> {event.type, event.widget_id, event.data} end)

    map_trace =
      interpreted_map.events
      |> Enum.map(fn event -> {event.type, event.widget_id, event.data} end)

    assert struct_trace == map_trace
    assert_signal_props_stripped(interpreted_struct)
    assert_signal_props_stripped(interpreted_map)
  end

  test "SCN-034 malformed primitive signal payloads fail closed with typed validation errors" do
    malformed = %{
      type: :vbox,
      children: [
        %{
          type: :table,
          id: :orders_table,
          on_sort: %{column: :price, direction: :sideways}
        }
      ]
    }

    assert {:error, %TypedError{} = error} =
             Interpreter.interpret(malformed, correlation_id: "corr-scn-034")

    assert error.error_code == "iur.interpreter.signal_mapping_failed"
    assert error.correlation_id == "corr-scn-034"
  end

  test "SCN-034 repeated equivalent interpretation flows produce equivalent traces and descriptor props" do
    flow_snapshot = fn ->
      assert {:ok, interpreted} = Interpreter.interpret(canonical_struct_input())

      %{
        root: interpreted.root,
        widgets: interpreted.widgets,
        signals: interpreted.signals,
        events: interpreted.events
      }
    end

    assert flow_snapshot.() == flow_snapshot.()
  end
end
