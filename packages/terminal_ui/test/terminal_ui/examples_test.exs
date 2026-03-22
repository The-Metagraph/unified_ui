defmodule TerminalUi.ExamplesTest do
  use ExUnit.Case, async: true

  test "maintained foundational examples expose native and canonical artifacts" do
    native = TerminalUi.Examples.native_foundational_screen()
    canonical = TerminalUi.Examples.canonical_foundational_screen()

    assert native.metadata.example_id == :native_foundational
    assert native.metadata.coverage == [:foundational_widgets, :native_runtime, :focus_traversal]
    assert canonical.id == "workspace-foundation"

    assert Enum.map(TerminalUi.Examples.native_examples(), & &1.id) == [:native_foundational]

    assert Enum.map(TerminalUi.Examples.canonical_examples(), & &1.id) == [
             :canonical_foundational
           ]
  end

  test "comparison helpers show native and canonical rendering through the shared runtime" do
    comparison = TerminalUi.Examples.foundational_comparison()

    assert comparison.id == :foundational_continuity
    assert comparison.native.source_kind == :native
    assert comparison.canonical.source_kind == :canonical
    assert comparison.parity.focus_order_match?
    assert comparison.parity.cell_surface_kinds_match?
    assert comparison.parity.shared_runtime_backbone?
  end

  test "reference and info surfaces include foundational example metadata and coverage" do
    reference = TerminalUi.reference()
    summary = TerminalUi.info()

    assert reference.examples.native_ids == [:native_foundational]
    assert reference.examples.canonical_ids == [:canonical_foundational]
    assert :foundational_continuity in reference.examples.comparison_ids
    assert Map.has_key?(reference.examples.coverage_matrix.categories, :forms)

    assert summary.examples.native_ids == [:native_foundational]
    assert summary.examples.canonical_ids == [:canonical_foundational]
    assert :actions in summary.examples.categories
    assert :parity_review in summary.examples.workflows
    assert :example_review in summary.tooling.workflows
  end
end
