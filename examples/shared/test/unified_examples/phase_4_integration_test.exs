defmodule UnifiedExamples.Phase4IntegrationTest do
  use ExUnit.Case, async: false

  alias UnifiedIUR.Element
  alias UnifiedIUR.Element.Child
  alias UnifiedExamples.Shared
  alias UnifiedExamples.Shared.Catalog
  alias UnifiedExamples.Shared.Runtime
  alias UnifiedExamples.Shared.Template

  @phase_entries Catalog.by_phase(4)
  @suite_readme Path.join(Shared.suite_root(), "README.md")

  setup_all do
    Enum.each(@phase_entries, fn entry ->
      Enum.each(Catalog.source_files(entry.directory), &load_example_app/1)
    end)

    :ok
  end

  test "phase 4 apps are discoverable from the suite catalog, advanced sweep, and README" do
    readme = File.read!(@suite_readme)

    assert Shared.advanced_catalog_directories() ==
             @phase_entries
             |> Enum.map(& &1.directory)
             |> Enum.sort()

    Enum.each(@phase_entries, fn entry ->
      app_root = Path.join(Shared.suite_root(), entry.directory)
      app = Catalog.app_module(entry.directory)

      assert entry.directory in Shared.catalog_directories()
      assert entry.directory in Shared.advanced_catalog_directories()
      assert readme =~ "`#{entry.directory}/`"
      assert File.exists?(Path.join(app_root, "mix.exs"))
      assert File.exists?(Path.join(app_root, "config/config.exs"))
      assert File.dir?(Path.join(app_root, "lib"))
      assert File.dir?(Path.join(app_root, "test"))
      assert Code.ensure_loaded?(app)
      assert {:ok, _runtime_state} = app.boot()
    end)
  end

  test "phase 4 apps preserve the shared DSL template and default theme across advanced families" do
    Enum.each(@phase_entries, fn entry ->
      app = Catalog.app_module(entry.directory)
      screen = Catalog.screen_module(entry.directory)
      shell = Runtime.renderable_element(Runtime.iur!(screen))

      assert app.metadata().theme_id == Template.default_theme_id()
      assert screen.default_theme_id() == Template.default_theme_id()
      assert screen.shared_style_profile() == Template.default_style_profile()
      assert shell.kind == entry.shell_kind
      assert get_in(shell.attributes, [:theme, :id]) == Template.default_theme_id()
      assert get_in(shell.attributes, [:theme, :variant]) == :panel

      assert {:ok, html} = app.render_html()
      assert html =~ ~s(data-live-ui-widget="#{html_widget(entry.shell_kind)}")
      assert html =~ ~s(data-live-ui-widget="#{html_widget(entry.widget)}")
    end)
  end

  test "phase 4 apps keep exactly one primary subject in the compiled tree" do
    Enum.each(@phase_entries, fn entry ->
      screen = Catalog.screen_module(entry.directory)
      shell = Runtime.renderable_element(Runtime.iur!(screen))

      assert count_kind(shell, entry.widget) == 1,
             "expected exactly one #{entry.widget} in #{entry.directory}, got #{count_kind(shell, entry.widget)}"
    end)
  end

  test "phase 4 apps enforce advanced catalog completeness automatically" do
    assert Shared.advanced_app_directories() == Shared.advanced_catalog_directories()
    assert Shared.missing_advanced_directories() == []
  end

  defp load_example_app(path) do
    unless Enum.any?(Code.required_files(), &(&1 == path)) do
      Code.require_file(path)
    end
  end

  defp html_widget(kind) when is_atom(kind) do
    case kind do
      :overlay ->
        "overlay-surface"

      _ ->
        kind
        |> Atom.to_string()
        |> String.replace("_", "-")
    end
  end

  defp count_kind(%Element{} = element, kind) do
    current = if element.kind == kind, do: 1, else: 0
    current + Enum.reduce(child_elements(element), 0, &(count_kind(&1, kind) + &2))
  end

  defp child_elements(%Element{children: children}) do
    Enum.map(children, fn %Child{element: element} -> element end)
  end
end
