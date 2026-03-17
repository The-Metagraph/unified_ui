defmodule UnifiedExamples.ReleaseReadinessTest do
  use ExUnit.Case, async: false

  alias UnifiedExamples.Shared.ReleaseReadiness
  alias UnifiedExamples.Shared.Template

  @moduletag timeout: 120_000

  test "passes for the current suite catalog and shared template continuity" do
    report = ReleaseReadiness.report()

    assert report.valid?
    assert report.metadata_load_failures == []
    assert report.launch_failures == []
    assert report.gates.catalog_complete.passed?
    assert report.gates.primary_subject_coverage.passed?
    assert report.gates.shared_template_continuity.passed?
    assert report.gates.browser_launch_continuity.passed?
    assert report.gates.interaction_story_continuity.passed?
    assert report.gates.aggregate_demo_continuity.passed?
    assert report.gates.shared_template_continuity.default_theme_id == Template.default_theme_id()
  end

  test "release readiness detects primary-subject and template drift" do
    mismatched_primary_subjects =
      ReleaseReadiness.primary_subject_coverage([
        {"button", %{primary_subject: :text}},
        {"text", %{primary_subject: :text}}
      ])

    assert mismatched_primary_subjects.passed? == false
    assert :button in mismatched_primary_subjects.missing_subjects
    assert mismatched_primary_subjects.duplicate_subjects == %{text: ["button", "text"]}

    shared_template_drift =
      ReleaseReadiness.shared_template_continuity([
        {"button",
         %{
           theme_id: :rogue_theme,
           default_theme_id: :rogue_theme,
           uses_shared_template: false
         }}
      ])

    assert shared_template_drift.passed? == false

    assert Enum.map(shared_template_drift.divergent_apps, & &1.kind) == [
             :app_theme,
             :screen_theme,
             :style_profile
           ]

    browser_launch_drift =
      ReleaseReadiness.browser_launch_continuity([
        {"button", {:ok, %{status: 200}}},
        {"overlay", {:error, :not_bootable}}
      ])

    assert browser_launch_drift.passed? == false
    assert browser_launch_drift.failures == [%{directory: "overlay", reason: :not_bootable}]

    interaction_story_drift =
      ReleaseReadiness.interaction_story_continuity(
        [
          {"button",
           {:ok,
            %{
              interaction_idle_prompt: "Click the primary button.",
              interaction_trigger_label: nil
            }}}
        ],
        [
          {"button",
           {:ok,
            %{
              body: "<section><h2>Canonical Signal Preview</h2></section>"
            }}}
        ]
      )

    assert interaction_story_drift.passed? == false

    assert Enum.map(interaction_story_drift.failures, & &1.reason) == [
             :missing_story_panel,
             :missing_idle_prompt
           ]

    aggregate_demo_drift =
      ReleaseReadiness.aggregate_demo_continuity(
        {"demo",
         {:ok,
          %{
            theme_id: :rogue_theme,
            default_theme_id: :rogue_theme,
            uses_shared_template: false,
            category_ids: [:foundational_content],
            signal_lab_contract: %{valid?: false, story_ids: [:action_to_feedback]},
            linked_example_directories: []
          }}}
      )

    assert aggregate_demo_drift.passed? == false

    assert Enum.map(aggregate_demo_drift.failures, & &1.reason) == [
             :app_theme_mismatch,
             :screen_theme_mismatch,
             :style_profile_drift,
             :category_registry_mismatch,
             :invalid_signal_lab_contract,
             :signal_lab_story_inventory_mismatch,
             :missing_linked_examples
           ]
  end
end
