defmodule WebUi.ReferenceTest do
  use ExUnit.Case

  alias WebUi.Reference

  describe "package_reference/0" do
    test "returns reference map with all areas" do
      ref = Reference.package_reference()

      assert is_map(ref.widgets)
      assert is_map(ref.server_runtime)
      assert is_map(ref.frontend_runtime)
      assert is_map(ref.renderer)
      assert is_map(ref.transport)
      assert is_map(ref.tooling)
    end

    test "returns module lists for each area" do
      ref = Reference.package_reference()

      assert is_list(ref.widgets.modules)
      assert is_list(ref.server_runtime.modules)
      assert is_list(ref.frontend_runtime.modules)
    end

    test "includes description for each area" do
      ref = Reference.package_reference()

      assert is_binary(ref.widgets.description)
      assert is_binary(ref.server_runtime.description)
      assert is_binary(ref.frontend_runtime.description)
    end
  end

  describe "widget_families/0" do
    test "returns list of widget families" do
      families = Reference.widget_families()
      assert is_list(families)
      assert :content in families
      assert :form in families
      assert :input in families
    end
  end

  describe "runtime_assumptions/0" do
    test "returns runtime assumptions map" do
      assumptions = Reference.runtime_assumptions()
      assert is_map(assumptions)
      assert assumptions.server_authoritative == true
      assert assumptions.frontend_projection == true
      assert assumptions.rendering == :split_phoenix_elm
    end
  end

  describe "bridge_entry_points/0" do
    test "returns bridge entry points" do
      entry_points = Reference.bridge_entry_points()
      assert is_map(entry_points)
      assert is_list(entry_points.server)
      assert is_list(entry_points.frontend)
    end
  end

  describe "transport_integrations/0" do
    test "returns transport integration points" do
      integrations = Reference.transport_integrations()
      assert is_map(integrations)
      assert is_atom(integrations.phoenix_channels)
      assert is_atom(integrations.browser_bridge)
    end
  end

  describe "validation_state/0" do
    test "returns package validation state" do
      state = Reference.validation_state()
      assert is_map(state)
      assert is_boolean(state.package_loaded)
      assert is_boolean(state.registry_available)
    end

    test "package_loaded is true" do
      state = Reference.validation_state()
      assert state.package_loaded == true
    end
  end
end
