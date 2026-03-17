defmodule UnifiedExamples.LayoutAndDisplayTest do
  use ExUnit.Case, async: true

  alias UnifiedExamples.Demo.Categories.LayoutAndDisplay
  alias UnifiedExamples.Shared.Template
  alias UnifiedUi.Compiler

  test "layout and display gallery compiles into the required representative constructs" do
    assert {:ok, result} = Compiler.compile_fragment(LayoutAndDisplay)

    kinds =
      result.iur
      |> collect_kinds()
      |> MapSet.new()

    assert LayoutAndDisplay.default_theme_id() == Template.default_theme_id()
    assert LayoutAndDisplay.shared_style_profile() == Template.default_style_profile()

    assert MapSet.subset?(
             MapSet.new([
               :box,
               :row,
               :column,
               :grid,
               :viewport,
               :scroll_bar,
               :split_pane,
               :canvas
             ]),
             kinds
           )
  end

  defp collect_kinds(element) do
    [element.kind | Enum.flat_map(element.children, &collect_kinds(&1.element))]
  end
end
