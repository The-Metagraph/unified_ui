defmodule UnifiedExamples.ImageTest do
  use ExUnit.Case, async: true

  alias UnifiedExamples.Image

  test "image example exposes standalone example metadata" do
    assert Image.metadata() == %{
             id: :image_example_screen,
             root_id: :image_example_screen_root,
             title: "Image Widget Example",
             summary: "Focused content-oriented example using the shared suite shell",
             notes:
               "Image examples keep the shared shell while foregrounding one primary image widget.",
             widget: :image,
             theme_id: :example_suite_default,
             app: :unified_example_image,
             directory: "examples/image",
             purpose: :widget_proof
           }
  end

  test "image example renders the shared shell and the focused content widget" do
    assert {:ok, runtime_state} = Image.boot()
    assert {:ok, html} = Image.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :image_example_screen_shell
    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "Image Widget Example"
    assert html =~ "data-live-ui-widget=\"image\""
    assert html =~ "Illustrative unified example image"
  end
end
