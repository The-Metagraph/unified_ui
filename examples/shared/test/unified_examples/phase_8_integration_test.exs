defmodule UnifiedExamples.Phase8IntegrationTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureIO

  alias UnifiedExamples.Shared
  alias UnifiedExamples.Shared.AppReadme
  alias UnifiedExamples.Shared.Catalog
  alias UnifiedExamples.Shared.InteractionDemo
  alias UnifiedExamples.Shared.Maintenance
  alias UnifiedExamples.Shared.ReleaseReadiness
  alias UnifiedExamples.Shared.Tooling
  alias UnifiedExamples.Shared.Validation

  @moduletag timeout: 300_000

  @representative_apps %{
    content: "button",
    input: "text_input",
    navigation: "menu",
    data: "table",
    feedback: "status",
    display: "viewport",
    overlay: "overlay",
    operational: "cluster_dashboard"
  }

  test "representative examples expose meaningful browser-visible interaction stories" do
    Enum.each(@representative_apps, fn {family, directory} ->
      assert {:ok, metadata} = Tooling.review_metadata(directory)
      assert {:ok, smoke} = Tooling.smoke_launch(directory)
      assert {:ok, html} = Tooling.preview(directory, :html)

      assert metadata.family == family
      assert metadata.interaction_storytelling in [:source_driven, :target_driven]
      assert metadata.interaction_idle_prompt not in [nil, ""]
      assert metadata.interaction_outcome not in [nil, ""]

      assert smoke.status == 200
      assert smoke.body =~ "Meaningful Interaction Story"
      assert smoke.body =~ "Canonical Signal Preview"
      assert smoke.body =~ metadata.interaction_idle_prompt

      if metadata.interaction_trigger_label not in [nil, ""] do
        assert smoke.body =~ metadata.interaction_trigger_label
      end

      case directory do
        "button" ->
          assert html =~ ~s(phx-click="canonical_interaction")
          assert html =~ "Save profile"

        "text_input" ->
          assert html =~ ~s(phx-change="canonical_interaction")
          assert html =~ "Type your note"

        "menu" ->
          assert smoke.body =~ "Review the menu navigation story"

        "table" ->
          assert smoke.body =~ "Inspect the table data story"

        "status" ->
          assert smoke.body =~ "Inspect the status feedback story"

        "viewport" ->
          assert smoke.body =~ "Inspect the viewport display story"

        "overlay" ->
          assert smoke.body =~ "Inspect the overlay layered story"

        "cluster_dashboard" ->
          assert smoke.body =~ "Review the cluster dashboard command story"
      end
    end)
  end

  test "catalog and generated app readmes stay aligned with the interaction-story contract" do
    manifest = File.read!(Shared.catalog_manifest_path())

    assert manifest =~ "interaction_storytelling"
    assert AppReadme.report().synchronized?

    Enum.each(Catalog.entries(), fn entry ->
      assert entry.interaction_demo.family in [
               :click,
               :change,
               :submit,
               :selection,
               :navigation,
               :open,
               :close,
               :focus,
               :command
             ]

      assert InteractionDemo.storytelling(entry.interaction_demo) in [
               :source_driven,
               :target_driven
             ]

      assert entry.interaction_demo.idle_prompt not in [nil, ""]
      assert entry.interaction_demo.outcome not in [nil, ""]

      readme = File.read!(AppReadme.path(entry.directory))

      assert readme =~ "## Try It"
      assert readme =~ "## Expect"
      assert readme =~ entry.interaction_demo.idle_prompt
      assert readme =~ entry.interaction_demo.outcome
    end)
  end

  test "strict maintainer workflows enforce the meaningful interaction standard across the suite" do
    assert Validation.report().valid?
    assert ReleaseReadiness.report().valid?
    assert Maintenance.report().valid?

    validate_output =
      capture_io(fn ->
        Mix.Tasks.Examples.Validate.run(["--strict"])
      end)

    release_output =
      capture_io(fn ->
        Mix.Tasks.Examples.Release.run(["--strict"])
      end)

    assert validate_output =~ "interaction_story_valid?: true"
    assert validate_output =~ "release_valid?: true"
    assert release_output =~ "validation_valid?: true"
    assert release_output =~ "mix examples.release --strict"
  end
end
