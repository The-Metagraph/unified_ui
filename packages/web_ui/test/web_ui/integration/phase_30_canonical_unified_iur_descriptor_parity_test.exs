defmodule WebUi.Integration.Phase30CanonicalUnifiedIurDescriptorParityTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Layouts
  alias UnifiedIUR.Widgets
  alias WebUi.Iur.Interpreter
  alias WebUi.TypedError

  @moduletag :conformance

  defp canonical_struct_input do
    %Layouts.VBox{
      id: :extended_root,
      children: [
        %Widgets.Menu{
          id: :main_menu,
          items: [
            %Widgets.MenuItem{id: :open_item, label: "Open", action: "open_file"}
          ]
        },
        %Widgets.Table{
          id: :orders_table,
          data: [],
          columns: [],
          on_row_select: %{row_index: 2},
          on_sort: %{column: "price", direction: "asc"}
        },
        %Widgets.Tabs{
          id: :main_tabs,
          active_tab: :overview,
          on_change: %{tab_id: "details"},
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
          on_select: %{node_id: "node-1"},
          on_toggle: %{node_id: "node-1", expanded: true}
        }
      ]
    }
  end

  defp canonical_map_input do
    %{
      type: :vbox,
      id: :extended_root,
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
          on_row_select: %{row_index: 2},
          on_sort: %{column: "price", direction: "asc"}
        },
        %{
          type: :tabs,
          id: :main_tabs,
          active_tab: :overview,
          on_change: %{tab_id: "details"},
          children: [
            %{type: :tab, id: :overview, label: "Overview"},
            %{type: :tab, id: :details, label: "Details"}
          ]
        },
        %{
          type: :tree_view,
          id: :nav_tree,
          on_select: %{node_id: "node-1"},
          on_toggle: %{node_id: "node-1", expanded: true},
          children: [
            %{type: :tree_node, id: :node_1, label: "Node 1", expanded: false}
          ]
        }
      ]
    }
  end

  test "SCN-035 equivalent canonical extended struct/map inputs produce identical descriptor and event traces" do
    assert {:ok, interpreted_struct} = Interpreter.interpret(canonical_struct_input())
    assert {:ok, interpreted_map} = Interpreter.interpret(canonical_map_input())

    assert interpreted_struct.root == interpreted_map.root
    assert interpreted_struct.widgets == interpreted_map.widgets
    assert interpreted_struct.signals == interpreted_map.signals
    assert interpreted_struct.events == interpreted_map.events

    menu_node = Enum.find(interpreted_struct.root.children, &(&1.id == "main_menu"))
    open_item = Enum.find(menu_node.children, &(&1.id == "open_item"))
    assert open_item.props == %{label: "Open"}
  end

  test "SCN-035 malformed extended payloads fail closed with typed validation errors" do
    malformed = %{
      type: :vbox,
      children: [
        %{type: :table, id: :orders_table, on_sort: %{column: "price", direction: "sideways"}}
      ]
    }

    assert {:error, %TypedError{} = error} =
             Interpreter.interpret(malformed, correlation_id: "corr-scn-035")

    assert error.error_code == "iur.interpreter.signal_mapping_failed"
    assert error.correlation_id == "corr-scn-035"
  end

  test "SCN-035 repeated equivalent canonical interpretation flows produce identical snapshots" do
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
