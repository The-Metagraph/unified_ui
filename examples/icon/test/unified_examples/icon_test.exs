defmodule UnifiedExamples.IconTest do
  use ExUnit.Case, async: true

  alias UnifiedExamples.Icon

  test "icon example exposes standalone example metadata" do
    assert Icon.metadata() == %{
             id: :icon_example_screen,
             root_id: :icon_example_screen_root,
             title: "Icon Widget Example",
             summary: "Focused content-oriented example using the shared suite shell",
             notes:
               "Icon examples keep the shared shell while foregrounding one primary icon widget.",
             widget: :icon,
             theme_id: :example_suite_default,
             app: :unified_example_icon,
             directory: "examples/icon",
             purpose: :widget_proof
           }
  end

  test "icon example renders the shared shell and the focused content widget" do
    assert {:ok, runtime_state} = Icon.boot()
    assert {:ok, html} = Icon.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :icon_example_screen_shell
    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "Icon Widget Example"
    assert html =~ "data-live-ui-widget=\"icon\""
    assert html =~ "data-live-ui-variant=\"headline\""
  end
end
