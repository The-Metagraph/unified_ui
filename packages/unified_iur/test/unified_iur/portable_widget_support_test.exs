defmodule UnifiedIUR.PortableWidgetSupportTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.{Fixtures, PortableWidgetSupport, Tree}

  test "declares the promoted widget surface and runtime support matrix" do
    assert PortableWidgetSupport.promoted_kind_families() == %{
             semantic: [
               :disclosure,
               :kicker,
               :avatar,
               :presence_dot,
               :segmented_button_group,
               :list_item_multi_column,
               :artifact_row,
               :sticky_header
             ],
             workflow: [
               :pipeline_stepper_horizontal,
               :segmented_progress_bar,
               :workflow_stage_list_vertical,
               :meter_thin,
               :slide_over_panel,
               :event_callout,
               :redline_inline,
               :code_block_syntax_highlighted,
               :chat_composer
             ],
             forms: [:host_form_shell],
             collection: [:repeated_collection]
           }

    terminal = PortableWidgetSupport.runtime_report(:terminal_ui)

    assert terminal.complete?
    assert terminal.support_mode == :degraded

    code_block = Enum.find(terminal.widgets, &(&1.kind == :code_block_syntax_highlighted))
    collection = Enum.find(terminal.widgets, &(&1.kind == :repeated_collection))

    assert code_block.fallback == :plain_code_block
    assert collection.fallback == :linearized_collection
  end

  test "reports canonical repeated collection row-scope coverage without renderer-local leakage" do
    fixture = Fixtures.fixture!("portable_widgets--ash_ui_portability")
    kinds = fixture.element |> Tree.depth_first() |> Enum.map(& &1.kind)
    report = PortableWidgetSupport.row_scope_report(fixture.element)

    assert PortableWidgetSupport.promoted_kinds() -- kinds == []
    assert report.complete?

    assert [
             %{
               id: "portable-artifact-rows",
               has_row_key?: true,
               has_row_index?: true,
               renderer_local?: false
             }
           ] = report.collections

    artifact_rows = List.first(report.collections)

    assert Enum.any?(artifact_rows.row_scope_bindings, &(&1.binding_kind == :index))
    assert Enum.any?(artifact_rows.row_scope_bindings, &(&1.binding_kind == :value))
  end

  test "surface validation fails when any promoted boundary is missing" do
    validation =
      PortableWidgetSupport.surface_validation(
        authored_kinds: [:disclosure],
        iur_kinds: PortableWidgetSupport.promoted_kinds(),
        runtime_reports: [PortableWidgetSupport.runtime_report(:live_ui)]
      )

    refute validation.complete?
    assert :kicker in validation.missing_authoring_kinds
    assert validation.missing_iur_kinds == []
    assert validation.missing_runtime_kinds == %{}
  end
end
