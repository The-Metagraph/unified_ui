defmodule WebUi.Transport.NamingTest do
  use ExUnit.Case, async: true

  alias WebUi.Transport.Naming
  alias WebUi.TypedError

  describe "validate_topic/1" do
    test "accepts canonical default topic" do
      assert :ok == Naming.validate_topic("webui:runtime:v1")
    end

    test "accepts canonical session topic" do
      assert :ok == Naming.validate_topic("webui:runtime:session:session_123:v1")
    end

    test "rejects unknown topic" do
      assert {:error, %TypedError{} = error} = Naming.validate_topic("webui:runtime:v2")
      assert error.error_code == "transport.invalid_topic"
      assert error.category == "protocol"
    end
  end

  describe "validate_client_event_name/1" do
    test "accepts canonical client event names" do
      assert :ok == Naming.validate_client_event_name("runtime.event.send.v1")
      assert :ok == Naming.validate_client_event_name("runtime.event.ping.v1")
    end

    test "rejects unknown client event names" do
      assert {:error, %TypedError{} = error} = Naming.validate_client_event_name("runtime.event.recv.v1")
      assert error.error_code == "transport.unknown_client_event"
    end
  end

  describe "validate_server_event_name/1" do
    test "accepts canonical server event names" do
      assert :ok == Naming.validate_server_event_name("runtime.event.recv.v1")
      assert :ok == Naming.validate_server_event_name("runtime.event.error.v1")
      assert :ok == Naming.validate_server_event_name("runtime.event.pong.v1")
    end

    test "rejects unknown server event names" do
      assert {:error, %TypedError{} = error} = Naming.validate_server_event_name("runtime.event.send.v1")
      assert error.error_code == "transport.unknown_server_event"
    end
  end
end
