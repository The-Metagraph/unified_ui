defmodule DesktopUi.DocumentationTest do
  use ExUnit.Case, async: true

  test "documentation surface lists maintained guides and files exist" do
    docs = DesktopUi.Tooling.documentation_surface()
    package_root = Path.expand("../..", __DIR__)

    assert docs == [
             "README.md",
             "guides/runtime_backbone.md",
             "guides/native_runtime_and_examples.md",
             "guides/canonical_rendering_and_transport.md",
             "guides/styling_platforms_and_artifacts.md",
             "guides/maintainer_workflows.md"
           ]

    assert Enum.all?(docs, fn relative_path ->
             package_root
             |> Path.join(relative_path)
             |> File.exists?()
           end)
  end

  test "reference and info summary helpers expose maintained review surfaces" do
    reference_examples = DesktopUi.Reference.example_summary()
    info_examples = DesktopUi.Info.example_summary()
    reference_transport = DesktopUi.Reference.transport_summary()
    info_transport = DesktopUi.Info.transport_summary()
    reference_style = DesktopUi.Reference.style_summary()
    info_style = DesktopUi.Info.style_summary()
    reference_artifacts = DesktopUi.Reference.artifact_summary()
    info_artifacts = DesktopUi.Info.artifact_summary()

    assert :native_styled_review in reference_examples.native_ids
    assert :canonical_styled_review in reference_examples.canonical_ids
    assert :styled_continuity_review in reference_examples.comparison_ids
    assert :style_review in Map.keys(reference_examples.coverage_matrix.workflows)
    assert :style_review in info_examples.workflows

    assert :canonical_signal_translation in reference_transport.integration_points
    assert :command in reference_transport.families
    assert :shortcut in info_transport.input_families

    assert reference_style.style.validation_state.direct_native_surface == :ready
    assert reference_style.theme.default_theme == :desktop_default
    assert :platform_semantics in reference_style.continuity.seams
    assert info_style.theme.default_theme == :desktop_default

    assert reference_artifacts.target_platforms == [:windows, :macos, :linux]
    assert reference_artifacts.validation_state.packaging_boundaries == :ready
    assert info_artifacts.target_platforms == [:windows, :macos, :linux]
  end
end
