defmodule WebUi.FrontendRuntime.BridgeTest do
  use ExUnit.Case

  alias WebUi.FrontendRuntime.Bridge

  describe "outbound/2" do
    test "creates outbound message" do
      message = Bridge.outbound("click", %{x: 10, y: 20})

      assert message.type == "click"
      assert message.payload == %{x: 10, y: 20}
      assert is_binary(message.timestamp)
    end
  end

  describe "validate_outbound/1" do
    test "validates correct outbound message" do
      message = %{type: "click", payload: %{x: 10}}
      assert :ok = Bridge.validate_outbound(message)
    end

    test "returns error for invalid type" do
      message = %{type: nil, payload: %{}}
      assert {:error, :invalid_outbound_message} = Bridge.validate_outbound(message)
    end

    test "returns error for invalid payload" do
      message = %{type: "click", payload: "not a map"}
      assert {:error, :invalid_outbound_message} = Bridge.validate_outbound(message)
    end
  end

  describe "serialize_outbound/1" do
    test "serializes outbound message to JSON" do
      message = Bridge.outbound("test", %{key: "value"})
      assert {:ok, json} = Bridge.serialize_outbound(message)
      assert is_binary(json)
      assert String.contains?(json, "test")
    end
  end

  describe "deserialize_inbound/1" do
    test "deserializes state update message" do
      json = ~s({"type":"state_update","data":{"count":5},"checksum":"abc123"})
      assert {:ok, inbound} = Bridge.deserialize_inbound(json)
      assert inbound.type == :state_update
      assert inbound.data == %{"count" => 5}
      assert inbound.checksum == "abc123"
    end

    test "deserializes event result message" do
      json = ~s({"type":"event_result","data":{},"checksum":"xyz"})
      assert {:ok, inbound} = Bridge.deserialize_inbound(json)
      assert inbound.type == :event_result
    end

    test "returns error for invalid JSON" do
      assert {:error, :invalid_inbound_message} = Bridge.deserialize_inbound("not json")
    end

    test "returns error for missing keys" do
      json = ~s({"type":"state_update"})
      assert {:error, :invalid_inbound_message} = Bridge.deserialize_inbound(json)
    end
  end

  describe "validate_checksum/2" do
    test "validates matching checksums" do
      assert :ok = Bridge.validate_checksum("abc123", "abc123")
    end

    test "returns error for mismatched checksums" do
      assert {:error, :checksum_mismatch} = Bridge.validate_checksum("abc123", "xyz789")
    end
  end
end
