defmodule UnifiedExamples.Phase1IntegrationTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureIO
  import Phoenix.ConnTest
  import Phoenix.LiveViewTest

  alias UnifiedExamples.Demo
  alias UnifiedExamples.Demo.Categories
  alias UnifiedExamples.Shared.Template

  @endpoint UnifiedExamples.Demo.Endpoint

  test "aggregate demo boots through the standalone Phoenix LiveView runtime path" do
    assert {:ok, runtime_state} = Demo.boot()
    assert runtime_state.assigns.iur.id == :demo_example_screen_shell

    {:ok, _view, html} = live(build_conn(), "/")

    assert html =~ "Examples Demo Application"
    assert html =~ "Aggregate category-oriented control demo scaffold"
    assert html =~ "data-example-directory=\"examples/demo\""
  end

  test "aggregate demo keeps the shared theme baseline and ordered category registry aligned" do
    metadata = Demo.review_metadata()
    assert {:ok, html} = Demo.render_html()

    assert metadata.theme_id == Template.default_theme_id()
    assert metadata.active_category_id == Categories.default_id()
    assert metadata.category_count == Categories.count()
    assert metadata.category_ids == Categories.ids()
    assert Enum.map(metadata.category_registry, & &1.id) == Categories.ids()

    assert html =~ "data-live-ui-widget=\"tabs\""
    assert html =~ "Foundational Content"
    assert html =~ "Signal Lab"
    assert html =~ "Active category: Foundational Content"
  end

  test "aggregate demo exposes consistent launch metadata through the app and shared launcher" do
    descriptor = Demo.launch_descriptor(port: 4170)

    output =
      capture_io(fn ->
        Mix.Tasks.Examples.Launch.run(["demo", "--dry-run", "--port", "4170"])
      end)

    assert descriptor.url == "http://127.0.0.1:4170/"
    assert descriptor.command =~ "examples/demo"
    assert output =~ "directory: demo"
    assert output =~ descriptor.url
    assert output =~ descriptor.command
  end
end
