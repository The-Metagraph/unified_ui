defmodule UnifiedExamples.Phase5IntegrationTest do
  use ExUnit.Case, async: false

  @moduletag timeout: 180_000

  alias UnifiedExamples.Shared
  alias UnifiedExamples.Shared.Catalog
  alias UnifiedExamples.Shared.Reporting
  alias UnifiedExamples.Shared.Template
  alias UnifiedExamples.Shared.Tooling
  alias UnifiedExamples.Shared.Validation

  test "maintainers can discover, run, and preview representative apps across families" do
    assert Tooling.catalog_report() =~ "button"
    assert Tooling.catalog_report() =~ "overlay"
    assert Tooling.catalog_report() =~ "cluster_dashboard"

    assert {:ok, button_preview} = Tooling.preview("button", :report)
    assert {:ok, overlay_preview} = Tooling.preview("overlay", :report)
    assert {:ok, cluster_metadata} = Tooling.preview("cluster_dashboard", :metadata)

    assert button_preview =~ "directory: button"
    assert overlay_preview =~ "widget: overlay"
    assert cluster_metadata.family == :operational
    assert cluster_metadata.primary_subject == :cluster_dashboard

    assert {:ok, button_run} = Tooling.run("button")
    assert {:ok, cluster_run} = Tooling.run("cluster_dashboard")

    assert button_run =~ "0 failures"
    assert cluster_run =~ "0 failures"
  end

  test "validation catches catalog drift and shared-template divergence reliably" do
    report = Validation.report()

    assert report.valid?
    assert report.catalog.missing_directories == []
    assert report.metadata.issues == []

    drift = Validation.catalog_findings(["button", "overlay"], ["button", "rogue_app"])
    assert drift.missing_directories == ["overlay"]
    assert drift.unexpected_directories == ["rogue_app"]

    issues =
      Validation.validate_review_metadata(%{
        directory: "rogue_app",
        theme_id: :rogue_theme,
        default_theme_id: :rogue_theme,
        uses_shared_template: false,
        shell_kind: :box,
        browser_runnable?: true,
        dev_server_enabled?: true,
        interaction_demo: %{
          mode: :source,
          family: :click,
          source: "test",
          outcome: "test",
          trigger_label: "test"
        },
        interaction_family: :click,
        interaction_storytelling: :source
      })

    # The rogue app should have theme/template issues but pass the new field checks
    assert Enum.map(issues, & &1.code) == [
             :app_theme_mismatch,
             :screen_theme_mismatch,
             :shared_template_divergence
           ]
  end

  test "suite metadata remains aligned with the catalog and root index" do
    report = Reporting.suite_report()

    assert File.exists?(Shared.suite_index_path())
    assert File.exists?(Shared.catalog_manifest_path())
    assert Shared.catalog_manifest() == File.read!(Shared.catalog_manifest_path())

    assert report.catalog.total == length(Catalog.entries())

    assert report.catalog.by_family[:display] == [
             "viewport",
             "scroll_bar",
             "split_pane",
             "canvas"
           ]

    assert report.catalog.by_family[:overlay] == [
             "overlay",
             "dialog",
             "alert_dialog",
             "context_menu",
             "toast"
           ]

    assert report.template.default_theme_id == Template.default_theme_id()
    assert report.validation.valid?
  end
end
