defmodule UnifiedExamples.Phase2IntegrationTest do
  use ExUnit.Case, async: false

  alias UnifiedExamples.Shared
  alias UnifiedExamples.Shared.Catalog
  alias UnifiedExamples.Shared.Runtime
  alias UnifiedExamples.Shared.Template

  @phase_entries Catalog.entries()

  setup_all do
    Enum.each(@phase_entries, fn entry ->
      Enum.each(Catalog.source_files(entry.directory), &load_example_app/1)
    end)

    :ok
  end

  test "foundational example apps boot as independent Mix projects" do
    Enum.each(@phase_entries, fn entry ->
      app_root = Path.join(Shared.suite_root(), entry.directory)

      assert File.exists?(Path.join(app_root, "mix.exs"))
      assert File.exists?(Path.join(app_root, "config/config.exs"))
      assert File.dir?(Path.join(app_root, "lib"))
      assert File.dir?(Path.join(app_root, "test"))

      app = Catalog.app_module(entry.directory)

      assert Code.ensure_loaded?(app)
      assert {:ok, _runtime_state} = app.boot()
    end)
  end

  test "foundational example apps compile to canonical UnifiedIUR and render through live_ui" do
    Enum.each(@phase_entries, fn entry ->
      app = Catalog.app_module(entry.directory)
      screen = Catalog.screen_module(entry.directory)
      shell = Runtime.renderable_element(Runtime.iur!(screen))

      assert shell.kind == entry.shell_kind

      assert {:ok, html} = app.render_html()
      assert html =~ ~s(data-live-ui-widget="#{shell_widget(entry.shell_kind)}")
    end)
  end

  test "foundational example apps preserve the shared theme and style profile" do
    Enum.each(@phase_entries, fn entry ->
      app = Catalog.app_module(entry.directory)
      screen = Catalog.screen_module(entry.directory)
      shell = Runtime.renderable_element(Runtime.iur!(screen))

      assert app.metadata().theme_id == Template.default_theme_id()
      assert screen.default_theme_id() == Template.default_theme_id()
      assert screen.shared_style_profile() == Template.default_style_profile()
      assert get_in(shell.attributes, [:theme, :id]) == Template.default_theme_id()
      assert get_in(shell.attributes, [:theme, :variant]) == :panel

      assert {:ok, inspection} = Runtime.inspect(screen)
      assert shell_widget(entry.shell_kind) in inspection.widgets
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
