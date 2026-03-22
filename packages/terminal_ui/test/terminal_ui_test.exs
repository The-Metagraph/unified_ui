defmodule TerminalUiTest do
  use ExUnit.Case, async: true

  test "package reference exposes terminal runtime and capability areas" do
    assert [:widgets, :runtime, :backend, :capabilities, :renderer, :transport, :tooling] ==
             TerminalUi.package_areas()

    assert %{
             package: TerminalUi,
             package_areas: package_areas,
             widgets: %{families: families},
             runtime: %{assumptions: runtime_assumptions},
             backend: %{modes: backend_modes},
             capabilities: %{categories: capability_categories},
             renderer: %{accepts: UnifiedIUR.Element},
             transport: %{modes: [:native_local, :canonical_boundary]},
             tooling: %{guides: guides}
           } = TerminalUi.reference()

    assert package_areas == TerminalUi.package_areas()
    assert :content in families
    assert runtime_assumptions.term_ui_backed
    assert backend_modes == [:raw, :tty]
    assert :unicode in capability_categories
    assert "guides/runtime_backbone.md" in guides
  end

  test "package summary reports package identity" do
    assert %{
             package: :terminal_ui,
             namespace: TerminalUi,
             documentation: %{guides: guides},
             tooling: %{workflows: workflows}
           } = TerminalUi.info()

    assert "guides/maintainer_workflows.md" in guides
    assert :capability_review in workflows
  end
end
