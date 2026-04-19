defmodule UnifiedExamples.RadioGroupTest do
  use ExUnit.Case, async: false

  import Phoenix.ConnTest

  alias UnifiedExamples.RadioGroup
  alias UnifiedExamples.RadioGroup.Screen

  @endpoint UnifiedExamples.RadioGroup.Endpoint

  test "radio_group example exposes self-contained example metadata" do
    metadata = RadioGroup.metadata()

    assert metadata.id == :radio_group_example_screen
    assert metadata.root_id == :radio_group_example_screen_root
    assert metadata.title == "Radio Group Widget Example"
    assert metadata.summary == "Focused input-oriented example using the local example shell"
    assert metadata.notes == "Radio group examples keep the local form shell while foregrounding one exclusive choice control."
    assert metadata.widget == :radio_group
    assert metadata.theme_id == :example_suite_default
    assert metadata.app == :unified_example_radio_group
    assert metadata.directory == "examples/radio_group"
    assert metadata.purpose == :widget_proof
    assert metadata.template_mode == :local
    refute metadata.uses_examples_shared?
    assert metadata.runtime_modules == [
             UnifiedExamples.RadioGroup.Application,
             UnifiedExamples.RadioGroup.Endpoint,
             UnifiedExamples.RadioGroup.Router,
             UnifiedExamples.RadioGroup.Layouts,
             UnifiedExamples.RadioGroup.Live
           ]
    assert metadata.authored_modules == [
             UnifiedExamples.RadioGroup.Screen,
             UnifiedExamples.RadioGroup.Theme,
             UnifiedExamples.RadioGroup.StyleProfile,
             UnifiedExamples.RadioGroup.Helpers
           ]
    assert metadata.interaction_demo.mode == :form_shell
    assert metadata.interaction_demo.family == :selection
    assert metadata.interaction_demo.source == :form_shell
    assert Screen.local_style_profile() == Screen.shared_style_profile()
  end

  test "radio_group example renders the local form shell and the focused widget" do
    assert {:ok, runtime_state} = RadioGroup.boot()
    assert {:ok, html} = RadioGroup.render_html()

    assert runtime_state.assigns.iur.id == :radio_group_example_screen_shell
    assert html =~ "data-live-ui-widget=\"form-builder\""
    assert html =~ "Radio Group Widget Example"
    assert html =~ "data-live-ui-widget=\"select\""
    assert html =~ "Admin"
    assert html =~ "data-live-ui-variant=\"filled\""
    assert html =~ "phx-change=\"canonical_selection_interaction\""
    assert html =~ "Meaningful Interaction Story"
  end

  test "radio_group example boots through its Phoenix LiveView app entrypoint" do
    conn = get(build_conn(), "/")
    body = html_response(conn, 200)

    assert body =~ "data-example-directory=\"examples/radio_group\""
    assert body =~ "Radio Group Widget Example"
    assert body =~ "data-live-ui-widget=\"form-builder\""
    assert body =~ "jido_run inspired live_ui example"
  end
end
