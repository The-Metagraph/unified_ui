defmodule LiveUi.DisplaySystemsTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule DisplayScreen do
    use LiveUi.Screen, id: :display_screen, title: "Display"

    @impl true
    def bridge_hooks do
      LiveUi.Display.browser_bridge_hooks()
    end

    @impl true
    def render(assigns) do
      ~H"""
      <LiveUi.Widgets.ScreenShell.render id="display-screen" title={title()}>
        <LiveUi.Widgets.SplitPane.render id="split" ratio={0.4} sync_scroll="inspectors">
          <:primary>
            <LiveUi.Widgets.Viewport.render id="viewport" offset_y={12} sync_group="inspectors">
              <LiveUi.Widgets.Text.render id="viewport-text" content="Scrollable content" />
            </LiveUi.Widgets.Viewport.render>
          </:primary>
          <:secondary>
            <LiveUi.Widgets.Canvas.render
              id="canvas"
              width={80}
              height={20}
              operations={[%{kind: :text, position: %{x: 2, y: 3}, text: "Canvas"}]}
            />
          </:secondary>
        </LiveUi.Widgets.SplitPane.render>
        <LiveUi.Widgets.ScrollBar.render id="scroll" viewport_ref="viewport" position_end={0.4} />
      </LiveUi.Widgets.ScreenShell.render>
      """
    end
  end

  test "display primitives render viewport, split pane, scroll, and canvas semantics" do
    html =
      Phoenix.HTML.raw("""
      #{render_component(&LiveUi.Widgets.Viewport.render/1, %{id: "viewport", offset_y: 4, sync_group: "logs", inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "Viewport" end}]})}
      #{render_component(&LiveUi.Widgets.ScrollBar.render/1, %{id: "scroll", viewport_ref: "viewport", position_end: 0.6})}
      #{render_component(&LiveUi.Widgets.SplitPane.render/1, %{id: "split", ratio: 0.6, primary: [%{__slot__: :primary, inner_block: fn _, _ -> "Left" end}], secondary: [%{__slot__: :secondary, inner_block: fn _, _ -> "Right" end}]})}
      #{render_component(&LiveUi.Widgets.Canvas.render/1, %{id: "canvas", operations: [%{kind: :text, position: %{x: 1, y: 2}, text: "Plot"}]})}
      """)
      |> Phoenix.HTML.safe_to_string()

    assert html =~ "data-live-ui-widget=\"viewport\""
    assert html =~ "data-live-ui-widget=\"scroll-bar\""
    assert html =~ "data-live-ui-widget=\"split-pane\""
    assert html =~ "data-live-ui-widget=\"canvas\""
    assert html =~ "Plot"
  end

  test "display screens keep browser hooks bounded and subordinate to the runtime" do
    assert {:ok, runtime_state} = LiveUi.Runtime.mount(DisplayScreen)

    assert runtime_state.bridge_hooks == [
             :viewport_measurement,
             :scroll_tracking,
             :canvas_pointer,
             :split_pane_drag
           ]

    html =
      render_component(LiveUi.Runtime.component(), id: "display", runtime_state: runtime_state)

    assert html =~ "data-live-ui-widget=\"split-pane\""
    assert html =~ "data-live-ui-widget=\"viewport\""
    assert html =~ "data-live-ui-widget=\"canvas\""
  end
end
