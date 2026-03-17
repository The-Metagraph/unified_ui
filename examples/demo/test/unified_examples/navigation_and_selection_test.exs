defmodule UnifiedExamples.NavigationAndSelectionTest do
  use ExUnit.Case, async: true

  alias UnifiedExamples.Demo.Categories.NavigationAndSelection
  alias UnifiedExamples.Shared.Catalog
  alias UnifiedExamples.Shared.Template
  alias UnifiedUi.Compiler

  test "navigation and selection gallery compiles into the required representative controls" do
    assert {:ok, result} = Compiler.compile_fragment(NavigationAndSelection)

    kinds =
      result.iur
      |> collect_kinds()
      |> MapSet.new()

    assert NavigationAndSelection.default_theme_id() == Template.default_theme_id()
    assert NavigationAndSelection.shared_style_profile() == Template.default_style_profile()

    assert MapSet.subset?(
             MapSet.new([:box, :grid, :menu, :tabs, :list, :command_palette]),
             kinds
           )
  end

  test "navigation and selection gallery stays traceable to the shared example catalog" do
    assert NavigationAndSelection.example_directories() == [
             "menu",
             "tabs",
             "list",
             "command_palette"
           ]

    assert Enum.all?(NavigationAndSelection.example_directories(), fn directory ->
             directory in Catalog.directories()
           end)
  end

  defp collect_kinds(element) do
    [element.kind | Enum.flat_map(element.children, &collect_kinds(&1.element))]
  end
end
