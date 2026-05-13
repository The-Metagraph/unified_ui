defmodule UnifiedIUR.FixturesTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.{Fixtures, Interaction, Interoperability}

  test "exposes stable fixture ids, categories, and naming conventions" do
    assert Fixtures.naming_rules() == %{
             fixture_id_pattern: "category--scenario",
             snapshot_suffix: ".snapshot",
             categories: [:foundational, :forms, :data, :portable_widgets, :display, :advanced]
           }

    assert Enum.all?(Fixtures.ids(), &Fixtures.valid_id?/1)

    assert Enum.sort(Fixtures.categories()) == [
             :advanced,
             :data,
             :display,
             :forms,
             :foundational,
             :portable_widgets
           ]
  end

  test "loads fixture catalog entries with semantics, parity obligations, and canonical elements" do
    assert {:ok, fixture} = Fixtures.fixture("forms--profile_editor")

    assert fixture.id == "forms--profile_editor"
    assert fixture.category == :forms
    assert fixture.snapshot_path == "fixtures/forms--profile_editor.snapshot"
    assert :input_widgets in fixture.parity_obligations
    assert length(fixture.semantics) >= 3

    assert Interoperability.identity(fixture.element) == %{
             id: "profile-editor",
             type: :composite,
             kind: :form_builder
           }
  end

  test "covers the full canonical catalog across the reference fixture suite" do
    report = Fixtures.coverage_report()

    assert report.complete?
    assert "advanced--operations_center" in report.fixture_ids
    assert "portable_widgets--ash_ui_portability" in report.fixture_ids
    assert :dialog in report.covered_kinds
    assert :canvas in report.covered_kinds
    assert :text_input in report.covered_kinds
    assert report.attachment_families.style_semantics.covered?
    assert report.attachment_families.theme_semantics.covered?
    assert report.attachment_families.interaction_semantics.covered?
    assert report.attachment_families.binding_semantics.covered?

    assert Enum.all?(report.categories, fn {_category, category_report} ->
             category_report.missing == []
           end)
  end

  test "exposes dedicated canonical navigation transition fixtures" do
    assert Fixtures.navigation_ids() == [
             "screen_transition--settings_profile",
             "replace_transition--home",
             "history_transition--back",
             "modal_transition--settings_dialog"
           ]

    assert {:ok, history_fixture} = Fixtures.navigation_fixture("history_transition--back")

    assert history_fixture.snapshot_path ==
             "fixtures/navigation/history_transition--back.snapshot"

    assert "targetless history traversal" in history_fixture.semantics

    assert %Interaction{
             family: :navigation,
             intent: :go_back_history,
             target: %{navigation: %{action: :go_back, kind: :history_transition}}
           } = history_fixture.interaction

    refute Map.has_key?(Interaction.navigation_descriptor(history_fixture.interaction), :screen)

    assert %{
             id: "modal_transition--settings_dialog",
             snapshot_path: "fixtures/navigation/modal_transition--settings_dialog.snapshot"
           } =
             Enum.find(
               Fixtures.navigation_catalog(),
               &(&1.id == "modal_transition--settings_dialog")
             )
  end
end
