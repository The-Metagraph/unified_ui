defmodule WebUi.ServerRuntime.BrowserBridgeTest do
  use ExUnit.Case

  alias WebUi.ServerRuntime.BrowserBridge

  describe "supported_hooks/0" do
    test "returns list of supported hooks" do
      hooks = BrowserBridge.supported_hooks()
      assert :resize_observer in hooks
      assert :viewport_measurement in hooks
      assert :scroll_tracking in hooks
      assert :form_interaction in hooks
      assert :navigation in hooks
    end
  end

  describe "init/1" do
    test "initializes bridge state with defaults" do
      state = BrowserBridge.init()
      assert is_list(state.hooks)
      assert is_struct(state.enabled_features, MapSet)
      assert is_nil(state.sync_interval)
    end

    test "accepts hooks option" do
      state = BrowserBridge.init(hooks: [:resize_observer, :scroll_tracking])
      assert :resize_observer in state.hooks
      assert :scroll_tracking in state.hooks
    end

    test "accepts enabled_features option" do
      state = BrowserBridge.init(enabled_features: [:feature_a, :feature_b])
      assert BrowserBridge.feature_enabled?(state, :feature_a)
      assert BrowserBridge.feature_enabled?(state, :feature_b)
      refute BrowserBridge.feature_enabled?(state, :feature_c)
    end

    test "accepts sync_interval option" do
      state = BrowserBridge.init(sync_interval: 1000)
      assert state.sync_interval == 1000
    end
  end

  describe "normalize_hooks/1" do
    test "removes duplicates" do
      hooks = [:resize_observer, :resize_observer, :scroll_tracking]
      normalized = BrowserBridge.normalize_hooks(hooks)
      assert length(normalized) == 2
    end

    test "filters unsupported hooks" do
      hooks = [:resize_observer, :unknown_hook, :scroll_tracking]
      normalized = BrowserBridge.normalize_hooks(hooks)
      refute :unknown_hook in normalized
      assert :resize_observer in normalized
    end
  end

  describe "supported?/1" do
    test "returns true for supported hooks" do
      assert BrowserBridge.supported?(:resize_observer)
      assert BrowserBridge.supported?(:navigation)
    end

    test "returns false for unsupported hooks" do
      refute BrowserBridge.supported?(:unknown_hook)
      refute BrowserBridge.supported?(nil)
    end
  end

  describe "authoritative?/0" do
    test "always returns true for server-authoritative runtime" do
      assert BrowserBridge.authoritative?() == true
    end
  end

  describe "normalize_browser_event/3" do
    setup do
      %{bridge_state: BrowserBridge.init()}
    end

    test "normalizes valid browser event", %{bridge_state: bridge_state} do
      assert {:ok, envelope} = BrowserBridge.normalize_browser_event("click", %{x: 10, y: 20}, bridge_state)
      assert envelope.type == "click"
      assert envelope.payload == %{x: 10, y: 20}
    end

    test "returns error for invalid event type", %{bridge_state: bridge_state} do
      assert {:error, _} = BrowserBridge.normalize_browser_event(nil, %{}, bridge_state)
    end

    test "returns error for invalid payload", %{bridge_state: bridge_state} do
      assert {:error, _} = BrowserBridge.normalize_browser_event("click", nil, bridge_state)
    end
  end

  describe "validate_state/1" do
    test "validates correct bridge state" do
      state = BrowserBridge.init()
      assert :ok = BrowserBridge.validate_state(state)
    end

    test "returns error for invalid state" do
      assert {:error, :invalid_bridge_state} = BrowserBridge.validate_state(%{})
      assert {:error, :invalid_bridge_state} = BrowserBridge.validate_state(%{hooks: "not a list"})
    end
  end

  describe "feature_enabled?/2" do
    test "checks if feature is enabled" do
      state = BrowserBridge.init(enabled_features: [:feature_a])
      assert BrowserBridge.feature_enabled?(state, :feature_a)
      refute BrowserBridge.feature_enabled?(state, :feature_b)
    end
  end

  describe "enable_feature/2" do
    test "enables a feature" do
      state = BrowserBridge.init()
      updated = BrowserBridge.enable_feature(state, :new_feature)
      assert BrowserBridge.feature_enabled?(updated, :new_feature)
    end
  end

  describe "disable_feature/2" do
    test "disables a feature" do
      state = BrowserBridge.init(enabled_features: [:feature_a])
      updated = BrowserBridge.disable_feature(state, :feature_a)
      refute BrowserBridge.feature_enabled?(updated, :feature_a)
    end
  end
end
