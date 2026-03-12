defmodule UnifiedUi.Adapters.Desktop.StyleTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Style
  alias UnifiedUi.Adapters.Desktop.Style, as: DesktopStyle

  test "to_props/1 returns empty list for nil style" do
    assert DesktopStyle.to_props(nil) == []
  end

  test "add_props/2 maps fg, bg, and supported font attrs" do
    props =
      DesktopStyle.add_props([text: "hello"], %Style{
        fg: :yellow,
        bg: :blue,
        attrs: [:bold, :underline, :italic]
      })

    assert Keyword.get(props, :text) == "hello"
    assert Keyword.get(props, :color) == :yellow
    assert Keyword.get(props, :background) == :blue
    assert Keyword.get_values(props, :font_style) |> Enum.sort() == [:bold, :italic, :underline]
  end

  test "add_props/2 ignores unsupported attrs and nil style" do
    base = [id: :name]

    assert DesktopStyle.add_props(base, nil) == base

    props = DesktopStyle.add_props(base, %Style{attrs: [:reverse, :blink, :unknown]})
    assert props == base
  end

  test "add_props/2 maps layout fields and extended attrs" do
    props =
      DesktopStyle.add_props([], %Style{
        padding: 2,
        margin: 1,
        width: :fill,
        height: 42,
        align: :center,
        attrs: [
          {:spacing, 6},
          {:font_family, "JetBrains Mono"},
          {:font_size, 14},
          {:font_weight, 700},
          {:border, %{width: 1, style: :solid, color: :blue}},
          {:border_width, 2},
          {:border_color, :red},
          {:border_style, :dashed}
        ]
      })

    assert Keyword.get(props, :padding) == 2
    assert Keyword.get(props, :margin) == 1
    assert Keyword.get(props, :width) == :fill
    assert Keyword.get(props, :height) == 42
    assert Keyword.get(props, :align) == :center
    assert Keyword.get(props, :gap) == 6
    assert Keyword.get(props, :font_family) == "JetBrains Mono"
    assert Keyword.get(props, :font_size) == 14
    assert Keyword.get(props, :font_weight) == 700
    assert Keyword.get(props, :border) == %{width: 1, style: :solid, color: :blue}
    assert Keyword.get(props, :border_width) == 2
    assert Keyword.get(props, :border_color) == :red
    assert Keyword.get(props, :border_style) == :dashed
  end

  test "merge_props/2 merges styles and keeps latest conflicting values" do
    props =
      DesktopStyle.merge_props([text: "value"], [
        %Style{fg: :red, attrs: [:bold]},
        nil,
        %Style{bg: :black, attrs: [:underline]},
        %Style{fg: :green}
      ])

    assert Keyword.get(props, :text) == "value"
    assert Keyword.get(props, :color) == :green
    assert Keyword.get(props, :background) == :black
    assert :bold in Keyword.get_values(props, :font_style)
    assert :underline in Keyword.get_values(props, :font_style)
  end

  test "merge_props/2 returns base props for empty style list" do
    base = [label: "unchanged"]
    assert DesktopStyle.merge_props(base, []) == base
  end
end
