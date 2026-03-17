defmodule UnifiedExamples.FormsAndInputTest do
  use ExUnit.Case, async: true

  alias UnifiedExamples.Demo.Categories.FormsAndInput
  alias UnifiedExamples.Shared.Template
  alias UnifiedUi.Compiler

  test "forms and input gallery compiles into the required representative controls" do
    assert {:ok, result} = Compiler.compile_fragment(FormsAndInput)

    kinds =
      result.iur
      |> collect_kinds()
      |> MapSet.new()

    assert FormsAndInput.default_theme_id() == Template.default_theme_id()
    assert FormsAndInput.shared_style_profile() == Template.default_style_profile()

    assert MapSet.subset?(
             MapSet.new([
               :form_builder,
               :field_group,
               :field,
               :text_input,
               :numeric_input,
               :checkbox,
               :radio_group,
               :select,
               :pick_list,
               :date_input,
               :time_input,
               :file_input,
               :toggle
             ]),
             kinds
           )
  end

  defp collect_kinds(element) do
    [element.kind | Enum.flat_map(element.children, &collect_kinds(&1.element))]
  end
end
