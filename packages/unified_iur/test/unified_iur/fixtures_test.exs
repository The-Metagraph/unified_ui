defmodule UnifiedIUR.FixturesTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.{Fixtures, Interoperability}

  test "exposes stable fixture ids, categories, and naming conventions" do
    assert Fixtures.naming_rules() == %{
             fixture_id_pattern: "category--scenario",
             snapshot_suffix: ".snapshot",
             categories: [:foundational, :forms, :data, :display, :advanced]
           }

    assert Enum.all?(Fixtures.ids(), &Fixtures.valid_id?/1)
    assert Enum.sort(Fixtures.categories()) == [:advanced, :data, :display, :forms, :foundational]
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
    assert :dialog in report.covered_kinds
    assert :canvas in report.covered_kinds
    assert :text_input in report.covered_kinds

    assert Enum.all?(report.categories, fn {_category, category_report} ->
             category_report.missing == []
           end)
  end
end
