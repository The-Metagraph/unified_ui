defmodule DesktopUi.CanonicalNavigationNonWebExamplesIntegrationTest do
  use ExUnit.Case, async: true

  test "desktop maintained navigation review preserves shared canonical targets through one-window navigation" do
    review = DesktopUi.Examples.navigation_transition_review()
    metadata = DesktopUi.Examples.metadata(:navigation_transition_review)
    reference = DesktopUi.reference()
    summary = DesktopUi.info()

    assert review.fixture_ids == [
             "screen_transition--settings_profile",
             "replace_transition--home",
             "history_transition--back",
             "modal_transition--settings_dialog"
           ]

    assert review.parity.shared_fixture_targets_consumed?
    assert review.parity.window_preserved_across_transitions?
    assert review.parity.registry_resolution_preserved?
    assert review.parity.history_semantics_preserved?
    assert review.parity.modal_stack_preserved?
    assert review.states.after_navigate.title == "Settings"
    assert review.states.after_reports.screen_id == "reports"
    assert review.states.after_reports.history_depth == 2
    assert review.states.after_back.forward_depth == 1
    assert review.states.after_replace.screen_params == %{source: :command_palette}
    assert review.states.mounted.primary_window == review.states.after_replace.primary_window
    assert review.routes.replace.target == review.fixture_targets.replace
    assert review.routes.forward.target == review.fixture_targets.forward
    assert metadata.workflow == :navigation_review
    assert metadata.parity_group == :navigation_transition_review
    assert :navigation_transition_review in reference.examples.comparison_ids
    assert :navigation_transition_review in summary.examples.comparison_ids
    assert :navigation_review in summary.examples.workflows
  end

  test "desktop maintained navigation review keeps canonical targets free of host route syntax" do
    review = DesktopUi.Examples.navigation_transition_review()

    assert Enum.all?(review.routes, fn {_step, route} ->
             match?(%{navigation: _}, route.target) and
               get_in(route.target, [:navigation, :route]) == nil
           end)
  end
end
