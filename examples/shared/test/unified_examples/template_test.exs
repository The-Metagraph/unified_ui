defmodule UnifiedExamples.TemplateTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Reference
  alias UnifiedUi.Compiler
  alias UnifiedExamples.Shared.Template

  defmodule TextExample do
    use Template,
      id: :template_text_example,
      title: "Text Example",
      summary: "Shared template proof for text content",
      widget: :text,
      notes: "Text is the focused widget in this proof example."

    example_panel do
      text :template_demo_text do
        value("Shared template content")
        tone(:accent)
        variant(:headline)
      end
    end
  end

  test "shared template compiles into canonical UnifiedIUR with the common shell structure" do
    {:ok, result} = Compiler.compile(TextExample)

    assert TextExample.default_theme_id() == :example_suite_default
    assert TextExample.shared_style_profile() == Template.default_style_profile()

    assert TextExample.example_metadata() == %{
             id: :template_text_example,
             root_id: :template_text_example_root,
             title: "Text Example",
             summary: "Shared template proof for text content",
             notes: "Text is the focused widget in this proof example.",
             widget: :text,
             theme_id: :example_suite_default
           }

    assert result.identity.id == :template_text_example
    assert result.composition.root == :template_text_example_root
    assert result.default_theme == :example_suite_default
    assert result.iur.type == :composite
    assert result.iur.kind == :screen

    assert Enum.map(result.iur.children, fn child ->
             {child.slot, child.element.id, child.element.kind}
           end) == [
             {:default, :template_text_example_shell, :box}
           ]

    assert Compiler.summary(TextExample).theme_ids == [:example_suite_default]

    assert Compiler.listing(TextExample).authored.authored_ids == [
             :template_demo_text,
             :template_text_example_notes_text,
             :template_text_example_panel,
             :template_text_example_shell,
             :template_text_example_summary,
             :template_text_example_title
           ]

    assert Reference.summarize_tree(result.iur).type_histogram == %{
             composite: 1,
             layout: 2,
             widget: 4
           }
  end
end
