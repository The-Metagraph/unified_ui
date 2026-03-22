defmodule TerminalUi.ExamplesTest do
  use ExUnit.Case, async: true

  test "maintained foundational examples expose native and canonical artifacts" do
    native = TerminalUi.Examples.native_foundational_screen()
    canonical = TerminalUi.Examples.canonical_foundational_screen()
    advanced_native = TerminalUi.Examples.native_advanced_operations_screen()
    advanced_canonical = TerminalUi.Examples.canonical_advanced_operations_screen()

    assert native.metadata.example_id == :native_foundational
    assert native.metadata.coverage == [:foundational_widgets, :native_runtime, :focus_traversal]
    assert canonical.id == "workspace-foundation"
    assert advanced_native.metadata.example_id == :native_advanced_operations
    assert advanced_canonical.id == "operations-overlay"

    assert Enum.map(TerminalUi.Examples.native_examples(), & &1.id) == [
             :native_foundational,
             :native_advanced_operations
           ]

    assert Enum.map(TerminalUi.Examples.canonical_examples(), & &1.id) == [
             :canonical_foundational,
             :canonical_advanced_operations
           ]
  end

  test "comparison helpers show native and canonical rendering through the shared runtime" do
    comparison = TerminalUi.Examples.foundational_comparison()
    advanced = TerminalUi.Examples.advanced_comparison()
    capability = TerminalUi.Examples.advanced_capability_comparison()

    assert comparison.id == :foundational_continuity
    assert comparison.native.source_kind == :native
    assert comparison.canonical.source_kind == :canonical
    assert comparison.parity.focus_order_match?
    assert comparison.parity.cell_surface_kinds_match?
    assert comparison.parity.shared_runtime_backbone?

    assert advanced.id == :advanced_continuity
    assert advanced.parity.shared_runtime_backbone?
    assert advanced.parity.advanced_state_match?
    assert advanced.parity.layered_roles_match?
    assert advanced.parity.display_kinds_match?

    assert capability.id == :advanced_capability_continuity
    assert capability.parity.native_semantics_stable?
    assert capability.parity.canonical_semantics_stable?
    assert capability.parity.tty_fallbacks_explicit?
    assert capability.parity.allowed_variation_bounded?
  end

  test "reference and info surfaces include foundational example metadata and coverage" do
    reference = TerminalUi.reference()
    summary = TerminalUi.info()

    assert reference.examples.native_ids == [:native_foundational, :native_advanced_operations]

    assert reference.examples.canonical_ids == [
             :canonical_foundational,
             :canonical_advanced_operations
           ]

    assert :foundational_continuity in reference.examples.comparison_ids
    assert :advanced_continuity in reference.examples.comparison_ids
    assert :advanced_capability_continuity in reference.examples.comparison_ids
    assert Map.has_key?(reference.examples.coverage_matrix.categories, :forms)
    assert Map.has_key?(reference.examples.coverage_matrix.categories, :layering)

    assert summary.examples.native_ids == [:native_foundational, :native_advanced_operations]

    assert summary.examples.canonical_ids == [
             :canonical_foundational,
             :canonical_advanced_operations
           ]

    assert :actions in summary.examples.categories
    assert :display in summary.examples.categories
    assert :advanced_review in summary.examples.workflows
    assert :parity_review in summary.examples.workflows
    assert :example_review in summary.tooling.workflows
  end
end
