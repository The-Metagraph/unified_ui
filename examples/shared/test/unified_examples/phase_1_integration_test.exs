defmodule UnifiedExamples.Phase1IntegrationTest do
  use ExUnit.Case, async: false

  alias UnifiedExamples.Shared.Runtime

  @text_screen_file "/Users/Pascal/code/unified/examples/text/lib/unified_examples/text/screen.ex"
  @text_app_file "/Users/Pascal/code/unified/examples/text/lib/unified_examples/text.ex"
  @button_screen_file "/Users/Pascal/code/unified/examples/button/lib/unified_examples/button/screen.ex"
  @button_app_file "/Users/Pascal/code/unified/examples/button/lib/unified_examples/button.ex"
  @text_input_screen_file "/Users/Pascal/code/unified/examples/text_input/lib/unified_examples/text_input/screen.ex"
  @text_input_app_file "/Users/Pascal/code/unified/examples/text_input/lib/unified_examples/text_input.ex"

  setup_all do
    load_example_app(@text_screen_file)
    load_example_app(@text_app_file)
    load_example_app(@button_screen_file)
    load_example_app(@button_app_file)
    load_example_app(@text_input_screen_file)
    load_example_app(@text_input_app_file)
    :ok
  end

  test "shared support library compiles and can be consumed by standalone example apps" do
    for app <- [app_module(:text), app_module(:button), app_module(:text_input)] do
      assert Code.ensure_loaded?(app)
      assert {:ok, _runtime_state} = app.boot()
    end
  end

  test "shared DSL template compiles to canonical UnifiedIUR and renders through live_ui" do
    assert {:ok, text_html} = app_module(:text).render_html()
    assert {:ok, button_html} = app_module(:button).render_html()
    assert {:ok, text_input_html} = app_module(:text_input).render_html()

    assert text_html =~ "data-live-ui-widget=\"box\""
    assert text_html =~ "data-live-ui-widget=\"text\""
    assert button_html =~ "data-live-ui-widget=\"button\""
    assert text_input_html =~ "data-live-ui-widget=\"text-input\""
  end

  test "proof apps share the same default shell and theme while differing in primary widget content" do
    text_shell = Runtime.renderable_element(Runtime.iur!(screen_module(:text)))
    button_shell = Runtime.renderable_element(Runtime.iur!(screen_module(:button)))
    text_input_shell = Runtime.renderable_element(Runtime.iur!(screen_module(:text_input)))

    assert get_in(text_shell.attributes, [:theme, :id]) == :example_suite_default
    assert get_in(button_shell.attributes, [:theme, :id]) == :example_suite_default
    assert get_in(text_input_shell.attributes, [:theme, :id]) == :example_suite_default

    assert get_in(text_shell.attributes, [:theme, :variant]) == :panel
    assert get_in(button_shell.attributes, [:theme, :variant]) == :panel
    assert get_in(text_input_shell.attributes, [:theme, :variant]) == :panel

    assert {:ok, text_runtime} = Runtime.inspect(screen_module(:text))
    assert {:ok, button_runtime} = Runtime.inspect(screen_module(:button))
    assert {:ok, text_input_runtime} = Runtime.inspect(screen_module(:text_input))

    assert "text" in text_runtime.widgets
    assert "button" not in text_runtime.widgets
    assert "button" in button_runtime.widgets
    assert "text-input" not in button_runtime.widgets
    assert "text-input" in text_input_runtime.widgets
    assert "button" not in text_input_runtime.widgets
  end

  defp load_example_app(path) do
    unless Enum.any?(Code.required_files(), &(&1 == path)) do
      Code.require_file(path)
    end
  end

  defp app_module(:text), do: Module.concat([UnifiedExamples, Text])
  defp app_module(:button), do: Module.concat([UnifiedExamples, Button])
  defp app_module(:text_input), do: Module.concat([UnifiedExamples, TextInput])

  defp screen_module(:text), do: Module.concat([UnifiedExamples, Text, Screen])
  defp screen_module(:button), do: Module.concat([UnifiedExamples, Button, Screen])
  defp screen_module(:text_input), do: Module.concat([UnifiedExamples, TextInput, Screen])
end
