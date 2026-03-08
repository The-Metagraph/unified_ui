defmodule WebUi.Integration.Phase31CanonicalUnifiedIurDeepValueParityTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Layouts
  alias UnifiedIUR.Style
  alias UnifiedIUR.Widgets
  alias WebUi.Iur.Interpreter
  alias WebUi.TypedError

  @moduletag :conformance

  defp canonical_struct_input do
    %Layouts.VBox{
      id: :styled_root,
      children: [
        %Widgets.Button{
          id: :save_button,
          label: "Save",
          on_click: :save,
          style: %Style{fg: :blue, attrs: [:bold]}
        },
        %Widgets.Table{
          id: :orders_table,
          data: [%{id: 1, total: 99}],
          columns: [
            %Widgets.Column{key: :id, header: "ID", sortable: true, align: :right}
          ],
          on_row_select: %{row_index: 0},
          on_sort: %{column: "id", direction: "asc"}
        }
      ]
    }
  end

  defp canonical_map_input do
    %{
      type: :vbox,
      id: :styled_root,
      children: [
        %{
          type: :button,
          id: :save_button,
          label: "Save",
          on_click: :save,
          style: %{"fg" => :blue, "attrs" => [:bold]}
        },
        %{
          type: :table,
          id: :orders_table,
          data: [%{"id" => 1, "total" => 99}],
          columns: [
            %{"key" => :id, "header" => "ID", "sortable" => true, "align" => :right}
          ],
          on_row_select: %{row_index: 0},
          on_sort: %{column: "id", direction: "asc"}
        }
      ]
    }
  end

  test "SCN-036 equivalent canonical nested struct/map inputs produce identical descriptor and event snapshots" do
    assert {:ok, interpreted_struct} = Interpreter.interpret(canonical_struct_input())
    assert {:ok, interpreted_map} = Interpreter.interpret(canonical_map_input())

    assert interpreted_struct.root == interpreted_map.root
    assert interpreted_struct.widgets == interpreted_map.widgets
    assert interpreted_struct.signals == interpreted_map.signals
    assert interpreted_struct.events == interpreted_map.events

    button_node = Enum.find(interpreted_struct.root.children, &(&1.id == "save_button"))
    assert button_node.props.style == %{fg: :blue, attrs: [:bold]}
  end

  test "SCN-036 malformed nested payloads fail closed with typed validation errors" do
    malformed = %{
      type: :vbox,
      children: [
        %{type: :table, id: :orders_table, on_sort: %{column: "id", direction: "sideways"}}
      ]
    }

    assert {:error, %TypedError{} = error} =
             Interpreter.interpret(malformed, correlation_id: "corr-scn-036")

    assert error.error_code == "iur.interpreter.signal_mapping_failed"
    assert error.correlation_id == "corr-scn-036"
  end

  test "SCN-036 repeated equivalent interpretation flows produce identical deep snapshots" do
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
