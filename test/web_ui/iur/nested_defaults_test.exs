defmodule WebUi.Iur.NestedDefaultsTest do
  use ExUnit.Case, async: true

  alias WebUi.Iur.NestedDefaults

  test "prunes style default profile values" do
    style = %{fg: :blue, attrs: []}

    assert NestedDefaults.canonicalize_nested_prop("button", :style, style) == %{fg: :blue}
  end

  test "prunes table column nested default profile values" do
    columns = [
      %{key: :id, header: "ID", sortable: true, align: :left},
      %{key: :total, header: "Total", sortable: false, align: :right}
    ]

    assert NestedDefaults.canonicalize_nested_prop("table", :columns, columns) == [
             %{key: :id, header: "ID"},
             %{key: :total, header: "Total", sortable: false, align: :right}
           ]
  end

  test "preserves unmatched nested props and kinds" do
    value = %{items: [%{id: 1}]}

    assert NestedDefaults.canonicalize_nested_prop("menu", :items, value) == value
  end
end
