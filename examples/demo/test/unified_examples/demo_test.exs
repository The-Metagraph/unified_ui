defmodule UnifiedExamples.DemoTest do
  use ExUnit.Case, async: false

  import Phoenix.ConnTest
  import Phoenix.LiveViewTest

  alias UnifiedExamples.Demo
  alias UnifiedExamples.Demo.Categories
  alias UnifiedExamples.Shared.Template

  @endpoint UnifiedExamples.Demo.Endpoint

  test "demo app exposes aggregate-demo metadata" do
    metadata = Demo.metadata()

    assert metadata.id == :demo_example_screen
    assert metadata.root_id == :demo_example_screen_root
    assert metadata.title == "Examples Demo Application"
    assert metadata.widget == :demo
    assert metadata.theme_id == :example_suite_default
    assert metadata.active_category_id == :foundational_content
    assert metadata.category_count == 7
    assert metadata.category_ids == Categories.ids()
    assert metadata.app == :unified_example_demo
    assert metadata.directory == "examples/demo"
    assert metadata.purpose == :aggregate_demo
    assert metadata.interaction_demo.mode == :shared_trigger
    assert metadata.interaction_demo.family == :navigation
  end

  test "demo app reuses the shared button-example theme and style contract" do
    assert Demo.screen_module().default_theme_id() == Template.default_theme_id()
    assert Demo.screen_module().shared_style_profile() == Template.default_style_profile()
    assert Demo.metadata().theme_id == Template.default_theme_id()
  end

  test "demo app exposes launch metadata aligned with the root screen and category registry" do
    metadata = Demo.review_metadata()
    launch = Demo.launch_descriptor()

    assert metadata.active_category_id == Categories.default_id()
    assert metadata.category_count == Categories.count()
    assert metadata.category_ids == Categories.ids()
    assert Enum.map(metadata.category_registry, & &1.id) == Categories.ids()
    assert metadata.launch_path == Demo.launch_path()
    assert metadata.launch_url == Demo.launch_url()
    assert metadata.launch_command == launch.command
    assert metadata.review_summary == Demo.review_summary()
    assert metadata.browser_runnable?
  end

  test "demo app renders the shared shell treatment through the LiveUi runtime" do
    assert {:ok, runtime_state} = Demo.boot()
    assert {:ok, html} = Demo.render_html()

    assert runtime_state.assigns.iur.id == :demo_example_screen_shell
    assert html =~ "Examples Demo Application"
    assert html =~ "Aggregate category-oriented control demo scaffold"
    assert html =~ "Standalone Phoenix LiveView scaffold is active."
    assert html =~ "same shared theme and style profile as the current button example"
    assert html =~ "Preview the aggregate demo shell"
    assert html =~ "Category Registry Backbone"
    assert html =~ "Foundational Content"
    assert html =~ "Signal Lab"
    assert html =~ "Active category: Foundational Content"
    assert html =~ "data-live-ui-variant=\"solid\""
    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "data-live-ui-widget=\"tabs\""
    assert html =~ "data-live-ui-runtime=\"screen\""
  end

  test "demo app mounts through its standalone Phoenix LiveView route" do
    {:ok, _view, html} = live(build_conn(), "/")

    assert html =~ "Examples Demo Application"
    assert html =~ "Aggregate category-oriented control demo scaffold"
    assert html =~ "data-example-directory=\"examples/demo\""
    assert html =~ "data-example-interaction-family=\"navigation\""
    assert html =~ Demo.review_summary()
    assert html =~ Demo.launch_url()
    assert html =~ "Foundational Content Gallery"
    assert html =~ "Review shared CTA"
    assert html =~ "Open shared guidelines"
    assert html =~ "data-example-launch-url=\"#{Demo.launch_url()}\""
    assert html =~ "data-example-category-count=\"7\""
  end

  test "tab selection updates the active category review content and labeling" do
    {:ok, view, html} = live(build_conn(), "/")

    assert html =~ "data-demo-active-category=\"foundational_content\""
    assert html =~ "Active category: Foundational Content"

    html =
      view
      |> element("#demo-category-tab-forms_and_input")
      |> render_click()

    assert html =~ "data-demo-active-category=\"forms_and_input\""
    assert html =~ "Forms and Input Gallery"
    assert html =~ "Forms and Input"
    assert html =~ "Structured data entry, field composition, and input-focused review flows."
    assert html =~ "Display name"
    assert html =~ "Region"
    assert html =~ "data-live-ui-widget=\"form-builder\""
    assert html =~ "data-live-ui-widget=\"text-input\""
    assert html =~ "data-live-ui-widget=\"toggle\""
    assert html =~ "data-demo-category-panel=\"forms_and_input\""
  end

  test "layout and display gallery stays stable across tab switches" do
    {:ok, view, _html} = live(build_conn(), "/")

    html =
      view
      |> element("#demo-category-tab-layout_and_display")
      |> render_click()

    assert html =~ "data-demo-active-category=\"layout_and_display\""
    assert html =~ "Layout and Display Gallery"
    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "data-live-ui-widget=\"row\""
    assert html =~ "data-live-ui-widget=\"column\""
    assert html =~ "data-live-ui-widget=\"grid\""
    assert html =~ "data-live-ui-widget=\"viewport\""
    assert html =~ "data-live-ui-widget=\"scroll-bar\""
    assert html =~ "data-live-ui-widget=\"split-pane\""
    assert html =~ "data-live-ui-widget=\"canvas\""
    assert html =~ "data-demo-category-panel=\"layout_and_display\""
  end
end
