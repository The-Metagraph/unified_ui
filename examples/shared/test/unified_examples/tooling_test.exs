defmodule UnifiedExamples.ToolingTest do
  use ExUnit.Case, async: false

  alias UnifiedExamples.Shared.Tooling

  test "catalog report includes the aggregate demo alongside focused widget apps" do
    report = Tooling.catalog_report()

    assert report =~ "Focused widget apps"
    assert report =~ "Aggregate review surfaces"
    assert report =~ "button\twidget=button"
    assert report =~ "demo\twidget=demo"
    assert report =~ "purpose=aggregate_demo"
  end

  test "builds review metadata for representative apps from multiple families" do
    assert {:ok, button} = Tooling.review_metadata("button")
    assert {:ok, checkbox} = Tooling.review_metadata("checkbox")
    assert {:ok, overlay} = Tooling.review_metadata("overlay")

    assert button.family == :content
    assert button.widget == :button
    assert button.uses_shared_template
    assert button.interaction_family == :click
    assert button.interaction_storytelling == :source_driven
    assert button.interaction_source in [:shared_trigger, :primary_widget]
    assert is_binary(button.interaction_outcome)

    assert overlay.family == :overlay
    assert overlay.widget == :overlay
    assert overlay.uses_shared_template
    assert overlay.interaction_family == :open
    assert overlay.interaction_storytelling == :target_driven
    assert is_binary(overlay.interaction_idle_prompt)

    assert checkbox.family == :input
    assert checkbox.widget == :checkbox
    assert checkbox.interaction_family == :change
    assert checkbox.interaction_storytelling == :source_driven
    assert checkbox.interaction_source == :form_shell
  end

  test "previews representative apps through one shared workflow" do
    assert {:ok, report} = Tooling.preview("button", :report)
    assert {:ok, html} = Tooling.preview("overlay", :html)
    assert {:ok, metadata} = Tooling.preview("cluster_dashboard", :metadata)

    assert report =~ "directory: button"
    assert report =~ "widget: button"
    assert report =~ "interaction_family: click"
    assert report =~ "interaction_storytelling: source_driven"
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

  test "builds deterministic launch descriptors for browser-runnable example apps" do
    button = Tooling.launch_descriptor("button")
    overlay = Tooling.launch_descriptor("overlay", port: 4104)
    demo = Tooling.launch_descriptor("demo", port: 4105)

    assert button.cwd =~ "/examples/button"
    assert button.argv == ["mix", "phx.server"]
    assert button.env == [{"PORT", "4000"}]
    assert button.path == "/"
    assert button.url == "http://127.0.0.1:4000/"
    assert button.command =~ "PORT=4000 mix phx.server"

    assert overlay.cwd =~ "/examples/overlay"
    assert overlay.env == [{"PORT", "4104"}]
    assert overlay.url == "http://127.0.0.1:4104/"
    assert overlay.command =~ "PORT=4104 mix phx.server"

    assert demo.cwd =~ "/examples/demo"
    assert demo.env == [{"PORT", "4105"}]
    assert demo.url == "http://127.0.0.1:4105/"
    assert demo.command =~ "PORT=4105 mix phx.server"
  end
end
