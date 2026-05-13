defmodule UnifiedUi.AshUiWidgetPortabilityPhase2IntegrationTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Export, as: IurExport
  alias UnifiedIUR.Widgets.{Foundational, Semantic}

  alias UnifiedIUR.{
    Binding,
    Collection,
    Fixtures,
    Inspect,
    Reference,
    Tree,
    Validate
  }

  alias UnifiedUi.{Compiler, Examples, Export, Tooling}

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

  test "maintained portable example lowers into valid deterministic IUR" do
    assert {:ok, example} = Examples.example(:portable_widgets)

    first = Compiler.compile!(example.module).iur
    second = Compiler.compile!(example.module).iur
    elements = Tree.depth_first(first)
    kinds = Enum.map(elements, & &1.kind)

    assert :ok = Validate.element(first)
    assert Reference.snapshot(first) == Reference.snapshot(second)

    assert :artifact_row in kinds
    assert :pipeline_stepper_horizontal in kinds
    assert :segmented_progress_bar in kinds
    assert :chat_composer in kinds
    assert :host_form_shell in kinds
    assert :repeated_collection in kinds

    host_shell = Tree.find_by_id(first, :host_review_shell)

    assert host_shell.attributes.form_shell == %{
             owner: :host,
             lifecycle: :host_owned,
             action_placement: :footer
           }

    artifact_summary = Tree.find_by_id(first, :artifact_summary)

    assert %Binding{source: :row_scope, scope: [:artifact], path: [:columns]} =
             artifact_summary.attributes.list_item.columns

    assert %Binding{source: :row_scope, scope: [:row], path: []} =
             artifact_summary.attributes.list_item.value

    refute inspect(first) =~ "Phoenix"
    refute inspect(first) =~ "AshPhoenix"
    refute inspect(first) =~ "Ash.Resource"
  end

  test "shared canonical fixture covers promoted widgets, row scope, inspection, and export" do
    fixture = Fixtures.fixture!("portable_widgets--ash_ui_portability")

    assert :ok = Validate.element(fixture.element)

    kinds =
      fixture.element
      |> Tree.depth_first()
      |> Enum.map(& &1.kind)

    assert Enum.all?(@semantic_kinds, &(&1 in kinds))
    assert Enum.all?(@workflow_kinds, &(&1 in kinds))
    assert :repeated_collection in kinds

    artifact_summary = Tree.find_by_id(fixture.element, "portable-artifact-summary-template")

    assert %Binding{source: :row_scope, scope: [:artifact], path: [:columns]} =
             artifact_summary.attributes.list_item.columns

    assert %Binding{source: :row_scope, scope: [:row], path: []} =
             artifact_summary.attributes.list_item.value

    assert {:ok, report} = Inspect.fixture("portable_widgets--ash_ui_portability")
    assert report.diagnostics.valid?

    assert [%{id: "portable-artifact-rows", template: %{kind: :row}}] = report.collections

    assert Enum.any?(report.portable_widgets, fn widget ->
             widget.kind == :code_block_syntax_highlighted and
               :plain_text_code_fallback in widget.degradation_hints
           end)

    assert {:ok, inspection} =
             IurExport.fixture("portable_widgets--ash_ui_portability", :inspection)

    assert inspection =~ "portable_widgets"
    assert inspection =~ "code_block_syntax_highlighted"
    assert inspection =~ "portable-artifact-rows"

    assert {:ok, authored_inspection} = Export.example(:portable_widgets, :inspection)
    assert authored_inspection =~ "UnifiedUi compiler inspection"
    assert authored_inspection =~ "repeated collections:"

    assert {:ok, tooling_report} = Tooling.inspect_example(:portable_widgets)
    assert :collection in tooling_report.construct_families
    assert ".spec/specs/unified-ui/dsl.spec.md" in tooling_report.related_specs
  end

  test "invalid collection and opaque promoted payload scenarios fail validation" do
    relationship_source =
      Collection.repeated_collection(Foundational.text("Title", id: "relationship-template"),
        id: "relationship-source",
        source: [name: :comments, path: [:comments], relationship: :comments],
        item_alias: :comment,
        key_path: [:id]
      )

    bad_alias =
      Collection.repeated_collection(
        Foundational.text("Title",
          id: "bad-alias-title",
          bindings: [Binding.row_value(:other_alias, :title)]
        ),
        id: "bad-alias",
        source: [name: :artifacts, path: [:artifacts]],
        item_alias: :artifact,
        key_path: [:id]
      )

    opaque_payload =
      Semantic.artifact_row(fn -> :artifact end, "Runtime artifact", id: "opaque-artifact")

    assert {:error, relationship_errors} = Validate.element(relationship_source)
    assert Enum.any?(relationship_errors, &(&1.code == :invalid_collection_source))

    assert {:error, alias_errors} = Validate.element(bad_alias)
    assert Enum.any?(alias_errors, &(&1.code == :invalid_row_scope_binding))

    assert {:error, opaque_errors} = Validate.element(opaque_payload)
    assert Enum.any?(opaque_errors, &(&1.code == :unsupported_opaque_payload))
  end
end
