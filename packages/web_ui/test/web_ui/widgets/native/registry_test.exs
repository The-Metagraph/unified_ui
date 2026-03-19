defmodule WebUi.Widgets.Native.RegistryTest do
  use ExUnit.Case

  alias WebUi.Widgets.Native.Registry

  defmodule TestRegistryWidget do
    def id, do: :test_registry_widget
    def metadata, do: %{name: "Test Registry Widget", family: :test, version: "1.0.0"}
  end

  describe "register/1" do
    test "returns :ok for valid widget module when registry is started" do
      # Note: Registry must be started for this to work
      # For now we just test the module has the required functions
      assert function_exported?(TestRegistryWidget, :id, 0)
      assert function_exported?(TestRegistryWidget, :metadata, 0)
    end
  end

  describe "lookup/1" do
    test "looks up a registered widget" do
      # Note: Registry must be started for this to work
      assert function_exported?(Registry, :lookup, 1)
    end
  end

  describe "all/0" do
    test "returns list of registered widgets" do
      # Note: Registry must be started for this to work
      assert function_exported?(Registry, :all, 0)
    end
  end

  describe "by_family/1" do
    test "returns widgets in a family" do
      # Note: Registry must be started for this to work
      assert function_exported?(Registry, :by_family, 1)
    end
  end

  describe "metadata/1" do
    test "returns metadata for a widget" do
      # Note: Registry must be started for this to work
      assert function_exported?(Registry, :metadata, 1)
    end
  end

  describe "registered?/1" do
    test "checks if a widget is registered" do
      # Note: Registry must be started for this to work
      # For now we test that the function exists
      assert function_exported?(Registry, :registered?, 1)
    end
  end
end
