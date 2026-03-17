defmodule UnifiedExamples.FoundationalContentTest do
  use ExUnit.Case, async: true

  alias UnifiedExamples.Demo.Categories.FoundationalContent
  alias UnifiedExamples.Shared.Template
  alias UnifiedUi.Compiler

  test "foundational content gallery compiles into the required representative controls" do
    assert {:ok, result} = Compiler.compile_fragment(FoundationalContent)

    kinds =
      result.iur
      |> collect_kinds()
      |> MapSet.new()

    assert FoundationalContent.default_theme_id() == Template.default_theme_id()
    assert FoundationalContent.shared_style_profile() == Template.default_style_profile()

    assert MapSet.subset?(
             MapSet.new([
               :box,
               :content,
               :text,
               :label,
               :icon,
               :image,
               :button,
               :link,
               :separator,
               :spacer,
               :grid
             ]),
             kinds
           )
  end

  defp collect_kinds(element) do
    [element.kind | Enum.flat_map(element.children, &collect_kinds(&1.element))]
  end
end
