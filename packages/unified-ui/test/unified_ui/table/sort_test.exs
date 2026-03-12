defmodule UnifiedUi.Table.SortTest do
  @moduledoc """
  Tests for table sorting logic.
  """

  use ExUnit.Case, async: true
  alias UnifiedUi.Table.Sort

  # Define test structs outside of test functions
  defmodule TestUser do
    defstruct [:id, :name]
  end

  describe "sort_data/3" do
    test "sorts list of maps by atom key in ascending order" do
      data = [
        %{id: 3, name: "Charlie"},
        %{id: 1, name: "Alice"},
        %{id: 2, name: "Bob"}
      ]

      result = Sort.sort_data(data, :id, :asc)

      assert [
        %{id: 1, name: "Alice"},
        %{id: 2, name: "Bob"},
        %{id: 3, name: "Charlie"}
      ] = result
    end

    test "sorts list of maps by atom key in descending order" do
      data = [
        %{id: 1, name: "Alice"},
        %{id: 3, name: "Charlie"},
        %{id: 2, name: "Bob"}
      ]

      result = Sort.sort_data(data, :id, :desc)

      assert [
        %{id: 3, name: "Charlie"},
        %{id: 2, name: "Bob"},
        %{id: 1, name: "Alice"}
      ] = result
    end

    test "sorts list of keyword lists by atom key" do
      data = [
        [id: 3, name: "Charlie"],
        [id: 1, name: "Alice"],
        [id: 2, name: "Bob"]
      ]

      result = Sort.sort_data(data, :id, :asc)

      assert [
        [id: 1, name: "Alice"],
        [id: 2, name: "Bob"],
        [id: 3, name: "Charlie"]
      ] = result
    end

    test "sorts list of structs by atom key" do
      data = [
        %TestUser{id: 3, name: "Charlie"},
        %TestUser{id: 1, name: "Alice"},
        %TestUser{id: 2, name: "Bob"}
      ]

      result = Sort.sort_data(data, :id, :asc)

      assert [
        %TestUser{id: 1, name: "Alice"},
        %TestUser{id: 2, name: "Bob"},
        %TestUser{id: 3, name: "Charlie"}
      ] = result
    end

    test "sorts string values alphabetically" do
      data = [
        %{name: "Charlie"},
        %{name: "Alice"},
        %{name: "Bob"}
      ]

      result = Sort.sort_data(data, :name, :asc)

      assert [
        %{name: "Alice"},
        %{name: "Bob"},
        %{name: "Charlie"}
      ] = result
    end

    test "handles nil values by sorting them first in ascending order" do
      data = [
        %{id: 2, name: "Bob"},
        %{id: nil, name: "Unknown"},
        %{id: 1, name: "Alice"}
      ]

      result = Sort.sort_data(data, :id, :asc)

      assert [
        %{id: nil, name: "Unknown"},
        %{id: 1, name: "Alice"},
        %{id: 2, name: "Bob"}
      ] = result
    end

    test "handles nil values by sorting them last in descending order" do
      data = [
        %{id: 2, name: "Bob"},
        %{id: nil, name: "Unknown"},
        %{id: 1, name: "Alice"}
      ]

      result = Sort.sort_data(data, :id, :desc)

      assert [
        %{id: 2, name: "Bob"},
        %{id: 1, name: "Alice"},
        %{id: nil, name: "Unknown"}
      ] = result
    end

    test "handles empty list" do
      assert Sort.sort_data([], :id, :asc) == []
    end

    test "handles list with single element" do
      data = [%{id: 1, name: "Alice"}]
      result = Sort.sort_data(data, :id, :asc)

      assert result == [%{id: 1, name: "Alice"}]
    end

    test "uses ascending order by default" do
      data = [
        %{id: 3},
        %{id: 1},
        %{id: 2}
      ]

      result = Sort.sort_data(data, :id)

      assert [
        %{id: 1},
        %{id: 2},
        %{id: 3}
      ] = result
    end

    test "returns data unchanged when column_key is nil" do
      data = [
        %{id: 3},
        %{id: 1},
        %{id: 2}
      ]

      result = Sort.sort_data(data, nil, :asc)

      assert result == data
    end

    test "sorts mixed type values by string representation" do
      data = [
        %{value: "Zebra"},
        %{value: 100},
        %{value: "Apple"},
        %{value: 50}
      ]

      # Sorting mixed types falls back to string comparison
      result = Sort.sort_data(data, :value, :asc)

      # Values are converted to strings for comparison
      assert length(result) == 4
      assert hd(result).value == 50  # "50" comes before "100" and "Apple" alphabetically
    end

    test "sorts atom values by their name" do
      data = [
        %{status: :active},
        %{status: :inactive},
        %{status: :pending}
      ]

      result = Sort.sort_data(data, :status, :asc)

      assert [
        %{status: :active},
        %{status: :inactive},
        %{status: :pending}
      ] = result
    end

    test "preserves all fields when sorting" do
      data = [
        %{id: 3, name: "Charlie", email: "charlie@example.com", age: 35},
        %{id: 1, name: "Alice", email: "alice@example.com", age: 30},
        %{id: 2, name: "Bob", email: "bob@example.com", age: 25}
      ]

      result = Sort.sort_data(data, :id, :asc)

      assert [
        %{id: 1, name: "Alice", email: "alice@example.com", age: 30},
        %{id: 2, name: "Bob", email: "bob@example.com", age: 25},
        %{id: 3, name: "Charlie", email: "charlie@example.com", age: 35}
      ] = result
    end
  end

  describe "get_value/2" do
    test "extracts value from map" do
      row = %{id: 1, name: "Alice"}
      assert Sort.get_value(row, :id) == 1
      assert Sort.get_value(row, :name) == "Alice"
    end

    test "extracts value from keyword list" do
      row = [id: 1, name: "Alice"]
      assert Sort.get_value(row, :id) == 1
      assert Sort.get_value(row, :name) == "Alice"
    end

    test "extracts value from struct" do
      row = %TestUser{id: 1, name: "Alice"}
      assert Sort.get_value(row, :id) == 1
      assert Sort.get_value(row, :name) == "Alice"
    end

    test "returns nil for missing key in map" do
      row = %{id: 1, name: "Alice"}
      assert Sort.get_value(row, :email) == nil
    end

    test "returns nil for missing key in keyword list" do
      row = [id: 1, name: "Alice"]
      assert Sort.get_value(row, :email) == nil
    end

    test "extracts nil value when present" do
      row = %{id: nil, name: "Alice"}
      assert Sort.get_value(row, :id) == nil
    end

    test "extracts zero value correctly" do
      row = %{id: 0, name: "Zero"}
      assert Sort.get_value(row, :id) == 0
    end

    test "extracts false boolean value correctly" do
      row = %{active: false, name: "Inactive"}
      assert Sort.get_value(row, :active) == false
    end

    test "extracts empty string value correctly" do
      row = %{name: "", id: 1}
      assert Sort.get_value(row, :name) == ""
    end
  end

  describe "comparator behavior" do
    test "compares integers correctly" do
      data = [
        %{value: 100},
        %{value: 1},
        %{value: 50}
      ]

      result = Sort.sort_data(data, :value, :asc)

      assert [
        %{value: 1},
        %{value: 50},
        %{value: 100}
      ] = result
    end

    test "compares floats correctly" do
      data = [
        %{value: 3.14},
        %{value: 1.41},
        %{value: 2.71}
      ]

      result = Sort.sort_data(data, :value, :asc)

      assert [
        %{value: 1.41},
        %{value: 2.71},
        %{value: 3.14}
      ] = result
    end

    test "compares negative numbers correctly" do
      data = [
        %{value: 10},
        %{value: -5},
        %{value: 0}
      ]

      result = Sort.sort_data(data, :value, :asc)

      assert [
        %{value: -5},
        %{value: 0},
        %{value: 10}
      ] = result
    end

    test "compares strings with different cases" do
      data = [
        %{name: "Zebra"},
        %{name: "apple"},
        %{name: "Banana"}
      ]

      result = Sort.sort_data(data, :name, :asc)

      # String comparison is case-sensitive (uppercase comes before lowercase in ASCII)
      assert length(result) == 3
      # "Banana" (B) comes first, then "Zebra" (Z), then "apple" (a)
      assert hd(result).name == "Banana"
    end
  end

  describe "complex scenarios" do
    test "sorts by secondary key when primary keys are equal" do
      # This tests that sorting by equal values groups items together
      data = [
        %{category: "A", priority: 1, name: "Task 1"},
        %{category: "A", priority: 2, name: "Task 2"},
        %{category: "A", priority: 1, name: "Task 3"}
      ]

      result = Sort.sort_data(data, :priority, :asc)

      # Check that priority 1 items come before priority 2
      assert Enum.at(result, 0).priority == 1
      assert Enum.at(result, 1).priority == 1
      assert Enum.at(result, 2).priority == 2
    end

    test "handles large dataset efficiently" do
      # Generate 1000 items
      data = for i <- 1..1000 do
        %{id: 1001 - i, name: "Item #{1001 - i}"}
      end

      result = Sort.sort_data(data, :id, :asc)

      assert length(result) == 1000
      assert hd(result).id == 1
      assert List.last(result).id == 1000
    end
  end
end
