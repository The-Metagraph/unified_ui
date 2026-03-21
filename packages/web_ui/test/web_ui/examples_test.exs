defmodule WebUi.ExamplesTest do
  use ExUnit.Case, async: true

  test "examples catalog exposes native, canonical, and continuity artifacts" do
    assert [
             :advanced_continuity,
             :canonical_advanced,
             :canonical_foundational,
             :canonical_welcome,
             :foundational_continuity,
             :native_advanced,
             :native_counter,
             :native_foundational
           ] =
             WebUi.Examples.catalog()
             |> Enum.map(& &1.id)
             |> Enum.sort()
  end

  test "native and canonical foundational examples stay aligned through the continuity artifact" do
    comparison = WebUi.Examples.foundational_comparison()

    assert comparison.continuity.widget_kinds_match?
    assert comparison.continuity.render_tags_match?
    assert "workspace-layout" in comparison.continuity.shared_ids
    assert "query-input" in comparison.continuity.shared_ids
  end

  test "native and canonical advanced examples stay aligned through the continuity artifact" do
    comparison = WebUi.Examples.advanced_comparison()

    assert comparison.continuity.widget_kinds_match?
    assert comparison.continuity.render_tags_match?
    assert comparison.continuity.display_kinds_match?
    assert comparison.continuity.layer_kinds_match?
    assert "advanced-operations" in comparison.continuity.shared_ids
    assert "inspect-dialog" in comparison.continuity.shared_ids
  end

  test "canonical foundational example renders through the package runtime" do
    assert {:ok, runtime_state} =
             WebUi.Runtime.mount_iur_screen(WebUi.Examples.canonical_foundational_screen())

    assert {:ok, model} = WebUi.Runtime.hydrate_frontend(runtime_state)

    assert runtime_state.boundary_mode == :canonical_boundary
    assert runtime_state.screen_id == "workspace-layout"

    assert Enum.any?(model.tree.slots, fn slot ->
             Enum.any?(slot.children, &(&1.id == "workspace-header"))
           end)
  end

  test "canonical advanced example renders through the advanced package runtime" do
    assert {:ok, runtime_state} =
             WebUi.Runtime.mount_iur_screen(WebUi.Examples.canonical_advanced_screen())

    assert {:ok, model} = WebUi.Runtime.hydrate_frontend(runtime_state)

    assert runtime_state.boundary_mode == :canonical_boundary
    assert runtime_state.screen_id == "advanced-operations"

    assert Enum.any?(model.tree.slots, fn slot ->
             Enum.any?(slot.children, &(&1.id == "operations-overlay"))
           end)
  end
end
