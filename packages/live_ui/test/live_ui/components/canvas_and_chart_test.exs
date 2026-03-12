defmodule LiveUi.Components.CanvasAndChartTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2, rendered_to_string: 1]

  alias LiveUi.WidgetRegistry

  test "renders canvas descriptors with a server-correct baseline" do
    rendered =
      render_component(&WidgetRegistry.render/1,
        descriptor: %{
          id: "canvas-1",
          kind: "canvas",
          props: %{
            "title" => "Sketch",
            "operations" => [%{"op" => "line", "from" => [0, 0], "to" => [10, 10]}]
          }
        }
      )
      |> rendered_to_string()

    assert rendered =~ "Sketch"
    assert rendered =~ "live-ui-canvas"
    assert rendered =~ "LiveUi.Canvas"
    assert rendered =~ "line"
  end

  test "renders chart descriptors without relying on client-side javascript" do
    rendered =
      render_component(&WidgetRegistry.render/1,
        descriptor: %{
          id: "chart-1",
          kind: "chart",
          props: %{"title" => "Trend", "series" => [1, 5, 9]}
        }
      )
      |> rendered_to_string()

    assert rendered =~ "Trend"
    assert rendered =~ "&lt;svg"
    assert rendered =~ "polyline"
  end
end
