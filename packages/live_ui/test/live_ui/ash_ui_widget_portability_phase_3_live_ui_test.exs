defmodule LiveUi.AshUiWidgetPortabilityPhase3LiveUiTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  alias LiveUi.Component
  alias UnifiedIUR.Fixtures
  alias UnifiedIUR.Forms
  alias UnifiedIUR.Widgets.Semantic

  @native_cases [
    {LiveUi.Widgets.Disclosure, %{id: "disclosure", label: "Release notes", open: true},
     ~s(data-live-ui-widget="disclosure")},
    {LiveUi.Widgets.Kicker, %{id: "kicker", value: "Workflow"}, ~s(data-live-ui-widget="kicker")},
    {LiveUi.Widgets.Avatar, %{id: "avatar", label: "Pat", initials: "PC"},
     ~s(data-live-ui-widget="avatar")},
    {LiveUi.Widgets.PresenceDot, %{id: "presence", status: "online"},
     ~s(data-live-ui-widget="presence-dot")},
    {LiveUi.Widgets.SegmentedButtonGroup,
     %{id: "segments", items: [compact: "Compact"], active_item: :compact},
     ~s(data-live-ui-widget="segmented-button-group")},
    {LiveUi.Widgets.ListItemMultiColumn,
     %{id: "list-item", label: "Artifact", columns: [name: "artifact.tar"]},
     ~s(data-live-ui-widget="list-item-multi-column")},
    {LiveUi.Widgets.ArtifactRow,
     %{id: "artifact", title: "artifact.tar", artifact: %{id: "artifact-1"}},
     ~s(data-live-ui-widget="artifact-row")},
    {LiveUi.Widgets.StickyHeader, %{id: "header", title: "Results"},
     ~s(data-live-ui-widget="sticky-header")},
    {LiveUi.Widgets.PipelineStepperHorizontal,
     %{id: "pipeline", steps: [:queued, :building], active_item: :building},
     ~s(data-live-ui-widget="pipeline-stepper-horizontal")},
    {LiveUi.Widgets.SegmentedProgressBar,
     %{id: "progress", segments: [queued: 20, building: 80], current: 80},
     ~s(data-live-ui-widget="segmented-progress-bar")},
    {LiveUi.Widgets.WorkflowStageListVertical,
     %{id: "stages", stages: [:plan, :build], active_item: :build},
     ~s(data-live-ui-widget="workflow-stage-list-vertical")},
    {LiveUi.Widgets.MeterThin, %{id: "meter", current: 82}, ~s(data-live-ui-widget="meter-thin")},
    {LiveUi.Widgets.SlideOverPanel, %{id: "panel", title: "Details", visible: true},
     ~s(data-live-ui-widget="slide-over-panel")},
    {LiveUi.Widgets.EventCallout, %{id: "callout", message: "Build completed"},
     ~s(data-live-ui-widget="event-callout")},
    {LiveUi.Widgets.RedlineInline, %{id: "redline", before_text: "Draft", after_text: "Ready"},
     ~s(data-live-ui-widget="redline-inline")},
    {LiveUi.Widgets.CodeBlockSyntaxHighlighted, %{id: "code", code: "IO.puts(\"ready\")"},
     ~s(data-live-ui-widget="code-block-syntax-highlighted")},
    {LiveUi.Widgets.ChatComposer, %{id: "composer", placeholder: "Add a review note"},
     ~s(data-live-ui-widget="chat-composer")},
    {LiveUi.Forms.HostFormShell, %{id: "host-form", validation_summary: "Host validates"},
     ~s(data-live-ui-widget="host-form-shell")},
    {LiveUi.Widgets.RepeatedCollection, %{id: "collection", rows: [%{key: "row-1", index: 0}]},
     ~s(data-live-ui-widget="repeated-collection")}
  ]

  test "native LiveUi promoted widgets expose mountable component boundaries and render markers" do
    assert LiveUi.Widgets.semantic_modules() == [
             LiveUi.Widgets.Disclosure,
             LiveUi.Widgets.Kicker,
             LiveUi.Widgets.Avatar,
             LiveUi.Widgets.PresenceDot,
             LiveUi.Widgets.SegmentedButtonGroup,
             LiveUi.Widgets.ListItemMultiColumn,
             LiveUi.Widgets.ArtifactRow,
             LiveUi.Widgets.StickyHeader
           ]

    assert LiveUi.Widgets.workflow_modules() == [
             LiveUi.Widgets.PipelineStepperHorizontal,
             LiveUi.Widgets.SegmentedProgressBar,
             LiveUi.Widgets.WorkflowStageListVertical,
             LiveUi.Widgets.MeterThin,
             LiveUi.Widgets.SlideOverPanel,
             LiveUi.Widgets.EventCallout,
             LiveUi.Widgets.RedlineInline,
             LiveUi.Widgets.CodeBlockSyntaxHighlighted,
             LiveUi.Widgets.ChatComposer
           ]

    for module <- LiveUi.Widgets.portable_modules() ++ [LiveUi.Forms.HostFormShell] do
      metadata = Component.metadata(module)

      assert metadata.mountable?
      assert metadata.component_module == Component.component_module(module)
    end

    for {module, assigns, marker} <- @native_cases do
      html = render_component(fn assigns -> apply(module, :render, [assigns]) end, assigns)

      assert html =~ marker
    end
  end

  test "LiveUi renderer consumes promoted IUR fixture through native widgets" do
    fixture = Fixtures.fixture!("portable_widgets--ash_ui_portability")

    html =
      render_component(&LiveUi.Renderer.render/1, %{
        element: fixture.element,
        event_target: "#runtime-host"
      })

    for marker <- [
          "disclosure",
          "kicker",
          "avatar",
          "presence-dot",
          "segmented-button-group",
          "list-item-multi-column",
          "artifact-row",
          "sticky-header",
          "pipeline-stepper-horizontal",
          "segmented-progress-bar",
          "workflow-stage-list-vertical",
          "meter-thin",
          "slide-over-panel",
          "event-callout",
          "redline-inline",
          "code-block-syntax-highlighted",
          "chat-composer",
          "repeated-collection"
        ] do
      assert html =~ ~s(data-live-ui-widget="#{marker}")
    end

    assert html =~ "artifact.tar"
    refute html =~ "row:artifact.columns"
    assert html =~ ~s(phx-submit="canonical_submit_interaction")
  end

  test "host form shell and equivalent artifact rows match native and IUR rendering paths" do
    host_form =
      Forms.host_form_shell([],
        id: "profile-shell",
        submit_intent: :save_profile,
        validation_summary: "Host validates profile changes"
      )

    host_html =
      render_component(&LiveUi.Renderer.render/1, %{
        element: host_form,
        event_target: "#runtime-host"
      })

    assert host_html =~ ~s(data-live-ui-widget="host-form-shell")
    assert host_html =~ ~s(data-live-ui-owner="host")
    assert host_html =~ ~s(data-live-ui-lifecycle="host_owned")
    assert host_html =~ ~s(phx-submit="canonical_submit_interaction")

    native_html =
      render_component(&LiveUi.Widgets.ArtifactRow.render/1, %{
        id: "artifact-row",
        title: "artifact.tar",
        artifact: %{id: "artifact-1"},
        status: "ready"
      })

    iur_html =
      render_component(&LiveUi.Renderer.render/1, %{
        element:
          Semantic.artifact_row(%{id: "artifact-1"}, "artifact.tar",
            id: "artifact-row",
            status: :ready
          )
      })

    assert native_html =~ ~s(data-live-ui-widget="artifact-row")
    assert iur_html =~ ~s(data-live-ui-widget="artifact-row")
    assert native_html =~ "artifact.tar"
    assert iur_html =~ "artifact.tar"
  end
end
