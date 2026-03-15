defmodule UnifiedExamples.LinkTest do
  use ExUnit.Case, async: true

  alias UnifiedExamples.Link

  test "link example exposes standalone example metadata" do
    assert Link.metadata() == %{
             id: :link_example_screen,
             root_id: :link_example_screen_root,
             title: "Link Widget Example",
             summary: "Focused content-oriented example using the shared suite shell",
             notes:
               "Link examples keep the shared shell while foregrounding one primary link widget.",
             widget: :link,
             theme_id: :example_suite_default,
             app: :unified_example_link,
             directory: "examples/link",
             purpose: :widget_proof
           }
  end

  test "link example renders the shared shell and the focused content widget" do
    assert {:ok, runtime_state} = Link.boot()
    assert {:ok, html} = Link.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :link_example_screen_shell
    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "Link Widget Example"
    assert html =~ "Open the shared documentation"
    assert html =~ "data-live-ui-widget=\"link\""
    assert html =~ "data-live-ui-variant=\"inline\""
  end
end
