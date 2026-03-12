defmodule UnifiedUi.Dsl.Entities.TablesTest do
  @moduledoc """
  Tests for table and column DSL entities.
  """

  use ExUnit.Case, async: true
  alias UnifiedUi.Dsl.Entities.Tables
  alias UnifiedIUR.Widgets

  describe "column_entity/0" do
    test "returns entity with correct name" do
      entity = Tables.column_entity()
      assert entity.name == :column
    end

    test "returns entity with correct target" do
      entity = Tables.column_entity()
      assert entity.target == Widgets.Column
    end

    test "returns entity with correct args" do
      entity = Tables.column_entity()
      assert entity.args == [:key, :header]
    end

    test "has required schema fields" do
      entity = Tables.column_entity()
      schema = Keyword.keyword?(entity.schema)
      assert schema == true

      # Required fields
      assert Keyword.get(entity.schema, :key)[:required] == true
      assert Keyword.get(entity.schema, :key)[:type] == :atom

      assert Keyword.get(entity.schema, :header)[:required] == true
      assert Keyword.get(entity.schema, :header)[:type] == :string
    end

    test "has optional schema fields with correct defaults" do
      entity = Tables.column_entity()

      # Optional fields with defaults
      assert Keyword.get(entity.schema, :sortable)[:required] == false
      assert Keyword.get(entity.schema, :sortable)[:default] == true

      align_spec = Keyword.get(entity.schema, :align)
      assert align_spec[:required] == false
      assert align_spec[:default] == :left
      assert align_spec[:type] == {:one_of, [:left, :center, :right]}

      # Optional fields without defaults
      assert Keyword.get(entity.schema, :formatter)[:required] == false
      assert Keyword.get(entity.schema, :formatter)[:type] == {:fun, 1}

      assert Keyword.get(entity.schema, :width)[:required] == false
      assert Keyword.get(entity.schema, :width)[:type] == :integer
    end

    test "has documentation" do
      entity = Tables.column_entity()
      assert is_binary(entity.describe)
      assert entity.describe != ""
      assert String.contains?(entity.describe, "column")
    end
  end

  describe "table_entity/0" do
    test "returns entity with correct name" do
      entity = Tables.table_entity()
      assert entity.name == :table
    end

    test "returns entity with correct target" do
      entity = Tables.table_entity()
      assert entity.target == Widgets.Table
    end

    test "returns entity with correct args" do
      entity = Tables.table_entity()
      assert entity.args == [:id, :data]
    end

    test "has required schema fields" do
      entity = Tables.table_entity()

      assert Keyword.get(entity.schema, :id)[:required] == true
      assert Keyword.get(entity.schema, :id)[:type] == :atom

      assert Keyword.get(entity.schema, :data)[:required] == true
      assert Keyword.get(entity.schema, :data)[:type] == {:list, :any}
    end

    test "has optional schema fields for sorting and selection" do
      entity = Tables.table_entity()

      # Sorting fields
      assert Keyword.get(entity.schema, :sort_column)[:required] == false
      assert Keyword.get(entity.schema, :sort_column)[:type] == :atom

      sort_direction_spec = Keyword.get(entity.schema, :sort_direction)
      assert sort_direction_spec[:required] == false
      assert sort_direction_spec[:default] == :asc
      assert sort_direction_spec[:type] == {:one_of, [:asc, :desc]}

      assert Keyword.get(entity.schema, :on_sort)[:required] == false

      assert Keyword.get(entity.schema, :on_sort)[:type] ==
               {:or, [:atom, {:tuple, [:atom, :map]}, {:tuple, [:atom, :atom, {:list, :any}]}]}

      # Selection fields
      assert Keyword.get(entity.schema, :selected_row)[:required] == false
      assert Keyword.get(entity.schema, :selected_row)[:type] == :integer

      assert Keyword.get(entity.schema, :on_row_select)[:required] == false

      assert Keyword.get(entity.schema, :on_row_select)[:type] ==
               {:or, [:atom, {:tuple, [:atom, :map]}, {:tuple, [:atom, :atom, {:list, :any}]}]}

      # Display fields
      assert Keyword.get(entity.schema, :height)[:required] == false
      assert Keyword.get(entity.schema, :height)[:type] == :integer
    end

    test "has style and visible fields" do
      entity = Tables.table_entity()

      assert Keyword.get(entity.schema, :style)[:required] == false
      assert Keyword.get(entity.schema, :style)[:type] == :keyword_list

      assert Keyword.get(entity.schema, :visible)[:required] == false
      assert Keyword.get(entity.schema, :visible)[:default] == true
    end

    test "has column entities as nested entities" do
      entity = Tables.table_entity()

      assert is_list(entity.entities)

      # Should have columns entity containing column_entity
      columns_spec = Keyword.get(entity.entities, :columns)
      assert is_list(columns_spec)

      [%Spark.Dsl.Entity{name: :column}] = columns_spec
    end

    test "has documentation" do
      entity = Tables.table_entity()
      assert is_binary(entity.describe)
      assert entity.describe != ""
      assert String.contains?(entity.describe, "table")
    end
  end

  describe "Column IUR struct" do
    alias UnifiedIUR.Widgets.Column

    test "can be created with required fields" do
      column = %Column{key: :id, header: "ID"}
      assert column.key == :id
      assert column.header == "ID"
      assert column.sortable == true
      assert column.align == :left
    end

    test "can be created with optional fields" do
      formatter = fn val -> to_string(val) end

      column = %Column{
        key: :name,
        header: "Name",
        sortable: true,
        formatter: formatter,
        width: 20,
        align: :center
      }

      assert column.key == :name
      assert column.header == "Name"
      assert column.sortable == true
      assert column.formatter == formatter
      assert column.width == 20
      assert column.align == :center
    end

    test "has type spec" do
      # This just ensures the type spec compiles
      column = %Column{key: :test, header: "Test"}
      assert is_struct(column)
    end
  end

  describe "Table IUR struct" do
    alias UnifiedIUR.Widgets.Table
    alias UnifiedIUR.Widgets.Column

    test "can be created with required fields" do
      data = [%{id: 1, name: "Alice"}, %{id: 2, name: "Bob"}]
      table = %Table{id: :users, data: data}

      assert table.id == :users
      assert table.data == data
      assert table.sort_direction == :asc
      assert table.visible == true
    end

    test "can be created with optional fields" do
      columns = [
        %Column{key: :id, header: "ID"},
        %Column{key: :name, header: "Name"}
      ]

      data = [%{id: 1, name: "Alice"}, %{id: 2, name: "Bob"}]

      table = %Table{
        id: :users,
        data: data,
        columns: columns,
        selected_row: 0,
        height: 10,
        on_row_select: :user_selected,
        on_sort: {:table_sorted, %{table: :users}},
        sort_column: :name,
        sort_direction: :asc
      }

      assert table.id == :users
      assert table.data == data
      assert table.columns == columns
      assert table.selected_row == 0
      assert table.height == 10
      assert table.on_row_select == :user_selected
      assert table.on_sort == {:table_sorted, %{table: :users}}
      assert table.sort_column == :name
      assert table.sort_direction == :asc
    end

    test "has type spec" do
      # This just ensures the type spec compiles
      table = %Table{id: :test, data: []}
      assert is_struct(table)
    end
  end

  describe "Element protocol for Column" do
    alias UnifiedIUR.Element
    alias UnifiedIUR.Widgets.Column

    test "children/1 returns empty list" do
      column = %Column{key: :id, header: "ID"}
      assert Element.children(column) == []
    end

    test "metadata/1 returns correct map" do
      formatter = fn val -> to_string(val) end

      column = %Column{
        key: :id,
        header: "ID",
        sortable: true,
        formatter: formatter,
        width: 10,
        align: :right
      }

      metadata = Element.metadata(column)

      assert metadata.type == :column
      assert metadata.key == :id
      assert metadata.header == "ID"
      assert metadata.sortable == true
      assert metadata.formatter == formatter
      assert metadata.width == 10
      assert metadata.align == :right
    end
  end

  describe "Element protocol for Table" do
    alias UnifiedIUR.Element
    alias UnifiedIUR.Widgets.Table
    alias UnifiedIUR.Widgets.Column
    alias UnifiedIUR.Style

    test "children/1 returns empty list" do
      table = %Table{id: :users, data: []}
      assert Element.children(table) == []
    end

    test "metadata/1 returns correct map without optional fields" do
      table = %Table{id: :users, data: [%{id: 1}]}

      metadata = Element.metadata(table)

      assert metadata.type == :table
      assert metadata.id == :users
      assert metadata.data == [%{id: 1}]
      assert metadata.columns == nil
      assert metadata.selected_row == nil
      assert metadata.height == nil
      assert metadata.on_row_select == nil
      assert metadata.on_sort == nil
      assert metadata.sort_column == nil
      assert metadata.sort_direction == :asc
      assert metadata.visible == true
    end

    test "metadata/1 returns correct map with optional fields" do
      columns = [
        %Column{key: :id, header: "ID"},
        %Column{key: :name, header: "Name"}
      ]

      style = %Style{fg: :blue}

      table = %Table{
        id: :users,
        data: [%{id: 1, name: "Alice"}],
        columns: columns,
        selected_row: 0,
        height: 10,
        on_row_select: :selected,
        on_sort: :sorted,
        sort_column: :name,
        sort_direction: :desc,
        style: style
      }

      metadata = Element.metadata(table)

      assert metadata.type == :table
      assert metadata.id == :users
      assert metadata.data == [%{id: 1, name: "Alice"}]
      assert metadata.columns == columns
      assert metadata.selected_row == 0
      assert metadata.height == 10
      assert metadata.on_row_select == :selected
      assert metadata.on_sort == :sorted
      assert metadata.sort_column == :name
      assert metadata.sort_direction == :desc
      assert metadata.visible == true
    end
  end
end
