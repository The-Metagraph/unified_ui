defmodule TerminalUi.ExamplesTest do
  use ExUnit.Case, async: true

  test "maintained foundational examples expose native and canonical artifacts" do
    native = TerminalUi.Examples.native_foundational_screen()
    canonical = TerminalUi.Examples.canonical_foundational_screen()
    advanced_native = TerminalUi.Examples.native_advanced_operations_screen()
    advanced_canonical = TerminalUi.Examples.canonical_advanced_operations_screen()
    native_transport = TerminalUi.Examples.native_transport_screen()
    canonical_transport = TerminalUi.Examples.canonical_transport_screen()
    native_styled = TerminalUi.Examples.native_styled_screen()
    canonical_styled = TerminalUi.Examples.canonical_styled_screen()

    assert native.metadata.example_id == :native_foundational
    assert native.metadata.coverage == [:foundational_widgets, :native_runtime, :focus_traversal]
    assert canonical.id == "workspace-foundation"
    assert advanced_native.metadata.example_id == :native_advanced_operations
    assert advanced_canonical.id == "operations-overlay"
    assert native_transport.metadata.example_id == :native_transport_review
    assert canonical_transport.id == "transport-root"
    assert native_styled.metadata.example_id == :native_styled_review
    assert canonical_styled.id == "styled-root"

    assert Enum.map(TerminalUi.Examples.native_examples(), & &1.id) == [
             :native_foundational,
             :native_advanced_operations,
             :native_transport_review,
             :native_styled_review
           ]

    assert Enum.map(TerminalUi.Examples.canonical_examples(), & &1.id) == [
             :canonical_foundational,
             :canonical_advanced_operations,
             :canonical_transport_review,
             :canonical_styled_review
           ]
  end

  test "examples catalog exposes native, canonical, and mixed review artifacts" do
    assert [
             :advanced_capability_continuity,
             :advanced_continuity,
             :canonical_advanced_operations,
             :canonical_foundational,
             :canonical_styled_review,
             :canonical_transport_review,
             :foundational_continuity,
             :native_advanced_operations,
             :native_foundational,
             :native_styled_review,
             :native_transport_review,
             :normalized_input_profiles,
             :styled_continuity_review,
             :styled_degradation_review,
             :transport_flow_review
           ] =
             TerminalUi.Examples.catalog()
             |> Enum.map(& &1.id)
             |> Enum.sort()

    assert Enum.sort(Enum.map(TerminalUi.Examples.mixed_examples(), & &1.id)) == [
             :advanced_capability_continuity,
             :advanced_continuity,
             :foundational_continuity,
             :normalized_input_profiles,
             :styled_continuity_review,
             :styled_degradation_review,
             :transport_flow_review
           ]

    assert %{
             category: :native,
             workflow: :styling,
             artifact_names: artifact_names,
             parity_with: [:canonical_styled_review, :styled_continuity_review],
             traceability: %{
               package_specs: package_specs,
               runtime_obligations: runtime_obligations
             }
           } = TerminalUi.Examples.metadata(:native_styled_review)

    assert artifact_names.preview == "terminal_ui.examples.native_styled_review.preview"
    assert artifact_names.validation == "terminal_ui.examples.native_styled_review.validation"
    assert :native_widgets in package_specs
    assert :direct_native_reviewable in runtime_obligations
  end

  test "comparison helpers show native and canonical rendering through the shared runtime" do
    comparison = TerminalUi.Examples.foundational_comparison()
    advanced = TerminalUi.Examples.advanced_comparison()
    capability = TerminalUi.Examples.advanced_capability_comparison()
    transport = TerminalUi.Examples.transport_flow_comparison()
    normalized = TerminalUi.Examples.normalized_input_comparison()
    styled = TerminalUi.Examples.styled_continuity_comparison()
    degradation = TerminalUi.Examples.styled_degradation_comparison()

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

    assert transport.id == :transport_flow_review
    assert transport.parity.local_route_stays_local?
    assert transport.parity.boundary_routes_emit_signals?
    assert transport.parity.runtime_event_meaning_preserved?

    assert normalized.id == :normalized_input_profiles
    assert normalized.parity.shortcut_family_match?
    assert normalized.parity.resize_family_match?
    assert normalized.parity.boundary_local_split_visible?
    assert normalized.parity.tty_capability_handling_explicit?

    assert styled.id == :styled_continuity_review
    assert styled.parity.widget_identity_match?
    assert styled.parity.theme_resolution_match?
    assert styled.parity.style_resolution_match?

    assert degradation.id == :styled_degradation_review
    assert degradation.parity.glyph_fallback_explicit?
    assert degradation.parity.degradation_bounded?
    assert degradation.parity.inspection_surfaces_agree?
  end

  test "reference and info surfaces include foundational example metadata and coverage" do
    reference = TerminalUi.reference()
    summary = TerminalUi.info()

    assert reference.examples.native_ids == [
             :native_foundational,
             :native_advanced_operations,
             :native_transport_review,
             :native_styled_review
           ]

    assert reference.examples.canonical_ids == [
             :canonical_foundational,
             :canonical_advanced_operations,
             :canonical_transport_review,
             :canonical_styled_review
           ]

    assert :foundational_continuity in reference.examples.comparison_ids
    assert :advanced_continuity in reference.examples.comparison_ids
    assert :advanced_capability_continuity in reference.examples.comparison_ids
    assert :transport_flow_review in reference.examples.comparison_ids
    assert :normalized_input_profiles in reference.examples.comparison_ids
    assert :styled_continuity_review in reference.examples.comparison_ids
    assert :styled_degradation_review in reference.examples.comparison_ids
    assert Map.has_key?(reference.examples.coverage_matrix.categories, :forms)
    assert Map.has_key?(reference.examples.coverage_matrix.categories, :layering)
    assert Map.has_key?(reference.examples.coverage_matrix.categories, :transport)
    assert Map.has_key?(reference.examples.coverage_matrix.categories, :style)

    assert summary.examples.native_ids == [
             :native_foundational,
             :native_advanced_operations,
             :native_transport_review,
             :native_styled_review
           ]

    assert summary.examples.canonical_ids == [
             :canonical_foundational,
             :canonical_advanced_operations,
             :canonical_transport_review,
             :canonical_styled_review
           ]

    assert :actions in summary.examples.categories
    assert :display in summary.examples.categories
    assert :transport in summary.examples.categories
    assert :style in summary.examples.categories
    assert :advanced_review in summary.examples.workflows
    assert :transport_review in summary.examples.workflows
    assert :style_review in summary.examples.workflows
    assert :parity_review in summary.examples.workflows
    assert :example_review in summary.tooling.workflows
  end
end
