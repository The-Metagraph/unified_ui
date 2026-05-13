defmodule UnifiedUi.AshUiWidgetPortabilityPhase5IntegrationTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.{Binding, Fixtures, PortableWidgetSupport, Reference, Tree, Validate}
  alias UnifiedIUR.Export, as: IurExport
  alias UnifiedUi.{Compiler, Examples, Export, Info, Tooling}

  @repo_root Path.expand("../../../..", __DIR__)
  @runtime_packages ["live_ui", "elm_ui", "desktop_ui", "terminal_ui"]

  test "portable example, canonical fixture, runtime matrix, and tooling expose every promoted widget deterministically" do
    expected_kinds = PortableWidgetSupport.promoted_kinds()
    expected_kind_names = Enum.map(expected_kinds, &Atom.to_string/1)

    assert {:ok, example} = Examples.example(:portable_widgets)
    assert Enum.map(example.runtime_coverage, &Atom.to_string/1) == @runtime_packages

    assert example.review_artifact.structured_fixture ==
             "examples/portable_widgets/review-fixtures.json"

    first = Compiler.compile!(example.module).iur
    second = Compiler.compile!(example.module).iur

    assert :ok = Validate.element(first)
    assert Reference.snapshot(first) == Reference.snapshot(second)

    report = Tooling.portable_widget_report(example.module)
    authored_kinds = Info.authoring_surface_summary(example.module).widgets |> Enum.map(& &1.kind)
    iur_kinds = first |> Tree.depth_first() |> Enum.map(& &1.kind)

    assert report.release_ready?
    assert expected_kinds -- authored_kinds == []
    assert expected_kinds -- iur_kinds == []
    assert report.validation.missing_runtime_kinds == %{}

    fixture = Fixtures.fixture!("portable_widgets--ash_ui_portability")
    fixture_kinds = fixture.element |> Tree.depth_first() |> Enum.map(& &1.kind)

    assert :ok = Validate.element(fixture.element)
    assert expected_kinds -- fixture_kinds == []

    review = read_json!("examples/portable_widgets/review-fixtures.json")
    review_kinds = review_kinds(review)

    assert expected_kind_names -- review_kinds == []
    assert Enum.map(review["runtime_coverage"], & &1["package"]) == @runtime_packages

    parity = read_json!(".spec/planning/ash_ui_widget_portability/runtime-parity-matrix.json")
    parity_kinds = Enum.map(parity["widgets"], & &1["kind"])

    assert Enum.sort(parity_kinds) == Enum.sort(expected_kind_names)
    assert_terminal_fallbacks_match_runtime_support(parity)

    assert {:ok, first_export} = Export.example(:portable_widgets, :portable_widgets)
    assert {:ok, second_export} = Export.example(:portable_widgets, :portable_widgets)
    assert first_export == second_export

    assert {:ok, first_canonical_export} =
             IurExport.fixture("portable_widgets--ash_ui_portability", :portable_widgets)

    assert {:ok, second_canonical_export} =
             IurExport.fixture("portable_widgets--ash_ui_portability", :portable_widgets)

    assert first_canonical_export == second_canonical_export
  end

  test "repeated collection row-scope values and row action payload mappings survive lowering" do
    assert {:ok, example} = Examples.example(:portable_widgets)
    iur = Compiler.compile!(example.module).iur
    row_scope = PortableWidgetSupport.row_scope_report(iur)

    assert row_scope.complete?
    assert Enum.map(row_scope.collections, & &1.id) == [:artifact_rows, :workflow_rows]

    assert Enum.all?(row_scope.collections, fn collection ->
             collection.has_row_key? and collection.has_row_index? and
               not collection.renderer_local?
           end)

    assert_row_action_payload(
      Tree.find_by_id(iur, :artifact_review_action),
      :review_artifact,
      [:artifact_id, :artifact, :row_index],
      artifact_id: {:artifact, [:id]},
      artifact: {:artifact, [:record]},
      row_index: {:row, []}
    )

    assert_row_action_payload(
      Tree.find_by_id(iur, :workflow_review_action),
      :open_workflow,
      [:workflow_id, :workflow, :row_index],
      workflow_id: {:workflow, [:id]},
      workflow: {:workflow, [:record]},
      row_index: {:workflow_row, []}
    )
  end

  test "ADR, docs, traceability, and conformance describe the same promoted widget contract" do
    adr =
      read_repo!(".spec/decisions/architecture/repo.ecosystem.widget_portability_from_ash_ui.md")

    migration = read_repo!("packages/unified-ui/guides/ash_ui_widget_migration.md")
    unified_ui_mix = read_repo!("packages/unified-ui/mix.exs")

    assert adr =~ "promoted into"
    assert adr =~ "the canonical UnifiedUi and UnifiedIUR contract"
    assert migration =~ "`row_payload` descriptors"
    assert migration =~ "AshUi or the host application owns"
    assert unified_ui_mix =~ "guides/ash_ui_widget_migration.md"

    assert_planning_covers!("unified_ui", [
      "unified_ui.dsl.repeated_collection_templates",
      "unified_ui.widgets.portable_semantic_micro_widgets",
      "unified_ui.widgets.portable_workflow_document_widgets",
      "unified_ui.widgets.repeated_collection_composition",
      "unified_iur.interactions.row_scope_binding_representation"
    ])

    assert_planning_covers!("unified_iur", [
      "unified_iur.widgets.portable_semantic_micro_widgets",
      "unified_iur.widgets.workflow_document_widgets",
      "unified_iur.widgets.no_integration_package_widget_escape_hatches",
      "unified_iur.constructs.repeated_collection_composition",
      "unified_iur.interactions.row_scope_binding_representation"
    ])

    Enum.each(["live_ui", "elm_ui", "desktop_ui", "terminal_ui"], fn package ->
      assert_planning_covers!(package, [
        "ecosystem.platform_runtimes.promoted_widget_runtime_equivalence",
        "#{package}.native_widgets.promoted_widget_equivalents",
        "#{package}.native_widgets.repeated_collection_realization",
        "unified_iur.interactions.row_scope_binding_representation"
      ])
    end)

    assert_conformance_covers!("unified_ui", [
      "unified_ui.dsl.repeated_collection_templates",
      "unified_ui.widgets.portable_semantic_micro_widgets",
      "unified_ui.widgets.portable_workflow_document_widgets",
      "unified_ui.widgets.repeated_collection_composition"
    ])

    assert_conformance_covers!("unified_iur", [
      "unified_iur.widgets.portable_semantic_micro_widgets",
      "unified_iur.widgets.workflow_document_widgets",
      "unified_iur.widgets.no_integration_package_widget_escape_hatches",
      "unified_iur.constructs.repeated_collection_composition",
      "unified_iur.interactions.row_scope_binding_representation"
    ])

    Enum.each(["live_ui", "elm_ui", "desktop_ui"], fn package ->
      assert_conformance_covers!(package, [
        "#{package}.native_widgets.promoted_widget_equivalents",
        "#{package}.native_widgets.repeated_collection_realization"
      ])
    end)
  end

  defp assert_row_action_payload(element, intent, expected_keys, expectations) do
    assert %{attributes: %{interactions: [interaction]}} = element
    assert interaction.intent == intent
    assert %{mapping: mapping} = interaction.payload
    assert Enum.sort(Map.keys(mapping)) == Enum.sort(expected_keys)

    Enum.each(expectations, fn {key, {scope, path}} ->
      assert %Binding{
               source: :row_scope,
               scope: [^scope],
               path: ^path,
               metadata: %{target: :interaction_payload, binding_kind: :payload}
             } = Map.fetch!(mapping, key)
    end)
  end

  defp assert_terminal_fallbacks_match_runtime_support(parity) do
    terminal_report =
      :terminal_ui
      |> PortableWidgetSupport.runtime_report()
      |> Map.fetch!(:widgets)
      |> Map.new(&{Atom.to_string(&1.kind), fallback_name(&1.fallback)})

    Enum.each(parity["widgets"], fn widget ->
      assert widget["terminal"]["fallback"] == Map.fetch!(terminal_report, widget["kind"])
    end)
  end

  defp fallback_name(nil), do: nil
  defp fallback_name(fallback), do: Atom.to_string(fallback)

  defp review_kinds(review) do
    review["groups"]
    |> Enum.flat_map(fn group -> Map.get(group, "widgets", []) end)
    |> Kernel.++(["repeated_collection"])
    |> Enum.uniq()
  end

  defp assert_planning_covers!(package, requirement_ids) do
    manifest = read_json!(".spec/planning/#{package}/spec-traceability.json")
    markdown = read_repo!(".spec/planning/#{package}/spec-traceability.md")
    mapping_ids = Enum.map(manifest["mappings"], & &1["requirement_id"])

    Enum.each(requirement_ids, fn requirement_id ->
      assert requirement_id in mapping_ids
      assert markdown =~ requirement_id
    end)
  end

  defp assert_conformance_covers!(package, requirement_ids) do
    manifest = read_json!(".spec/conformance/#{package}/manifest.json")
    covered_ids = Enum.map(manifest["requirements"], & &1["requirement_id"])

    Enum.each(requirement_ids, fn requirement_id ->
      assert requirement_id in covered_ids
    end)
  end

  defp read_json!(relative_path) do
    relative_path
    |> read_repo!()
    |> JSON.decode!()
  end

  defp read_repo!(relative_path) do
    @repo_root
    |> Path.join(relative_path)
    |> File.read!()
  end
end
