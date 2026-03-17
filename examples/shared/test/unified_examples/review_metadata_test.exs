defmodule UnifiedExamples.ReviewMetadataTest do
  use ExUnit.Case, async: false

  alias UnifiedExamples.Shared.Catalog
  alias UnifiedExamples.Shared.Reporting
  alias UnifiedExamples.Shared.Template
  alias UnifiedExamples.Shared.Tooling

  @moduletag timeout: 120_000

  test "per-app review metadata stays traceable to the example catalog" do
    assert {:ok, button} = Tooling.review_metadata("button")
    assert {:ok, checkbox} = Tooling.review_metadata("checkbox")
    assert {:ok, cluster_dashboard} = Tooling.review_metadata("cluster_dashboard")
    assert {:ok, demo} = Tooling.review_metadata("demo")

    assert button.primary_subject == :button
    assert button.family == Catalog.entry!("button").family
    assert button.phase == Catalog.entry!("button").phase
    assert button.uses_shared_template
    assert button.browser_runnable?
    assert button.launch_path == "/"
    assert button.launch_command =~ "mix phx.server"
    assert button.interaction_family == Catalog.entry!("button").interaction_demo.family
    assert button.interaction_storytelling == :source_driven
    assert button.interaction_source == Catalog.entry!("button").interaction_demo.source
    assert button.interaction_outcome == Catalog.entry!("button").interaction_demo.outcome
    assert button.traceability.authored_dsl.package == :unified_ui

    assert checkbox.primary_subject == :checkbox
    assert checkbox.family == Catalog.entry!("checkbox").family
    assert checkbox.interaction_family == Catalog.entry!("checkbox").interaction_demo.family
    assert checkbox.interaction_storytelling == :source_driven
    assert checkbox.interaction_source == Catalog.entry!("checkbox").interaction_demo.source

    assert cluster_dashboard.primary_subject == :cluster_dashboard
    assert cluster_dashboard.family == Catalog.entry!("cluster_dashboard").family
    assert cluster_dashboard.phase == Catalog.entry!("cluster_dashboard").phase
    assert cluster_dashboard.default_theme_id == Template.default_theme_id()
    assert cluster_dashboard.browser_runnable?
    assert cluster_dashboard.launch_url =~ "http://127.0.0.1:"
    assert cluster_dashboard.interaction_family == :command
    assert cluster_dashboard.interaction_storytelling == :target_driven
    assert is_binary(cluster_dashboard.interaction_idle_prompt)
    assert cluster_dashboard.traceability.runtime_library.package == :live_ui

    assert demo.purpose == :aggregate_demo
    assert demo.theme_id == Template.default_theme_id()
    assert demo.default_theme_id == Template.default_theme_id()
    assert demo.uses_shared_template
    assert demo.category_count == 7

    assert demo.category_ids == [
             :foundational_content,
             :forms_and_input,
             :layout_and_display,
             :navigation_and_selection,
             :data_and_feedback,
             :overlays_and_operational,
             :signal_lab
           ]

    assert demo.signal_lab_contract.valid?

    assert demo.signal_lab_contract.story_ids == [
             :action_to_feedback,
             :input_to_preview,
             :selection_to_filter,
             :toggle_to_visibility_or_enabled_state
           ]

    assert "button" in demo.linked_example_directories

    assert demo.category_example_directories.signal_lab == [
             "button",
             "text_input",
             "select",
             "toggle"
           ]
  end

  test "suite review report stays aligned with the catalog and root discovery surfaces" do
    report = Reporting.suite_report()

    assert report.index.readme_path =~ "/examples/README.md"
    assert report.index.manifest_path =~ "/examples/catalog.tsv"
    assert report.catalog.total == length(Catalog.entries())
    assert report.catalog.family_counts[:overlay] == 5
    assert report.catalog.family_counts[:operational] == 4
    assert report.template.default_theme_id == Template.default_theme_id()
    assert report.runtime.launchable_total == length(Catalog.entries())
    assert report.runtime.mount_paths["button"] == "/"
    assert "button" in report.interaction_stories.source_driven_directories
    assert "overlay" in report.interaction_stories.target_driven_directories
    assert report.interaction_stories.follow_up_directories == []
    assert report.traceability.valid?
    assert report.validation.valid?
  end
end
