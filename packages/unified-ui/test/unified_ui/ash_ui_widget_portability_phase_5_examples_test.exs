defmodule UnifiedUi.AshUiWidgetPortabilityPhase5ExamplesTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.{Binding, Reference, Tree, Validate}
  alias UnifiedUi.{Compiler, Examples, Export, Tooling}

  @repo_root Path.expand("../../../..", __DIR__)

  @semantic_kinds [
    :disclosure,
    :kicker,
    :avatar,
    :presence_dot,
    :segmented_button_group,
    :list_item_multi_column,
    :artifact_row,
    :sticky_header
  ]

  @workflow_kinds [
    :pipeline_stepper_horizontal,
    :segmented_progress_bar,
    :workflow_stage_list_vertical,
    :meter_thin,
    :slide_over_panel,
    :event_callout,
    :redline_inline,
    :code_block_syntax_highlighted,
    :chat_composer
  ]

  test "portable widgets example covers the promoted authored and canonical surface" do
    assert {:ok, example} = Examples.example(:portable_widgets)

    assert example.authored_dsl_module == "UnifiedUi.Examples.PortableWidgets"
    assert example.canonical_fixture == "portable_widgets--ash_ui_portability"
    assert example.runtime_coverage == [:live_ui, :elm_ui, :desktop_ui, :terminal_ui]

    first = Compiler.compile!(example.module).iur
    second = Compiler.compile!(example.module).iur
    elements = Tree.depth_first(first)
    kinds = Enum.map(elements, & &1.kind)

    assert :ok = Validate.element(first)
    assert Reference.snapshot(first) == Reference.snapshot(second)
    assert Enum.all?(@semantic_kinds, &(&1 in kinds))
    assert Enum.all?(@workflow_kinds, &(&1 in kinds))
    assert :host_form_shell in kinds

    artifact_rows = Tree.find_by_id(first, :artifact_rows)
    workflow_rows = Tree.find_by_id(first, :workflow_rows)

    assert artifact_rows.attributes.collection.item_alias == :artifact
    assert artifact_rows.attributes.collection.index_alias == :row
    assert artifact_rows.attributes.collection.key_path == [:id]
    assert workflow_rows.attributes.collection.item_alias == :workflow
    assert workflow_rows.attributes.collection.index_alias == :workflow_row
    assert workflow_rows.attributes.collection.key_path == [:id]

    artifact_summary = Tree.find_by_id(first, :artifact_summary)
    workflow_summary = Tree.find_by_id(first, :workflow_summary)

    assert %Binding{source: :row_scope, scope: [:artifact], path: [:columns]} =
             artifact_summary.attributes.list_item.columns

    assert %Binding{source: :row_scope, scope: [:row], path: []} =
             artifact_summary.attributes.list_item.value

    assert %Binding{source: :row_scope, scope: [:workflow], path: [:columns]} =
             workflow_summary.attributes.list_item.columns

    assert %Binding{source: :row_scope, scope: [:workflow_row], path: []} =
             workflow_summary.attributes.list_item.value

    assert has_interaction?(Tree.find_by_id(first, :artifact_review_action), :review_artifact)
    assert has_interaction?(Tree.find_by_id(first, :workflow_review_action), :open_workflow)
  end

  test "root catalog and example catalog spec register the portable review fixture" do
    catalog = read_repo!("examples/catalog.tsv")

    assert catalog =~
             "\nportable_widgets\tportable_widgets\tportable_widgets\t5\tbox\tselection\tsource_driven\tcross_runtime_review\t"

    assert catalog =~
             "UnifiedUi authored DSL, canonical IUR, and live_ui/elm_ui/desktop_ui/terminal_ui runtime review coverage"

    catalog_spec = read_repo!(".spec/specs/examples/catalog.spec.md")

    assert catalog_spec =~
             "| `examples/portable_widgets/` | `portable_widgets` | portable widgets |"
  end

  test "cross-runtime review fixture is deterministic and includes constrained-runtime degradation" do
    fixture =
      "examples/portable_widgets/review-fixtures.json"
      |> read_repo!()
      |> JSON.decode!()

    assert fixture["id"] == "portable_widgets"

    assert fixture["authored"] == %{
             "module" => "UnifiedUi.Examples.PortableWidgets",
             "export" => "portable_widgets.inspection",
             "surface" => "UnifiedUi authored DSL"
           }

    assert fixture["canonical"] == %{
             "fixture" => "portable_widgets--ash_ui_portability",
             "export" => "portable_widgets.snapshot",
             "surface" => "UnifiedIUR canonical IUR"
           }

    assert Enum.map(fixture["groups"], & &1["id"]) == [
             "semantic_micro_widgets",
             "workflow_document_widgets",
             "host_form_shell_and_chat",
             "repeated_collections"
           ]

    semantic_group = Enum.find(fixture["groups"], &(&1["id"] == "semantic_micro_widgets"))
    workflow_group = Enum.find(fixture["groups"], &(&1["id"] == "workflow_document_widgets"))
    collection_group = Enum.find(fixture["groups"], &(&1["id"] == "repeated_collections"))

    assert semantic_group["widgets"] == Enum.map(@semantic_kinds, &Atom.to_string/1)
    assert workflow_group["widgets"] == Enum.map(@workflow_kinds, &Atom.to_string/1)
    assert collection_group["collections"] == ["artifact_rows", "workflow_rows"]
    assert collection_group["row_actions"] == ["artifact_review_action", "workflow_review_action"]

    runtime_packages = Enum.map(fixture["runtime_coverage"], & &1["package"])
    assert runtime_packages == ["live_ui", "elm_ui", "desktop_ui", "terminal_ui"]

    terminal = Enum.find(fixture["runtime_coverage"], &(&1["package"] == "terminal_ui"))

    assert terminal["support"] == "degraded"
    assert "plain_code_block" in terminal["degradation"]
    assert "linearized_collection" in terminal["degradation"]

    assert fixture["review_outputs"]["runtime_parity_matrix"] ==
             ".spec/planning/ash_ui_widget_portability/runtime-parity-matrix.json"
  end

  test "tooling, export, and validation expose promoted widget release-readiness checks" do
    assert {:ok, inspection} = Tooling.inspect_example(:portable_widgets)

    assert inspection.portable_widget_support.release_ready?
    assert inspection.portable_widget_support.validation.missing_authoring_kinds == []
    assert inspection.portable_widget_support.validation.missing_iur_kinds == []
    assert inspection.portable_widget_support.validation.missing_runtime_kinds == %{}

    assert {:ok, exported} = Export.example(:portable_widgets, :portable_widgets)
    assert exported =~ "runtime_support"
    assert exported =~ "row_scope"

    validation = Tooling.validation_report()

    assert validation.portable_widget_support.release_ready?

    assert Enum.any?(
             validation.release_readiness.criteria,
             &(&1.id == :portable_widget_support and &1.passed?)
           )
  end

  defp read_repo!(relative_path) do
    @repo_root
    |> Path.join(relative_path)
    |> File.read!()
  end

  defp has_interaction?(element, intent) do
    element.attributes
    |> Map.get(:interactions, [])
    |> Enum.any?(&(&1.family == :click and &1.intent == intent))
  end
end
