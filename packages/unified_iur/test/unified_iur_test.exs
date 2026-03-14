defmodule UnifiedIURTest do
  use ExUnit.Case, async: true

  test "exposes the canonical package module areas" do
    assert %{
             constructs: UnifiedIUR.Constructs,
             core: UnifiedIUR.Core,
             interactions: UnifiedIUR.Interactions,
             interoperability: UnifiedIUR.Interoperability,
             normalize: UnifiedIUR.Normalize,
             reference: UnifiedIUR.Reference,
             tooling: UnifiedIUR.Tooling
           } = UnifiedIUR.module_areas()
  end

  test "loads as a pure library without an application callback module" do
    assert Application.load(:unified_iur) in [:ok, {:error, {:already_loaded, :unified_iur}}]
    assert Application.spec(:unified_iur, :mod) in [nil, []]
  end

  test "reference helpers mirror the package module areas" do
    assert UnifiedIUR.module_areas() == UnifiedIUR.Reference.module_areas()
  end

  test "constructs namespace exposes foundational widget modules" do
    assert %{
             widgets: UnifiedIUR.Widgets,
             container: UnifiedIUR.Container,
             forms: UnifiedIUR.Forms
           } = UnifiedIUR.Constructs.modules()

    assert %{
             foundational: UnifiedIUR.Widgets.Foundational,
             input: UnifiedIUR.Widgets.Input
           } = UnifiedIUR.Widgets.modules()
  end

  test "core namespace exposes the canonical core modules" do
    assert %{
             element: UnifiedIUR.Element,
             metadata: UnifiedIUR.Metadata,
             tree: UnifiedIUR.Tree,
             invariant: UnifiedIUR.Core.Invariant
           } = UnifiedIUR.Core.modules()

    assert [:widget, :layout, :layer, :style, :theme, :interaction, :composite] ==
             UnifiedIUR.Core.element_types()
  end
end
