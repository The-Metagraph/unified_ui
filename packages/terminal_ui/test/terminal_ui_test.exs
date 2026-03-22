defmodule TerminalUiTest do
  use ExUnit.Case, async: true

  test "package reference exposes terminal runtime and capability areas" do
    assert [:widgets, :runtime, :backend, :capabilities, :renderer, :transport, :tooling] ==
             TerminalUi.package_areas()

    assert %{
             package: TerminalUi,
             package_areas: package_areas,
             widgets: %{families: families, kinds: kinds, modules: widget_modules},
             runtime: %{assumptions: runtime_assumptions, modules: runtime_modules},
             backend: %{modes: backend_modes},
             capabilities: %{categories: capability_categories},
             renderer: %{accepts: UnifiedIUR.Element},
             transport: %{modes: [:native_local, :canonical_boundary]},
             tooling: %{guides: guides, workflows: workflows}
           } = TerminalUi.reference()

    assert package_areas == TerminalUi.package_areas()
    assert :content in families
    assert :text in kinds
    assert TerminalUi.Widget in widget_modules
    assert runtime_assumptions.term_ui_backed
    assert TerminalUi.Runtime.Boot in runtime_modules
    assert backend_modes == [:raw, :tty]
    assert :unicode in capability_categories
    assert "guides/runtime_backbone.md" in guides
    assert :runtime_review in workflows
  end

  test "package summary reports package identity" do
    assert %{
             package: :terminal_ui,
             namespace: TerminalUi,
             runtime: %{validation_state: :backbone_ready},
             widgets: %{families: families},
             documentation: %{guides: guides},
             tooling: %{workflows: workflows}
           } = TerminalUi.info()

    assert :layout in families
    assert "guides/maintainer_workflows.md" in guides
    assert :capability_review in workflows
  end
end
