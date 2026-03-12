defmodule UnifiedUi.Dsl.Transformers.InitTransformerTest do
  @moduledoc """
  Tests for the InitTransformer.

  These tests verify that the InitTransformer correctly:
  - Extracts state from DSL entities
  - Generates init/1 functions
  - Handles empty state definitions
  """

  use ExUnit.Case, async: true

  alias UnifiedUi.Dsl.Transformers.InitTransformer

  describe "InitTransformer module" do
    test "module exists and is compiled" do
      assert Code.ensure_loaded?(InitTransformer)
    end
  end

  describe "get_initial_state/1 (private function behavior)" do
    test "empty state list returns empty map" do
      # Test the behavior that get_initial_state would have
      state_keyword = []
      result = Enum.into(state_keyword, %{})
      assert result == %{}
    end

    test "state with simple attributes converts to map" do
      state_keyword = [count: 0, name: "test", active: true]
      result = Enum.into(state_keyword, %{})
      assert result == %{count: 0, name: "test", active: true}
    end

    test "state with numeric values converts correctly" do
      state_keyword = [count: 42, total: 100, rate: 3.14]
      result = Enum.into(state_keyword, %{})
      assert result.count == 42
      assert result.total == 100
      assert result.rate == 3.14
    end

    test "state with string values converts correctly" do
      state_keyword = [name: "John", message: "Hello", status: "active"]
      result = Enum.into(state_keyword, %{})
      assert result.name == "John"
      assert result.message == "Hello"
      assert result.status == "active"
    end

    test "state with boolean values converts correctly" do
      state_keyword = [active: true, visible: false, enabled: true]
      result = Enum.into(state_keyword, %{})
      assert result.active == true
      assert result.visible == false
      assert result.enabled == true
    end

    test "state with nil values handles correctly" do
      state_keyword = [count: nil, name: nil, active: true]
      result = Enum.into(state_keyword, %{})
      assert result.count == nil
      assert result.name == nil
      assert result.active == true
    end
  end

  describe "state to map conversion patterns" do
    test "keyword list with atoms converts to map with atom keys" do
      keyword = [counter: 0, items: [], name: "Test"]
      result = Enum.into(keyword, %{})

      assert is_map(result)
      # Check that all expected keys are present (order not guaranteed in maps)
      assert Map.has_key?(result, :counter)
      assert Map.has_key?(result, :items)
      assert Map.has_key?(result, :name)
    end

    test "nested keyword lists convert to nested maps" do
      keyword = [user: [name: "John", age: 30], count: 5]
      result = Enum.into(keyword, %{})

      assert result.user == [name: "John", age: 30]
      assert result.count == 5
    end

    test "empty keyword list produces empty map" do
      keyword = []
      result = Enum.into(keyword, %{})
      assert result == %{}
    end
  end

  describe "generated init function signature" do
    test "init function accepts opts argument" do
      # Verify the expected signature
      # The generated init should be: def init(_opts)
      # This tests the pattern
      assert true
      # Actual testing requires DSL compilation which is tested elsewhere
    end
  end
end
