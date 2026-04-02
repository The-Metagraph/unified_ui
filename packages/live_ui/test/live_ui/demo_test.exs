defmodule LiveUi.DemoTest do
  use ExUnit.Case, async: true

  test "home workbench renders the package-local demo shell" do
    assert {:ok, demo} = LiveUi.Demo.run()

    assert demo.screen == LiveUi.Demo.Screen
    assert demo.view == :home
    assert demo.selected_category == :foundational
    assert demo.selected_example == nil
    assert demo.total_examples > 0
    assert demo.html =~ "Live UI Workbench"
    assert demo.html =~ "live_ui package demo"

    assert demo.html =~
             "Browse the package-local demo through the same server-authoritative runtime the package exposes everywhere else."

    assert demo.html =~ ~s(data-live-ui-widget="screen-shell")
    assert demo.html =~ ~s(data-live-ui-widget="tabs")
    assert demo.html =~ "Current category: Foundational"
    refute demo.html =~ "Meaningful Interaction Story"
    refute demo.html =~ "Canonical Signal Preview"
    refute demo.html =~ "No signal captured yet"
    refute demo.html =~ "Examples in this category"
    refute demo.html =~ "Featured example:"
    refute demo.html =~ "Widget:"
    refute demo.html =~ "<h1>Live UI Demo</h1>"
    refute demo.html =~ ">Overview<"
    refute demo.html =~ "Examples:"
    refute demo.html =~ "Native:"
    refute demo.html =~ "Canonical:"
    refute demo.html =~ "Mixed:"
    refute demo.html =~ "Maintained Runtime Surfaces"
    refute demo.html =~ "One workbench across native, canonical, and mixed example paths."

    assert demo.html =~ ~s(id="live-ui-demo-category-tabs")
    assert demo.html =~ ~s(data-item-id="button")
    assert demo.html =~ ">Button<"

    refute demo.html =~ ~s(phx-click="select_example")
  end

  test "widget example workbench renders the selected widget surface" do
    assert {:ok, demo} = LiveUi.Demo.run(example: :button)

    assert demo.view == :example
    assert demo.selected_example.id == :button
    assert demo.selected_example.title == "Button"
    assert demo.preview == nil
    assert demo.html =~ ~s(id="live-ui-demo-example-title")
    assert demo.html =~ ~s(id="live-ui-demo-widget-button-panel")
    assert demo.html =~ ~s(id="live-ui-demo-widget-button-button")
    assert demo.html =~ ~s(data-live-ui-widget="button")
    refute demo.html =~ "live-ui-demo-example-breadcrumbs"
    refute demo.html =~ "Back To Overview"
    assert demo.html =~ ~s(id="live-ui-demo-category-tabs")
    refute demo.html =~ ~s(id="live-ui-demo-interaction-grid")
    refute demo.html =~ "Meaningful Interaction Story"
    refute demo.html =~ "Canonical Signal Preview"
    refute demo.html =~ "No signal captured yet"
    refute demo.html =~ "Review Metadata"
    refute demo.html =~ ~s(id="live-ui-demo-metadata-card")
    refute demo.html =~ "Rendered Preview"
    refute demo.html =~ "Comparison Report"
    assert demo.html =~ ~s(id="live-ui-demo-example-metadata")
    assert demo.html =~ "Category: Foundational | Widget family: Content"
  end

  test "widgets from other categories also render through the same shell" do
    assert {:ok, demo} = LiveUi.Demo.run(example: :toast)

    assert demo.selected_example.id == :toast
    assert demo.selected_category == :overlay
    assert demo.preview == nil
    refute demo.html =~ "Comparison Report"
    assert demo.html =~ "Current category: Overlay"
    assert demo.html =~ ~s(id="live-ui-demo-example-metadata")
    assert demo.html =~ "Category: Overlay | Widget family: Overlay"
    assert demo.html =~ ~s(id="live-ui-demo-widget-toast-toast")
    assert demo.html =~ ~s(data-live-ui-widget="toast")
  end

  test "browser host paths support home categories and deep-linked examples" do
    assert LiveUi.Demo.path() == "/"
    assert LiveUi.Demo.path(category: :navigation) == "/?category=navigation"
    assert LiveUi.Demo.path(example: :button) == "/examples/button"

    assert LiveUi.Demo.path(example: :button, category: :foundational) ==
             "/examples/button?category=foundational"
  end
end
