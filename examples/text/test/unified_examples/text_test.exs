defmodule UnifiedExamples.TextTest do
  use ExUnit.Case, async: false

  alias UnifiedExamples.Text
  alias UnifiedExamples.Shared.Tooling

  test "text example exposes standalone example metadata" do
    assert Text.metadata() == %{
             id: :text_example_screen,
             root_id: :text_example_screen_root,
             title: "Text Widget Example",
             summary: "Focused content-oriented example using the shared suite shell",
             notes:
               "Text examples keep the shared shell while foregrounding one primary content widget.",
             widget: :text,
             theme_id: :example_suite_default,
             app: :unified_example_text,
             directory: "examples/text",
             purpose: :widget_proof
           }
  end

  test "text example renders the shared shell and the focused content widget" do
    assert {:ok, runtime_state} = Text.boot()
    assert {:ok, html} = Text.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :text_example_screen_shell
    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "Text Widget Example"
    assert html =~ "Shared text example"
    assert html =~ "data-live-ui-widget=\"text\""
    assert html =~ "data-live-ui-variant=\"headline\""
  end

  test "text example boots through its Phoenix LiveView app entrypoint" do
    assert {:ok, smoke} = Tooling.smoke_launch("text")

    assert smoke.status == 200
    assert smoke.body =~ "data-example-directory=\"examples/text\""
    assert smoke.body =~ "Text Widget Example"
    assert smoke.body =~ "data-live-ui-widget=\"text\""
  end
end
