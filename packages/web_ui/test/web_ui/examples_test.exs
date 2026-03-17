defmodule WebUi.ExamplesTest do
  use ExUnit.Case, async: true

  test "examples catalog exposes native, canonical, and continuity artifacts" do
    assert [:canonical_foundational, :foundational_continuity, :native_foundational] =
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
end
