defmodule UnifiedExamples.OverlaysAndOperationalTest do
  use ExUnit.Case, async: true

  alias UnifiedExamples.Demo.Categories.OverlaysAndOperational
  alias UnifiedExamples.Shared.Catalog
  alias UnifiedExamples.Shared.Template
  alias UnifiedUi.Compiler

  test "overlays and operational gallery compiles into the required representative controls" do
    assert {:ok, result} = Compiler.compile_fragment(OverlaysAndOperational)

    kinds =
      result.iur
      |> collect_kinds()
      |> MapSet.new()

    assert OverlaysAndOperational.default_theme_id() == Template.default_theme_id()
    assert OverlaysAndOperational.shared_style_profile() == Template.default_style_profile()

    assert MapSet.subset?(
             MapSet.new([
               :box,
               :grid,
               :dialog,
               :alert_dialog,
               :context_menu,
               :toast,
               :overlay,
               :stream_widget,
               :process_monitor,
               :supervision_tree_viewer,
               :cluster_dashboard
             ]),
             kinds
           )
  end

  test "overlays and operational gallery stays traceable to the shared example catalog" do
    assert Enum.all?(OverlaysAndOperational.example_directories(), fn directory ->
             directory in Catalog.directories()
           end)
  end

  defp collect_kinds(element) do
    [element.kind | Enum.flat_map(element.children, &collect_kinds(&1.element))]
  end
end
