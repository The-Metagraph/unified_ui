defmodule UnifiedExamples.Phase3IntegrationTest do
  use ExUnit.Case, async: false

  alias UnifiedIUR.Element
  alias UnifiedIUR.Element.Child
  alias UnifiedExamples.Shared
  alias UnifiedExamples.Shared.Catalog
  alias UnifiedExamples.Shared.Runtime
  alias UnifiedExamples.Shared.SelfContainedBlueprint
  alias UnifiedExamples.Shared.Template
  alias UnifiedExamples.Shared.Tooling

  @phase_entries Catalog.by_phase(3)
  @suite_readme Path.join(Shared.suite_root(), "README.md")

  setup_all do
    Enum.each(@phase_entries, fn entry ->
      Enum.each(Catalog.source_files(entry.directory), &load_example_app/1)
    end)

    :ok
  end

  test "phase 3 apps stay discoverable, self-contained, and independently bootable" do
    readme = File.read!(@suite_readme)

    Enum.each(@phase_entries, fn entry ->
      app_root = Path.join(Shared.suite_root(), entry.directory)
      app = Catalog.app_module(entry.directory)
      screen = Catalog.screen_module(entry.directory)
      mix_path = Path.join(app_root, "mix.exs")
      app_path = Path.join(app_root, "lib/unified_examples/#{entry.directory}.ex")
      screen_path = Path.join(app_root, "lib/unified_examples/#{entry.directory}/screen.ex")

      mix_source = File.read!(mix_path)
      app_source = File.read!(app_path)
      screen_source = File.read!(screen_path)
      metadata = app.metadata()

      assert entry.directory in Shared.catalog_directories()
      assert readme =~ "`#{entry.directory}/`"
      assert File.exists?(mix_path)
      assert File.exists?(Path.join(app_root, "config/config.exs"))
      assert File.dir?(Path.join(app_root, "lib"))
      assert File.dir?(Path.join(app_root, "test"))
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

  test "phase 3 apps preserve the self-contained shell, theme, and style baseline across families" do
    baseline = SelfContainedBlueprint.current_baseline()

    Enum.each(@phase_entries, fn entry ->
      app = Catalog.app_module(entry.directory)
      screen = Catalog.screen_module(entry.directory)
      {:ok, metadata} = Tooling.review_metadata(entry.directory)
      shell = Runtime.renderable_element(Runtime.iur!(screen))

      assert metadata.theme_id == baseline.default_theme_id
      assert screen.default_theme_id() == baseline.default_theme_id
      assert screen.shared_style_profile() == Template.default_style_profile()
      assert metadata.style_contract.browser_shell_classes == baseline.browser_shell_classes
      assert metadata.style_contract.theme_tokens == baseline.theme_tokens
      assert metadata.style_contract.component_style_ids == baseline.component_style_ids
      assert metadata.style_contract.semantic_roles == baseline.semantic_roles
      assert shell.kind == entry.shell_kind
      assert get_in(shell.attributes, [:theme, :id]) == baseline.default_theme_id

      assert {:ok, html} = app.render_html()
      assert html =~ ~s(data-live-ui-widget="#{html_widget(entry.shell_kind)}")
      assert html =~ ~s(data-live-ui-widget="#{html_widget(entry.widget)}")

      if metadata.interaction_demo.trigger_label not in [nil, ""] do
        assert html =~ metadata.interaction_demo.trigger_label
      end
    end)
  end

  test "phase 3 apps keep one primary subject and stay aligned with catalog interaction contracts" do
    Enum.each(@phase_entries, fn entry ->
      screen = Catalog.screen_module(entry.directory)
      {:ok, metadata} = Tooling.review_metadata(entry.directory)
      shell = Runtime.renderable_element(Runtime.iur!(screen))

      assert metadata.family == entry.family
      assert metadata.phase == entry.phase
      assert metadata.interaction_demo.mode == entry.interaction_demo.mode
      assert metadata.interaction_demo.family == entry.interaction_demo.family
      assert metadata.interaction_demo.source == entry.interaction_demo.source
      assert metadata.interaction_demo.trigger_label == entry.interaction_demo.trigger_label
      assert metadata.interaction_demo.idle_prompt == entry.interaction_demo.idle_prompt
      assert metadata.interaction_demo.outcome == entry.interaction_demo.outcome

      assert count_kind(shell, entry.widget) == 1,
             "expected exactly one #{entry.widget} in #{entry.directory}, got #{count_kind(shell, entry.widget)}"
    end)
  end

  defp load_example_app(path) do
    unless Enum.any?(Code.required_files(), &(&1 == path)) do
      Code.require_file(path)
    end
  end

  defp html_widget(kind) when is_atom(kind) do
    kind
    |> Atom.to_string()
    |> String.replace("_", "-")
  end

  defp count_kind(%Element{} = element, kind) do
    current = if element.kind == kind, do: 1, else: 0
    current + Enum.reduce(child_elements(element), 0, &(count_kind(&1, kind) + &2))
  end

  defp child_elements(%Element{children: children}) do
    Enum.map(children, fn %Child{element: element} -> element end)
  end
end
