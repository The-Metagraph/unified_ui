defmodule DesktopUi.ExamplesTest do
  use ExUnit.Case, async: true

  test "foundational examples expose native, canonical, and comparison coverage" do
    native = DesktopUi.Examples.native_foundational_screen()
    canonical = DesktopUi.Examples.canonical_foundational_screen()
    comparison = DesktopUi.Examples.foundational_comparison()

    assert native.metadata.example_id == :native_foundational
    assert native.metadata.source == :native
    assert :content_widgets in native.metadata.coverage

    assert canonical.kind == :column
    assert canonical.type == :layout

    assert comparison.id == :foundational_continuity
    assert comparison.parity.shared_runtime_backbone?
    assert comparison.parity.focus_order_match?
    assert comparison.parity.body_kind_sequence_match?
    assert comparison.parity.binding_names_match?
  end

  test "reference and info surfaces expose foundational example identifiers" do
    reference = DesktopUi.reference()
    summary = DesktopUi.info()

    assert :native_foundational in reference.examples.native_ids
    assert :canonical_foundational in reference.examples.canonical_ids
    assert :foundational_continuity in reference.examples.comparison_ids

    assert :native_foundational in summary.examples.native_ids
    assert :foundational_continuity in summary.examples.comparison_ids
    assert DesktopUi.examples() == DesktopUi.Examples
  end

  test "advanced examples expose layered, display, and target-semantics coverage" do
    native = DesktopUi.Examples.native_advanced_operations_screen()
    canonical = DesktopUi.Examples.canonical_advanced_operations_screen()
    comparison = DesktopUi.Examples.advanced_comparison()

    assert native.metadata.example_id == :native_advanced_operations
    assert :multiwindow_runtime in native.metadata.coverage
    assert Map.has_key?(native.metadata.target_semantics, :linux)

    assert canonical.kind == :multi_window
    assert canonical.type == :layer

    assert comparison.id == :advanced_continuity
    assert comparison.parity.shared_runtime_backbone?
    assert comparison.parity.advanced_ready_match?
    assert comparison.parity.layer_count_match?
    assert comparison.parity.viewport_count_match?
    assert comparison.parity.window_registry_match?
  end

  test "reference and info surfaces expose advanced example identifiers" do
    reference = DesktopUi.reference()
    summary = DesktopUi.info()

    assert reference.examples.native_ids == [:native_foundational, :native_advanced_operations]

    assert reference.examples.canonical_ids == [
             :canonical_foundational,
             :canonical_advanced_operations
           ]

    assert reference.examples.comparison_ids == [:foundational_continuity, :advanced_continuity]
    assert summary.examples.native_ids == [:native_foundational, :native_advanced_operations]
    assert summary.examples.comparison_ids == [:foundational_continuity, :advanced_continuity]
  end
end
