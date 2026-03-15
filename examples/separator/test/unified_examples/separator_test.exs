defmodule UnifiedExamples.SeparatorTest do
  use ExUnit.Case, async: true

  alias UnifiedExamples.Separator

  test "separator example exposes standalone example metadata" do
    assert Separator.metadata() == %{
             id: :separator_example_screen,
             root_id: :separator_example_screen_root,
             title: "Separator Widget Example",
             summary: "Focused content-oriented example using the shared suite shell",
             notes:
               "Separator examples keep the shared shell while foregrounding one primary separator widget.",
             widget: :separator,
             theme_id: :example_suite_default,
             app: :unified_example_separator,
             directory: "examples/separator",
             purpose: :widget_proof
           }
  end

  test "separator example renders the shared shell and the focused content widget" do
    assert {:ok, runtime_state} = Separator.boot()
    assert {:ok, html} = Separator.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :separator_example_screen_shell
    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "Separator Widget Example"
    assert html =~ "data-live-ui-widget=\"separator\""
    assert html =~ "data-live-ui-variant=\"rule\""
  end
end
