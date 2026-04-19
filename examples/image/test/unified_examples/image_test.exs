defmodule UnifiedExamples.ImageTest do
  use ExUnit.Case, async: false

  import Phoenix.ConnTest

  alias UnifiedExamples.Image
  alias UnifiedExamples.Image.Screen

  @endpoint UnifiedExamples.Image.Endpoint

  test "image example exposes self-contained example metadata" do
    metadata = Image.metadata()

    assert metadata.id == :image_example_screen
    assert metadata.root_id == :image_example_screen_root
    assert metadata.title == "Image Widget Example"
    assert metadata.summary == "Focused content-oriented example using the local example shell"
    assert metadata.notes == "Image examples keep the local shell while foregrounding one primary image widget."
    assert metadata.widget == :image
    assert metadata.theme_id == :example_suite_default
    assert metadata.app == :unified_example_image
    assert metadata.directory == "examples/image"
    assert metadata.purpose == :widget_proof
    assert metadata.template_mode == :local
    refute metadata.uses_examples_shared?
    assert metadata.runtime_modules == [
             UnifiedExamples.Image.Application,
             UnifiedExamples.Image.Endpoint,
             UnifiedExamples.Image.Router,
             UnifiedExamples.Image.Layouts,
             UnifiedExamples.Image.Live
           ]
    assert metadata.authored_modules == [
             UnifiedExamples.Image.Screen,
             UnifiedExamples.Image.Theme,
             UnifiedExamples.Image.StyleProfile,
             UnifiedExamples.Image.Helpers
           ]
    assert metadata.style_contract.component_style_ids == [
             :example_shell,
             :example_panel,
             :example_form_shell,
             :example_title,
             :example_summary,
             :example_notes,
             :example_primary_button,
             :example_primary_input
           ]
    assert metadata.interaction_demo.mode == :shared_trigger
    assert metadata.interaction_demo.family == :click
    assert Screen.local_style_profile() == Screen.shared_style_profile()
  end

  test "image example renders the local shell and the focused widget" do
    assert {:ok, runtime_state} = Image.boot()
    assert {:ok, html} = Image.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :image_example_screen_shell
    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "Image Widget Example"
    assert html =~ "data-live-ui-widget=\"image\""
    assert html =~ "Highlight the image story"
    assert html =~ "Meaningful Interaction Story"
  end

  test "image example boots through its Phoenix LiveView app entrypoint" do
    conn = get(build_conn(), "/")
    body = html_response(conn, 200)

    assert body =~ "data-example-directory=\"examples/image\""
    assert body =~ "Image Widget Example"
    assert body =~ "data-live-ui-widget=\"image\""
    assert body =~ "jido_run inspired live_ui example"
    assert body =~ "<meta name=\"csrf-token\""
    assert body =~ "/vendor/phoenix/phoenix.js"
    assert body =~ "/vendor/live_view/phoenix_live_view.js"
  end
end
