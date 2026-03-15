defmodule UnifiedExamples.SelectTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Tree
  alias UnifiedExamples.Select

  test "select example exposes standalone example metadata" do
    assert Select.metadata() == %{
             id: :select_example_screen,
             root_id: :select_example_screen_root,
             title: "Select Widget Example",
             summary: "Focused input-oriented example using the shared suite shell",
             notes:
               "Select examples keep the shared form shell while foregrounding one menu-based choice control.",
             widget: :select,
             theme_id: :example_suite_default,
             app: :unified_example_select,
             directory: "examples/select",
             purpose: :widget_proof
           }
  end

  test "select example renders the shared shell and the focused input widget" do
    assert {:ok, runtime_state} = Select.boot()
    assert {:ok, html} = Select.render_html()

    assert runtime_state.assigns.iur.id == :select_example_screen_shell

    assert %UnifiedIUR.Element{kind: :select} =
             Tree.find_by_id(runtime_state.assigns.iur, :select_example_primary_input)

    assert html =~ "data-live-ui-widget=\"form-builder\""
    assert html =~ "Select Widget Example"
    assert html =~ "data-live-ui-widget=\"select\""
    assert html =~ "United States"
    assert html =~ "data-live-ui-variant=\"filled\""
  end
end
