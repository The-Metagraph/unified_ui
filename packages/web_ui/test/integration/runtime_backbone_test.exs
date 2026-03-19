defmodule WebUi.Integration.RuntimeBackboneTest do
  use ExUnit.Case

  @moduletag :integration
  @moduletag :runtime_backbone

  alias WebUi.ServerRuntime.State

  defmodule MinimalScreen do
    def id, do: :minimal_screen
    def mount_defaults, do: %{value: "test"}
    def render(_assigns), do: {:safe, "<div>Test</div>"}
    def event_routes, do: %{"test_event" => :handle_test}
    def frontend_schema, do: %{version: "1.0", fields: %{value: :string}}

    def handle_event(:handle_test, _payload, assigns) do
      {:ok, assigns}
    end
  end

  describe "native screen mounting" do
    test "a minimal native screen can mount" do
      assert {:ok, state} = State.mount(MinimalScreen)
      assert state.screen == MinimalScreen
      assert state.assigns.value == "test"
      assert is_struct(state.frontend_sync)
    end

    test "a screen can initialize with custom assigns" do
      assert {:ok, state} = State.mount(MinimalScreen, assigns: %{value: "custom"})
      assert state.assigns.value == "custom"
    end
  end

  describe "frontend hydration" do
    test "a mounted screen can generate frontend state" do
      {:ok, state} = State.mount(MinimalScreen)
      frontend = State.frontend_state(state)

      assert is_map(frontend.schema)
      assert is_binary(frontend.version)
      assert is_map(frontend.assigns)
      assert is_binary(frontend.checksum)
    end

    test "frontend state includes assigns for hydration" do
      {:ok, state} = State.mount(MinimalScreen)
      frontend = State.frontend_state(state)

      assert frontend.assigns.value == "test"
    end
  end

  describe "event handling" do
    test "a screen can handle registered events" do
      {:ok, state} = State.mount(MinimalScreen)
      assert {:ok, _new_state} = State.handle_event(state, "test_event", %{})
    end

    test "a screen rejects unregistered events" do
      {:ok, state} = State.mount(MinimalScreen)
      assert {:error, _} = State.handle_event(state, "unknown_event", %{})
    end
  end

  describe "deterministic diagnostics" do
    test "malformed widget declarations fail with deterministic diagnostics" do
      # Invalid screen module
      assert {:error, error} = State.mount(InvalidScreen)
      assert error.reason == :invalid_screen_module
    end

    test "malformed hydration payloads are detected" do
      # Invalid schema
      assert {:error, error} = State.mount(BadSchemaScreen)
      assert error.reason == :invalid_frontend_schema
    end

    test "invalid runtime wiring fails with clear error messages" do
      {:ok, state} = State.mount(MinimalScreen)

      # Invalid event route
      assert {:error, error} = State.handle_event(state, "nonexistent", %{})
      assert error.reason == :invalid_event_route
      assert String.contains?(error.message, "not registered")
    end
  end
end

defmodule InvalidScreen do
  def id, do: :invalid
end

defmodule BadSchemaScreen do
  def id, do: :bad_schema
  def mount_defaults, do: %{}
  def render(_), do: {:safe, "<div></div>"}
  def event_routes, do: %{}
  def frontend_schema, do: "invalid"
  def handle_event(_, _, _), do: {:ok, %{}}
end
