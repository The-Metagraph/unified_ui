defmodule WebUi.Integration.Phase28CanonicalUnifiedIurExtendedMappingTest do
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

  test "SCN-033 equivalent canonical extended inputs produce deterministic event traces and widget inventories" do
    assert {:ok, interpreted_struct} = Interpreter.interpret(canonical_struct_input())
    assert {:ok, interpreted_map} = Interpreter.interpret(canonical_map_input())

    struct_trace =
      interpreted_struct.events
      |> Enum.map(fn event -> {event.type, event.widget_id, event.data} end)

    map_trace =
      interpreted_map.events
      |> Enum.map(fn event -> {event.type, event.widget_id, event.data} end)

    assert struct_trace == map_trace

    struct_widget_ids = interpreted_struct.widgets |> Enum.map(& &1.widget_id) |> Enum.sort()
    map_widget_ids = interpreted_map.widgets |> Enum.map(& &1.widget_id) |> Enum.sort()
    assert struct_widget_ids == map_widget_ids
  end

  test "SCN-033 malformed extended signal payloads fail closed with typed validation errors" do
    malformed = %{
      type: :vbox,
      children: [
        %{type: :table, id: :orders_table, on_sort: %{column: "price", direction: "sideways"}}
      ]
    }

    assert {:error, %TypedError{} = error} =
             Interpreter.interpret(malformed, correlation_id: "corr-scn-033")

    assert error.error_code == "iur.interpreter.signal_mapping_failed"
    assert error.correlation_id == "corr-scn-033"
  end

  test "SCN-033 repeated equivalent extended interpretation flows produce equivalent traces" do
    flow_trace = fn ->
      assert {:ok, interpreted} = Interpreter.interpret(canonical_struct_input())

      %{
        widgets: interpreted.widgets,
        signals: interpreted.signals,
        events: interpreted.events
      }
    end

    assert flow_trace.() == flow_trace.()
  end
end
