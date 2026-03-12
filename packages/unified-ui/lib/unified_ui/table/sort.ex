defmodule UnifiedUi.Table.Sort do
  @moduledoc """
  Sorting logic for table widgets.

  This module provides functions to sort table data by column keys
  in ascending or descending order. It handles different data structures
  (maps, keyword lists, and structs) and properly manages nil values.

  ## Data Structure Support

  Tables can contain data as:
  * Maps: `%{id: 1, name: "Alice"}`
  * Keyword lists: `[id: 1, name: "Alice"]`
  * Structs: `%User{id: 1, name: "Alice"}`

  ## Examples

      iex> data = [%{id: 2, name: "Bob"}, %{id: 1, name: "Alice"}]
      iex> UnifiedUi.Table.Sort.sort_data(data, :id, :asc)
      [%{id: 1, name: "Alice"}, %{id: 2, name: "Bob"}]

      iex> data = [%{id: 2, name: "Bob"}, %{id: 1, name: "Alice"}]
      iex> UnifiedUi.Table.Sort.sort_data(data, :name, :desc)
      [%{id: 2, name: "Bob"}, %{id: 1, name: "Alice"}]

  ## Nil Handling

  Nil values are always sorted first (ascending) or last (descending),
  regardless of the sort direction. This ensures consistent behavior
  across different data types.

  ## Type Comparison

  The sorter attempts to compare values of the same type:
  * Numbers are compared numerically
  * Strings are compared lexicographically
  * Atoms are compared by their name
  * Mixed types fall back to string comparison
  """

  @type row :: map() | keyword()
  @type direction :: :asc | :desc
  @type column_key :: atom()

  @doc """
  Sorts a list of rows by the specified column key and direction.

  ## Parameters

  * `data` - List of rows (maps, keyword lists, or structs)
  * `column_key` - The atom key to sort by
  * `direction` - Sort direction (:asc or :desc)

  ## Returns

  A new list with the sorted rows.

  ## Examples

      iex> data = [%{id: 2}, %{id: 1}, %{id: 3}]
      iex> UnifiedUi.Table.Sort.sort_data(data, :id, :asc)
      [%{id: 1}, %{id: 2}, %{id: 3}]

      iex> data = [%{id: 2}, %{id: 1}, %{id: 3}]
      iex> UnifiedUi.Table.Sort.sort_data(data, :id, :desc)
      [%{id: 3}, %{id: 2}, %{id: 1}]

  ## Nil Values

  Nil values are handled specially:
  * Ascending: nils come first
  * Descending: nils come last

      iex> data = [%{id: 1}, %{id: nil}, %{id: 2}]
      iex> UnifiedUi.Table.Sort.sort_data(data, :id, :asc)
      [%{id: nil}, %{id: 1}, %{id: 2}]
  """
  @spec sort_data([row()], column_key(), direction()) :: [row()]
  def sort_data(data, column_key, direction \\ :asc)

  def sort_data([], _column_key, _direction), do: []
  def sort_data(data, nil, _direction), do: data

  def sort_data(data, column_key, direction) do
    # Use Enum.sort with a custom comparator
    Enum.sort(data, fn row_a, row_b ->
      value_a = get_value(row_a, column_key)
      value_b = get_value(row_b, column_key)
      compare_values(value_a, value_b, direction)
    end)
  end

  @doc """
  Gets a value from a row by key, handling different data structures.

  ## Parameters

  * `row` - A single row (map, keyword list, or struct)
  * `key` - The atom key to fetch

  ## Returns

  The value at the key, or nil if not found.

  ## Examples

      iex> UnifiedUi.Table.Sort.get_value(%{id: 1, name: "Alice"}, :name)
      "Alice"

      iex> UnifiedUi.Table.Sort.get_value([id: 1, name: "Bob"], :id)
      1

      iex> UnifiedUi.Table.Sort.get_value(%{id: 1}, :missing)
      nil
  """
  @spec get_value(row(), atom()) :: any()
  def get_value(row, key)

  def get_value(%_{} = struct, key) do
    Map.get(struct, key)
  end

  def get_value(map, key) when is_map(map) do
    Map.get(map, key)
  end

  def get_value(keyword_list, key) when is_list(keyword_list) do
    Keyword.get(keyword_list, key)
  end

  # Private Functions

  defp compare_values(a, b, direction) do
    # Returns true if a should come before b
    should_come_before = do_compare(a, b)

    case direction do
      :asc -> should_come_before
      :desc -> not should_come_before
    end
  end

  # Equal, keep order
  defp do_compare(nil, nil), do: false
  # nil comes first
  defp do_compare(nil, _b), do: true
  # non-nil comes after nil
  defp do_compare(_a, nil), do: false

  defp do_compare(a, b) when is_number(a) and is_number(b), do: a < b
  defp do_compare(a, b) when is_binary(a) and is_binary(b), do: a < b
  defp do_compare(a, b) when is_atom(a) and is_atom(b), do: to_string(a) < to_string(b)

  defp do_compare(a, b) do
    # Fallback to string comparison for mixed types
    to_string(a) < to_string(b)
  end
end
