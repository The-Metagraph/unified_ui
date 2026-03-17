defmodule UnifiedExamples.Phase3IntegrationTest do
  use ExUnit.Case, async: false

  import Phoenix.ConnTest
  import Phoenix.LiveViewTest

  alias UnifiedExamples.Demo
  alias UnifiedExamples.Demo.Categories
  alias UnifiedExamples.Shared.Runtime
  alias UnifiedExamples.Shared.Template

  @endpoint UnifiedExamples.Demo.Endpoint

  test "advanced category galleries render through one shared tabbed review flow" do
    {:ok, view, html} = live(build_conn(), "/")

    assert html =~ "Examples Demo Application"
    assert html =~ "Linked example apps"
    assert html =~ "Representative gallery"

    html =
      view
      |> element("#demo-category-tab-navigation_and_selection")
      |> render_click()

    assert html =~ "Navigation and Selection Gallery"
    assert html =~ "data-live-ui-widget=\"menu\""
    assert html =~ "data-live-ui-widget=\"tabs\""
    assert html =~ "data-live-ui-widget=\"list\""
    assert html =~ "data-live-ui-widget=\"command-palette\""

    html =
      view
      |> element("#demo-category-tab-data_and_feedback")
      |> render_click()

    assert html =~ "Data and Feedback Gallery"
    assert html =~ "data-live-ui-widget=\"table\""
    assert html =~ "data-live-ui-widget=\"tree-view\""
    assert html =~ "data-live-ui-widget=\"inline-feedback\""
    assert html =~ "data-live-ui-widget=\"line-chart\""

    html =
      view
      |> element("#demo-category-tab-overlays_and_operational")
      |> render_click()

    assert html =~ "Overlays and Operational Gallery"
    assert html =~ "data-live-ui-widget=\"dialog\""
    assert html =~ "data-live-ui-widget=\"overlay-surface\""
    assert html =~ "data-live-ui-widget=\"stream-widget\""
    assert html =~ "data-live-ui-widget=\"cluster-dashboard\""
    assert html =~ ~s(data-demo-panel-chrome="true")
  end

  test "phase 3 review metadata preserves theme continuity and cross-category traceability" do
    metadata = Demo.review_metadata()
    registry = Categories.review_registry()
    advanced_ids = [:navigation_and_selection, :data_and_feedback, :overlays_and_operational]

    assert metadata.theme_id == Template.default_theme_id()
    assert metadata.category_count == Categories.count()
    assert Enum.map(metadata.category_registry, & &1.id) == Categories.ids()
    assert Enum.all?(Enum.filter(registry, &(&1.id in advanced_ids)), &(&1.example_count > 0))

    {:ok, html} = Demo.render_html()

    assert html =~ "Examples Demo Application"
    assert html =~ "Category Registry Backbone"
    assert html =~ "Foundational Content"
    assert html =~ "Signal Lab"
  end

  test "advanced category fragments remain mountable through the shared live_ui runtime path" do
    for category_id <- [:navigation_and_selection, :data_and_feedback, :overlays_and_operational] do
      entry = Categories.review_entry!(category_id)

      assert {:ok, assigns} = Runtime.component_assigns(entry.fragment_module)
      assert is_binary(assigns.id)
      assert %{id: _id} = assigns.runtime_state.assigns.iur

      assert {:ok, html} = Runtime.render_html(entry.fragment_module)
      assert html =~ "data-live-ui-widget="
    end
  end
end
