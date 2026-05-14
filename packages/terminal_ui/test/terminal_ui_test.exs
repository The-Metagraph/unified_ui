defmodule TerminalUiTest do
  use ExUnit.Case, async: true

  test "package reference exposes terminal runtime and capability areas" do
    assert [
             :widgets,
             :runtime,
             :backend,
             :capabilities,
             :degradation,
             :style,
             :theme,
             :inspection,
             :continuity,
             :layout,
             :layer,
             :renderer,
             :transport,
             :tooling
           ] == TerminalUi.package_areas()

    assert %{
             package: TerminalUi,
             package_areas: package_areas,
             widgets: %{families: families, kinds: kinds, modules: widget_modules},
             runtime: %{assumptions: runtime_assumptions, modules: runtime_modules},
             backend: %{modes: backend_modes},
             capabilities: %{categories: capability_categories},
             degradation: %{modules: degradation_modules},
             style: %{hooks: style_hooks},
             theme: %{catalog: theme_catalog},
             inspection: %{helpers: inspection_helpers},
             continuity: %{seams: continuity_seams},
             layout: %{kinds: layout_kinds, module: TerminalUi.Layout},
             layer: %{kinds: layer_kinds, module: TerminalUi.Layer},
             renderer: %{accepts: UnifiedIUR.Element, mapper: TerminalUi.Renderer.Mapper},
             transport: %{modes: [:native_local, :canonical_boundary]},
             examples: %{native_ids: native_ids, canonical_ids: canonical_ids},
             tooling: %{guides: guides, workflows: workflows}
           } = TerminalUi.reference()

    assert package_areas == TerminalUi.package_areas()
    assert :action in families
    assert :content in families
    assert :data in families
    assert :text in kinds
    assert :command in kinds
    assert :table in kinds
    assert TerminalUi.Widget in widget_modules
    assert runtime_assumptions.term_ui_backed
    assert TerminalUi.Runtime.Boot in runtime_modules
    assert backend_modes == [:raw, :tty]
    assert :unicode in capability_categories
    assert TerminalUi.Degradation in degradation_modules
    assert :theme_tokens in style_hooks
    assert :high_contrast in theme_catalog
    assert :runtime_snapshot in inspection_helpers
    assert :style_resolution in continuity_seams
    assert :viewport in layout_kinds
    assert :overlay in layer_kinds

    assert native_ids == [
             :native_foundational,
             :native_advanced_operations,
             :native_transport_review,
             :native_styled_review
           ]

    assert canonical_ids == [
             :canonical_foundational,
             :canonical_advanced_operations,
             :canonical_transport_review,
             :canonical_styled_review
           ]

    assert "guides/runtime_backbone.md" in guides
    assert :runtime_review in workflows
  end

  test "package summary reports package identity" do
    assert %{
             package: :terminal_ui,
             namespace: TerminalUi,
             runtime: %{validation_state: :advanced_runtime_ready},
             layout: %{kinds: layout_kinds},
             layer: %{kinds: layer_kinds},
             widgets: %{families: families},
             degradation: %{diagnostics: degradation_diagnostics},
             style: %{primitives: style_primitives},
             theme: %{catalog: theme_catalog, default: default_theme},
             inspection: %{helpers: inspection_helpers},
             continuity: %{seams: continuity_seams, diagnostic_kinds: diagnostic_kinds},
             examples: %{comparison_ids: comparison_ids},
             documentation: %{guides: guides},
             tooling: %{workflows: workflows}
           } = TerminalUi.info()

    assert :action in families
    assert :visualization in families
    assert :layout in families
    assert :colors in style_primitives
    assert :high_contrast in theme_catalog
    assert default_theme == :terminal_default
    assert degradation_diagnostics.plan.glyph_set == :unicode
    assert :runtime_snapshot in inspection_helpers
    assert :degradation_boundaries in continuity_seams
    assert :resolved_style_mismatch in diagnostic_kinds
    assert :canvas_surface in layout_kinds
    assert :context_menu in layer_kinds

    assert comparison_ids == [
             :advanced_capability_continuity,
             :advanced_continuity,
             :foundational_continuity,
             :modal_stack_navigation_review,
             :normalized_input_profiles,
             :styled_continuity_review,
             :styled_degradation_review,
             :transport_flow_review
           ]

    assert "guides/maintainer_workflows.md" in guides
    assert :capability_review in workflows
  end
end
