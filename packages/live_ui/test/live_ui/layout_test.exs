defmodule LiveUi.LayoutTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  test "row, column, and grid preserve child ordering and layout metadata" do
    html =
      render_component(&LiveUi.Layout.Grid.render/1, %{
        id: "grid",
        columns: 2,
        inner_block: [
          %{
            __slot__: :inner_block,
            inner_block: fn _, _ ->
              Phoenix.HTML.raw("""
              #{render_component(&LiveUi.Layout.Row.render/1, %{id: "row", inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "Row Child" end}]})}
              #{render_component(&LiveUi.Layout.Column.render/1, %{id: "column", inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "Column Child" end}]})}
              """)
            end
          }
        ]
      })

    assert html =~ "data-live-ui-widget=\"grid\""
    assert html =~ "data-live-ui-widget=\"row\""
    assert html =~ "data-live-ui-widget=\"column\""
    assert html =~ "Row Child"
    assert html =~ "Column Child"
  end
end
