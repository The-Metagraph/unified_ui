defmodule UnifiedExamples.PickListTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Tree
  alias UnifiedExamples.PickList

  test "pick_list example exposes standalone example metadata" do
    assert PickList.metadata() == %{
             id: :pick_list_example_screen,
             root_id: :pick_list_example_screen_root,
             title: "Pick List Widget Example",
             summary: "Focused input-oriented example using the shared suite shell",
             notes:
               "Pick list examples keep the shared form shell while foregrounding one multi-select control.",
             widget: :pick_list,
             theme_id: :example_suite_default,
             app: :unified_example_pick_list,
             directory: "examples/pick_list",
             purpose: :widget_proof
           }
  end

  test "pick_list example renders the shared shell and the focused input widget" do
    assert {:ok, runtime_state} = PickList.boot()
    assert {:ok, html} = PickList.render_html()

    assert runtime_state.assigns.iur.id == :pick_list_example_screen_shell

    assert %UnifiedIUR.Element{kind: :pick_list} =
             Tree.find_by_id(runtime_state.assigns.iur, :pick_list_example_primary_input)

    assert html =~ "data-live-ui-widget=\"form-builder\""
    assert html =~ "Pick List Widget Example"
    assert html =~ "data-live-ui-widget=\"select\""
    assert html =~ "Alpha"
    assert html =~ "multiple"
    assert html =~ "data-live-ui-variant=\"filled\""
  end
end
