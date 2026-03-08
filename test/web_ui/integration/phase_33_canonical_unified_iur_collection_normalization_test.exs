defmodule WebUi.Integration.Phase33CanonicalUnifiedIurCollectionNormalizationTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Layouts
  alias UnifiedIUR.Widgets
  alias WebUi.Iur.Interpreter
  alias WebUi.TypedError

  @moduletag :conformance

  defp canonical_struct_input do
    %Layouts.VBox{
      id: :tree_root,
      children: [
        %Widgets.TreeView{
          id: :nav_tree,
          expanded_nodes: MapSet.new([:node_2, :node_1]),
          root_nodes: [
            %Widgets.TreeNode{id: :node_1, label: "Node 1"},
            %Widgets.TreeNode{id: :node_2, label: "Node 2"}
          ],
          on_select: %{node_id: "node-1"}
        }
      ]
    }
  end

  defp canonical_map_input do
    %{
      type: :vbox,
      id: :tree_root,
      children: [
        %{
          type: :tree_view,
          id: :nav_tree,
          expanded_nodes: [:node_1, :node_2],
          children: [
            %{type: :tree_node, id: :node_1, label: "Node 1"},
            %{type: :tree_node, id: :node_2, label: "Node 2"}
          ],
          on_select: %{node_id: "node-1"}
        }
      ]
    }
  end

  test "SCN-038 equivalent canonical set/list inputs produce identical interpreted snapshots" do
    assert {:ok, interpreted_struct} = Interpreter.interpret(canonical_struct_input())
    assert {:ok, interpreted_map} = Interpreter.interpret(canonical_map_input())

    assert interpreted_struct.root == interpreted_map.root
    assert interpreted_struct.widgets == interpreted_map.widgets
    assert interpreted_struct.signals == interpreted_map.signals
    assert interpreted_struct.events == interpreted_map.events

    tree_node = Enum.find(interpreted_struct.root.children, &(&1.id == "nav_tree"))
    assert tree_node.props.expanded_nodes == [:node_1, :node_2]
  end

  test "SCN-038 malformed payloads fail closed with typed validation errors" do
    malformed = %{
      type: :vbox,
      children: [
        %{type: :table, id: :orders_table, on_sort: %{column: "id", direction: "sideways"}}
      ]
    }

    assert {:error, %TypedError{} = error} =
             Interpreter.interpret(malformed, correlation_id: "corr-scn-038")

    assert error.error_code == "iur.interpreter.signal_mapping_failed"
    assert error.correlation_id == "corr-scn-038"
  end

  test "SCN-038 repeated equivalent interpretation flows produce identical snapshots" do
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
