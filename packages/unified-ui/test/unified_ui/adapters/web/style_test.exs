defmodule UnifiedUi.Adapters.Web.StyleTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Style
  alias UnifiedUi.Adapters.Web.Style, as: WebStyle

  test "to_css/1 maps fg/bg and text attrs" do
    css =
      WebStyle.to_css(%Style{
        fg: :cyan,
        bg: :black,
        attrs: [:bold, :underline, :italic, :strikethrough, :dim]
      })

    assert css =~ "color: cyan"
    assert css =~ "background-color: black"
    assert css =~ "font-weight: bold"
    assert css =~ "text-decoration: underline"
    assert css =~ "font-style: italic"
    assert css =~ "text-decoration: line-through"
    assert css =~ "opacity: 0.7"
  end

  test "to_css/1 supports string, rgb, and rgba color inputs" do
    rgb_css = WebStyle.to_css(%Style{fg: {12, 34, 56}})
    rgba_css = WebStyle.to_css(%Style{bg: {1, 2, 3, 128}})
    hex_css = WebStyle.to_css(%Style{fg: "#ff00aa"})

    assert rgb_css =~ "color: rgb(12, 34, 56)"
    assert rgba_css =~ "background-color: rgba(1, 2, 3, "
    assert hex_css =~ "color: #ff00aa"
  end

  test "to_css/1 maps layout and extended style attrs" do
    css =
      WebStyle.to_css(%Style{
        padding: 2,
        margin: 1,
        width: :fill,
        height: 240,
        align: :center,
        attrs: [
          {:spacing, 6},
          {:font_family, "JetBrains Mono"},
          {:font_size, 14},
          {:font_weight, 700},
          {:border, %{width: 2, style: :dashed, color: :blue}},
          {:border_width, 3},
          {:border_color, "#ff00aa"},
          {:border_style, :solid}
        ]
      })

    assert css =~ "padding: 2px"
    assert css =~ "margin: 1px"
    assert css =~ "width: 100%"
    assert css =~ "height: 240px"
    assert css =~ "text-align: center"
    assert css =~ "gap: 6px"
    assert css =~ "font-family: JetBrains Mono"
    assert css =~ "font-size: 14px"
    assert css =~ "font-weight: 700"
    assert css =~ "border: 2px dashed blue"
    assert css =~ "border-width: 3px"
    assert css =~ "border-color: #ff00aa"
    assert css =~ "border-style: solid"
  end

  test "to_css/1 returns empty css for nil style" do
    assert WebStyle.to_css(nil) == ""
  end

  test "add_to_css/2 appends style css to existing css" do
    assert WebStyle.add_to_css("display: block", nil) == "display: block"

    appended = WebStyle.add_to_css("display: block", %Style{fg: :green})
    assert appended == "display: block; color: green"

    replacement = WebStyle.add_to_css("", %Style{bg: :blue})
    assert replacement == "background-color: blue"
  end

  test "merge_styles/1 accumulates non-nil styles in order" do
    css =
      WebStyle.merge_styles([
        %Style{fg: :red},
        nil,
        %Style{bg: :white, attrs: [:bold]}
      ])

    assert css =~ "color: red"
    assert css =~ "background-color: white"
    assert css =~ "font-weight: bold"
  end
end
