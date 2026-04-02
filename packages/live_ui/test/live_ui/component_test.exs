defmodule LiveUi.ComponentTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  test "native widget metadata exposes shared assigns contract" do
    metadata = LiveUi.Component.metadata(LiveUi.Widgets.Text)

    assert metadata.family == :content
    assert metadata.name == :text
    assert metadata.component_module == LiveUi.Widgets.Text.Component
    assert metadata.mountable?
    assert metadata.identity_keys == [:id]
    assert :id in metadata.assigns
    assert :content in metadata.assigns
    assert :tone in metadata.style_hooks
  end

  test "widgets expose a mountable component helper that delegates to the live component boundary" do
    html =
      render_component(&LiveUi.Widgets.Button.component/1, %{
        id: "save",
        label: "Save"
      })

    assert html =~ "data-live-ui-widget=\"button\""
    assert html =~ "data-live-ui-widget-boundary=\"button\""
    assert html =~ "data-live-ui-widget-key=\"native:content:button:save:root\""
    assert html =~ ">Save<"
  end

  test "function components render through liveview-native boundaries" do
    html =
      render_component(&LiveUi.Widgets.Container.render/1, %{
        id: "root",
        inner_block: [
          %{
            __slot__: :inner_block,
            inner_block: fn _, _ ->
              Phoenix.HTML.raw(
                render_component(&LiveUi.Widgets.Text.render/1, %{
                  id: "greeting",
                  content: "Hello"
                })
              )
            end
          }
        ]
      })

    assert html =~ "data-live-ui-widget=\"container\""
    assert html =~ "data-live-ui-widget=\"text\""
    assert html =~ "Hello"
  end

  test "foundational widgets expose style hooks and click-capable surfaces" do
    button = LiveUi.Component.metadata(LiveUi.Widgets.Button)
    link = LiveUi.Component.metadata(LiveUi.Widgets.Link)

    assert button.events == [:click]
    assert link.events == [:click, :navigate]
    assert LiveUi.Component.style_hooks() == [:tone, :variant, :state]
  end

  test "layout primitives remain structural unless a dedicated lifecycle boundary is required" do
    assert LiveUi.Layout.structural?(LiveUi.Layout.Row)
    assert LiveUi.Layout.structural?(LiveUi.Layout.Column)
    assert LiveUi.Layout.structural?(LiveUi.Layout.Grid)
    refute LiveUi.Layout.structural?(LiveUi.Widgets.Button)
  end

  test "foundational widgets render baseline visual and container surfaces" do
    html =
      render_component(&LiveUi.Widgets.Box.render/1, %{
        id: "shell",
        padding: "lg",
        inner_block: [
          %{
            __slot__: :inner_block,
            inner_block: fn _, _ ->
              Phoenix.HTML.raw("""
              #{render_component(&LiveUi.Widgets.Label.render/1, %{id: "label", for: "name", content: "Name"})}
              #{render_component(&LiveUi.Widgets.Button.render/1, %{id: "save", label: "Save", tone: "primary"})}
              #{render_component(&LiveUi.Widgets.Link.render/1, %{id: "docs", label: "Docs", href: "/docs"})}
              """)
            end
          }
        ]
      })

    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "data-live-ui-widget=\"label\""
    assert html =~ "data-live-ui-widget=\"button\""
    assert html =~ "data-live-ui-widget=\"link\""
    assert html =~ "data-live-ui-tone=\"primary\""
  end
end
