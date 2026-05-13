defmodule UnifiedIUR.Widgets.WorkflowTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Element
  alias UnifiedIUR.Interaction
  alias UnifiedIUR.Validate
  alias UnifiedIUR.Widgets.{Foundational, Workflow}

  test "exposes portable workflow, document, and composer widget kinds" do
    assert [
             :pipeline_stepper_horizontal,
             :segmented_progress_bar,
             :workflow_stage_list_vertical,
             :meter_thin,
             :slide_over_panel,
             :event_callout,
             :redline_inline,
             :code_block_syntax_highlighted,
             :chat_composer
           ] == Workflow.kinds()
  end

  test "builds workflow progress and stage widgets with deterministic item semantics" do
    pipeline =
      Workflow.pipeline_stepper_horizontal(
        [:queued, :building, :deployed],
        id: "deploy-pipeline",
        active_item: :building,
        status: :running
      )

    progress =
      Workflow.segmented_progress_bar(
        %{deployed: 25, building: 55, queued: 20},
        id: "deploy-progress",
        current: 55,
        maximum: 100,
        label: "Deploy progress"
      )

    stage_list =
      Workflow.workflow_stage_list_vertical(
        [plan: "Plan", build: "Build", deploy: "Deploy"],
        id: "stage-list",
        active_item: :build
      )

    meter = Workflow.meter_thin(82, id: "health-meter", maximum: 100, severity: :success)

    assert %Element{
             kind: :pipeline_stepper_horizontal,
             attributes: %{
               workflow: %{
                 variant: :pipeline_stepper,
                 orientation: :horizontal,
                 active_item: :building,
                 status: :running,
                 steps: [
                   %{id: :queued, label: "queued", value: :queued},
                   %{id: :building, label: "building", value: :building},
                   %{id: :deployed, label: "deployed", value: :deployed}
                 ]
               }
             }
           } = pipeline

    assert %Element{
             attributes: %{
               progress: %{
                 variant: :segmented,
                 current: 55,
                 maximum: 100,
                 label: "Deploy progress",
                 segments: [
                   %{id: :building, value: 55},
                   %{id: :deployed, value: 25},
                   %{id: :queued, value: 20}
                 ]
               }
             }
           } = progress

    assert %Element{
             attributes: %{
               workflow: %{
                 variant: :stage_list,
                 orientation: :vertical,
                 active_item: :build,
                 stages: [
                   %{id: :plan, label: "Plan", value: "Plan"},
                   %{id: :build, label: "Build", value: "Build"},
                   %{id: :deploy, label: "Deploy", value: "Deploy"}
                 ]
               }
             }
           } = stage_list

    assert %Element{
             attributes: %{meter: %{variant: :thin, current: 82, minimum: 0, maximum: 100}}
           } = meter

    for widget <- [pipeline, progress, stage_list, meter] do
      assert :ok = Validate.element(widget)
    end
  end

  test "builds panel, callout, document diff, code, and composer widgets" do
    panel =
      Workflow.slide_over_panel(
        [{:content, Foundational.text("Panel body", id: "panel-body")}],
        id: "details-panel",
        title: "Details",
        placement: :end,
        visible?: true,
        visibility_intent: :toggle_details
      )

    callout =
      Workflow.event_callout("Build completed",
        id: "build-event",
        severity: :success,
        timestamp: "2026-05-13T10:35:00Z"
      )

    redline =
      Workflow.redline_inline("Draft", "Ready", id: "title-redline", label: "Status change")

    code =
      Workflow.code_block_syntax_highlighted("IO.puts(\"ready\")",
        id: "release-code",
        language: :elixir,
        wrap?: true
      )

    composer =
      Workflow.chat_composer(
        id: "review-composer",
        placeholder: "Add a review note",
        submit_intent: :send_review,
        actions: [send: "Send"]
      )

    assert %Element{
             kind: :slide_over_panel,
             children: [%{slot: :content}],
             attributes: %{
               panel: %{variant: :slide_over, title: "Details", placement: :end, visible?: true},
               interactions: [%Interaction{family: :open, intent: :toggle_details}]
             }
           } = panel

    assert %Element{
             attributes: %{
               callout: %{
                 message: "Build completed",
                 severity: :success,
                 timestamp: "2026-05-13T10:35:00Z"
               }
             }
           } = callout

    assert %Element{
             attributes: %{redline: %{before_text: "Draft", after_text: "Ready"}}
           } = redline

    assert %Element{
             attributes: %{
               code_block: %{code: "IO.puts(\"ready\")", language: :elixir, wrap?: true}
             }
           } = code

    assert %Element{
             attributes: %{
               composer: %{
                 placeholder: "Add a review note",
                 submit_intent: :send_review,
                 actions: [%{id: :send, label: "Send", value: "Send"}],
                 multiline?: true
               },
               interactions: [%Interaction{family: :submit, intent: :send_review}]
             }
           } = composer

    for widget <- [panel, callout, redline, code, composer] do
      assert :ok = Validate.element(widget)
    end
  end
end
