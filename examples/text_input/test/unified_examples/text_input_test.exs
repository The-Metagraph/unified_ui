defmodule UnifiedExamples.TextInputTest do
  use ExUnit.Case, async: false

  import Phoenix.ConnTest
  import Phoenix.LiveViewTest

  alias UnifiedExamples.TextInput
  alias UnifiedExamples.Shared.Tooling

  @endpoint UnifiedExamples.TextInput.Endpoint

  test "text_input example exposes standalone example metadata" do
    assert TextInput.metadata() == %{
             id: :text_input_example_screen,
             root_id: :text_input_example_screen_root,
             title: "Text Input Widget Example",
             summary: "Focused input-oriented example using the shared suite shell",
             notes:
               "Type in the field to inspect the canonical change signal compiled from the authored DSL.",
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
    assert html =~ "data-live-ui-signal-preview=\"true\""
    assert html =~ "No signal captured yet"
  end

  test "text_input example boots through its Phoenix LiveView app entrypoint" do
    assert {:ok, smoke} = Tooling.smoke_launch("text_input")

    assert smoke.status == 200
    assert smoke.body =~ "data-example-directory=\"examples/text_input\""
    assert smoke.body =~ "Text Input Widget Example"
    assert smoke.body =~ "data-live-ui-widget=\"text-input\""
  end

  test "text_input example changes surface the canonical signal preview through LiveView" do
    {:ok, view, html} = live(build_conn(), "/")

    assert html =~ "Type your note"
    assert html =~ "data-live-ui-signal-preview=\"true\""
    assert html =~ "No signal captured yet"

    updated_html =
      view
      |> form(
        ~s(form[data-live-ui-interaction-form="true"]),
        %{"text_input_example_primary_input" => "Ship the release"}
      )
      |> render_change()

    assert updated_html =~ "data-live-ui-signal-preview=\"true\""
    assert updated_html =~ "live_ui.change.draft_note"
    assert updated_html =~ "change:draft_note"
    assert updated_html =~ "dsl_text_input"
    assert updated_html =~ "text_input_example_primary_input"
    assert updated_html =~ "Ship the release"
  end
end
