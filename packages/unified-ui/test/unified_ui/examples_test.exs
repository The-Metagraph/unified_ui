defmodule UnifiedUi.ExamplesTest do
  use ExUnit.Case, async: true

  alias UnifiedUi.{Examples, Info, Reference}

  test "registers maintained examples with stable metadata and coverage obligations" do
    assert Examples.modules() == [
             UnifiedUi.Examples.FoundationalScreen,
             UnifiedUi.Examples.ProfileForm,
             UnifiedUi.Examples.OverlayWorkspace,
             UnifiedUi.Examples.OperationsDashboard,
             UnifiedUi.Examples.PortableWidgets,
             UnifiedUi.Examples.ThemedSignalWorkspace
           ]

    assert Examples.ids() == [
             :foundational_screen,
             :profile_form,
             :overlay_workspace,
             :operations_dashboard,
             :portable_widgets,
             :themed_signal_workspace
           ]

    assert Examples.categories() == [
             :advanced_dashboard,
             :advanced_flow,
             :cross_cutting,
             :form_workflow,
             :foundational,
             :portable_widgets
           ]

    assert Examples.validation_purposes() == [
             :coverage,
             :determinism,
             :display_systems,
             :docs,
             :parity,
             :signals,
             :themes
           ]

    assert {:ok, themed_signal_workspace} = Examples.example(:themed_signal_workspace)

    assert themed_signal_workspace == %{
             id: :themed_signal_workspace,
             category: :cross_cutting,
             scenario: :theme_signal_workspace,
             module: UnifiedUi.Examples.ThemedSignalWorkspace,
             constructs: [:themes, :signals, :overlay, :display, :forms, :canvas],
             parity_obligations: [
               :feedback_widgets,
               :input_widgets,
               :layer_constructs,
               :layout_constructs,
               :canvas_constructs
             ],
             validation_purpose: [:docs, :signals, :themes, :determinism, :parity],
             review_artifact: %{
               inspection: "themed_signal_workspace.inspection",
               snapshot: "themed_signal_workspace.snapshot"
             },
             summary:
               "Cross-cutting themed workspace combining style inheritance, bindings, interactions, overlays, and canvas output."
           }

    assert :error = Examples.example(:missing)
    assert Reference.example_catalog() == Examples.catalog()
  end

  test "reports aggregated example coverage for later tooling and validation" do
    assert Examples.coverage_report() == %{
             total_examples: 6,
             ids: [
               :foundational_screen,
               :profile_form,
               :overlay_workspace,
               :operations_dashboard,
               :portable_widgets,
               :themed_signal_workspace
             ],
             categories: %{
               advanced_dashboard: 1,
               advanced_flow: 1,
               cross_cutting: 1,
               form_workflow: 1,
               foundational: 1,
               portable_widgets: 1
             },
             constructs: [
               :advanced,
               :canvas,
               :collection,
               :data,
               :display,
               :feedback,
               :forms,
               :foundational_visual,
               :input,
               :layout,
               :navigation,
               :overlay,
               :semantic,
               :signals,
               :themes,
               :workflow
             ],
             parity_obligations: [
               :advanced_widgets,
               :canvas_constructs,
               :collection_constructs,
               :container_constructs,
               :data_widgets,
               :feedback_widgets,
               :form_constructs,
               :foundational_widgets,
               :input_widgets,
               :layer_constructs,
               :layout_constructs,
               :navigation_widgets,
               :semantic_widgets,
               :workflow_widgets
             ],
             validation_purposes: [
               :coverage,
               :determinism,
               :display_systems,
               :docs,
               :parity,
               :signals,
               :themes
             ]
           }
  end

  test "exposes maintained example summaries without runtime-library dependencies" do
    summaries = Info.example_summaries()

    assert Enum.map(summaries, & &1.id) == [
             :foundational_screen,
             :profile_form,
             :overlay_workspace,
             :operations_dashboard,
             :portable_widgets,
             :themed_signal_workspace
           ]

    dashboard =
      Enum.find(summaries, &(&1.id == :operations_dashboard))

    assert dashboard.category == :advanced_dashboard

    assert dashboard.review_artifact == %{
             inspection: "operations_dashboard.inspection",
             snapshot: "operations_dashboard.snapshot"
           }

    assert Enum.any?(dashboard.composition, fn node ->
             node.id == :operations_shell and
               Enum.any?(
                 node.children,
                 &(&1.id == :cluster_status and &1.kind == :cluster_dashboard)
               ) and
               Enum.any?(
                 node.children,
                 &(&1.id == :release_notes and &1.kind == :markdown_viewer)
               )
           end)

    portable_widgets =
      Enum.find(summaries, &(&1.id == :portable_widgets))

    assert portable_widgets.category == :portable_widgets
    assert portable_widgets.constructs == [:semantic, :workflow, :collection]

    assert Enum.any?(portable_widgets.composition, fn node ->
             node.id == :portable_shell and
               Enum.any?(node.children, &(&1.id == :latest_artifact and &1.kind == :artifact_row)) and
               Enum.any?(
                 node.children,
                 &(&1.id == :release_pipeline and &1.kind == :pipeline_stepper_horizontal)
               ) and
               Enum.any?(
                 node.children,
                 &(&1.id == :artifact_rows and &1.kind == :repeated_collection)
               )
           end)

    themed_workspace =
      Enum.find(summaries, &(&1.id == :themed_signal_workspace))

    assert themed_workspace.category == :cross_cutting

    assert themed_workspace.validation_purpose == [
             :docs,
             :signals,
             :themes,
             :determinism,
             :parity
           ]

    assert Enum.any?(themed_workspace.composition, fn node ->
             node.id == :workspace_shell and
               Enum.any?(node.children, &(&1.id == :activity_viewport and &1.kind == :viewport)) and
               Enum.any?(node.children, &(&1.id == :status_canvas and &1.kind == :canvas))
           end)
  end
end
