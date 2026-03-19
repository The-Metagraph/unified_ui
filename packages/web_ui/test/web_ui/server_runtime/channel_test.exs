defmodule WebUi.ServerRuntime.ChannelTest do
  use ExUnit.Case

  alias WebUi.ServerRuntime.Channel

  describe "channel_name/0" do
    test "returns the channel name" do
      assert Channel.channel_name() == :web_ui
    end
  end

  describe "envelope/3" do
    test "creates a message envelope" do
      envelope = Channel.envelope("test_event", %{key: "value"})
      assert envelope.type == "test_event"
      assert envelope.payload == %{key: "value"}
      assert is_struct(envelope.timestamp, DateTime)
    end

    test "accepts version option" do
      envelope = Channel.envelope("test", %{}, version: "1.0.0")
      assert envelope.version == "1.0.0"
    end
  end

  describe "state_update/2" do
    test "creates a state update" do
      assigns = %{count: 5}
      checksum = "abc123"
      update = Channel.state_update(assigns, checksum)
      assert update.type == :state_update
      assert update.assigns == assigns
      assert update.checksum == checksum
    end
  end

  describe "event_result/3" do
    test "creates an event result with default status" do
      assigns = %{count: 5}
      checksum = "abc123"
      result = Channel.event_result(assigns, checksum)
      assert result.type == :event_result
      assert result.assigns == assigns
      assert result.checksum == checksum
      assert result.status == :ok
    end

    test "creates an event result with custom status" do
      result = Channel.event_result(%{}, "abc", :error)
      assert result.status == :error
    end
  end

  describe "validate_envelope/1" do
    test "validates correct envelope" do
      envelope = %{type: "event", payload: %{}}
      assert :ok = Channel.validate_envelope(envelope)
    end

    test "returns error for invalid envelope" do
      assert {:error, :invalid_envelope} = Channel.validate_envelope(%{type: "event"})
      assert {:error, :invalid_envelope} = Channel.validate_envelope(%{payload: %{}})
      assert {:error, :invalid_envelope} = Channel.validate_envelope(%{})
    end
  end

  describe "event_type/1" do
    test "extracts event type" do
      envelope = %{type: "my_event", payload: %{}}
      assert {:ok, "my_event"} = Channel.event_type(envelope)
    end

    test "returns error for missing type" do
      assert {:error, :missing_event_type} = Channel.event_type(%{payload: %{}})
    end
  end

  describe "payload/1" do
    test "extracts payload" do
      envelope = %{type: "event", payload: %{data: "value"}}
      assert {:ok, %{data: "value"}} = Channel.payload(envelope)
    end

    test "returns error for missing payload" do
      assert {:error, :missing_payload} = Channel.payload(%{type: "event"})
    end
  end
end
