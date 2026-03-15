defmodule LiveUi.RendererStyleTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  alias UnifiedIUR.{Canvas, Container, Layer, Viewport}
  alias UnifiedIUR.Widgets.Foundational

  test "renderer lowers canonical style and theme values into native foundational markers" do
    element =
      Container.box(
        [
          Foundational.button("Save",
            id: "save-button",
            style: %{
              emphasis: %{tone: :critical},
              extra: %{class: "canonical-button"}
            },
            theme: %{id: :live_ui, variant: :quiet, state: :active}
          )
        ],
        id: "profile-panel",
        style: %{
          emphasis: %{tone: :surface},
          extra: %{class: "canonical-panel"}
        },
        theme: %{id: :live_ui, variant: :panel}
      )

    html = render_component(&LiveUi.Renderer.render/1, %{element: element})

    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "data-live-ui-tone=\"surface\""
    assert html =~ "data-live-ui-variant=\"panel\""
    assert html =~ "canonical-panel"
    assert html =~ "data-live-ui-widget=\"button\""
    assert html =~ "data-live-ui-tone=\"critical\""
    assert html =~ "data-live-ui-variant=\"quiet\""
    assert html =~ "data-live-ui-state=\"active\""
    assert html =~ "canonical-button"
  end

  test "renderer lowers canonical style meaning for layered, viewport, and canvas constructs" do
    layered =
      Layer.overlay(
        Viewport.region(
          Canvas.surface(
            [
              %{kind: :text, position: %{x: 3, y: 2}, text: "Plot"}
            ],
            id: "analytics-canvas",
            style: %{extra: %{class: "analytics-canvas"}},
            theme: %{id: :live_ui, variant: :analysis}
          ),
          id: "analytics-viewport",
          style: %{extra: %{class: "analytics-viewport"}},
          theme: %{id: :live_ui}
        ),
        [
          {:modal,
           Layer.dialog(
             Container.content([{:content, Foundational.text("Styled overlay")}],
               id: "overlay-copy"
             ),
             id: "style-dialog",
             title: "Style"
           )}
        ],
        id: "analytics-overlay",
        style: %{extra: %{class: "analytics-overlay"}},
        theme: %{id: :live_ui, variant: :modal}
      )

    html = render_component(&LiveUi.Renderer.render/1, %{element: layered})

    assert html =~ "data-live-ui-widget=\"overlay-surface\""
    assert html =~ "data-live-ui-variant=\"modal\""
    assert html =~ "analytics-overlay"
    assert html =~ "data-live-ui-widget=\"viewport\""
    assert html =~ "analytics-viewport"
    assert html =~ "data-live-ui-widget=\"canvas\""
    assert html =~ "data-live-ui-variant=\"analysis\""
    assert html =~ "analytics-canvas"
    assert html =~ "live-ui-canvas-analysis"
  end

  test "equivalent canonical style input produces deterministic native styling output" do
    left =
      Foundational.text("Ready",
        id: "status",
        style: %{emphasis: %{tone: :success}},
        theme: %{id: :live_ui}
      )

    right =
      Foundational.text("Ready",
        id: "status",
        style: %{emphasis: %{tone: :success}, extra: %{}},
        theme: %{id: :live_ui, token_refs: []}
      )

    assert render_component(&LiveUi.Renderer.render/1, %{element: left}) ==
             render_component(&LiveUi.Renderer.render/1, %{element: right})
  end
end
