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
    assert ".example-app-shell" not in baseline.browser_shell_classes
    assert "example-app-shell" in baseline.browser_shell_classes
    assert :surface in baseline.semantic_roles
    assert :shell_surface in baseline.theme_tokens
    assert :example_shell in baseline.component_style_ids
    assert SelfContainedBlueprint.baseline_source_present?()
  end

  test "inventory guide documents the current helper map and baseline" do
    guide = File.read!(SelfContainedBlueprint.guide_paths().inventory)

    assert guide =~ "UnifiedExamples.Shared.App"
    assert guide =~ "UnifiedExamples.Shared.Template"
    assert guide =~ "UnifiedExamples.Shared.SelfContainedBlueprint.inventory/0"
    assert guide =~ ":example_suite_default"
    assert guide =~ ".example-app-shell"
  end
end
