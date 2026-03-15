defmodule UnifiedExamples.RadioGroupTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Tree
  alias UnifiedExamples.RadioGroup

  test "radio_group example exposes standalone example metadata" do
    assert RadioGroup.metadata() == %{
             id: :radio_group_example_screen,
             root_id: :radio_group_example_screen_root,
             title: "Radio Group Widget Example",
             summary: "Focused input-oriented example using the shared suite shell",
             notes:
               "Radio group examples keep the shared form shell while foregrounding one exclusive choice control.",
             widget: :radio_group,
             theme_id: :example_suite_default,
             app: :unified_example_radio_group,
             directory: "examples/radio_group",
             purpose: :widget_proof
           }
  end

  test "radio_group example renders the shared shell and the focused input widget" do
    assert {:ok, runtime_state} = RadioGroup.boot()
    assert {:ok, html} = RadioGroup.render_html()

    assert runtime_state.assigns.iur.id == :radio_group_example_screen_shell

    assert %UnifiedIUR.Element{kind: :radio_group} =
             Tree.find_by_id(runtime_state.assigns.iur, :radio_group_example_primary_input)

    assert html =~ "data-live-ui-widget=\"form-builder\""
    assert html =~ "Radio Group Widget Example"
    assert html =~ "data-live-ui-widget=\"select\""
    assert html =~ "Admin"
    assert html =~ "data-live-ui-variant=\"filled\""
  end
end
