defmodule UnifiedUi.DocumentationTest do
  use ExUnit.Case, async: true

  alias UnifiedUi.Tooling

  test "tracks the package documentation surface and docs extras" do
    documentation = Tooling.documentation_surface()
    docs = UnifiedUi.MixProject.project()[:docs]

    assert documentation.complete?
    assert documentation.missing_paths == []

    assert docs[:extras] == [
             "README.md",
             "guides/dsl_model.md",
             "guides/theming_and_signals.md",
             "guides/compiler_and_parity.md",
             "guides/maintainer_workflows.md"
           ]
  end
end
