defmodule UnifiedUi.GitHubAutomationConfigTest do
  use ExUnit.Case, async: true

  @ci_workflow_path ".github/workflows/ci.yml"
  @release_workflow_path ".github/workflows/release.yml"
  @bug_template_path ".github/ISSUE_TEMPLATE/bug_report.yml"
  @feature_template_path ".github/ISSUE_TEMPLATE/feature_request.yml"
  @guide_feedback_template_path ".github/ISSUE_TEMPLATE/guide_feedback.yml"
  @issue_config_path ".github/ISSUE_TEMPLATE/config.yml"
  @pr_template_path "PULL_REQUEST_TEMPLATE.md"

  test "ci workflow defines lint, test, and benchmark checks for pull requests and main pushes" do
    ci_workflow = File.read!(@ci_workflow_path)

    assert ci_workflow =~ "pull_request:"
    assert ci_workflow =~ "push:"
    assert ci_workflow =~ "- main"
    assert ci_workflow =~ "\n  lint:"
    assert ci_workflow =~ "\n  test:"
    assert ci_workflow =~ "\n  benchmark:"
    assert ci_workflow =~ "elixir-lint.yml@main"
    assert ci_workflow =~ "elixir-test.yml@main"
    assert ci_workflow =~ "test_command: mix test --cover"
    assert ci_workflow =~ "test_command: MIX_ENV=dev mix unified_ui.bench --quick"
    assert ci_workflow =~ "MIX_ENV=dev mix unified_ui.perf.check --quick"
  end

  test "ci workflow covers multiple OTP/Elixir versions" do
    ci_workflow = File.read!(@ci_workflow_path)

    assert ci_workflow =~ ~s(otp_versions: '["27", "28"]')
    assert ci_workflow =~ ~s(elixir_versions: '["1.18", "1.19"]')
  end

  test "ci lint command enforces format, compile, credo, and dialyzer checks" do
    ci_workflow = File.read!(@ci_workflow_path)

    assert ci_workflow =~ "lint_command:"
    assert ci_workflow =~ "mix format --check-formatted"
    assert ci_workflow =~ "mix compile --warnings-as-errors"
    assert ci_workflow =~ "mix credo --strict"
    assert ci_workflow =~ "mix dialyzer --format raw --ignore-exit-status"
  end

  test "release workflow is configured for controlled manual releases" do
    release_workflow = File.read!(@release_workflow_path)

    assert release_workflow =~ "workflow_dispatch:"
    assert release_workflow =~ "dry_run:"
    assert release_workflow =~ "hex_dry_run:"
    assert release_workflow =~ "skip_tests:"
    assert release_workflow =~ "elixir-release.yml@main"
    assert release_workflow =~ "contents: write"
  end

  test "issue and pr templates provide required authoring structure" do
    bug_template = File.read!(@bug_template_path)
    feature_template = File.read!(@feature_template_path)
    guide_feedback_template = File.read!(@guide_feedback_template_path)
    issue_config = File.read!(@issue_config_path)
    pr_template = File.read!(@pr_template_path)

    assert bug_template =~ "Summary"
    assert bug_template =~ "Steps to reproduce"
    assert bug_template =~ "Expected behavior"

    assert feature_template =~ "Problem statement"
    assert feature_template =~ "Proposed solution"
    assert feature_template =~ "Impact and use cases"

    assert guide_feedback_template =~ "Guide or tutorial"
    assert guide_feedback_template =~ "What was unclear?"
    assert guide_feedback_template =~ "Impact on progress"

    assert issue_config =~ "blank_issues_enabled: false"
    assert issue_config =~ "mailto:"

    assert pr_template =~ "## Summary"
    assert pr_template =~ "## Changes"
    assert pr_template =~ "## Validation"
    assert pr_template =~ "## Checklist"
  end
end
