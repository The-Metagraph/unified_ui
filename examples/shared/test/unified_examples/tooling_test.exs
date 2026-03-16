defmodule UnifiedExamples.ToolingTest do
  use ExUnit.Case, async: false

  alias UnifiedExamples.Shared.Tooling

  test "builds review metadata for representative apps from multiple families" do
    assert {:ok, button} = Tooling.review_metadata("button")
    assert {:ok, overlay} = Tooling.review_metadata("overlay")

    assert button.family == :content
    assert button.widget == :button
    assert button.uses_shared_template

    assert overlay.family == :overlay
    assert overlay.widget == :overlay
    assert overlay.uses_shared_template
  end

  test "previews representative apps through one shared workflow" do
    assert {:ok, report} = Tooling.preview("button", :report)
    assert {:ok, html} = Tooling.preview("overlay", :html)
    assert {:ok, metadata} = Tooling.preview("cluster_dashboard", :metadata)

    assert report =~ "directory: button"
    assert report =~ "widget: button"
    assert html =~ ~s(data-live-ui-widget="overlay-surface")
    assert metadata.family == :operational
    assert metadata.widget == :cluster_dashboard
  end

  test "builds deterministic run descriptors for representative apps" do
    button = Tooling.run_descriptor("button")
    overlay = Tooling.run_descriptor("overlay")

    assert button.cwd =~ "/examples/button"
    assert button.argv == ["mix", "test"]
    assert button.command =~ "examples/button"

    assert overlay.cwd =~ "/examples/overlay"
    assert overlay.argv == ["mix", "test"]
    assert overlay.command =~ "mix test"
  end
end
