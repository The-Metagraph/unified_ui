defmodule DesktopUi.WidgetComponentsTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.{Element, RuntimeParity}

  test "native component constructors expose desktop widget models" do
    widgets = [
      DesktopUi.Widgets.inline_rich_text_heading("heading", :h2, [
        %{type: :text, value: "Runtime parity"}
      ]),
      DesktopUi.Widgets.disclosure(
        "details",
        "More",
        [
          DesktopUi.Widgets.kicker("kicker", ["Spec", "Runtime"])
        ],
        open?: true
      ),
      DesktopUi.Widgets.avatar("avatar", initials: "PC", accessibility_label: "Pascal"),
      DesktopUi.Widgets.presence_dot("presence", :active, accessibility_label: "Active"),
      DesktopUi.Widgets.segmented_button_group(
        "segment",
        [%{value: :open, label: "Open"}, %{value: :closed, label: "Closed"}],
        active_value: :open,
        on_select: %{intent: :select_status}
      ),
      DesktopUi.Widgets.runtime_form_shell(
        "form",
        [%{name: :title, type: :text, label: "Title"}],
        submit_label: "Save",
        on_submit: %{intent: :save_form},
        on_change: %{intent: :validate_form}
      ),
      DesktopUi.Widgets.chat_composer(
        "composer",
        [DesktopUi.Widgets.button("attach", "Attach")],
        value: "Draft",
        on_send: %{intent: :send_message}
      ),
      DesktopUi.Widgets.artifact_row(
        "artifact",
        "ADR",
        [DesktopUi.Widgets.button("open", "Open")],
        row_identity: "adr-1",
        on_activate: %{intent: :open_artifact}
      ),
      DesktopUi.Widgets.pipeline_stepper_horizontal(
        "stepper",
        [%{id: :draft, label: "Draft"}, %{id: :review, label: "Review"}],
        on_step: %{intent: :select_step}
      ),
      DesktopUi.Widgets.segmented_progress_bar(
        "progress",
        [%{id: :a, state: :done}, %{id: :b, state: :active}],
        aggregate_progress: %{current: 1, maximum: 2}
      ),
      DesktopUi.Widgets.workflow_stage_list_vertical(
        "stages",
        [%{id: :authored, label: "Authored"}, %{id: :implemented, label: "Implemented"}]
      ),
      DesktopUi.Widgets.meter_thin("meter", 35),
      DesktopUi.Widgets.sticky_frosted_header("header", [
        DesktopUi.Widgets.text("header-title", "Header")
      ]),
      DesktopUi.Widgets.slide_over_panel(
        "panel",
        [
          DesktopUi.Widgets.text("panel-body", "Body")
        ],
        open?: true
      ),
      DesktopUi.Widgets.event_callout("callout", "Paused", [
        DesktopUi.Widgets.button("inspect", "Inspect")
      ]),
      DesktopUi.Widgets.redline_inline("redline", [
        %{state: :insert, text: "<script>safe</script>"}
      ]),
      DesktopUi.Widgets.code_block_syntax_highlighted(
        "code",
        :elixir,
        [%{type: :keyword, text: "<defmodule>"}]
      ),
      DesktopUi.Widgets.list_repeat(
        "repeat",
        [
          DesktopUi.Widgets.artifact_row("repeat:a1", "ADR 1")
        ],
        repeat_binding: :artifacts,
        hydrated?: true
      )
    ]

    assert DesktopUi.Widgets.Components in DesktopUi.Widgets.modules()
    assert DesktopUi.Widgets.validation_state().widget_components == :ready

    assert RuntimeParity.acceptance_criteria().required_widget_kinds -- DesktopUi.Widgets.kinds() ==
             []

    assert RuntimeParity.acceptance_criteria().required_widget_kinds --
             DesktopUi.Renderer.supported_kinds() == []

    assert Enum.all?(widgets, &(&1.family == :component))

    segment = Enum.find(widgets, &(&1.kind == :segmented_button_group))
    composer = Enum.find(widgets, &(&1.kind == :chat_composer))
    repeat = Enum.find(widgets, &(&1.kind == :list_repeat))

    assert segment.events.selection.intent == :select_status
    assert composer.events.submit.intent == :send_message
    assert composer.metadata.focusable
    assert repeat.attributes.repeat.row_count == 1
  end

  test "canonical runtime parity fixtures map into DesktopUi component widgets" do
    Enum.each(RuntimeParity.fixtures(), fn fixture ->
      assert {:ok, widget} = DesktopUi.Renderer.render(fixture.element)
      assert widget.kind == fixture.element.kind
      assert widget.family == :component
      assert widget.metadata.component_family
      assert get_in(widget.attributes, [:component, :kind]) == widget.kind

      Enum.each(Map.get(fixture.expected, :children, %{}), fn {slot, count} ->
        assert length(Map.get(widget.slot_children, slot, [])) == count
      end)
    end)
  end

  test "component fixtures mount through shared desktop runtime and render plan" do
    screen =
      Element.new(:layout, :column,
        id: "component-parity-screen",
        children: Enum.map(RuntimeParity.fixtures(), & &1.element)
      )

    assert {:ok, runtime_state} =
             DesktopUi.Runtime.mount_iur_screen(screen,
               screen_id: "component-parity",
               title: "Component Parity",
               platform_target: :linux
             )

    assert runtime_state.source_kind == :canonical
    assert "parity-control" in runtime_state.realization.focus_order
    assert runtime_state.realization.event_targets["parity-control"] == [:selection]

    assert {:ok, plan} = DesktopUi.Sdl3.RenderPlan.build(runtime_state)

    assert plan.diagnostics.draw_kind_counts.segmented_control == 1
    assert plan.diagnostics.draw_kind_counts.artifact_row >= 3
    assert plan.diagnostics.draw_kind_counts.code_block_text == 1
    assert find_operation(plan, "parity-repeat").draw_kind == :repeat_surface
  end

  test "component interactions and safe text keep canonical desktop meaning" do
    screen =
      Element.new(:layout, :column,
        id: "component-interactions",
        children: [
          RuntimeParity.fixture!(:control).element,
          RuntimeParity.fixture!(:redline).element,
          RuntimeParity.fixture!(:code).element
        ]
      )

    assert {:ok, runtime_state} =
             DesktopUi.Runtime.mount_iur_screen(screen,
               screen_id: "component-interactions",
               platform_target: :linux
             )

    assert {:ok, _next_state, route} =
             DesktopUi.Runtime.dispatch_widget_interaction(
               runtime_state,
               "parity-control",
               :selection,
               intent: :select_status
             )

    assert route.route == :canonical_boundary
    assert route.translation.signal.type == "desktop_ui.selection.select_status"

    assert {:ok, plan} = DesktopUi.Sdl3.RenderPlan.build(runtime_state)
    redline = find_operation(plan, "parity-redline")
    code = find_operation(plan, "parity-code")

    assert redline.resource.text_safety == :plain_text
    assert code.resource.text_safety == :plain_text
    assert redline.content == "<script>safe redline</script>"
    assert code.content == "<defmodule>"
  end

  defp find_operation(plan, widget_id) do
    plan.windows
    |> Enum.flat_map(& &1.draw_operations)
    |> Enum.find(&(&1.widget_id == widget_id))
  end
end
