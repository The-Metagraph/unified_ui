defmodule LiveUi.AdvancedRendererTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  alias UnifiedIUR.{Canvas, Container, Layer, Layout, Viewport}
  alias UnifiedIUR.Widgets.{Advanced, Data, Feedback, Foundational}

  test "renderer maps advanced canonical widgets into native advanced components" do
    element =
      Layout.column([
        Data.list(
          [
            %{id: "overview", label: "Overview", selected?: true},
            %{id: "activity", label: "Activity"}
          ],
          id: "nav-list"
        ),
        Feedback.inline_feedback("Runtime warning", id: "warning", severity: :warning),
        Advanced.markdown_viewer("# Release Notes", id: "release-notes"),
        Advanced.stream_widget(
          [
            %{id: "evt-1", message: "ready", severity: :info}
          ],
          id: "event-stream"
        )
      ])

    html = render_component(&LiveUi.Renderer.render/1, %{element: element})

    assert html =~ "data-live-ui-widget=\"column\""
    assert html =~ "data-live-ui-widget=\"list\""
    assert html =~ "data-live-ui-widget=\"inline-feedback\""
    assert html =~ "data-live-ui-widget=\"markdown-viewer\""
    assert html =~ "data-live-ui-widget=\"stream-widget\""
  end

  test "renderer maps layered and viewport canonical constructs through native display primitives" do
    base =
      Viewport.split_pane(
        Viewport.region(
          Container.box([{:content, Foundational.text("Navigation")}], id: "nav-box"),
          id: "nav-viewport",
          offset: %{x: 0, y: 8}
        ),
        Viewport.region(
          Layout.column([
            Foundational.text("Details"),
            Canvas.surface(
              [
                %{kind: :text, position: %{x: 1, y: 2}, text: "Plot"}
              ],
              id: "detail-canvas"
            )
          ]),
          id: "detail-viewport"
        ),
        id: "workspace-split",
        ratio: 0.4
      )

    layered =
      Layer.overlay(
        base,
        [
          {:modal,
           Layer.dialog(
             Container.content([{:content, Foundational.text("Edit settings")}],
               id: "dialog-content"
             ),
             id: "settings-dialog",
             title: "Settings"
           )},
          {:transient,
           Layer.toast(Foundational.text("Saved"), id: "save-toast", severity: :success)},
          {:popup,
           Layer.context_menu(
             [
               %{id: "copy", label: "Copy"},
               %{id: "delete", label: "Delete"}
             ],
             id: "row-menu",
             anchor: %{x: 12, y: 8}
           )}
        ],
        id: "workspace-overlay",
        background_fill: :scrim
      )

    html = render_component(&LiveUi.Renderer.render/1, %{element: layered})

    assert html =~ "data-live-ui-widget=\"overlay-surface\""
    assert html =~ "data-live-ui-widget=\"split-pane\""
    assert html =~ "data-live-ui-widget=\"viewport\""
    assert html =~ "data-live-ui-widget=\"canvas\""
    assert html =~ "data-live-ui-widget=\"dialog\""
    assert html =~ "data-live-ui-widget=\"toast\""
    assert html =~ "data-live-ui-widget=\"context-menu\""
  end

  test "runtime mounts advanced canonical screens through the shared native renderer" do
    canonical =
      Layout.column([
        Feedback.gauge(id: "cpu-gauge", value: 72, label: "CPU"),
        Canvas.line_chart(
          [
            %{id: :cpu, label: "CPU", values: [10, 20, 30]}
          ],
          id: "cpu-chart"
        ),
        Advanced.cluster_dashboard(
          [
            %{id: "node-a", status: :up}
          ],
          id: "cluster-dashboard",
          summary: %{healthy: 1}
        )
      ])

    assert {:ok, runtime_state} = LiveUi.Runtime.mount_iur(canonical)

    html =
      render_component(LiveUi.Runtime.component(),
        id: "advanced-canonical",
        runtime_state: runtime_state
      )

    assert html =~ "data-live-ui-widget=\"gauge\""
    assert html =~ "data-live-ui-widget=\"line-chart\""
    assert html =~ "data-live-ui-widget=\"cluster-dashboard\""
  end
end
