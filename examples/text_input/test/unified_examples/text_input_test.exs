defmodule UnifiedExamples.TextInputTest do
  use ExUnit.Case, async: false

  import Phoenix.ConnTest
  import Phoenix.LiveViewTest

  alias UnifiedExamples.TextInput
  alias UnifiedExamples.Shared.Tooling

  @endpoint UnifiedExamples.TextInput.Endpoint

  test "text_input example exposes standalone example metadata" do
    metadata = TextInput.metadata()

    assert metadata.id == :text_input_example_screen
    assert metadata.root_id == :text_input_example_screen_root
    assert metadata.title == "Text Input Widget Example"

    assert metadata.notes ==
             "Type in the field to inspect the canonical change signal compiled from the authored DSL."

    assert metadata.widget == :text_input
    assert metadata.theme_id == :example_suite_default
    assert metadata.app == :unified_example_text_input
    assert metadata.directory == "examples/text_input"
    assert metadata.purpose == :widget_proof
    assert metadata.interaction_demo.mode == :custom
    assert metadata.interaction_demo.family == :change
    assert metadata.interaction_demo.source == :primary_widget
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
    assert html =~ "Meaningful Interaction Story"
    assert html =~ "Canonical Signal Preview"
    assert html =~ "phx-change=\"canonical_interaction\""
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

    assert html =~
             "Type into the draft field to capture the authored change signal and latest value."

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
