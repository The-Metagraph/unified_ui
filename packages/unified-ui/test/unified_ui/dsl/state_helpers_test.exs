defmodule UnifiedUi.Dsl.StateHelpersTest do
  @moduledoc """
  Tests for the StateHelpers module.

  These tests verify that state update helper functions correctly
  generate update maps for common state mutation patterns.
  """

  use ExUnit.Case, async: true

  alias UnifiedUi.Dsl.StateHelpers

  describe "increment/2" do
    test "increments a positive integer" do
      state = %{count: 5}
      result = StateHelpers.increment(:count, state)
      assert result == %{count: 6}
    end

    test "increments from zero" do
      state = %{count: 0}
      result = StateHelpers.increment(:count, state)
      assert result == %{count: 1}
    end

    test "increments a negative integer" do
      state = %{count: -5}
      result = StateHelpers.increment(:count, state)
      assert result == %{count: -4}
    end

    test "increments a float" do
      state = %{rate: 3.14}
      result = StateHelpers.increment(:rate, state)
      # Use approximate comparison for floating point
      assert_in_delta result.rate, 4.14, 0.0001
    end

    test "defaults to 0 when key is missing in state" do
      state = %{other: 5}
      result = StateHelpers.increment(:missing, state)
      assert result == %{missing: 1}
    end

    test "increments multiple keys separately" do
      state = %{count: 1, total: 10}
      count_result = StateHelpers.increment(:count, state)
      total_result = StateHelpers.increment(:total, state)

      assert count_result == %{count: 2}
      assert total_result == %{total: 11}
    end
  end

  describe "increment_by/3" do
    test "increments by positive amount" do
      state = %{count: 5}
      result = StateHelpers.increment_by(:count, 5, state)
      assert result == %{count: 10}
    end

    test "increments by negative amount" do
      state = %{count: 10}
      result = StateHelpers.increment_by(:count, -3, state)
      assert result == %{count: 7}
    end

    test "increments by zero" do
      state = %{count: 5}
      result = StateHelpers.increment_by(:count, 0, state)
      assert result == %{count: 5}
    end

    test "increments float by fractional amount" do
      state = %{rate: 3.5}
      result = StateHelpers.increment_by(:rate, 0.5, state)
      assert result == %{rate: 4.0}
    end

    test "defaults to 0 when key is missing" do
      state = %{other: 5}
      result = StateHelpers.increment_by(:missing, 10, state)
      assert result == %{missing: 10}
    end
  end

  describe "toggle/2" do
    test "toggles false to true" do
      state = %{active: false}
      result = StateHelpers.toggle(:active, state)
      assert result == %{active: true}
    end

    test "toggles true to false" do
      state = %{active: true}
      result = StateHelpers.toggle(:active, state)
      assert result == %{active: false}
    end

    test "defaults to false when key is missing" do
      state = %{other: true}
      result = StateHelpers.toggle(:missing, state)
      assert result == %{missing: true}
    end

    test "toggles multiple keys independently" do
      state = %{visible: false, enabled: true}
      visible_result = StateHelpers.toggle(:visible, state)
      enabled_result = StateHelpers.toggle(:enabled, state)

      assert visible_result == %{visible: true}
      assert enabled_result == %{enabled: false}
    end

    test "can toggle the same key twice to get original value" do
      state = %{active: true}
      first_toggle = StateHelpers.toggle(:active, state)
      second_toggle = StateHelpers.toggle(:active, Map.merge(state, first_toggle))

      assert second_toggle == %{active: true}
    end
  end

  describe "set/3" do
    test "sets a new value" do
      state = %{count: 5}
      result = StateHelpers.set(:count, 10, state)
      assert result == %{count: 10}
    end

    test "sets a string value" do
      state = %{}
      result = StateHelpers.set(:email, "test@example.com", state)
      assert result == %{email: "test@example.com"}
    end

    test "sets a nil value" do
      state = %{error: "Something went wrong"}
      result = StateHelpers.set(:error, nil, state)
      assert result == %{error: nil}
    end

    test "sets a list value" do
      state = %{}
      result = StateHelpers.set(:items, [:a, :b, :c], state)
      assert result == %{items: [:a, :b, :c]}
    end

    test "sets a map value" do
      state = %{}
      user = %{name: "John", age: 30}
      result = StateHelpers.set(:user, user, state)
      assert result == %{user: user}
    end

    test "replaces existing value with different type" do
      state = %{count: 5}
      result = StateHelpers.set(:count, "not a number", state)
      assert result == %{count: "not a number"}
    end
  end

  describe "apply_update/3" do
    test "applies function to numeric value" do
      state = %{count: 5}
      result = StateHelpers.apply_update(:count, &(&1 * 2), state)
      assert result == %{count: 10}
    end

    test "applies function to string value" do
      state = %{name: "john"}
      result = StateHelpers.apply_update(:name, &String.upcase/1, state)
      assert result == %{name: "JOHN"}
    end

    test "applies function to list value" do
      state = %{items: [1, 2, 3]}
      result = StateHelpers.apply_update(:items, &Enum.reverse/1, state)
      assert result == %{items: [3, 2, 1]}
    end

    test "applies anonymous function" do
      state = %{value: 10}
      result = StateHelpers.apply_update(:value, fn x -> x * x + 5 end, state)
      assert result == %{value: 105}
    end

    test "handles missing key with nil" do
      state = %{other: 5}
      # When key is missing, Map.get returns nil, and the function must handle it
      # Using a function that handles nil gracefully
      result = StateHelpers.apply_update(:missing, fn x -> (is_nil(x) && 0) || x + 1 end, state)
      assert result == %{missing: 0}
    end
  end

  describe "merge_updates/2" do
    test "merges updates into state" do
      state = %{count: 5, active: false, name: "test"}
      updates = %{count: 6, active: true}
      result = StateHelpers.merge_updates(state, updates)
      assert result == %{count: 6, active: true, name: "test"}
    end

    test "handles empty updates" do
      state = %{count: 5}
      updates = %{}
      result = StateHelpers.merge_updates(state, updates)
      assert result == %{count: 5}
    end

    test "handles new keys" do
      state = %{count: 5}
      updates = %{new_key: "value"}
      result = StateHelpers.merge_updates(state, updates)
      assert result == %{count: 5, new_key: "value"}
    end

    test "updates override existing values" do
      state = %{a: 1, b: 2}
      updates = %{a: 10, b: 20, c: 30}
      result = StateHelpers.merge_updates(state, updates)
      assert result == %{a: 10, b: 20, c: 30}
    end
  end

  describe "clear/2" do
    test "clears a key to nil" do
      state = %{error: "Something went wrong"}
      result = StateHelpers.clear(:error, state)
      assert result == %{error: nil}
    end

    test "clears numeric value" do
      state = %{count: 5}
      result = StateHelpers.clear(:count, state)
      assert result == %{count: nil}
    end

    test "clears boolean value" do
      state = %{active: true}
      result = StateHelpers.clear(:active, state)
      assert result == %{active: nil}
    end

    test "clears list value" do
      state = %{items: [:a, :b]}
      result = StateHelpers.clear(:items, state)
      assert result == %{items: nil}
    end
  end

  describe "append/3" do
    test "appends to existing list" do
      state = %{items: [:a, :b]}
      result = StateHelpers.append(:items, :c, state)
      assert result == %{items: [:a, :b, :c]}
    end

    test "creates new list when key is missing" do
      state = %{}
      result = StateHelpers.append(:items, :first, state)
      assert result == %{items: [:first]}
    end

    test "appends to nil key by creating new list" do
      state = %{items: nil}
      result = StateHelpers.append(:items, :first, state)
      assert result == %{items: [:first]}
    end

    test "appends multiple items" do
      state = %{items: [1]}
      result = StateHelpers.append(:items, 2, state)
      result2 = StateHelpers.append(:items, 3, Map.merge(state, result))
      assert result2 == %{items: [1, 2, 3]}
    end

    test "appends different types" do
      state = %{items: ["text"]}
      result = StateHelpers.append(:items, 42, state)
      assert result == %{items: ["text", 42]}
    end
  end

  describe "remove/3" do
    test "removes existing item from list" do
      state = %{items: [:a, :b, :c]}
      result = StateHelpers.remove(:items, :b, state)
      assert result == %{items: [:a, :c]}
    end

    test "removes only first occurrence" do
      state = %{items: [:a, :b, :b, :c]}
      result = StateHelpers.remove(:items, :b, state)
      assert result == %{items: [:a, :b, :c]}
    end

    test "handles non-existent item" do
      state = %{items: [:a, :b]}
      result = StateHelpers.remove(:items, :missing, state)
      assert result == %{items: [:a, :b]}
    end

    test "handles missing key" do
      state = %{}
      result = StateHelpers.remove(:items, :anything, state)
      assert result == %{items: []}
    end

    test "handles nil key" do
      state = %{items: nil}
      result = StateHelpers.remove(:items, :anything, state)
      assert result == %{items: []}
    end
  end

  describe "integration scenarios" do
    test "can increment and merge" do
      state = %{count: 5, name: "test"}
      update = StateHelpers.increment(:count, state)
      new_state = StateHelpers.merge_updates(state, update)
      assert new_state == %{count: 6, name: "test"}
    end

    test "can toggle and merge" do
      state = %{active: true, count: 5}
      update = StateHelpers.toggle(:active, state)
      new_state = StateHelpers.merge_updates(state, update)
      assert new_state == %{active: false, count: 5}
    end

    test "can set multiple values and merge" do
      state = %{a: 1}
      update1 = StateHelpers.set(:b, 2, state)
      update2 = StateHelpers.set(:c, 3, state)

      new_state =
        StateHelpers.merge_updates(state, update1) |> StateHelpers.merge_updates(update2)

      assert new_state == %{a: 1, b: 2, c: 3}
    end

    test "can append and remove from list" do
      state = %{items: [:a, :b]}
      append_update = StateHelpers.append(:items, :c, state)
      state_with_append = StateHelpers.merge_updates(state, append_update)

      remove_update = StateHelpers.remove(:items, :b, state_with_append)
      final_state = StateHelpers.merge_updates(state_with_append, remove_update)

      assert final_state == %{items: [:a, :c]}
    end

    test "can combine multiple operations" do
      state = %{count: 0, active: false, items: []}

      # Increment count
      state = StateHelpers.merge_updates(state, StateHelpers.increment(:count, state))

      # Toggle active
      state = StateHelpers.merge_updates(state, StateHelpers.toggle(:active, state))

      # Append to items
      state = StateHelpers.merge_updates(state, StateHelpers.append(:items, :first, state))

      assert state == %{count: 1, active: true, items: [:first]}
    end
  end
end
