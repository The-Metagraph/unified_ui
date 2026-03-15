defmodule UnifiedExamples.ValidationTest do
  use ExUnit.Case, async: false

  @moduletag timeout: 120_000

  alias UnifiedExamples.Shared.Validation

  test "passes for the current suite catalog and shared template contract" do
    report = Validation.report()

    assert report.valid?
    assert report.catalog.missing_directories == []
    assert report.catalog.unexpected_directories == []
    assert report.catalog.manifest_in_sync?
    assert report.metadata.issues == []
  end

  test "detects catalog drift when expected and actual directories diverge" do
    findings = Validation.catalog_findings(["button", "overlay"], ["button", "rogue_app"])

    assert findings.missing_directories == ["overlay"]
    assert findings.unexpected_directories == ["rogue_app"]
  end

  test "detects shared template and theme divergence in review metadata" do
    issues =
      Validation.validate_review_metadata(%{
        directory: "rogue_app",
        theme_id: :rogue_theme,
        default_theme_id: :rogue_theme,
        uses_shared_template: false,
        shell_kind: :box
      })

    assert Enum.map(issues, & &1.code) == [
             :app_theme_mismatch,
             :screen_theme_mismatch,
             :shared_template_divergence
           ]
  end
end
