defmodule UnifiedIUR.Widgets.DataTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Element
  alias UnifiedIUR.Widgets.Data

  test "builds list, table, and tree data structures with stable item semantics" do
    list =
      Data.list(
        [
          [id: :a, label: "Alpha", value: :alpha, selected?: true],
          [id: :b, label: "Beta", value: :beta]
        ],
        id: "artifact-list"
      )

    table =
      Data.table(
        [
          [id: :name, label: "Name"],
          [id: :status, label: "Status", align: :center]
        ],
        [
          [id: "row-1", cells: ["Spec", "Ready"], selected?: true],
          [id: "row-2", cells: ["Tests", "Queued"]]
        ],
        id: "artifact-table",
        dense?: true
      )

    tree =
      Data.tree_view(
        [
          [
            id: :root,
            label: "Root",
            expanded?: true,
            children: [
              [id: :child, label: "Child", selected?: true]
            ]
          ]
        ],
        id: "artifact-tree"
      )

    assert %Element{
             kind: :list,
             attributes: %{
               list: %{
                 ordered?: false,
                 selection_mode: :single,
                 items: [
                   %{id: :a, label: "Alpha", value: :alpha, selected?: true},
                   %{id: :b, label: "Beta", value: :beta}
                 ]
               }
             }
           } = list

    assert %Element{
             kind: :table,
             attributes: %{
               table: %{
                 dense?: true,
                 columns: [
                   %{id: :name, label: "Name"},
                   %{id: :status, label: "Status", align: :center}
                 ],
                 rows: [
                   %{id: "row-1", cells: ["Spec", "Ready"], selected?: true},
                   %{id: "row-2", cells: ["Tests", "Queued"]}
                 ]
               }
             }
           } = table

    assert %Element{
             kind: :tree_view,
             attributes: %{
               tree: %{
                 selection_mode: :single,
                 nodes: [
                   %{
                     id: :root,
                     label: "Root",
                     expanded?: true,
                     children: [
                       %{id: :child, label: "Child", selected?: true}
                     ]
                   }
                 ]
               }
             }
           } = tree
  end
end
