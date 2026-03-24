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

    assert reference.examples.native_ids == [
             :native_foundational,
             :native_advanced_operations,
             :native_transport_review
           ]

    assert reference.examples.canonical_ids == [
             :canonical_foundational,
             :canonical_advanced_operations,
             :canonical_transport_review
           ]

    assert reference.examples.comparison_ids == [
             :foundational_continuity,
             :advanced_continuity,
             :transport_flow_review,
             :normalized_input_profiles
           ]

    assert summary.examples.native_ids == [
             :native_foundational,
             :native_advanced_operations,
             :native_transport_review
           ]

    assert summary.examples.comparison_ids == [
             :foundational_continuity,
             :advanced_continuity,
             :transport_flow_review,
             :normalized_input_profiles
           ]
  end

  test "transport examples expose local routing, boundary translation, and normalized profiles" do
    native = DesktopUi.Examples.native_transport_review()
    canonical = DesktopUi.Examples.canonical_transport_review()
    comparison = DesktopUi.Examples.transport_comparison()
    normalized = DesktopUi.Examples.normalized_input_comparison()

    assert native.metadata.example_id == :native_transport_review
    assert :canonical_boundary_events in native.metadata.coverage
    assert Map.has_key?(native.metadata.target_semantics, :windows)

    assert canonical.kind == :window
    assert canonical.type == :widget

    assert comparison.id == :transport_flow_review
    assert comparison.parity.local_focus_stays_local?
    assert comparison.parity.boundary_routes_match?
    assert comparison.parity.boundary_signal_types_match?
    assert comparison.parity.normalized_input_family_match?

    assert normalized.id == :normalized_input_profiles
    assert normalized.parity.shortcut_family_match?
    assert normalized.parity.window_events_stay_local?
    assert normalized.parity.local_boundary_split_visible?
    assert normalized.parity.platform_variation_bounded?
  end
end
