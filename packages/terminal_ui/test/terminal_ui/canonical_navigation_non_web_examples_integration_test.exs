defmodule TerminalUi.CanonicalNavigationNonWebExamplesIntegrationTest do
  use ExUnit.Case, async: true

  test "terminal maintained navigation review consumes shared canonical fixtures across raw and tty backends" do
    review = TerminalUi.Examples.navigation_transition_review()
    metadata = TerminalUi.Examples.metadata(:navigation_transition_review)
    reference = TerminalUi.reference()
    summary = TerminalUi.info()

    assert review.fixture_ids == [
             "screen_transition--settings_profile",
             "replace_transition--home",
             "history_transition--back",
             "modal_transition--settings_dialog"
           ]

    assert review.parity.shared_fixture_targets_consumed?
    assert review.parity.screen_transition_meaning_preserved?
    assert review.parity.modal_degradation_explicit?
    assert review.parity.history_semantics_preserved?
    assert review.raw.after_navigate.active_screen_id == "settings"
    assert review.raw.after_back.forward_depth == 1
    assert review.raw.after_replace.active_screen_id == "home"
    assert review.tty.after_replace.active_screen_id == "home"
    assert review.tty.with_modal.last_realization.degraded?
    assert review.tty.with_modal.last_realization.fallback == :focused_surface
    assert metadata.workflow == :navigation
    assert metadata.parity_group == :navigation_transition_review
    assert :navigation_transition_review in reference.examples.comparison_ids
    assert :navigation_transition_review in summary.examples.comparison_ids
    assert :navigation_review in summary.examples.workflows
  end

  test "terminal maintained navigation review keeps canonical targets free of host route syntax and stable across backends" do
    review = TerminalUi.Examples.navigation_transition_review()

    assert Enum.all?(review.raw_routes, fn {step, route} ->
             match?(%{navigation: _}, route.target) and
               route.target == review.tty_routes[step].target and
               get_in(route.target, [:navigation, :route]) == nil
           end)
  end
end
