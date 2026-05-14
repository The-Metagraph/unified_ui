defmodule LiveUi.WidgetComponentsRendererTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  alias UnifiedIUR.Interaction
  alias UnifiedIUR.Widgets.Components
  alias UnifiedIUR.Widgets.Foundational

  test "renderer maps content and form-control IUR into native component boundaries" do
    heading =
      Components.inline_rich_text_heading(:h2, [%{type: :text, value: "Renderer heading"}],
        id: "heading"
      )

    segmented =
      Components.segmented_button_group(
        [%{value: "all", label: "All"}, %{value: "open", label: "Open"}],
        id: "filter",
        active_value: "open",
        interactions: [Interaction.selection(intent: :select_status, element_id: "filter")]
      )

    form =
      Components.runtime_form_shell(
        [%{name: "title", type: "text", label: "Title"}],
        id: "settings-form",
        submit_label: "Save",
        host_adapter_hints: %{live_ui: %{adapter: :phoenix_form}},
        interactions: [
          Interaction.submit(intent: :save_settings, element_id: "settings-form"),
          Interaction.change(intent: :validate_settings, element_id: "settings-form")
        ]
      )

    composer =
      Components.chat_composer([Foundational.button("Attach")],
        id: "composer",
        value: "Draft",
        interactions: [
          Interaction.submit(intent: :send_message, element_id: "composer"),
          Interaction.change(intent: :update_message, element_id: "composer")
        ]
      )

    html =
      [heading, segmented, form, composer]
      |> Enum.map_join(fn element ->
        render_component(&LiveUi.Renderer.render/1, %{
          element: element,
          event_target: "#runtime-host"
        })
      end)

    assert html =~ ~s(data-live-ui-widget-boundary="inline_rich_text_heading")
    assert html =~ "Renderer heading"

    assert html =~ ~s(data-live-ui-widget-boundary="segmented_button_group")
    assert html =~ ~s(aria-pressed="true")
    assert html =~ ~s(phx-value-selected_value="open")

    assert html =~ ~s(data-live-ui-widget-boundary="runtime_form_shell")
    assert html =~ ~s(data-live-ui-host-adapter="phoenix_form")
    assert html =~ ~s(phx-submit="canonical_submit_interaction")
    assert html =~ ~s(phx-change="canonical_change_interaction")

    assert html =~ ~s(data-live-ui-widget-boundary="chat_composer")
    assert html =~ ~s(phx-click="canonical_submit_interaction")
    assert html =~ ~s(phx-change="canonical_change_interaction")
    assert html =~ "Attach"
  end

  test "renderer maps row, workflow, and repeat IUR into native component boundaries" do
    artifact =
      Components.artifact_row("ADR", [Foundational.button("Open")],
        id: "artifact",
        row_identity: "adr-1",
        meta: %{status: :accepted},
        interactions: [Interaction.click(intent: :open_artifact, element_id: "artifact")]
      )

    stepper =
      Components.pipeline_stepper_horizontal(
        [
          %{id: "draft", label: "Draft", state: :done},
          %{id: "review", label: "Review", state: :active}
        ],
        id: "stepper",
        active_index: 1,
        interactions: [Interaction.navigation(intent: :select_step, element_id: "stepper")]
      )

    repeat =
      Components.list_repeat(nil,
        id: "repeat",
        repeat_binding: :artifacts,
        hydrated?: true,
        row_count: 1,
        children: [artifact]
      )

    html =
      [artifact, stepper, repeat]
      |> Enum.map_join(fn element ->
        render_component(&LiveUi.Renderer.render/1, %{
          element: element,
          event_target: "#runtime-host"
        })
      end)

    assert html =~ ~s(data-live-ui-widget-boundary="artifact_row")
    assert html =~ ~s(phx-value-row_identity="adr-1")
    assert html =~ ~s(phx-click="canonical_interaction")

    assert html =~ ~s(data-live-ui-widget-boundary="pipeline_stepper_horizontal")
    assert html =~ ~s(data-live-ui-step-state="done")
    assert html =~ ~s(data-live-ui-step-state="active")
    assert html =~ ~s(phx-value-step_id="review")

    assert html =~ ~s(data-live-ui-widget-boundary="list_repeat")
    assert html =~ ~s(data-live-ui-repeat-binding="artifacts")
    assert html =~ ~s(data-live-ui-repeat-row-count="1")
  end

  test "renderer maps layer and text-safety IUR without trusting markup text" do
    panel =
      Components.slide_over_panel([Foundational.text("Panel body")],
        id: "panel",
        accessibility_label: "Details",
        open?: true,
        dismiss_intent: :close_panel,
        interactions: [Interaction.close(intent: :close_panel, element_id: "panel")]
      )

    callout =
      Components.event_callout(
        "<script>plain text</script>",
        [Foundational.button("Inspect")],
        id: "callout",
        tone: :warning,
        interactions: [Interaction.click(intent: :inspect_event, element_id: "callout")]
      )

    redline =
      Components.redline_inline([%{state: :insert, text: "<script>safe</script>"}],
        id: "redline"
      )

    code =
      Components.code_block_syntax_highlighted(:elixir, [%{type: :keyword, text: "<def>"}],
        id: "code"
      )

    html =
      [panel, callout, redline, code]
      |> Enum.map_join(fn element ->
        render_component(&LiveUi.Renderer.render/1, %{
          element: element,
          event_target: "#runtime-host"
        })
      end)

    assert html =~ ~s(data-live-ui-widget-boundary="slide_over_panel")
    assert html =~ ~s(aria-hidden="false")
    assert html =~ ~s(phx-value-widget="slide_over_panel")

    assert html =~ ~s(data-live-ui-widget-boundary="event_callout")
    assert html =~ ~s(data-live-ui-callout-tone="warning")
    assert html =~ ~s(phx-click="canonical_interaction")

    assert html =~ "&lt;script&gt;plain text&lt;/script&gt;"
    assert html =~ "&lt;script&gt;safe&lt;/script&gt;"
    assert html =~ "&lt;def&gt;"
    refute html =~ "<script>"
  end
end
