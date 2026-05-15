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
             "docs/README.md",
             "docs/user/getting-started.md",
             "docs/user/widget-catalog.md",
             "docs/user/layouts-layers-and-display.md",
             "docs/user/styling-and-themes.md",
             "docs/user/bindings-and-interactions.md",
             "docs/user/canonical-navigation.md",
             "docs/developer/architecture-overview.md",
             "docs/developer/dsl-section-model.md",
             "docs/developer/compilation-pipeline.md",
             "docs/developer/package-components.md",
             "docs/developer/canonical-navigation.md",
             "guides/dsl_model.md",
             "guides/theming_and_signals.md",
             "guides/compiler_and_parity.md",
             "guides/maintainer_workflows.md"
           ]
  end

  test "documents CSS block caveats in styling guidance" do
    styling_doc = File.read!("docs/user/styling-and-themes.md")

    assert styling_doc =~ "CSS stylesheet blocks"
    assert styling_doc =~ "does not imply full browser CSS semantic equivalence"
    assert styling_doc =~ "raw runtime CSS"
  end
end
