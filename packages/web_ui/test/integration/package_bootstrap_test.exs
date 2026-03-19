defmodule WebUi.Integration.PackageBootstrapTest do
  use ExUnit.Case

  @moduletag :integration
  @moduletag :package_bootstrap

  alias WebUi.ServerRuntime.State
  alias WebUi.FrontendRuntime.Boot
  alias WebUi.FrontendRuntime.Bridge

  defmodule TestScreen do
    def id, do: :test
    def mount_defaults, do: %{}
    def render(_), do: {:safe, "<div></div>"}
    def event_routes, do: %{}
    def frontend_schema, do: %{version: "1.0", fields: %{}}
    def handle_event(_, _, _), do: {:ok, %{}}
  end

  describe "package bootstrap" do
    test "package loads as a web runtime library" do
      assert Code.ensure_loaded?(WebUi)
      assert Code.ensure_loaded?(WebUi.ServerRuntime)
      assert Code.ensure_loaded?(WebUi.FrontendRuntime)
      assert Code.ensure_loaded?(WebUi.Widgets)
    end

    test "package exposes Phoenix-side entrypoints" do
      # Test by actually calling the functions
      assert {:ok, _state} = State.mount(TestScreen)
      # ServerRuntime delegates work
      assert {:ok, _state} = WebUi.ServerRuntime.mount(TestScreen)
    end

    test "package exposes Elm-side entrypoints" do
      # Test by actually calling the functions
      config = Boot.default_config()
      assert is_map(config)
      message = Bridge.outbound("test", %{})
      assert is_map(message)
    end

    test "package does not take over application startup" do
      # web_ui should be a library, not an application
      assert :ok = Application.ensure_started(:web_ui)
    end
  end

  describe "split runtime wiring" do
    test "server runtime is properly configured" do
      # Test by actually mounting a screen
      assert {:ok, state} = State.mount(TestScreen)
      assert is_struct(state)
    end

    test "frontend runtime is properly configured" do
      # Test by preparing hydration
      {:ok, state} = State.mount(TestScreen)
      hydration = Boot.prepare_hydration(state)
      assert is_map(hydration)
    end

    test "transport layer is properly configured" do
      # Test by creating outbound message
      message = Bridge.outbound("test", %{key: "value"})
      assert message.type == "test"
      assert is_binary(message.timestamp)
    end
  end
end
