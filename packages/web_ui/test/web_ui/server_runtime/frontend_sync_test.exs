defmodule WebUi.ServerRuntime.FrontendSyncTest do
  use ExUnit.Case

  alias WebUi.ServerRuntime.FrontendSync
  alias WebUi.ServerRuntime.Error

  defmodule ValidSchemaScreen do
    def frontend_schema do
      %{
        version: "1.0.0",
        fields: %{
          count: %{type: :integer},
          title: %{type: :string}
        }
      }
    end
  end

  defmodule InvalidSchemaScreen do
    def frontend_schema, do: "not a map"
  end

  defmodule MissingFieldsSchemaScreen do
    def frontend_schema, do: %{version: "1.0.0"}
  end

  describe "build/2" do
    test "builds sync from valid schema" do
      assigns = %{count: 0, title: "Test"}
      assert {:ok, sync} = FrontendSync.build(ValidSchemaScreen, assigns)
      assert is_map(sync.schema)
      assert is_binary(sync.version)
      assert is_binary(sync.checksum)
    end

    test "returns error for invalid schema" do
      assigns = %{}
      assert {:error, %Error{} = error} = FrontendSync.build(InvalidSchemaScreen, assigns)
      assert error.reason == :invalid_frontend_schema
    end

    test "returns error for schema missing required keys" do
      assigns = %{}
      assert {:error, %Error{} = error} = FrontendSync.build(MissingFieldsSchemaScreen, assigns)
      assert error.reason == :invalid_frontend_schema
    end

    test "returns error when assigns have keys not in schema" do
      assigns = %{count: 0, unknown_field: "value"}
      assert {:error, %Error{} = error} = FrontendSync.build(ValidSchemaScreen, assigns)
      assert error.reason == :hydration_failed
    end
  end

  describe "to_map/2" do
    setup do
      assigns = %{count: 5, title: "Test"}
      {:ok, sync} = FrontendSync.build(ValidSchemaScreen, assigns)
      %{sync: sync, assigns: assigns}
    end

    test "converts sync to map for Elm", %{sync: sync, assigns: assigns} do
      result = FrontendSync.to_map(sync, assigns)
      assert is_map(result.schema)
      assert is_binary(result.version)
      assert is_map(result.assigns)
      assert is_binary(result.checksum)
      assert result.assigns.count == 5
      assert result.assigns.title == "Test"
    end

    test "filters assigns by schema", %{sync: sync} do
      extra_assigns = %{count: 5, title: "Test", extra: "ignored"}
      result = FrontendSync.to_map(sync, extra_assigns)
      refute Map.has_key?(result.assigns, :extra)
    end
  end

  describe "update/2" do
    setup do
      assigns = %{count: 0, title: "Test"}
      {:ok, sync} = FrontendSync.build(ValidSchemaScreen, assigns)
      %{sync: sync}
    end

    test "updates checksum on state change", %{sync: sync} do
      new_assigns = %{count: 1, title: "Test"}
      updated = FrontendSync.update(sync, new_assigns)
      assert updated.checksum != sync.checksum
    end
  end

  describe "validate_sync/2" do
    setup do
      assigns = %{count: 0, title: "Test"}
      {:ok, sync} = FrontendSync.build(ValidSchemaScreen, assigns)
      %{sync: sync}
    end

    test "validates matching checksum", %{sync: sync} do
      frontend_state = %{checksum: sync.checksum}
      assert :ok = FrontendSync.validate_sync(sync, frontend_state)
    end

    test "returns error for missing checksum", %{sync: sync} do
      assert {:error, %Error{}} = FrontendSync.validate_sync(sync, %{})
    end

    test "returns error for mismatched checksum", %{sync: sync} do
      frontend_state = %{checksum: "wrong"}
      assert {:error, %Error{} = error} = FrontendSync.validate_sync(sync, frontend_state)
      assert error.reason == :sync_mismatch
    end
  end
end
