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
             :native_transport_review,
             :native_styled_review,
             :basic_navigation,
             :history_navigation,
             :modal_navigation,
             :master_detail_navigation
           ]

    assert reference.examples.canonical_ids == [
             :canonical_foundational,
             :canonical_advanced_operations,
             :canonical_transport_review,
             :canonical_styled_review
           ]

    assert reference.examples.comparison_ids == [
             :foundational_continuity,
             :advanced_continuity,
             :transport_flow_review,
             :normalized_input_profiles,
             :styled_continuity_review,
             :navigation_transition_review
           ]

    assert summary.examples.native_ids == [
             :native_foundational,
             :native_advanced_operations,
             :native_transport_review,
             :native_styled_review,
             :basic_navigation,
             :history_navigation,
             :modal_navigation,
             :master_detail_navigation
           ]

    assert summary.examples.comparison_ids == [
             :foundational_continuity,
             :advanced_continuity,
             :transport_flow_review,
             :normalized_input_profiles,
             :styled_continuity_review,
             :navigation_transition_review
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

  test "styled examples and catalog metadata expose maintained style review coverage" do
    native = DesktopUi.Examples.native_styled_review()
    canonical = DesktopUi.Examples.canonical_styled_review()
    comparison = DesktopUi.Examples.styled_comparison()
    catalog = DesktopUi.Examples.catalog()
    matrix = DesktopUi.Examples.coverage_matrix()

    assert native.metadata.example_id == :native_styled_review
    assert :style_primitives in native.metadata.coverage
    assert canonical.kind == :window
    assert comparison.id == :styled_continuity_review
    assert comparison.parity.widget_identity_match?
    assert comparison.parity.style_resolution_match?
    assert comparison.parity.platform_semantics_match?

    assert DesktopUi.Examples.metadata(:native_styled_review).workflow == :style_review
    assert :native_styled_review in Enum.map(DesktopUi.Examples.native_examples(), & &1.id)
    assert :canonical_styled_review in Enum.map(DesktopUi.Examples.canonical_examples(), & &1.id)
    assert :styled_continuity_review in Enum.map(DesktopUi.Examples.mixed_examples(), & &1.id)
    assert :style_review in Map.keys(matrix.workflows)
    assert :style_review in Map.keys(matrix.parity_groups)

    assert Enum.any?(catalog, fn entry ->
             entry.id == :styled_continuity_review and
               entry.artifact_names.comparison ==
                 "desktop_ui.examples.styled_continuity_review.comparison"
           end)
  end

  test "navigation review exposes shared canonical fixtures through one-window desktop navigation" do
    review = DesktopUi.Examples.navigation_transition_review()
    metadata = DesktopUi.Examples.metadata(:navigation_transition_review)
    matrix = DesktopUi.Examples.coverage_matrix()

    assert review.id == :navigation_transition_review

    assert review.fixture_ids == [
             "screen_transition--settings_profile",
             "replace_transition--home",
             "history_transition--back",
             "modal_transition--settings_dialog"
           ]

    assert review.fixture_targets.navigate ==
             %{
               navigation: %{
                 action: :navigate_to,
                 kind: :screen_transition,
                 params: %{tab: :profile},
                 screen: :settings
               }
             }

    assert %{navigation: modal_target} = review.fixture_targets.modal
    assert modal_target.action == :open_modal
    assert modal_target.kind == :modal_transition
    assert modal_target.modal == :settings_dialog
    assert modal_target.params == %{mode: :advanced}
    assert modal_target.metadata == %{surface: :workspace}

    assert review.parity.shared_fixture_targets_consumed?
    assert review.parity.window_preserved_across_transitions?
    assert review.parity.registry_resolution_preserved?
    assert review.parity.history_semantics_preserved?
    assert review.parity.modal_stack_preserved?
    assert review.states.after_navigate.screen_id == "settings"
    assert review.states.after_reports.screen_id == "reports"
    assert review.states.after_replace.screen_id == "home"

    assert review.states.with_modal.current_modal == %{
             modal: :settings_dialog,
             params: %{mode: :advanced}
           }

    assert review.routes.forward.target == %{navigation: %{action: :go_forward}}
    assert metadata.workflow == :navigation_review
    assert metadata.parity_group == :navigation_transition_review
    assert matrix.parity_groups.navigation_transition_review == [:navigation_transition_review]
  end
end
