defmodule UnifiedExamples.Phase2IntegrationTest do
  use ExUnit.Case, async: false

  import Phoenix.ConnTest
  import Phoenix.LiveViewTest

  alias UnifiedExamples.Demo
  alias UnifiedExamples.Demo.Categories
  alias UnifiedExamples.Shared.Runtime
  alias UnifiedExamples.Shared.Template

  @endpoint UnifiedExamples.Demo.Endpoint

  test "aggregate demo keeps the shared shell stable while switching across the phase 2 tabs" do
    {:ok, view, html} = live(build_conn(), "/")

    assert html =~ "Examples Demo Application"
    assert html =~ "Aggregate category review"
    assert html =~ "Representative gallery"
    assert html =~ "data-demo-active-category=\"foundational_content\""
    assert html =~ "Foundational Content Gallery"
    assert html =~ "Review shared CTA"
    assert html =~ "Open shared guidelines"

    html =
      view
      |> element("#demo-category-tab-forms_and_input")
      |> render_click()

    assert html =~ "data-demo-active-category=\"forms_and_input\""
    assert html =~ "Forms and Input Gallery"
    assert html =~ "Display name"
    assert html =~ "Region"
    assert html =~ "data-live-ui-widget=\"form-builder\""
    assert html =~ "data-live-ui-widget=\"text-input\""
    assert html =~ "data-live-ui-widget=\"toggle\""

    html =
      view
      |> element("#demo-category-tab-layout_and_display")
      |> render_click()

    assert html =~ "data-demo-active-category=\"layout_and_display\""
    assert html =~ "Layout and Display Gallery"
    assert html =~ "data-live-ui-widget=\"viewport\""
    assert html =~ "data-live-ui-widget=\"scroll-bar\""
    assert html =~ "data-live-ui-widget=\"split-pane\""
    assert html =~ "data-live-ui-widget=\"canvas\""
    assert html =~ "data-demo-category-panel=\"layout_and_display\""

    html =
      view
      |> element("#demo-category-tab-foundational_content")
      |> render_click()

    assert html =~ "data-demo-active-category=\"foundational_content\""
    assert html =~ "Foundational Content Gallery"
  end

  test "phase 2 category galleries preserve shared theme continuity and ordered registry coverage" do
    metadata = Demo.review_metadata()
    phase_2_ids = [:foundational_content, :forms_and_input, :layout_and_display]

    assert metadata.theme_id == Template.default_theme_id()
    assert Enum.take(metadata.category_ids, 3) == phase_2_ids
    assert Enum.take(Enum.map(metadata.category_registry, & &1.id), 3) == phase_2_ids

    {:ok, html} = Demo.render_html()

    assert html =~ "Foundational Content"
    assert html =~ "Forms and Input"
    assert html =~ "Layout and Display"
    assert html =~ "Active category: Foundational Content"
  end

  test "phase 2 category fragments mount through the shared live_ui runtime path" do
    for category_id <- [:foundational_content, :forms_and_input, :layout_and_display] do
      entry = Categories.entry!(category_id)

      assert {:ok, assigns} = Runtime.component_assigns(entry.fragment_module)
      assert is_binary(assigns.id)
      assert %{id: _id} = assigns.runtime_state.assigns.iur

      assert {:ok, html} = Runtime.render_html(entry.fragment_module)

      assert html =~ "data-live-ui-widget="
    end
  end
end
