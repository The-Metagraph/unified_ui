defmodule UnifiedExamples.Phase2IntegrationTest do
  use ExUnit.Case, async: false

  alias UnifiedExamples.Shared.Catalog
  alias UnifiedExamples.Shared.Runtime
  alias UnifiedExamples.Shared.SelfContainedBlueprint
  alias UnifiedExamples.Shared.Template

  @phase2_directories ~w(
    text
    label
    icon
    image
    link
    separator
    spacer
    content
    button
    form_builder
    field_group
    field
    text_input
    numeric_input
    checkbox
    radio_group
    select
    pick_list
    toggle
    date_input
    time_input
    file_input
  )

  setup_all do
    Enum.each(@phase2_directories, fn directory ->
      Enum.each(Catalog.source_files(directory), &load_example_app/1)
    end)

    :ok
  end

  test "phase 2 apps boot without examples/shared in their focused dependency and screen paths" do
    Enum.each(@phase2_directories, fn directory ->
      app = Catalog.app_module(directory)
      screen = Catalog.screen_module(directory)
      mix_path = Path.expand("examples/#{directory}/mix.exs", File.cwd!())
      app_path = Path.expand("examples/#{directory}/lib/unified_examples/#{directory}.ex", File.cwd!())
      screen_path = Path.expand("examples/#{directory}/lib/unified_examples/#{directory}/screen.ex", File.cwd!())

      mix_source = File.read!(mix_path)
      app_source = File.read!(app_path)
      screen_source = File.read!(screen_path)
      metadata = app.metadata()

      refute mix_source =~ "unified_examples_shared"
      refute app_source =~ "UnifiedExamples.Shared.App"
      refute screen_source =~ "UnifiedExamples.Shared.Template"
      refute screen_source =~ "example_panel do"
      refute screen_source =~ "example_form_panel do"

      assert metadata.template_mode == :local
      refute metadata.uses_examples_shared?
      assert Code.ensure_loaded?(app)
      assert Code.ensure_loaded?(screen)
      assert {:ok, _runtime_state} = app.boot()
    end)
  end

  test "phase 2 apps preserve the shell, theme, and style baseline captured in phase 1" do
    baseline = SelfContainedBlueprint.current_baseline()

    Enum.each(@phase2_directories, fn directory ->
      app = Catalog.app_module(directory)
      screen = Catalog.screen_module(directory)
      metadata = app.metadata()
      shell = Runtime.renderable_element(Runtime.iur!(screen))

      assert metadata.theme_id == baseline.default_theme_id
      assert screen.default_theme_id() == baseline.default_theme_id
      assert screen.shared_style_profile() == Template.default_style_profile()
      assert metadata.style_contract.browser_shell_classes == baseline.browser_shell_classes
      assert metadata.style_contract.theme_tokens == baseline.theme_tokens
      assert metadata.style_contract.component_style_ids == baseline.component_style_ids
      assert metadata.style_contract.semantic_roles == baseline.semantic_roles
      assert get_in(shell.attributes, [:theme, :id]) == baseline.default_theme_id
    end)
  end

  test "representative content, form, and input apps still show the intended authored-to-runtime flow" do
    representatives = %{
      text: %{shell_kind: :box, rendered_widget: "text", visible_copy: "Self-contained text example"},
      field: %{shell_kind: :form_builder, rendered_widget: "field", visible_copy: "Display name"},
      text_input: %{shell_kind: :box, rendered_widget: "text-input", visible_copy: "Type your note"}
    }

    Enum.each(representatives, fn {directory, expectation} ->
      app = Catalog.app_module(directory)
      screen = Catalog.screen_module(directory)
      shell = Runtime.renderable_element(Runtime.iur!(screen))

      assert shell.kind == expectation.shell_kind

      assert {:ok, html} = app.render_html()
      assert html =~ ~s(data-live-ui-widget="#{shell_widget(expectation.shell_kind)}")
      assert html =~ ~s(data-live-ui-widget="#{expectation.rendered_widget}")
      assert html =~ expectation.visible_copy
    end)
  end

  defp load_example_app(path) do
    unless Enum.any?(Code.required_files(), &(&1 == path)) do
      Code.require_file(path)
    end
  end

  defp shell_widget(:box), do: "box"
  defp shell_widget(:form_builder), do: "form-builder"
end
