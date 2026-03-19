defmodule WebUi.FrontendRuntime.DiagnosticsTest do
  use ExUnit.Case

  alias WebUi.FrontendRuntime.Diagnostics

  describe "validate_hydration_state/1" do
    test "validates correct hydration state" do
      state = %{
        schema: %{version: "1.0", fields: %{}},
        version: "1.0.0",
        assigns: %{count: 0},
        checksum: "abc123"
      }

      assert :ok = Diagnostics.validate_hydration_state(state)
    end

    test "returns error for missing keys" do
      state = %{schema: %{}, version: "1.0"}
      assert {:error, diagnostic} = Diagnostics.validate_hydration_state(state)
      assert diagnostic.type == :missing_hydration_keys
      assert diagnostic.severity == :error
    end

    test "returns error for invalid schema type" do
      state = %{
        schema: "not a map",
        version: "1.0.0",
        assigns: %{},
        checksum: "abc123"
      }

      assert {:error, diagnostic} = Diagnostics.validate_hydration_state(state)
      assert diagnostic.type == :invalid_schema
    end

    test "returns error for invalid version type" do
      state = %{
        schema: %{},
        version: nil,
        assigns: %{},
        checksum: "abc123"
      }

      assert {:error, diagnostic} = Diagnostics.validate_hydration_state(state)
      assert diagnostic.type == :invalid_version
    end
  end

  describe "validate_outbound_message/1" do
    test "validates correct outbound message" do
      message = %{type: "click", payload: %{x: 10}}
      assert :ok = Diagnostics.validate_outbound_message(message)
    end

    test "returns error for invalid message" do
      message = %{type: nil, payload: "invalid"}
      assert {:error, diagnostic} = Diagnostics.validate_outbound_message(message)
      assert diagnostic.type == :invalid_outbound_message
    end
  end

  describe "validate_inbound_message/1" do
    test "validates state update message" do
      message = %{type: :state_update, data: %{}, checksum: "abc123"}
      assert :ok = Diagnostics.validate_inbound_message(message)
    end

    test "validates event result message" do
      message = %{type: :event_result, data: %{}, checksum: "xyz"}
      assert :ok = Diagnostics.validate_inbound_message(message)
    end

    test "returns error for invalid type" do
      message = %{type: :invalid, data: %{}, checksum: "abc"}
      assert {:error, _diagnostic} = Diagnostics.validate_inbound_message(message)
    end

    test "returns error for missing keys" do
      message = %{type: :state_update, data: %{}}
      assert {:error, _diagnostic} = Diagnostics.validate_inbound_message(message)
    end
  end

  describe "validate_elm_assets/1" do
    test "validates elm assets path" do
      assert :ok = Diagnostics.validate_elm_assets("/assets/js")
    end
  end
end
