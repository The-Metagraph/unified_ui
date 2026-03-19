defmodule WebUi.FrontendRuntime.BootTest do
  use ExUnit.Case

  alias WebUi.FrontendRuntime.Boot
  alias WebUi.ServerRuntime.State

  defmodule TestScreen do
    def id, do: :test
    def mount_defaults, do: %{count: 0}
    def render(_), do: {:safe, "<div></div>"}
    def event_routes, do: %{}
    def frontend_schema, do: %{version: "1.0", fields: %{count: :integer}}
    def handle_event(_, _, _), do: {:ok, %{}}
  end

  describe "default_config/0" do
    test "returns default boot configuration" do
      config = Boot.default_config()
      assert is_binary(config.assets_path)
      assert is_binary(config.elm_module)
      assert is_boolean(config.debug_mode)
    end
  end

  describe "prepare_hydration/1" do
    test "prepares hydration state from server runtime state" do
      {:ok, state} = State.mount(TestScreen)
      hydration = Boot.prepare_hydration(state)

      assert is_map(hydration.schema)
      assert is_binary(hydration.version)
      assert is_map(hydration.assigns)
      assert is_binary(hydration.checksum)
    end
  end

  describe "elm_init_flags/1" do
    test "creates init flags for Elm" do
      hydration = %{
        schema: %{version: "1.0", fields: %{}},
        version: "1.0.0",
        assigns: %{count: 5},
        checksum: "abc123"
      }

      flags = Boot.elm_init_flags(hydration)

      assert flags.hydration == hydration
      assert is_binary(flags.timestamp)
    end
  end

  describe "validate_assets/1" do
    test "validates assets configuration" do
      config = Boot.default_config()
      assert :ok = Boot.validate_assets(config)
    end
  end
end
