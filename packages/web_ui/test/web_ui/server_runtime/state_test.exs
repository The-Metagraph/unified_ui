defmodule WebUi.ServerRuntime.StateTest do
  use ExUnit.Case

  alias WebUi.ServerRuntime.{State, Error}

  defmodule ValidScreen do
    def id, do: :test_screen
    def mount_defaults, do: %{count: 0, title: "Test"}
    def render(_assigns), do: {:safe, "<div>Test Screen</div>"}
    def event_routes, do: %{"increment" => :handle_increment}
    def frontend_schema, do: %{version: "1.0.0", fields: %{count: :integer, title: :string}}

    def handle_event(:handle_increment, _payload, assigns) do
      {:ok, %{assigns | count: assigns.count + 1}}
    end
  end

  defmodule InvalidScreen do
    def id, do: :invalid
  end

  describe "mount/2" do
    test "mounts a valid screen successfully" do
      assert {:ok, state} = State.mount(ValidScreen)
      assert state.screen == ValidScreen
      assert state.assigns.count == 0
      assert state.assigns.title == "Test"
      assert state.mode == :native
      assert is_map(state.event_routes)
      assert is_struct(state.frontend_sync)
      assert %DateTime{} = state.mounted_at
    end

    test "merges initial assigns with defaults" do
      assert {:ok, state} = State.mount(ValidScreen, assigns: %{count: 5})
      assert state.assigns.count == 5
      assert state.assigns.title == "Test"
    end

    test "accepts mode option" do
      assert {:ok, state} = State.mount(ValidScreen, mode: :canonical)
      assert state.mode == :canonical
    end

    test "returns error for invalid screen module" do
      assert {:error, %Error{} = error} = State.mount(InvalidScreen)
      assert error.reason == :invalid_screen_module
    end

    test "returns error for non-existent module" do
      assert {:error, %Error{} = error} = State.mount(NonExistentScreen)
      assert error.reason == :invalid_screen_module
    end

    test "returns error when mount_defaults is not a map" do
      defmodule BadDefaultsScreen do
        def id, do: :bad
        def mount_defaults, do: "not a map"
        def render(_), do: nil
        def event_routes, do: %{}
        def frontend_schema, do: %{version: "1.0", fields: %{}}
        def handle_event(_, _, _), do: {:ok, %{}}
      end

      assert {:error, %Error{} = error} = State.mount(BadDefaultsScreen)
      assert error.reason == :invalid_mount_defaults
    end
  end

  describe "handle_event/3" do
    setup do
      {:ok, state} = State.mount(ValidScreen)
      %{state: state}
    end

    test "handles valid events and updates state", %{state: state} do
      assert {:ok, new_state} = State.handle_event(state, "increment", %{})
      assert new_state.assigns.count == 1
      assert new_state.assigns.title == "Test"
    end

    test "returns error for unregistered event", %{state: state} do
      assert {:error, %Error{} = error} = State.handle_event(state, "unknown", %{})
      assert error.reason == :invalid_event_route
    end

    test "handles multiple sequential events", %{state: state} do
      assert {:ok, state1} = State.handle_event(state, "increment", %{})
      assert {:ok, state2} = State.handle_event(state1, "increment", %{})
      assert {:ok, state3} = State.handle_event(state2, "increment", %{})
      assert state3.assigns.count == 3
    end
  end

  describe "frontend_state/1" do
    setup do
      {:ok, state} = State.mount(ValidScreen)
      %{state: state}
    end

    test "returns frontend state for hydration", %{state: state} do
      frontend = State.frontend_state(state)
      assert is_map(frontend.schema)
      assert is_binary(frontend.version)
      assert is_map(frontend.assigns)
      assert is_binary(frontend.checksum)
    end
  end
end
