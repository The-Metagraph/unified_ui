defmodule LiveUi.WidgetComponentsPhase3IntegrationTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  alias UnifiedIUR.Interaction
  alias UnifiedIUR.Widgets.Components
  alias UnifiedIUR.Widgets.Foundational

  defp slot_text(slot, text) do
    %{__slot__: slot, inner_block: fn _, _ -> text end}
  end

  test "direct native components cover the expanded widget-component families" do
    native_html =
      [
        render_component(&LiveUi.Widgets.Components.InlineRichTextHeading.component/1, %{
          id: "heading",
          level: "h2",
          segments: [%{type: :text, value: "Native components"}]
        }),
        render_component(&LiveUi.Widgets.Components.Disclosure.component/1, %{
          id: "disclosure",
          summary: "Details",
          open: true,
          inner_block: [slot_text(:inner_block, "Disclosure body")]
        }),
        render_component(&LiveUi.Widgets.Components.Kicker.component/1, %{
          id: "kicker",
          items: ["Spec", "ADR"]
        }),
        render_component(&LiveUi.Widgets.Components.Avatar.component/1, %{
          id: "avatar",
          initials: "PC",
          label: "Pascal"
        }),
        render_component(&LiveUi.Widgets.Components.PresenceDot.component/1, %{
          id: "presence",
          presence: "active"
        }),
        render_component(&LiveUi.Widgets.Components.SegmentedButtonGroup.component/1, %{
          id: "segments",
          active_value: "open",
          options: [%{value: "open", label: "Open"}]
        }),
        render_component(&LiveUi.Widgets.Components.RuntimeFormShell.component/1, %{
          id: "form",
          fields: [%{name: "title", label: "Title"}],
          submit_label: "Save"
        }),
        render_component(&LiveUi.Widgets.Components.ChatComposer.component/1, %{
          id: "composer",
          value: "Draft",
          tools: [slot_text(:tools, "Attach")]
        }),
        render_component(&LiveUi.Widgets.Components.ListItemMultiColumn.component/1, %{
          id: "row",
          row_identity: "row-1",
          columns: [%{id: "title", label: "Title"}],
          actions: [slot_text(:actions, "Open")]
        }),
        render_component(&LiveUi.Widgets.Components.ArtifactRow.component/1, %{
          id: "artifact",
          title: "ADR",
          meta: %{status: :accepted}
        }),
        render_component(&LiveUi.Widgets.Components.PipelineStepperHorizontal.component/1, %{
          id: "stepper",
          steps: [%{label: "Draft", state: :done}]
        }),
        render_component(&LiveUi.Widgets.Components.SegmentedProgressBar.component/1, %{
          id: "progress",
          label: "Health",
          aggregate_progress: %{current: 1, maximum: 1},
          segments: [%{label: "Passing", weight: 1}]
        }),
        render_component(&LiveUi.Widgets.Components.WorkflowStageListVertical.component/1, %{
          id: "stages",
          stages: [%{label: "Authored", state: :active}]
        }),
        render_component(&LiveUi.Widgets.Components.MeterThin.component/1, %{
          id: "meter",
          current: 1.0,
          maximum: 1.0,
          label: "Coverage"
        }),
        render_component(&LiveUi.Widgets.Components.StickyFrostedHeader.component/1, %{
          id: "header",
          title: "Workspace"
        }),
        render_component(&LiveUi.Widgets.Components.SlideOverPanel.component/1, %{
          id: "panel",
          label: "Details",
          open: true,
          inner_block: [slot_text(:inner_block, "Panel body")]
        }),
        render_component(&LiveUi.Widgets.Components.EventCallout.component/1, %{
          id: "callout",
          message: "Paused",
          action_label: "Inspect"
        }),
        render_component(&LiveUi.Widgets.Components.RedlineInline.component/1, %{
          id: "redline",
          segments: [%{state: :insert, text: "<script>safe</script>"}]
        }),
        render_component(&LiveUi.Widgets.Components.CodeBlockSyntaxHighlighted.component/1, %{
          id: "code",
          tokens: [%{type: :keyword, text: "<def>"}]
        })
      ]
      |> Enum.join()

    for boundary <- [
          "inline_rich_text_heading",
          "disclosure",
          "kicker",
          "avatar",
          "presence_dot",
          "segmented_button_group",
          "runtime_form_shell",
          "chat_composer",
          "list_item_multi_column",
          "artifact_row",
          "pipeline_stepper_horizontal",
          "segmented_progress_bar",
          "workflow_stage_list_vertical",
          "meter_thin",
          "sticky_frosted_header",
          "slide_over_panel",
          "event_callout",
          "redline_inline",
          "code_block_syntax_highlighted"
        ] do
      assert native_html =~ ~s(data-live-ui-widget-boundary="#{boundary}")
    end

    assert native_html =~ "&lt;script&gt;safe&lt;/script&gt;"
    assert native_html =~ "&lt;def&gt;"
    refute native_html =~ "<script>"
  end

  test "IUR renderer output converges with direct native component semantics" do
    direct =
      render_component(&LiveUi.Widgets.Components.SegmentedButtonGroup.component/1, %{
        id: "direct-filter",
        active_value: "open",
        option_attrs: %{"phx-click" => "select_status"},
        options: [%{value: "open", label: "Open"}]
      })

    canonical =
      Components.segmented_button_group([%{value: "open", label: "Open"}],
        id: "canonical-filter",
        active_value: "open",
        interactions: [
          Interaction.selection(intent: :select_status, element_id: "canonical-filter")
        ]
      )

    rendered =
      render_component(&LiveUi.Renderer.render/1, %{
        element: canonical,
        event_target: "#runtime-host"
      })

    for html <- [direct, rendered] do
      assert html =~ ~s(data-live-ui-widget-boundary="segmented_button_group")
      assert html =~ ~s(aria-pressed="true")
      assert html =~ ~s(data-live-ui-segment-value="open")
      assert html =~ ~s(phx-click=)
    end

    assert rendered =~ ~s(phx-value-selected_value="open")
    assert rendered =~ ~s(phx-target="#runtime-host")
  end

  test "IUR renderer repeats hydrated rows and preserves safety semantics" do
    repeat =
      Components.list_repeat(nil,
        id: "artifact-repeat",
        repeat_binding: :artifacts,
        hydrated?: true,
        row_count: 2,
        children: [
          Components.artifact_row("ADR 1", [Foundational.button("Open", id: "open-a1")],
            id: "artifact-repeat:a1:artifact",
            row_identity: "a1",
            interactions: [Interaction.click(intent: :open_artifact, element_id: "a1")]
          ),
          Components.artifact_row("ADR 2", [Foundational.button("Open", id: "open-a2")],
            id: "artifact-repeat:a2:artifact",
            row_identity: "a2",
            interactions: [Interaction.click(intent: :open_artifact, element_id: "a2")]
          ),
          Components.redline_inline([%{state: :delete, text: "<script>remove</script>"}],
            id: "repeat-redline"
          )
        ]
      )

    html =
      render_component(&LiveUi.Renderer.render/1, %{
        element: repeat,
        event_target: "#runtime-host"
      })

    assert html =~ ~s(data-live-ui-widget-boundary="list_repeat")
    assert html =~ ~s(data-live-ui-repeat-row-count="2")
    assert html =~ "artifact-repeat:a1:artifact"
    assert html =~ "artifact-repeat:a2:artifact"
    assert html =~ ~s(phx-value-row_identity="a1")
    assert html =~ ~s(phx-value-row_identity="a2")
    assert html =~ "&lt;script&gt;remove&lt;/script&gt;"
    refute html =~ "<script>"
  end
end
