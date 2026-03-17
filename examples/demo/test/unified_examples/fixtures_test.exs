defmodule UnifiedExamples.FixturesTest do
  use ExUnit.Case, async: true

  alias UnifiedExamples.Demo
  alias UnifiedExamples.Demo.Categories
  alias UnifiedExamples.Demo.Fixtures
  alias UnifiedExamples.Demo.SignalLab

  test "fixture contract stays aligned with the aggregate demo category registry" do
    fixture_contract = Fixtures.contract_summary()
    metadata = Demo.review_metadata()

    assert fixture_contract.digest == Fixtures.digest()
    assert metadata.fixture_contract.digest == Fixtures.digest()

    assert fixture_contract.category_example_directories ==
             Map.new(Categories.review_registry(), &{&1.id, &1.example_directories})

    assert fixture_contract.category_counts ==
             Map.new(Categories.review_registry(), &{&1.id, &1.example_count})
  end

  test "fixture contract keeps signal lab review states deterministic" do
    targets = Fixtures.signal_lab_targets()
    initial_state = SignalLab.initial_state()

    assert targets.action_to_feedback.idle_feedback ==
             initial_state.action_to_feedback.feedback_text

    assert targets.action_to_feedback.idle_note ==
             initial_state.action_to_feedback.feedback_note

    assert targets.input_to_preview.idle_preview == initial_state.input_to_preview.preview_value
    assert targets.input_to_preview.idle_summary == initial_state.input_to_preview.summary

    assert targets.selection_to_filter.idle_filter_label ==
             initial_state.selection_to_filter.filter_label

    assert targets.selection_to_filter.idle_summary ==
             initial_state.selection_to_filter.summary

    assert targets.toggle_to_visibility_or_enabled_state.idle_target_label ==
             initial_state.toggle_to_visibility_or_enabled_state.target_label

    assert targets.toggle_to_visibility_or_enabled_state.idle_target_note ==
             initial_state.toggle_to_visibility_or_enabled_state.target_note
  end

  test "fixture contract advertises the responsive review shell breakpoints" do
    responsive = Fixtures.responsive_layout()

    assert responsive.desktop_two_column_min_width == 980
    assert responsive.compact_single_column_max_width == 979
    assert responsive.dense_stack_max_width == 720
    assert responsive.tab_wrap_enabled?
    assert responsive.linked_examples_stack_below == 720
  end
end
