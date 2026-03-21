defmodule WebUiTest do
  use ExUnit.Case, async: true

  test "package reference exposes split runtime and renderer areas" do
    assert [:widgets, :runtime, :renderer, :transport, :tooling] = WebUi.package_areas()

    assert %{
             package: WebUi,
             widgets: %{families: families},
             runtime: %{capabilities: runtime_capabilities},
             transport: %{modes: [:native_local, :canonical_boundary]}
           } = WebUi.reference()

    assert :content in families
    assert :native_mount in runtime_capabilities
  end

  test "package summary reports package identity" do
    assert %{package: :web_ui, namespace: WebUi} = WebUi.info()
  end

  test "package exposes maintained native and canonical examples" do
    assert %{native: native, canonical: canonical} = WebUi.Examples.comparison_examples()
    assert native.title == "Native Counter"
    assert canonical.kind == :text
  end
end
