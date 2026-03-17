defmodule UnifiedExamples.CheckboxTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Tree
  alias UnifiedExamples.Checkbox

  test "checkbox example exposes standalone example metadata" do
    metadata = Checkbox.metadata()

    assert metadata.id == :checkbox_example_screen
    assert metadata.root_id == :checkbox_example_screen_root
    assert metadata.widget == :checkbox
    assert metadata.app == :unified_example_checkbox
    assert metadata.directory == "examples/checkbox"
    assert metadata.interaction_demo.mode == :form_shell
    assert metadata.interaction_demo.family == :change
    assert metadata.interaction_demo.source == :form_shell
  end

  test "checkbox example renders the shared shell and the focused input widget" do
    assert {:ok, runtime_state} = Checkbox.boot()
    assert {:ok, html} = Checkbox.render_html()

    assert runtime_state.assigns.iur.id == :checkbox_example_screen_shell

    assert %UnifiedIUR.Element{kind: :checkbox} =
             Tree.find_by_id(runtime_state.assigns.iur, :checkbox_example_primary_input)

    assert html =~ "data-live-ui-widget=\"form-builder\""
    assert html =~ "Checkbox Widget Example"
    assert html =~ "data-live-ui-widget=\"toggle\""
    assert html =~ "type=\"checkbox\""
    assert html =~ "data-live-ui-variant=\"filled\""
    assert html =~ "phx-change=\"canonical_change_interaction\""
  end
end
