defmodule UnifiedExamples.TextInputTest do
  use ExUnit.Case, async: false

  alias UnifiedExamples.TextInput
  alias UnifiedExamples.Shared.Tooling

  test "text_input example exposes standalone example metadata" do
    assert TextInput.metadata() == %{
             id: :text_input_example_screen,
             root_id: :text_input_example_screen_root,
             title: "Text Input Widget Example",
             summary: "Focused input-oriented example using the shared suite shell",
             notes:
               "Text input examples keep the shared shell while foregrounding one input control.",
             widget: :text_input,
             theme_id: :example_suite_default,
             app: :unified_example_text_input,
             directory: "examples/text_input",
             purpose: :widget_proof
           }
  end

  test "text_input example renders the shared shell and the focused input widget" do
    assert {:ok, runtime_state} = TextInput.boot()
    assert {:ok, html} = TextInput.render_html()

    assert runtime_state.assigns.iur.id == :text_input_example_screen_shell
    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "Text Input Widget Example"
    assert html =~ "data-live-ui-widget=\"text-input\""
    assert html =~ "Type your note"
    assert html =~ "data-live-ui-variant=\"filled\""
  end

  test "text_input example boots through its Phoenix LiveView app entrypoint" do
    assert {:ok, smoke} = Tooling.smoke_launch("text_input")

    assert smoke.status == 200
    assert smoke.body =~ "data-example-directory=\"examples/text_input\""
    assert smoke.body =~ "Text Input Widget Example"
    assert smoke.body =~ "data-live-ui-widget=\"text-input\""
  end
end
