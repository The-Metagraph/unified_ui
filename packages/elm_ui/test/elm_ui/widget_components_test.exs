defmodule ElmUi.WidgetComponentsTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.{Element, RuntimeParity}

  test "native component constructors expose the expanded catalog" do
    widgets = [
      ElmUi.Widgets.inline_rich_text_heading("heading", :h2, [
        %{type: :text, value: "Runtime parity"}
      ]),
      ElmUi.Widgets.disclosure(
        "details",
        "More",
        [
          ElmUi.Widgets.kicker("kicker", ["Spec", "Runtime"])
        ], open?: true),
      ElmUi.Widgets.avatar("avatar", initials: "PC", accessibility_label: "Pascal"),
      ElmUi.Widgets.presence_dot("presence", :active, accessibility_label: "Active"),
      ElmUi.Widgets.segmented_button_group(
        "segment",
        [%{value: :open, label: "Open"}, %{value: :closed, label: "Closed"}],
        active_value: :open,
        on_select: %{intent: :select_status}
      ),
      ElmUi.Widgets.runtime_form_shell(
        "form",
        [%{name: :title, type: :text, label: "Title"}],
        submit_label: "Save",
        host_adapter_hints: %{phoenix: %{adapter: :form}},
        on_submit: %{intent: :save_form},
        on_change: %{intent: :validate_form}
      ),
      ElmUi.Widgets.chat_composer(
        "composer",
        [ElmUi.Widgets.button("attach", "Attach")],
        value: "Draft",
        on_send: %{intent: :send_message},
        on_change: %{intent: :update_message}
      ),
      ElmUi.Widgets.artifact_row(
        "artifact",
        "ADR",
        [ElmUi.Widgets.button("open", "Open")],
        row_identity: "adr-1",
        meta: %{status: :accepted},
        on_activate: %{intent: :open_artifact}
      ),
      ElmUi.Widgets.pipeline_stepper_horizontal(
        "stepper",
        [%{id: :draft, label: "Draft"}, %{id: :review, label: "Review"}],
        active_index: 1,
        on_step: %{intent: :select_step}
      ),
      ElmUi.Widgets.segmented_progress_bar(
        "progress",
        [%{id: :a, state: :done}, %{id: :b, state: :active}],
        aggregate_progress: %{current: 1, maximum: 2}
      ),
      ElmUi.Widgets.workflow_stage_list_vertical(
        "stages",
        [%{id: :authored, label: "Authored"}, %{id: :implemented, label: "Implemented"}]
      ),
      ElmUi.Widgets.meter_thin("meter", 35, maximum: 100),
      ElmUi.Widgets.sticky_frosted_header("header", [
        ElmUi.Widgets.text("header-title", "Header")
      ]),
      ElmUi.Widgets.slide_over_panel(
        "panel",
        [
          ElmUi.Widgets.text("panel-body", "Body")
        ], open?: true),
      ElmUi.Widgets.event_callout(
        "callout",
        "Paused",
        [
          ElmUi.Widgets.button("inspect", "Inspect")
        ], tone: :warning),
      ElmUi.Widgets.redline_inline("redline", [%{state: :insert, text: "<script>safe</script>"}]),
      ElmUi.Widgets.code_block_syntax_highlighted(
        "code",
        :elixir,
        [%{type: :keyword, text: "<defmodule>"}]
      ),
      ElmUi.Widgets.list_repeat(
        "repeat",
        [
          ElmUi.Widgets.artifact_row("repeat:a1", "ADR 1")
        ], repeat_binding: :artifacts, hydrated?: true)
    ]

    assert ElmUi.Widgets.Components in ElmUi.Widgets.modules()
    assert ElmUi.Widgets.validation_state().widget_components == :ready

    assert RuntimeParity.acceptance_criteria().required_widget_kinds -- ElmUi.Widgets.kinds() ==
             []

    assert ElmUi.Renderer.required_canonical_kinds() -- ElmUi.Widgets.kinds() == []
    assert Enum.all?(widgets, &(&1.family == :component))

    segment = Enum.find(widgets, &(&1.kind == :segmented_button_group))
    form = Enum.find(widgets, &(&1.kind == :runtime_form_shell))
    composer = Enum.find(widgets, &(&1.kind == :chat_composer))
    repeat = Enum.find(widgets, &(&1.kind == :list_repeat))

    assert segment.events.selection.intent == :select_status
    assert form.events.submit.intent == :save_form
    assert form.events.change.intent == :validate_form
    assert composer.events.submit.intent == :send_message
    assert composer.slot_children.default |> hd() |> Map.fetch!(:kind) == :button
    assert repeat.attributes.repeat.row_count == 1
  end

  test "canonical runtime parity fixtures map into ElmUi native component widgets" do
    Enum.each(RuntimeParity.fixtures(), fn fixture ->
      assert {:ok, widget} = ElmUi.Renderer.render(fixture.element)
      assert widget.kind == fixture.element.kind
      assert widget.family == :component
      assert widget.metadata.component_family
      assert get_in(widget.attributes, [:component, :kind]) == widget.kind

      expected_children = Map.get(fixture.expected, :children, %{})

      Enum.each(expected_children, fn {slot, count} ->
        assert length(Map.get(widget.slot_children, slot, [])) == count
      end)
    end)
  end

  test "component fixtures hydrate through the Phoenix and Elm split runtime" do
    screen =
      Element.new(:layout, :column,
        id: "component-parity-screen",
        children: Enum.map(RuntimeParity.fixtures(), & &1.element)
      )

    assert {:ok, runtime_state} =
             ElmUi.Runtime.mount_iur_screen(screen,
               runtime_id: "elm-component-parity",
               title: "Component Parity"
             )

    assert {:ok, model} = ElmUi.Runtime.hydrate_frontend(runtime_state)

    assert find_node(model.tree, "parity-form").role == "form"
    assert find_node(model.tree, "parity-control").role == "radiogroup"
    assert find_node(model.tree, "parity-repeat").role == "list"
    assert find_node(model.tree, "parity-composer").browser.editable?
  end

  test "redline and code component text remains plain text data in browser realization" do
    screen =
      Element.new(:layout, :column,
        id: "safe-text-screen",
        children: [
          RuntimeParity.fixture!(:redline).element,
          RuntimeParity.fixture!(:code).element
        ]
      )

    assert {:ok, runtime_state} = ElmUi.Runtime.mount_iur_screen(screen)
    assert {:ok, model} = ElmUi.Runtime.hydrate_frontend(runtime_state)

    redline = find_node(model.tree, "parity-redline")
    code = find_node(model.tree, "parity-code")

    assert redline.attrs.plain_text_output
    assert code.attrs.plain_text_output

    assert redline.attributes.redline.segments == [
             %{state: :insert, text: "<script>safe redline</script>"}
           ]

    assert code.attributes.code.tokens == [%{type: :keyword, text: "<defmodule>"}]
    refute Map.has_key?(redline.attributes, :trusted_html)
    refute Map.has_key?(code.attributes, :trusted_html)
  end

  defp find_node(%{id: id} = node, id), do: node

  defp find_node(node, id) when is_map(node) do
    node.slots
    |> Enum.flat_map(& &1.children)
    |> Enum.find_value(&find_node(&1, id))
  end

  defp find_node(nil, _id), do: nil
end
