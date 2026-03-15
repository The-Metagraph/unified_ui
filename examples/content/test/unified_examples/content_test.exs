defmodule UnifiedExamples.ContentTest do
  use ExUnit.Case, async: true

  alias UnifiedExamples.Content

  test "content example exposes standalone example metadata" do
    assert Content.metadata() == %{
             id: :content_example_screen,
             root_id: :content_example_screen_root,
             title: "Content Widget Example",
             summary: "Focused content-oriented example using the shared suite shell",
             notes:
               "Content examples keep the shared shell while foregrounding one primary content container.",
             widget: :content,
             theme_id: :example_suite_default,
             app: :unified_example_content,
             directory: "examples/content",
             purpose: :widget_proof
           }
  end

  test "content example renders the shared shell and the focused content widget" do
    assert {:ok, runtime_state} = Content.boot()
    assert {:ok, html} = Content.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :content_example_screen_shell
    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "Content Widget Example"
    assert html =~ "Shared content block"
    assert html =~ "data-live-ui-widget=\"content\""
    assert html =~ "data-live-ui-variant=\"panel\""
  end
end
