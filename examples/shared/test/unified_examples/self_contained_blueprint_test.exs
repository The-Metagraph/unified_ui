defmodule UnifiedExamples.SelfContainedBlueprintTest do
  use ExUnit.Case, async: true

  alias UnifiedExamples.Shared
  alias UnifiedExamples.Shared.SelfContainedBlueprint

  test "inventory captures the current shared helper usage across the example suite" do
    inventory = SelfContainedBlueprint.inventory()

    assert inventory.total_directories == length(Shared.app_directories())
    assert inventory.directories_without_app_macro == []
    assert inventory.directories_without_template_macro == []
    assert length(inventory.app_macro_usages) == inventory.total_directories
    assert length(inventory.template_macro_usages) == inventory.total_directories

    assert Enum.any?(inventory.app_macro_usages, &String.ends_with?(&1.file, "/button.ex"))
    assert Enum.any?(inventory.template_macro_usages, &String.ends_with?(&1.file, "/button/screen.ex"))
    assert Enum.any?(inventory.fixture_usages, &(&1.directory == "cluster_dashboard"))
    assert Enum.any?(inventory.example_panel_usages, &(&1.directory == "button"))
    assert inventory.shared_helper_modules == SelfContainedBlueprint.shared_helper_modules()
  end

  test "baseline captures the browser shell, theme, and style ids that must survive localization" do
    baseline = SelfContainedBlueprint.current_baseline()

    assert baseline.default_theme_id == :example_suite_default
    assert baseline.default_notes == "This example uses the shared suite template, theme, and style profile."
    assert baseline.inventory_guide_path == SelfContainedBlueprint.guide_paths().inventory
    assert baseline.blueprint_guide_path == SelfContainedBlueprint.guide_paths().blueprint
    assert ".example-app-shell" not in baseline.browser_shell_classes
    assert "example-app-shell" in baseline.browser_shell_classes
    assert :surface in baseline.semantic_roles
    assert :shell_surface in baseline.theme_tokens
    assert :example_shell in baseline.component_style_ids
    assert SelfContainedBlueprint.baseline_source_present?()
  end

  test "target blueprint defines the required local module set and boundary policy" do
    blueprint = SelfContainedBlueprint.target_blueprint()
    policy = SelfContainedBlueprint.abstraction_boundary_policy()

    assert blueprint.guide_path == SelfContainedBlueprint.guide_paths().blueprint
    assert Enum.map(blueprint.required_local_runtime_modules, & &1.id) == [
             :application,
             :endpoint,
             :router,
             :layouts,
             :live
           ]

    assert Enum.map(blueprint.required_local_authored_modules, & &1.id) == [
             :screen,
             :theme,
             :style_profile,
             :helpers
           ]

    assert Enum.any?(
             blueprint.conditional_local_surfaces,
             &(&1.id == :fixtures and String.contains?(&1.when_needed, "UnifiedExamples.Shared.Fixtures"))
           )

    assert Enum.any?(policy.forbidden_shared_surfaces, &(&1.surface == "examples/shared"))
    assert Enum.any?(policy.forbidden_shared_surfaces, &(&1.surface == "UnifiedExamples.Shared.App"))
    assert Enum.any?(policy.forbidden_shared_surfaces, &(&1.surface == "UnifiedExamples.Shared.Template"))
    assert "use Phoenix.LiveView" in policy.allowed_framework_macros
    assert "use UnifiedUi.Dsl" in policy.allowed_framework_macros
    assert Enum.any?(policy.validation_rules, &(&1.id == :preserved_visual_baseline))
  end

  test "inventory guide documents the current helper map and baseline" do
    guide = File.read!(SelfContainedBlueprint.guide_paths().inventory)

    assert guide =~ "UnifiedExamples.Shared.App"
    assert guide =~ "UnifiedExamples.Shared.Template"
    assert guide =~ "UnifiedExamples.Shared.SelfContainedBlueprint.inventory/0"
    assert guide =~ ":example_suite_default"
    assert guide =~ ".example-app-shell"
  end

  test "blueprint guide documents the local module target and abstraction boundary" do
    guide = File.read!(SelfContainedBlueprint.guide_paths().blueprint)

    assert guide =~ ":application"
    assert guide =~ ":screen"
    assert guide =~ "examples/shared/"
    assert guide =~ "UnifiedExamples.Shared.App"
    assert guide =~ "UnifiedExamples.Shared.Template"
    assert guide =~ "use Phoenix.LiveView"
    assert guide =~ ":preserved_visual_baseline"
  end
end
