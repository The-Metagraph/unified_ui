defmodule UnifiedExamples.CategoriesTest do
  use ExUnit.Case, async: true

  alias UnifiedExamples.Demo.Categories
  alias UnifiedExamples.Shared.Template
  alias UnifiedUi.Compiler

  test "category registry remains ordered, complete, and traceable" do
    assert Categories.ids() == [
             :foundational_content,
             :forms_and_input,
             :layout_and_display,
             :navigation_and_selection,
             :data_and_feedback,
             :overlays_and_operational,
             :signal_lab
           ]

    assert Categories.count() == 7
    assert Categories.default_id() == :foundational_content
    assert Enum.map(Categories.entries(), & &1.order) == Enum.to_list(1..7)
    assert Enum.map(Categories.entries(), & &1.id) == Categories.ids()
    assert Enum.map(Categories.entries(), & &1.label) == Keyword.values(Categories.tab_items())
  end

  test "each category registry entry points to a fragment with the shared theme contract" do
    for entry <- Categories.entries() do
      assert {:ok, result} = Compiler.compile_fragment(entry.fragment_module)
      assert result.composition.mode == :fragment
      assert result.identity.id == entry.id
      assert entry.fragment_module.default_theme_id() == Template.default_theme_id()
      assert entry.fragment_module.shared_style_profile() == Template.default_style_profile()
    end
  end
end
