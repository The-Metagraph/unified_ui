defmodule UnifiedUi.GuidesExtensionsGuideTest do
  use ExUnit.Case, async: true

  @guide_path "guides/extensions.md"

  test "extensions guide covers core extension authoring sections" do
    markdown = File.read!(@guide_path)

    assert markdown =~ ~r/^## Creating Custom Widgets$/m
    assert markdown =~ ~r/^## Creating Custom Layouts$/m
    assert markdown =~ ~r/^## Creating Custom Renderers$/m
    assert markdown =~ ~r/^## Extension API Reference$/m
  end

  test "extensions guide includes publishing guidance for Hex, naming, and versioning" do
    markdown = File.read!(@guide_path)

    assert markdown =~ ~r/^## Extension Publishing$/m
    assert markdown =~ "Hex package: `unified_ui_<extension_name>`"
    assert markdown =~ "Apply versioning guidelines (SemVer)"
    assert markdown =~ "mix hex.publish"
  end
end
