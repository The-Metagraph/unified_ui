defmodule LiveUi.WidgetComponentsWorkflowTextTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defp slot_text(slot, text) do
    %{__slot__: slot, inner_block: fn _, _ -> text end}
  end

  test "row and artifact components preserve row identity, actions, and link variants" do
    list_row =
      render_component(&LiveUi.Widgets.Components.ListItemMultiColumn.component/1, %{
        id: "row",
        row_identity: "row-1",
        active: true,
        link_target: "/rows/1",
        columns: [
          %{id: "title", label: "Title", attrs: %{"data-field" => "title"}},
          %{id: "state", label: "Ready"}
        ],
        row_attrs: %{"phx-click" => "open_row", "phx-value-row-id" => "row-1"},
        actions: [slot_text(:actions, "Open")]
      })

    artifact =
      render_component(&LiveUi.Widgets.Components.ArtifactRow.component/1, %{
        id: "artifact",
        title: "ADR",
        row_identity: "adr-1",
        meta: %{status: :accepted},
        link_target: "/artifacts/adr-1",
        link_label: "View",
        row_attrs: %{"phx-click" => "open_artifact"}
      })

    assert list_row =~ "data-live-ui-row-id=\"row-1\""
    assert list_row =~ "data-live-ui-active=\"true\""
    assert list_row =~ "href=\"/rows/1\""
    assert list_row =~ "phx-value-row-id=\"row-1\""
    assert list_row =~ "data-field=\"title\""
    assert list_row =~ "Open"

    assert artifact =~ "ADR"
    assert artifact =~ "status"
    assert artifact =~ "accepted"
    assert artifact =~ "href=\"/artifacts/adr-1\""
    assert artifact =~ "phx-click=\"open_artifact\""
  end

  test "workflow and progress components expose deterministic state and accessibility" do
    stepper =
      render_component(&LiveUi.Widgets.Components.PipelineStepperHorizontal.component/1, %{
        id: "steps",
        active_index: 1,
        completed_indices: [0],
        step_attrs: %{"phx-click" => "select_step"},
        steps: [
          %{id: "draft", label: "Draft"},
          %{id: "review", label: "Review", attrs: %{"phx-value-step-id" => "review"}},
          %{id: "done", label: "Done", disabled?: true}
        ]
      })

    stages =
      render_component(&LiveUi.Widgets.Components.WorkflowStageListVertical.component/1, %{
        id: "stages",
        active_index: 1,
        stage_attrs: %{"phx-click" => "select_stage"},
        stages: [
          %{id: "authored", label: "Authored", state: :done},
          %{id: "implemented", label: "Implemented"}
        ]
      })

    progress =
      render_component(&LiveUi.Widgets.Components.SegmentedProgressBar.component/1, %{
        id: "progress",
        label: "Scenario health",
        aggregate_progress: %{current: 8, maximum: 10},
        segments: [%{label: "Passing", weight: 8, state: :success}]
      })

    meter =
      render_component(&LiveUi.Widgets.Components.MeterThin.component/1, %{
        id: "meter",
        current: 50.0,
        minimum: 0.0,
        maximum: 100.0,
        label: "Coverage"
      })

    assert stepper =~ "data-live-ui-step-state=\"done\""
    assert stepper =~ "data-live-ui-step-state=\"active\""
    assert stepper =~ "data-live-ui-step-state=\"pending\""
    assert stepper =~ "aria-current=\"step\""
    assert stepper =~ "phx-value-step-id=\"review\""
    assert stepper =~ "disabled"

    assert stages =~ "data-live-ui-stage-state=\"done\""
    assert stages =~ "data-live-ui-stage-state=\"active\""
    assert stages =~ "phx-click=\"select_stage\""

    assert progress =~ "role=\"progressbar\""
    assert progress =~ "aria-valuenow=\"8\""
    assert progress =~ "aria-valuemax=\"10\""
    assert progress =~ "data-live-ui-progress-state=\"success\""

    assert meter =~ "<meter"
    assert meter =~ "aria-label=\"Coverage\""
    assert meter =~ "data-live-ui-meter-percent=\"50.0\""
  end

  test "layer, callout, redline, and code components render safe document workflow output" do
    header =
      render_component(&LiveUi.Widgets.Components.StickyFrostedHeader.component/1, %{
        id: "header",
        title: "Workspace",
        leading: ["Back"],
        trailing: ["Save"],
        inner_block: [slot_text(:inner_block, "Header body")]
      })

    panel =
      render_component(&LiveUi.Widgets.Components.SlideOverPanel.component/1, %{
        id: "panel",
        open: true,
        size: "wide",
        label: "Details",
        inner_block: [slot_text(:inner_block, "Panel body")]
      })

    callout =
      render_component(&LiveUi.Widgets.Components.EventCallout.component/1, %{
        id: "callout",
        eyebrow: "Deploy",
        title: "Paused",
        message: "<script>plain text</script>",
        callout_tone: "warning",
        action_label: "Inspect",
        action_attrs: %{"phx-click" => "inspect_event"}
      })

    redline =
      render_component(&LiveUi.Widgets.Components.RedlineInline.component/1, %{
        id: "redline",
        segments: [%{state: :insert, text: "<script>safe</script>"}]
      })

    code =
      render_component(&LiveUi.Widgets.Components.CodeBlockSyntaxHighlighted.component/1, %{
        id: "code",
        language: "elixir",
        tokens: [%{type: :keyword, text: "<defmodule>"}]
      })

    assert header =~ "data-live-ui-position=\"sticky\""
    assert header =~ "data-live-ui-visual-effect=\"frosted\""
    assert header =~ "Header body"

    assert panel =~ "aria-hidden=\"false\""
    assert panel =~ "data-live-ui-panel-size=\"wide\""
    assert panel =~ "Panel body"

    assert callout =~ "data-live-ui-callout-tone=\"warning\""
    assert callout =~ "&lt;script&gt;plain text&lt;/script&gt;"
    assert callout =~ "phx-click=\"inspect_event\""

    assert redline =~ "data-live-ui-redline-state=\"insert\""
    assert redline =~ "&lt;script&gt;safe&lt;/script&gt;"
    refute redline =~ "<script>"

    assert code =~ "data-live-ui-code-language=\"elixir\""
    assert code =~ "data-live-ui-code-token=\"keyword\""
    assert code =~ "&lt;defmodule&gt;"
  end
end
