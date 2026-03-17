defmodule WebUi.ExamplesTest do
  use ExUnit.Case, async: true

  test "examples catalog exposes native, canonical, and continuity artifacts" do
    assert [
             :advanced_continuity,
             :canonical_advanced_operations,
             :canonical_foundational,
             :foundational_continuity,
             :native_advanced_operations,
             :native_foundational
           ] =
             WebUi.Examples.catalog()
             |> Enum.map(& &1.id)
             |> Enum.sort()
  end

  test "native and canonical foundational examples stay aligned through the continuity artifact" do
    comparison = WebUi.Examples.FoundationalContinuity.compare()

    assert comparison.continuity.widget_kinds_match?
    assert comparison.continuity.render_tags_match?
    assert "workspace-layout" in comparison.continuity.shared_ids
    assert "query-input" in comparison.continuity.shared_ids
  end

  test "canonical foundational example renders through the package renderer" do
    assert {:ok, view_state} = WebUi.Examples.CanonicalFoundationalScreen.render_view_state()

    assert view_state.screen.mode == :canonical
    assert view_state.screen.id == :canonical_foundational
    assert Enum.any?(view_state.render_tree, &(&1.id == "workspace-layout"))
  end

  test "advanced native and canonical examples stay aligned through the continuity artifact" do
    comparison = WebUi.Examples.AdvancedContinuity.compare()

    assert comparison.continuity.widget_kinds_match?
    assert comparison.continuity.render_tags_match?
    assert comparison.continuity.display_kinds_match?
    assert comparison.continuity.layer_kinds_match?
    assert "operations-overlay" in comparison.continuity.shared_ids
    assert "log-viewport" in comparison.continuity.shared_ids
  end

  test "canonical advanced example renders through the advanced package renderer" do
    assert {:ok, view_state} =
             WebUi.Examples.CanonicalAdvancedOperationsScreen.render_view_state()

    assert view_state.screen.mode == :canonical
    assert view_state.screen.id == :canonical_advanced_operations
    assert Enum.any?(view_state.render_tree, &(&1.id == "operations-root"))
  end
end
