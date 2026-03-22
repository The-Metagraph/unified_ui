defmodule TerminalUi.DocumentationTest do
  use ExUnit.Case, async: true

  test "documentation surface includes the maintained runtime canonical and inspection guides" do
    assert TerminalUi.Tooling.documentation_surface() == [
             "README.md",
             "guides/runtime_backbone.md",
             "guides/native_runtime_and_examples.md",
             "guides/canonical_rendering_and_transport.md",
             "guides/styling_capabilities_and_inspection.md",
             "guides/maintainer_workflows.md"
           ]

    package_root = Path.expand("../..", __DIR__)

    Enum.each(TerminalUi.Tooling.documentation_surface(), fn path ->
      assert File.exists?(Path.join(package_root, path))
    end)
  end

  test "reference and info helpers expose maintainer summaries for docs tooling and shared runtime boundaries" do
    reference = TerminalUi.Reference.package_reference()
    summary = TerminalUi.info()

    assert reference.documentation.maintainer_commands == TerminalUi.Tooling.mix_tasks()

    assert reference.documentation.shared_runtime_contract.direct_native_and_canonical_share_runtime

    assert :date_input in reference.renderer.supported_kinds
    assert :form_builder in reference.renderer.supported_kinds
    assert reference.validation.inspect == TerminalUi.Inspect
    assert reference.validation.validate == TerminalUi.Validate

    assert :styled_degradation_review in reference.examples.mixed_ids

    assert summary.validation.example_coverage == :pass
    assert summary.validation.transport_validation == :pass
    assert summary.documentation.guides == TerminalUi.Tooling.documentation_surface()
    assert TerminalUi.Inspect in summary.documentation.preview_surfaces
    assert "mix terminal_ui.validate" in summary.tooling.mix_tasks
  end
end
