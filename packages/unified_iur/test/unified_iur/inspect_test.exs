defmodule UnifiedIUR.InspectTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.{Fixtures, Inspect}
  alias UnifiedIUR.Widgets.Foundational

  test "builds maintainer-facing fixture inspection reports" do
    assert {:ok, report} = Inspect.fixture("foundational--workspace_chrome")

    assert report.fixture_id == "foundational--workspace_chrome"
    assert report.identity == %{id: "workspace-chrome", kind: :column, type: :layout}
    assert report.tree_summary.total_elements >= 7
    assert report.classification.layout?
    assert is_binary(report.render_tree)
    assert report.diagnostics.valid?
  end

  test "renders stable tree output for nested canonical fixtures" do
    fixture = Fixtures.fixture!("display--layered_workspace")

    assert Inspect.render_tree(fixture.element) =~ "- layered-workspace [layer:overlay]"
    assert Inspect.render_tree(fixture.element) =~ "@dialog"
    assert Inspect.render_tree(fixture.element) =~ "- preferences-dialog [layer:dialog]"
  end

  test "extracts styles, themes, interactions, and extension metadata" do
    styled_element =
      Foundational.button("Save",
        id: "styled-button",
        style: [foreground: :accent, spacing: %{padding: 1}],
        theme: :workspace
      )

    styles = Inspect.styles(styled_element)
    themes = Inspect.themes(styled_element)

    assert Enum.any?(styles, &(&1.id == "styled-button"))
    assert Enum.any?(themes, &(&1.id == "styled-button"))

    assert [%{family: :command, intent: :open_file}] =
             Inspect.interactions(Fixtures.fixture!("advanced--operations_center").element)

    assert %{
             extension_points: _,
             compatibility_rules: _,
             iur_catalog: _,
             unified_ui_family_map: _
           } =
             Inspect.extension_metadata()
  end

  test "surfaces portable widget and repeated collection inspection summaries" do
    assert {:ok, report} = Inspect.fixture("portable_widgets--ash_ui_portability")

    assert Enum.any?(report.portable_widgets, fn widget ->
             widget.kind == :artifact_row and widget.family == :semantic and
               [:plain_text_code_fallback] not in widget.degradation_hints
           end)

    assert Enum.any?(report.portable_widgets, fn widget ->
             widget.kind == :code_block_syntax_highlighted and
               :plain_text_code_fallback in widget.degradation_hints
           end)

    assert [
             %{
               id: "portable-artifact-rows",
               item_alias: :artifact,
               index_alias: :row,
               key_path: [:id],
               template: %{id: "portable-artifact-row-template", kind: :row}
             }
           ] = report.collections
  end

  test "inspects canonical navigation fixtures and surfaces navigation summaries" do
    assert {:ok, report} = Inspect.navigation_fixture("screen_transition--settings_profile")

    assert report.fixture_id == "screen_transition--settings_profile"
    assert report.intent == :open_settings_screen

    assert report.navigation == %{
             action: :navigate_to,
             kind: :screen_transition,
             params: %{tab: :profile},
             screen: :settings
           }

    assert report.target == %{navigation: report.navigation}
    assert "symbolic screen identifiers" in report.semantics
  end
end
