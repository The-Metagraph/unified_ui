defmodule UnifiedExamples.SelfContainedBlueprintPhaseOneIntegrationTest do
  use ExUnit.Case, async: true

  alias UnifiedExamples.Shared
  alias UnifiedExamples.Shared.SelfContainedBlueprint

  test "phase one report combines inventory, baseline, blueprint, policy, and proof surfaces" do
    report = SelfContainedBlueprint.phase_one_report()

    assert report.valid?
    assert report.checks.inventory_complete?
    assert report.checks.guide_bundle_present?
    assert report.checks.baseline_source_present?
    assert report.checks.runtime_blueprint_complete?
    assert report.checks.authored_blueprint_complete?
    assert report.checks.conditional_surfaces_complete?
    assert report.checks.forbidden_surface_policy_complete?
    assert report.checks.allowed_framework_macros_complete?
    assert report.checks.validation_rules_complete?
    assert report.checks.reference_examples_exist?
    assert report.checks.reference_shapes_complete?
    assert report.checks.replacement_map_complete?

    assert report.inventory.total_directories == length(Shared.app_directories())
    assert report.baseline.default_theme_id == :example_suite_default
    assert report.blueprint.guide_path == SelfContainedBlueprint.guide_paths().blueprint
    assert report.proof.guide_path == SelfContainedBlueprint.guide_paths().proof
  end

  test "phase one summary stays readable for maintainers" do
    summary =
      SelfContainedBlueprint.phase_one_summary(%{
        valid?: true,
        checks: %{
          inventory_complete?: true,
          guide_bundle_present?: true,
          baseline_source_present?: true,
          runtime_blueprint_complete?: true,
          authored_blueprint_complete?: true,
          reference_examples_exist?: true,
          reference_shapes_complete?: true,
          replacement_map_complete?: true
        }
      })

    assert summary =~ "Phase 1 self-contained blueprint"
    assert summary =~ "inventory_complete?: true"
    assert summary =~ "reference_examples_exist?: true"
    assert summary =~ "replacement_map_complete?: true"
  end
end
