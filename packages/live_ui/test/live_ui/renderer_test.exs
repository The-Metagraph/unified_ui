defmodule LiveUi.RendererTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  alias UnifiedIUR.{Container, Forms, Layout}
  alias UnifiedIUR.Widgets.{Foundational, Input, Navigation}

  test "renderer maps foundational canonical widgets and layouts into native components" do
    element =
      Container.box(
        [
          Layout.row([
            Foundational.text("Hello"),
            Foundational.button("Save")
          ]),
          Navigation.tabs(
            [
              %{id: "details", label: "Details", active?: true},
              %{id: "activity", label: "Activity"}
            ],
            active_item: "details"
          )
        ],
        id: "root-box"
      )

    html = render_component(&LiveUi.Renderer.render/1, %{element: element})

    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "data-live-ui-widget=\"row\""
    assert html =~ "data-live-ui-widget=\"text\""
    assert html =~ "data-live-ui-widget=\"button\""
    assert html =~ "data-live-ui-widget=\"tabs\""
  end

  test "renderer maps canonical form constructs through native form and input surfaces" do
    element =
      Forms.form_builder(
        [
          Forms.field_group(
            [
              Forms.field(
                Input.text_input(name: "name", value: "Pascal", placeholder: "Name"),
                id: "name-field",
                name: "name",
                label: "Name"
              )
            ],
            legend: "Identity"
          )
        ],
        id: "profile-form"
      )

    html = render_component(&LiveUi.Renderer.render/1, %{element: element})

    assert html =~ "data-live-ui-widget=\"form-builder\""
    assert html =~ "data-live-ui-widget=\"field-group\""
    assert html =~ "data-live-ui-widget=\"field\""
    assert html =~ "data-live-ui-widget=\"text-input\""
    assert html =~ "Pascal"
  end

  test "runtime can mount canonical unified_iur input through the shared screen host" do
    element =
      Layout.column([
        Foundational.label("Status"),
        Input.select(
          [
            %{value: "draft", label: "Draft"},
            %{value: "published", label: "Published", selected?: true}
          ],
          name: "status"
        )
      ])

    assert {:ok, runtime_state} = LiveUi.Runtime.mount_iur(element)

    html =
      render_component(LiveUi.Runtime.component(), id: "canonical", runtime_state: runtime_state)

    assert html =~ "data-live-ui-runtime=\"screen\""
    assert html =~ "data-live-ui-widget=\"column\""
    assert html =~ "data-live-ui-widget=\"label\""
    assert html =~ "data-live-ui-widget=\"select\""
  end

  test "renderer lowers canonical button interactions into LiveView click bindings when an event target is present" do
    element =
      Foundational.button("Inspect",
        id: "inspect-button",
        interactions: [
          UnifiedIUR.Interaction.click(intent: :inspect_button, element_id: "inspect-button")
        ]
      )

    html =
      render_component(&LiveUi.Renderer.render/1, %{
        element: element,
        event_target: "#runtime-host"
      })

    assert html =~ ~s(phx-click="canonical_interaction")
    assert html =~ ~s(phx-target="#runtime-host")
    assert html =~ ~s(phx-value-widget="button")
    assert html =~ ~s(phx-value-element_id="inspect-button")
  end

  test "renderer lowers canonical input interactions into LiveView change bindings when an event target is present" do
    element =
      Input.text_input(
        name: "draft_note",
        value: "review-ready",
        placeholder: "Draft",
        id: "draft-note-input",
        interactions: [
          UnifiedIUR.Interaction.change(intent: :draft_note, element_id: "draft-note-input")
        ]
      )

    html =
      render_component(&LiveUi.Renderer.render/1, %{
        element: element,
        event_target: "#runtime-host"
      })

    assert html =~ ~s(phx-change="canonical_interaction")
    assert html =~ ~s(phx-target="#runtime-host")
    assert html =~ ~s(phx-value-widget="text_input")
    assert html =~ ~s(phx-value-element_id="draft-note-input")
  end

  test "renderer lowers canonical form interactions into LiveView form bindings when an event target is present" do
    element =
      Forms.form_builder(
        [
          Forms.field(
            Input.text_input(name: "name", value: "Pascal"),
            id: "name-field",
            name: "name",
            label: "Name"
          )
        ],
        id: "profile-form",
        interactions: [
          UnifiedIUR.Interaction.change(intent: :review_form, element_id: "profile-form")
        ]
      )

    html =
      render_component(&LiveUi.Renderer.render/1, %{
        element: element,
        event_target: "#runtime-host"
      })

    assert html =~ ~s(phx-change="canonical_change_interaction")
    assert html =~ ~s(phx-target="#runtime-host")
    assert html =~ ~s(phx-value-widget="form_builder")
    assert html =~ ~s(phx-value-element_id="profile-form")
  end

  test "equivalent canonical inputs map deterministically into the same native structure" do
    left =
      Layout.row([
        Foundational.text("A"),
        Foundational.spacer(size: :sm),
        Foundational.link("Docs", "/docs")
      ])

    right =
      Layout.row([
        Foundational.text("A", %{}),
        Foundational.spacer(size: :sm, metadata: %{}),
        Foundational.link("Docs", "/docs", [])
      ])

    assert render_component(&LiveUi.Renderer.render/1, %{element: left}) ==
             render_component(&LiveUi.Renderer.render/1, %{element: right})
  end
end
