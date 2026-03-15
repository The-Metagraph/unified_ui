defmodule UnifiedExamples.TemplateRuntimeTest do
  use ExUnit.Case, async: true

  alias UnifiedExamples.Shared.Runtime

  defmodule ButtonExample do
    use UnifiedExamples.Shared.Template,
      id: :template_button_example,
      title: "Button Example",
      summary: "Shared template proof for action-oriented widgets",
      widget: :button

    example_panel do
      button :template_demo_button do
        label("Save")
        style_refs([:example_primary_button])
        theme_ref(:example_suite_default)
        tone(:accent)
        variant(:quiet)
      end
    end
  end

  defmodule TextInputExample do
    use UnifiedExamples.Shared.Template,
      id: :template_text_input_example,
      title: "Text Input Example",
      summary: "Shared template proof for input-oriented widgets",
      widget: :text_input

    example_panel do
      text_input :template_demo_text_input do
        placeholder("Type here")
        style_refs([:example_primary_input])
        theme_ref(:example_suite_default)
        tone(:surface)
        variant(:filled)
      end
    end
  end

  test "shared runtime helper renders canonical examples through live_ui with the suite theme" do
    button_iur = Runtime.iur!(ButtonExample)
    text_input_iur = Runtime.iur!(TextInputExample)

    assert {:ok, button_runtime} = Runtime.inspect(ButtonExample)
    assert {:ok, text_input_runtime} = Runtime.inspect(TextInputExample)
    assert {:ok, button_html} = Runtime.render_html(ButtonExample)
    assert {:ok, text_input_html} = Runtime.render_html(TextInputExample)

    assert get_in(Runtime.renderable_element(button_iur).attributes, [:theme, :id]) ==
             :example_suite_default

    assert get_in(Runtime.renderable_element(text_input_iur).attributes, [:theme, :id]) ==
             :example_suite_default

    assert "box" in button_runtime.widgets
    assert "text" in button_runtime.widgets
    assert "button" in button_runtime.widgets
    assert "box" in text_input_runtime.widgets
    assert "text-input" in text_input_runtime.widgets

    assert button_runtime.html =~ "data-live-ui-variant=\"panel\""
    assert text_input_runtime.html =~ "data-live-ui-variant=\"panel\""
    assert button_html =~ "data-live-ui-widget=\"button\""
    assert text_input_html =~ "data-live-ui-widget=\"text-input\""
    assert button_html =~ "data-live-ui-variant=\"quiet\""
    assert text_input_html =~ "data-live-ui-variant=\"filled\""
  end
end
