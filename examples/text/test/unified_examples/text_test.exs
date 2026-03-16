defmodule UnifiedExamples.TextTest do
  use ExUnit.Case, async: false

  alias UnifiedExamples.Text
  alias UnifiedExamples.Shared.Tooling

  test "text example exposes standalone example metadata" do
    metadata = Text.metadata()

    assert metadata.id == :text_example_screen
    assert metadata.root_id == :text_example_screen_root
    assert metadata.title == "Text Widget Example"
    assert metadata.widget == :text
    assert metadata.theme_id == :example_suite_default
    assert metadata.app == :unified_example_text
    assert metadata.directory == "examples/text"
    assert metadata.purpose == :widget_proof
    assert metadata.interaction_demo.mode == :shared_trigger
    assert metadata.interaction_demo.family == :click
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
    assert html =~ "Highlight the text story"
    assert html =~ "Meaningful Interaction Story"
  end

  test "text example boots through its Phoenix LiveView app entrypoint" do
    assert {:ok, smoke} = Tooling.smoke_launch("text")

    assert smoke.status == 200
    assert smoke.body =~ "data-example-directory=\"examples/text\""
    assert smoke.body =~ "Text Widget Example"
    assert smoke.body =~ "data-live-ui-widget=\"text\""
  end
end
