defmodule UnifiedExamples.Shared.SelfContainedBlueprint do
  @moduledoc """
  Inventory and baseline surfaces for the self-contained examples refactor.
  """

  alias UnifiedExamples.Shared
  alias UnifiedExamples.Shared.Template

  @app_macro "UnifiedExamples.Shared.App"
  @template_macro "UnifiedExamples.Shared.Template"
  @fixture_module "UnifiedExamples.Shared.Fixtures"
  @inventory_guide_path "guides/self_contained_inventory.md"
  @blueprint_guide_path "guides/self_contained_blueprint.md"

  @browser_shell_classes [
    "example-app-shell",
    "example-app-header",
    "example-app-runtime",
    "example-app-header-top",
    "example-app-kicker",
    "example-app-widget",
    "example-app-title",
    "example-app-summary",
    "example-app-notes"
  ]

  @semantic_roles [
    :surface,
    :accent,
    :success,
    :warning,
    :critical,
    :muted,
    :foreground
  ]

  @theme_tokens [
    :shell_surface,
    :panel_surface,
    :accent_action,
    :input_surface
  ]

  @component_style_ids [
    :example_shell,
    :example_panel,
    :example_form_shell,
    :example_title,
    :example_summary,
    :example_notes,
    :example_primary_button,
    :example_primary_input
  ]

  @helper_surface_categories %{
    app_bootstrap: [
      "UnifiedExamples.Shared.App",
      "UnifiedExamples.Shared.Loader",
      "UnifiedExamples.Shared.Runtime",
      "UnifiedExamples.Shared.RuntimeAdapter"
    ],
    screen_authoring: [
      "UnifiedExamples.Shared.Template",
      "UnifiedExamples.Shared.Fixtures",
      "UnifiedExamples.Shared.InteractionDemo"
    ],
    docs_and_validation: [
      "UnifiedExamples.Shared.AppReadme",
      "UnifiedExamples.Shared.Documentation",
      "UnifiedExamples.Shared.Maintenance",
      "UnifiedExamples.Shared.ReleaseReadiness",
      "UnifiedExamples.Shared.Reporting",
      "UnifiedExamples.Shared.Tooling",
      "UnifiedExamples.Shared.Traceability",
      "UnifiedExamples.Shared.Validation"
    ],
    suite_catalog: [
      "UnifiedExamples.Shared",
      "UnifiedExamples.Shared.Catalog"
    ]
  }

  @shared_helper_modules Enum.flat_map(@helper_surface_categories, fn {_category, modules} -> modules end)

  @required_local_runtime_modules [
    %{
      id: :application,
      responsibility: "Own the Phoenix application startup tree for one example project."
    },
    %{
      id: :endpoint,
      responsibility: "Own the Phoenix endpoint and browser runtime configuration."
    },
    %{
      id: :router,
      responsibility: "Own the browser route and mount path for the example app."
    },
    %{
      id: :layouts,
      responsibility: "Own the browser shell HTML and CSS emitted by the example app."
    },
    %{
      id: :live,
      responsibility: "Own the LiveView entrypoint that renders the focused screen."
    }
  ]

  @required_local_authored_modules [
    %{
      id: :screen,
      responsibility: "Own the focused `unified_ui` screen and widget composition for the example."
    },
    %{
      id: :theme,
      responsibility: "Own the localized `:example_suite_default` theme definition."
    },
    %{
      id: :style_profile,
      responsibility: "Own the localized shell, panel, title, summary, notes, and control style ids."
    },
    %{
      id: :helpers,
      responsibility: "Own any local helper functions needed by the screen without delegating back to `examples/shared/`."
    }
  ]

  @conditional_local_surfaces [
    %{
      id: :fixtures,
      when_needed: "Use a project-local fixture module when the example currently depends on `UnifiedExamples.Shared.Fixtures`."
    },
    %{
      id: :interaction_support,
      when_needed: "Use project-local interaction or metadata helpers when the example needs focused reviewer guidance."
    },
    %{
      id: :documentation,
      when_needed: "Keep README and migration notes with the example project when local details are necessary to run or review it."
    }
  ]

  @forbidden_shared_surfaces [
    %{
      surface: "examples/shared",
      kind: :path_dependency,
      rule: "Focused example apps must not depend on the shared support package in the target state."
    },
    %{
      surface: "UnifiedExamples.Shared.App",
      kind: :repo_macro,
      rule: "Project-local runtime modules must replace the shared app scaffolding macro."
    },
    %{
      surface: "UnifiedExamples.Shared.Template",
      kind: :repo_macro,
      rule: "Project-local screen, theme, and style modules must replace the shared template macro."
    },
    %{
      surface: "example_panel/1 and example_form_panel/1",
      kind: :repo_macro_helper,
      rule: "Local functions and explicit authored modules must replace shared panel helper macros."
    }
  ]

  @allowed_framework_macros [
    "use Phoenix.LiveView",
    "use Phoenix.Component",
    "use UnifiedUi.Dsl"
  ]

  @validation_rules [
    %{
      id: :no_examples_shared_path_dependency,
      description: "Reject any focused example app that still depends on `examples/shared/`."
    },
    %{
      id: :no_repo_scaffolding_macros,
      description: "Reject any focused example app that still uses repository-owned helper macros for app or screen scaffolding."
    },
    %{
      id: :explicit_runtime_modules_present,
      description: "Require local application, endpoint, router, layouts, and LiveView entrypoint modules."
    },
    %{
      id: :explicit_authored_modules_present,
      description: "Require local screen, theme, style, and helper modules, plus local fixtures when the example needs them."
    },
    %{
      id: :preserved_visual_baseline,
      description: "Require the preserved browser shell classes, default theme id, theme tokens, semantic roles, and component style ids."
    }
  ]

  @spec guide_paths() :: %{inventory: String.t(), blueprint: String.t()}
  def guide_paths do
    %{
      inventory: Path.join(Shared.shared_root(), @inventory_guide_path),
      blueprint: Path.join(Shared.shared_root(), @blueprint_guide_path)
    }
  end

  @spec shared_helper_modules() :: [String.t()]
  def shared_helper_modules do
    @shared_helper_modules
  end

  @spec helper_surface_categories() :: %{optional(atom()) => [String.t()]}
  def helper_surface_categories do
    @helper_surface_categories
  end

  @spec browser_shell_classes() :: [String.t()]
  def browser_shell_classes do
    @browser_shell_classes
  end

  @spec semantic_roles() :: [atom()]
  def semantic_roles do
    @semantic_roles
  end

  @spec theme_tokens() :: [atom()]
  def theme_tokens do
    @theme_tokens
  end

  @spec component_style_ids() :: [atom()]
  def component_style_ids do
    @component_style_ids
  end

  @spec inventory() :: map()
  def inventory do
    app_macro_usages = shared_usage(@app_macro)
    template_macro_usages = shared_usage(@template_macro)
    fixture_usages = shared_usage(@fixture_module)

    %{
      total_directories: length(Shared.app_directories()),
      shared_helper_modules: @shared_helper_modules,
      helper_surface_categories: @helper_surface_categories,
      app_macro_usages: app_macro_usages,
      template_macro_usages: template_macro_usages,
      example_panel_usages: helper_form_usages("example_panel"),
      example_form_panel_usages: helper_form_usages("example_form_panel"),
      fixture_usages: fixture_usages,
      directories_without_app_macro:
        missing_directories_for(app_macro_usages, Shared.app_directories()),
      directories_without_template_macro:
        missing_directories_for(template_macro_usages, Shared.app_directories()),
      directories_with_fixtures:
        fixture_usages
        |> Enum.map(& &1.directory)
        |> Enum.uniq()
        |> Enum.sort()
    }
  end

  @spec current_baseline() :: map()
  def current_baseline do
    %{
      inventory_guide_path: guide_paths().inventory,
      blueprint_guide_path: guide_paths().blueprint,
      browser_shell_source_path: shared_source_path("app.ex"),
      template_source_path: shared_source_path("template.ex"),
      default_theme_id: Template.default_theme_id(),
      default_notes: Template.default_notes(),
      default_style_profile: Template.default_style_profile(),
      browser_shell_classes: @browser_shell_classes,
      semantic_roles: @semantic_roles,
      theme_tokens: @theme_tokens,
      component_style_ids: @component_style_ids
    }
  end

  @spec target_blueprint() :: map()
  def target_blueprint do
    %{
      guide_path: guide_paths().blueprint,
      required_local_runtime_modules: @required_local_runtime_modules,
      required_local_authored_modules: @required_local_authored_modules,
      conditional_local_surfaces: @conditional_local_surfaces
    }
  end

  @spec abstraction_boundary_policy() :: map()
  def abstraction_boundary_policy do
    %{
      forbidden_shared_surfaces: @forbidden_shared_surfaces,
      allowed_framework_macros: @allowed_framework_macros,
      validation_rules: @validation_rules
    }
  end

  @spec baseline_source_present?() :: boolean()
  def baseline_source_present? do
    app_source = File.read!(shared_source_path("app.ex"))
    template_source = File.read!(shared_source_path("template.ex"))

    Enum.all?(@browser_shell_classes, &String.contains?(app_source, ".#{&1}")) and
      Enum.all?(@semantic_roles, &String.contains?(template_source, "id(:#{&1})")) and
      Enum.all?(@theme_tokens, &String.contains?(template_source, "id(:#{&1})")) and
      Enum.all?(@component_style_ids, &String.contains?(template_source, "id(:#{&1})"))
  end

  defp shared_usage(module_name) do
    source_files()
    |> Enum.flat_map(fn path ->
      contents = File.read!(path)

      if String.contains?(contents, module_name) do
        [
          %{
            directory: directory_for_source(path),
            file: path
          }
        ]
      else
        []
      end
    end)
    |> Enum.sort_by(&{&1.directory, &1.file})
  end

  defp helper_form_usages(helper_name) do
    source_files()
    |> Enum.flat_map(fn path ->
      contents = File.read!(path)

      if String.contains?(contents, "#{helper_name} do") do
        [
          %{
            directory: directory_for_source(path),
            file: path
          }
        ]
      else
        []
      end
    end)
    |> Enum.sort_by(&{&1.directory, &1.file})
  end

  defp source_files do
    Shared.app_directories()
    |> Enum.flat_map(fn directory ->
      Path.join([Shared.suite_root(), directory, "{lib,test}", "**", "*.ex*"])
      |> Path.wildcard()
    end)
    |> Enum.sort()
  end

  defp directory_for_source(path) do
    [directory | _rest] =
      path
      |> Path.relative_to(Shared.suite_root())
      |> Path.split()

    directory
  end

  defp missing_directories_for(usages, directories) do
    used_directories =
      usages
      |> Enum.map(& &1.directory)
      |> Enum.uniq()

    directories -- used_directories
  end

  defp shared_source_path(filename) do
    Path.join(Shared.shared_root(), "lib/unified_examples/shared/#{filename}")
  end
end
