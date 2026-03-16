defmodule UnifiedExamples.ReviewMetadataTest do
  use ExUnit.Case, async: false

  alias UnifiedExamples.Shared.Catalog
  alias UnifiedExamples.Shared.Reporting
  alias UnifiedExamples.Shared.Template
  alias UnifiedExamples.Shared.Tooling

  @moduletag timeout: 120_000

  test "per-app review metadata stays traceable to the example catalog" do
    assert {:ok, button} = Tooling.review_metadata("button")
    assert {:ok, cluster_dashboard} = Tooling.review_metadata("cluster_dashboard")

    assert button.primary_subject == :button
    assert button.family == Catalog.entry!("button").family
    assert button.phase == Catalog.entry!("button").phase
    assert button.uses_shared_template
    assert button.browser_runnable?
    assert button.launch_path == "/"
    assert button.launch_command =~ "mix phx.server"
    assert button.traceability.authored_dsl.package == :unified_ui

    assert cluster_dashboard.primary_subject == :cluster_dashboard
    assert cluster_dashboard.family == Catalog.entry!("cluster_dashboard").family
    assert cluster_dashboard.phase == Catalog.entry!("cluster_dashboard").phase
    assert cluster_dashboard.default_theme_id == Template.default_theme_id()
    assert cluster_dashboard.browser_runnable?
    assert cluster_dashboard.launch_url =~ "http://127.0.0.1:"
    assert cluster_dashboard.traceability.runtime_library.package == :live_ui
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
    assert report.traceability.valid?
    assert report.validation.valid?
  end
end
