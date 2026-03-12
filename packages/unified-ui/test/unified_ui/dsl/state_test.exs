defmodule UnifiedUi.Dsl.StateTest do
  @moduledoc """
  Tests for the UnifiedUi.Dsl.State struct.
  """

  use ExUnit.Case, async: true

  alias UnifiedUi.Dsl.State

  describe "State struct" do
    test "can be created with struct/0" do
      assert %State{} = %State{}
    end

    test "can be created with struct/1 and attributes" do
      assert %State{attrs: [count: 0]} = %State{attrs: [count: 0]}
    end

    test "can be created with struct!/2" do
      assert %State{attrs: [name: "test"]} = struct!(State, attrs: [name: "test"])
    end

    test "attrs defaults to nil" do
      assert %State{attrs: nil} = %State{}
    end

    test "can hold empty list of attributes" do
      assert %State{attrs: []} = %State{attrs: []}
    end

    test "can hold various attribute types" do
      state = %State{attrs: [count: 0, name: "test", active: true, value: 3.14]}
      assert state.attrs == [count: 0, name: "test", active: true, value: 3.14]
    end

    test "can hold nested attributes" do
      state = %State{attrs: [user: [name: "John", age: 30]]}
      assert state.attrs == [user: [name: "John", age: 30]]
    end

    test "can hold atom keys in attributes" do
      state = %State{attrs: [count: 1, total: 100]}
      assert Keyword.get(state.attrs, :count) == 1
      assert Keyword.get(state.attrs, :total) == 100
    end

    test "pattern matching works on State struct" do
      state = %State{attrs: [count: 5]}

      case state do
        %State{attrs: attrs} when is_list(attrs) ->
          assert attrs == [count: 5]

        _ ->
          flunk("Pattern match failed")
      end
    end
  end

  describe "State integration with DSL" do
    test "State struct can be used in DSL context" do
      # Simulate what the DSL would create
      state_entity = %State{attrs: [counter: 0, text: "Hello"]}

      assert is_list(state_entity.attrs)
      assert Keyword.has_key?(state_entity.attrs, :counter)
      assert Keyword.has_key?(state_entity.attrs, :text)
    end

    test "State can be converted to map for Elm Architecture" do
      state = %State{attrs: [count: 0, name: "Test", items: []]}
      state_map = Enum.into(state.attrs, %{})

      assert state_map == %{count: 0, name: "Test", items: []}
    end
  end
end
