defmodule UnifiedExamples.DemoTest do
  use ExUnit.Case, async: false

  import Phoenix.ConnTest
  import Phoenix.LiveViewTest

  alias UnifiedExamples.Demo

  @endpoint UnifiedExamples.Demo.Endpoint

  test "demo app exposes aggregate-demo metadata" do
    metadata = Demo.metadata()

    assert metadata.id == :demo_example_screen
    assert metadata.root_id == :demo_example_screen_root
    assert metadata.title == "Examples Demo Application"
    assert metadata.widget == :demo
    assert metadata.app == :unified_example_demo
    assert metadata.directory == "examples/demo"
    assert metadata.purpose == :aggregate_demo
    assert metadata.interaction_demo.mode == :placeholder
    assert metadata.interaction_demo.family == :select
  end

  test "demo app renders the authored scaffold through the LiveUi runtime" do
    assert {:ok, runtime_state} = Demo.boot()
    assert {:ok, html} = Demo.render_html()

    assert runtime_state.assigns.iur.id == :demo_example_screen_shell
    assert html =~ "Examples Demo Application"
    assert html =~ "Aggregate category-oriented control demo scaffold"
    assert html =~ "Standalone Phoenix LiveView scaffold is active."
    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "data-live-ui-runtime=\"screen\""
  end

  test "demo app mounts through its standalone Phoenix LiveView route" do
    {:ok, _view, html} = live(build_conn(), "/")

    assert html =~ "Examples Demo Application"
    assert html =~ "Aggregate category-oriented control demo scaffold"
    assert html =~ "data-example-directory=\"examples/demo\""
  end
end
