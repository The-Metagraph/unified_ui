defmodule UnifiedExamples.FileInputTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Tree
  alias UnifiedExamples.FileInput

  test "file_input example exposes standalone example metadata" do
    assert FileInput.metadata() == %{
             id: :file_input_example_screen,
             root_id: :file_input_example_screen_root,
             title: "File Input Widget Example",
             summary: "Focused input-oriented example using the shared suite shell",
             notes:
               "File input examples keep the shared form shell while foregrounding one file picker control.",
             widget: :file_input,
             theme_id: :example_suite_default,
             app: :unified_example_file_input,
             directory: "examples/file_input",
             purpose: :widget_proof
           }
  end

  test "file_input example renders the shared shell and the focused input widget" do
    assert {:ok, runtime_state} = FileInput.boot()
    assert {:ok, html} = FileInput.render_html()

    assert runtime_state.assigns.iur.id == :file_input_example_screen_shell

    assert %UnifiedIUR.Element{kind: :file_input} =
             Tree.find_by_id(runtime_state.assigns.iur, :file_input_example_primary_input)

    assert html =~ "data-live-ui-widget=\"form-builder\""
    assert html =~ "File Input Widget Example"
    assert html =~ "data-live-ui-widget=\"text-input\""
    assert html =~ "type=\"file\""
    assert html =~ "data-live-ui-variant=\"filled\""
  end
end
