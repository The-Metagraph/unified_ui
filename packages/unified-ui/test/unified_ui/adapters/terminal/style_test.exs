defmodule UnifiedUi.Adapters.Terminal.StyleTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Style
  alias UnifiedUi.Adapters.Terminal.Style, as: TerminalStyle

  test "convert_style/1 maps colors and supported attributes" do
    iur_style = %Style{
      fg: :red,
      bg: :blue,
      attrs: [:bold, :underline, :reverse, :blink, :dim, :italic, :strikethrough]
    }

    converted = TerminalStyle.convert_style(iur_style)

    assert converted.fg == :red
    assert converted.bg == :blue
    assert MapSet.member?(converted.attrs, :bold)
    assert MapSet.member?(converted.attrs, :underline)
    assert MapSet.member?(converted.attrs, :reverse)
    assert MapSet.member?(converted.attrs, :blink)
    assert MapSet.member?(converted.attrs, :dim)
    assert MapSet.member?(converted.attrs, :italic)
    assert MapSet.member?(converted.attrs, :strikethrough)
  end

  test "convert_style/1 ignores unknown attrs without breaking accumulated style" do
    iur_style = %Style{fg: :cyan, attrs: [:bold, :unknown, :underline]}
    converted = TerminalStyle.convert_style(iur_style)

    assert converted.fg == :cyan
    assert MapSet.member?(converted.attrs, :bold)
    assert MapSet.member?(converted.attrs, :underline)
  end

  test "convert_style/1 maps font_weight tuple attrs to terminal emphasis" do
    iur_style = %Style{attrs: [{:font_weight, 700}, {:font_weight, :lighter}]}
    converted = TerminalStyle.convert_style(iur_style)

    assert MapSet.member?(converted.attrs, :bold)
    assert MapSet.member?(converted.attrs, :dim)
  end

  test "convert_style/1 returns nil for nil style" do
    assert TerminalStyle.convert_style(nil) == nil
  end

  test "merge_styles/1 merges and overrides properties across styles" do
    styles = [
      %Style{fg: :red, attrs: [:bold]},
      nil,
      %Style{bg: :black, attrs: [:underline]},
      %Style{fg: :green}
    ]

    merged = TerminalStyle.merge_styles(styles)

    assert merged.fg == :green
    assert merged.bg == :black
    assert MapSet.member?(merged.attrs, :bold)
    assert MapSet.member?(merged.attrs, :underline)
  end

  test "merge_styles/1 handles empty style list" do
    merged = TerminalStyle.merge_styles([])

    assert merged.fg == nil
    assert merged.bg == nil
    assert merged.attrs == MapSet.new()
  end
end
