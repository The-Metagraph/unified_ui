defmodule WebUi.ServerRuntime.ErrorTest do
  use ExUnit.Case

  alias WebUi.ServerRuntime.Error

  describe "error creation" do
    test "creates invalid_screen_module error" do
      error = Error.invalid_screen_module(MyScreen)
      assert error.reason == :invalid_screen_module
      assert is_binary(error.message)
      # inspect/1 returns the module name as a string
      assert String.contains?(error.details.screen, "MyScreen")
    end

    test "creates invalid_mount_defaults error" do
      error = Error.invalid_mount_defaults(MyScreen)
      assert error.reason == :invalid_mount_defaults
      assert is_binary(error.message)
    end

    test "creates invalid_event_route error" do
      error = Error.invalid_event_route(MyScreen, "unknown_event")
      assert error.reason == :invalid_event_route
      assert error.details.event == "unknown_event"
    end

    test "creates invalid_event_result error" do
      error = Error.invalid_event_result(MyScreen, :my_route, :bad_result)
      assert error.reason == :invalid_event_result
      assert error.details.route == :my_route
    end

    test "creates hydration_failed error" do
      error = Error.hydration_failed(MyScreen, :bad_data)
      assert error.reason == :hydration_failed
      # inspect/1 converts atoms to their string representation
      assert error.details.reason == ":bad_data"
    end

    test "creates sync_mismatch error" do
      error = Error.sync_mismatch(MyScreen, :checksum, "abc123", "xyz789")
      assert error.reason == :sync_mismatch
      assert error.details.field == :checksum
    end
  end

  describe "exception behaviour" do
    test "can be raised and rescued" do
      assert_raise Error, "screen module does not satisfy the WebUi.ServerRuntime.Screen contract", fn ->
        raise Error.invalid_screen_module(BadScreen)
      end
    end

    test "exception message is descriptive" do
      error = Error.invalid_screen_module(MyScreen)
      assert String.contains?(error.message, "screen module")
    end
  end
end
