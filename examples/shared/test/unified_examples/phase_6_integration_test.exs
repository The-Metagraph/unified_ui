defmodule UnifiedExamples.Phase6IntegrationTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureIO

  alias UnifiedExamples.Shared
  alias UnifiedExamples.Shared.Catalog
  alias UnifiedExamples.Shared.Documentation
  alias UnifiedExamples.Shared.Maintenance
  alias UnifiedExamples.Shared.ReleaseReadiness
  alias UnifiedExamples.Shared.Template
  alias UnifiedExamples.Shared.Tooling
  alias UnifiedExamples.Shared.Traceability

  @moduletag timeout: 240_000

  @representative_apps %{
    content: "button",
    layout: "row",
    display: "viewport",
    forms: "form_builder",
    input: "text_input",
    navigation: "tabs",
    data: "table",
    feedback: "progress",
    overlay: "dialog",
    operational: "cluster_dashboard"
  }

  test "full widget catalog stays represented by runnable app directories and review metadata" do
    assert Shared.app_directories() == Catalog.directories()

    Enum.each(Catalog.entries(), fn entry ->
      assert File.dir?(Path.join(Shared.suite_root(), entry.directory))
      assert {:ok, metadata} = Tooling.review_metadata(entry.directory)
      assert metadata.primary_subject == entry.widget
      assert metadata.family == entry.family
      assert metadata.phase == entry.phase
      assert Tooling.run_descriptor(entry.directory).cwd =~ "/examples/#{entry.directory}"
    end)

    Enum.each(@representative_apps, fn {_family, directory} ->
      assert {:ok, output} = Tooling.run(directory)
      assert output =~ "0 failures"
    end)
  end

  test "shared template and shared default theme stay consistent across representative families" do
    Enum.each(@representative_apps, fn {family, directory} ->
      assert {:ok, metadata} = Tooling.review_metadata(directory)
      assert {:ok, inspection} = Tooling.preview(directory, :inspection)

      assert metadata.family == family
      assert metadata.theme_id == Template.default_theme_id()
      assert metadata.default_theme_id == Template.default_theme_id()
      assert metadata.style_profile == Template.default_style_profile()
      assert metadata.uses_shared_template
      assert is_list(inspection.widgets)
      assert inspection.widgets != []
    end)
  end

  test "suite passes the full release workflow through one repeatable maintainer command path" do
    assert Documentation.report().valid?
    assert Traceability.report().valid?
    assert ReleaseReadiness.report().valid?
    assert Maintenance.report().valid?

    output =
      capture_io(fn ->
        Mix.Tasks.Examples.Release.run(["--strict"])
      end)

    assert output =~ "Example suite maintainer workflow"
    assert output =~ "documentation_valid?: true"
    assert output =~ "traceability_valid?: true"
    assert output =~ "validation_valid?: true"
    assert output =~ "mix examples.release --strict"
  end
end
