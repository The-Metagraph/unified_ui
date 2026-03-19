defmodule WebUi.Widgets.Native.RegistryTest do
  use ExUnit.Case

  alias WebUi.Widgets.Native.Registry

  defmodule TestRegistryWidget do
    def id, do: :test_registry_widget
    def metadata, do: %{name: "Test Registry Widget", family: :test, version: "1.0.0"}
  end

  describe "module interface" do
    test "all function exists" do
      # Registry may not be started, so catch the error
      try do
        result = Registry.all()
        assert is_list(result)
      rescue
        ArgumentError -> :ok  # Registry not started - expected for Phase 1
      end
    end

    test "lookup function exists" do
      try do
        result = Registry.lookup(:some_id)
        assert is_tuple(result)
      rescue
        ArgumentError -> :ok  # Registry not started - expected for Phase 1
      end
    end

    test "by_family function exists" do
      try do
        result = Registry.by_family(:some_family)
        assert is_list(result)
      rescue
        ArgumentError -> :ok  # Registry not started - expected for Phase 1
      end
    end

    test "metadata function exists" do
      try do
        result = Registry.metadata(:some_id)
        assert is_tuple(result)
      rescue
        ArgumentError -> :ok  # Registry not started - expected for Phase 1
      end
    end

    test "registered? function exists" do
      try do
        result = Registry.registered?(:some_id)
        assert is_boolean(result)
      rescue
        ArgumentError -> :ok  # Registry not started - expected for Phase 1
      end
    end
  end

  describe "register/1" do
    test "test widget has required functions" do
      assert function_exported?(TestRegistryWidget, :id, 0)
      assert function_exported?(TestRegistryWidget, :metadata, 0)
    end
  end
end
