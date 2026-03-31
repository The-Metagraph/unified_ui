defmodule LiveUi.ValidationTest do
  use ExUnit.Case, async: true

  test "validation report summarizes example health continuity transport and runtime authority" do
    report = LiveUi.Tooling.validation_report()

    assert report.example_health.all_passing?
    assert report.example_coverage.complete?
    assert report.continuity.aligned?
    assert report.continuity.browser_style_aligned?
    assert report.transport.sound?
    assert report.runtime_authority.server_authoritative?
    assert report.documentation_surface.complete?
    assert report.release_readiness.ready?

    assert :paired_native_and_canonical_example_review in report.governance_gates.change_review_expectations
  end

  test "validation summary prints actionable release-readiness information" do
    summary = LiveUi.Tooling.validation_summary(LiveUi.Tooling.validation_report())

    assert summary =~ "LiveUi validation summary"
    assert summary =~ "examples passing?: true"
    assert summary =~ "continuity aligned?: true"
    assert summary =~ "browser style aligned?: true"
    assert summary =~ "documentation complete?: true"
    assert summary =~ "release ready?: true"
  end
end
