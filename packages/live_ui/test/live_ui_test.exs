defmodule LiveUiTest do
  use ExUnit.Case, async: true

  test "package reference exposes canonical areas" do
    assert [:widgets, :runtime, :renderer, :transport, :tooling] = LiveUi.package_areas()

    assert %{
             package: LiveUi,
             widgets: families,
             runtime: runtime_capabilities,
             transport: [:native_local, :canonical_boundary]
           } = LiveUi.reference()

    assert :content in families
    assert :native_mount in runtime_capabilities
  end

  test "package exposes native screen namespace" do
    assert LiveUi.screen() == LiveUi.Screen
  end

  test "package summary reports package identity" do
    assert %{package: :live_ui, namespace: LiveUi} = LiveUi.info()
  end
end
