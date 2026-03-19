defmodule WebUi.Integration.ReferenceInspectionTest do
  use ExUnit.Case

  @moduletag :integration
  @moduletag :reference_inspection

  alias WebUi.Reference

  describe "package reference helpers" do
    test "report widget families without renderer dependencies" do
      families = Reference.widget_families()
      assert is_list(families)
      assert :content in families
      assert :form in families
      assert :input in families
      assert :display in families
      assert :overlay in families
      assert :operational in families
    end

    test "report runtime modules split between server and frontend" do
      ref = Reference.package_reference()

      assert is_list(ref.server_runtime.modules)
      assert is_list(ref.frontend_runtime.modules)

      server_modules = ref.server_runtime.modules |> Enum.map(fn {m, _} -> m end)
      frontend_modules = ref.frontend_runtime.modules |> Enum.map(fn {m, _} -> m end)

      assert WebUi.ServerRuntime.State in server_modules
      assert WebUi.FrontendRuntime.Boot in frontend_modules
    end
  end

  describe "runtime assumptions" do
    test "expose server-authoritative runtime model" do
      assumptions = Reference.runtime_assumptions()
      assert assumptions.server_authoritative == true
      assert assumptions.frontend_projection == true
    end

    test "expose state sync mechanism" do
      assumptions = Reference.runtime_assumptions()
      assert assumptions.state_sync == :checksum_based
    end

    test "expose rendering split" do
      assumptions = Reference.runtime_assumptions()
      assert assumptions.rendering == :split_phoenix_elm
    end
  end

  describe "bridge entry points" do
    test "expose server-side bridge entry points" do
      entry_points = Reference.bridge_entry_points()
      assert is_list(entry_points.server)
      assert is_list(entry_points.frontend)
    end

    test "server bridge points reference correct modules" do
      entry_points = Reference.bridge_entry_points()
      server_points = entry_points.server

      assert Enum.any?(server_points, fn {mod, _fun} ->
        mod == WebUi.ServerRuntime.BrowserBridge or mod == WebUi.ServerRuntime.Channel
      end)
    end

    test "frontend bridge points reference correct modules" do
      entry_points = Reference.bridge_entry_points()
      frontend_points = entry_points.frontend

      assert Enum.any?(frontend_points, fn {mod, _fun} ->
        mod == WebUi.FrontendRuntime.Bridge or mod == WebUi.FrontendRuntime.Boot
      end)
    end
  end

  describe "validation state" do
    test "expose package loading state" do
      state = Reference.validation_state()
      assert is_boolean(state.package_loaded)
      assert state.package_loaded == true
    end

    test "expose runtime availability" do
      state = Reference.validation_state()
      assert is_boolean(state.runtime_available)
      assert is_boolean(state.frontend_available)
    end

    test "expose registry availability" do
      state = Reference.validation_state()
      assert is_boolean(state.registry_available)
    end
  end

  describe "transport integration points" do
    test "list transport integration points" do
      integrations = Reference.transport_integrations()
      assert is_map(integrations)
      assert is_atom(integrations.phoenix_channels)
      assert is_atom(integrations.browser_bridge)
    end

    test "transport integrations reference actual modules" do
      integrations = Reference.transport_integrations()
      assert Code.ensure_loaded?(integrations.phoenix_channels)
      assert Code.ensure_loaded?(integrations.browser_bridge)
    end
  end
end
