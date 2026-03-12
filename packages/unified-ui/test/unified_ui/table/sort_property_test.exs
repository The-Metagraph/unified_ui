defmodule UnifiedUi.Table.SortPropertyTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias UnifiedUi.Table.Sort
  import StreamData

  describe "sort_data/3 properties" do
    property "ascending integer+nil ordering matches canonical nil-first sort" do
      check all(values <- list_of(one_of([integer(), constant(nil)]), max_length: 120)) do
        rows = Enum.with_index(values, fn value, idx -> %{id: idx, value: value} end)

        sorted_values =
          rows
          |> Sort.sort_data(:value, :asc)
          |> Enum.map(& &1.value)

        assert sorted_values == Enum.sort(values, &asc_less?/2)
      end
    end

    property "descending integer+nil ordering matches canonical nil-last sort" do
      check all(values <- list_of(one_of([integer(), constant(nil)]), max_length: 120)) do
        rows = Enum.with_index(values, fn value, idx -> %{id: idx, value: value} end)

        sorted_values =
          rows
          |> Sort.sort_data(:value, :desc)
          |> Enum.map(& &1.value)

        assert sorted_values == Enum.sort(values, &desc_less?/2)
      end
    end

    property "sorting preserves row multiset" do
      check all(values <- list_of(one_of([integer(), constant(nil)]), max_length: 120)) do
        rows = Enum.with_index(values, fn value, idx -> %{id: idx, value: value} end)

        sorted_rows = Sort.sort_data(rows, :value, :asc)

        assert Enum.frequencies(sorted_rows) == Enum.frequencies(rows)
      end
    end

    property "nil column key returns data unchanged" do
      check all(
              rows <-
                list_of(
                  fixed_map(%{
                    id: integer(),
                    value: one_of([integer(), binary(), boolean(), constant(nil)])
                  }),
                  max_length: 80
                )
            ) do
        assert Sort.sort_data(rows, nil, :asc) == rows
      end
    end
  end

  describe "get_value/2 properties" do
    property "extracts same value from map and keyword rows" do
      check all(
              id <- integer(),
              value <- one_of([integer(), binary(), boolean(), constant(nil)])
            ) do
        map_row = %{id: id, value: value}
        keyword_row = [id: id, value: value]

        assert Sort.get_value(map_row, :value) == value
        assert Sort.get_value(keyword_row, :value) == value
      end
    end
  end

  defp asc_less?(nil, nil), do: false
  defp asc_less?(nil, _), do: true
  defp asc_less?(_, nil), do: false
  defp asc_less?(a, b), do: a < b

  defp desc_less?(nil, nil), do: false
  defp desc_less?(nil, _), do: false
  defp desc_less?(_, nil), do: true
  defp desc_less?(a, b), do: a > b
end
