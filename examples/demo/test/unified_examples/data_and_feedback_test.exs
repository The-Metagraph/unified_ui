defmodule UnifiedExamples.DataAndFeedbackTest do
  use ExUnit.Case, async: true

  alias UnifiedExamples.Demo.Categories.DataAndFeedback
  alias UnifiedExamples.Shared.Catalog
  alias UnifiedExamples.Shared.Template
  alias UnifiedUi.Compiler

  test "data and feedback gallery compiles into the required representative controls" do
    assert {:ok, result} = Compiler.compile_fragment(DataAndFeedback)

    kinds =
      result.iur
      |> collect_kinds()
      |> MapSet.new()

    assert DataAndFeedback.default_theme_id() == Template.default_theme_id()
    assert DataAndFeedback.shared_style_profile() == Template.default_style_profile()

    assert MapSet.subset?(
             MapSet.new([
               :box,
               :grid,
               :table,
               :tree_view,
               :markdown_viewer,
               :log_viewer,
               :status,
               :progress,
               :gauge,
               :inline_feedback,
               :sparkline,
               :bar_chart,
               :line_chart
             ]),
             kinds
           )
  end

  test "data and feedback gallery stays traceable to the shared example catalog" do
    assert Enum.all?(DataAndFeedback.example_directories(), fn directory ->
             directory in Catalog.directories()
           end)
  end

  defp collect_kinds(element) do
    [element.kind | Enum.flat_map(element.children, &collect_kinds(&1.element))]
  end
end
