defmodule UnifiedExamples.Phase6IntegrationTest do
  use ExUnit.Case, async: false

  import Phoenix.ConnTest
  import Phoenix.LiveViewTest

  alias UnifiedExamples.Demo
  alias UnifiedExamples.Demo.Fixtures
  alias UnifiedExamples.Shared.AggregateDemo
  alias UnifiedExamples.Shared.Catalog
  alias UnifiedExamples.Shared.Documentation
  alias UnifiedExamples.Shared.Maintenance
  alias UnifiedExamples.Shared.ReleaseReadiness
  alias UnifiedExamples.Shared.Template
  alias UnifiedExamples.Shared.Tooling
  alias UnifiedExamples.Shared.Validation

  @endpoint UnifiedExamples.Demo.Endpoint
  @moduletag timeout: 240_000

  test "final demo shell stays keyboard navigable and deterministic" do
    {:ok, view, html} = live(build_conn(), "/")

    assert html =~ "Examples Demo Application"
    assert html =~ ~s(role="tablist")
    assert html =~ ~s(data-demo-responsive-shell="true")
    assert html =~ ~s(data-demo-responsive-digest="#{Fixtures.digest()}")
    assert html =~ "Fixture digest:"
    assert html =~ "Responsive contract:"

    html =
      view
      |> element("#demo-category-tab-foundational_content")
      |> render_keydown(%{"key" => "End"})

    assert html =~ "data-demo-active-category=\"signal_lab\""
    assert html =~ "Moved focus and selection to the last category tab."
    assert html =~ "Signal Lab"
    assert html =~ "Cross-control interaction stories where authored signals visibly change other surfaces."
  end

  test "signal lab remains reachable through smoke launch and interactive runtime flows" do
    assert {:ok, smoke} = Tooling.smoke_launch("demo")

    assert smoke.directory == "demo"
    assert smoke.status == 200
    assert smoke.path == "/"
    assert smoke.body =~ "Examples Demo Application"
    assert smoke.body =~ ~s(data-demo-tablist="true")
    assert smoke.body =~ ~s(id="demo-category-tab-signal_lab")
    assert smoke.body =~ "Signal Lab"

    {:ok, view, _html} = live(build_conn(), "/")

    view
    |> element("#demo-category-tab-signal_lab")
    |> render_click()

    html =
      view
      |> element("#signal_lab_action_trigger")
      |> render_click()

    assert html =~ "Action signal acknowledged."
    assert html =~ "Action to Feedback reacted to a canonical click signal."
    assert html =~ "live_ui.click.action_to_feedback"
  end

  test "release-ready demo stays aligned with the catalog shared styling baseline and suite gates" do
    assert {:ok, demo} = Tooling.review_metadata("demo")
    assert {:ok, button} = Tooling.review_metadata("button")

    validation = Validation.report()
    release = ReleaseReadiness.report()
    documentation = Documentation.report()
    maintenance = Maintenance.report()

    assert validation.valid?
    assert validation.aggregate_demo.issues == []
    assert release.valid?
    assert release.aggregate_demo_launch_failures == []
    assert release.gates.aggregate_demo_continuity.passed?
    assert documentation.valid?
    assert documentation.aggregate_demo.synchronized?
    assert maintenance.valid?
    assert maintenance.validation.release.gates.aggregate_demo_continuity.passed?

    assert demo.category_ids == AggregateDemo.required_category_ids()
    assert demo.signal_lab_contract.valid?
    assert demo.signal_lab_contract.story_ids == AggregateDemo.required_signal_lab_story_ids()
    assert Enum.sort(demo.linked_example_directories) == Catalog.directories()

    assert demo.theme_id == Template.default_theme_id()
    assert demo.default_theme_id == Template.default_theme_id()
    assert demo.theme_id == button.theme_id
    assert demo.default_theme_id == button.default_theme_id
    assert demo.style_profile == Template.default_style_profile()
    assert demo.style_profile == button.style_profile
  end
end
