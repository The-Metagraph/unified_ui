defmodule WebUiTest do
  use ExUnit.Case, async: true

  test "package reference exposes split runtime and renderer areas" do
    assert [
             :widgets,
             :layout,
             :layer,
             :runtime,
             :renderer,
             :signals,
             :transport,
             :style,
             :theme,
             :inspection,
             :tooling
           ] =
             WebUi.package_areas()

    assert %{
             package: WebUi,
             widgets: %{families: families},
             layout: %{kinds: layout_kinds},
             layer: %{kinds: layer_kinds},
             signals: %{families: signal_families},
             runtime: %{capabilities: runtime_capabilities},
             transport: %{modes: [:native_local, :canonical_boundary]},
             style: %{hooks: style_hooks},
             theme: %{catalog: theme_catalog},
             inspection: %{helpers: inspection_helpers}
           } = WebUi.reference()

    assert :content in families
    assert :viewport in layout_kinds
    assert :dialog in layer_kinds
    assert :command in signal_families
    assert :native_mount in runtime_capabilities
    assert :theme_tokens in style_hooks
    assert :default in theme_catalog
    assert :runtime_snapshot in inspection_helpers
  end

  test "package summary reports package identity" do
    assert %{
             package: :web_ui,
             namespace: WebUi,
             theme: %{default: :default},
             inspection: %{continuity_seams: continuity_seams}
           } = WebUi.info()

    assert :server_style_resolution in continuity_seams
  end

  test "package exposes maintained native and canonical examples" do
    assert %{native: native, canonical: canonical} = WebUi.Examples.comparison_examples()
    assert native.title == "Native Counter"
    assert canonical.kind == :text
  end
end
