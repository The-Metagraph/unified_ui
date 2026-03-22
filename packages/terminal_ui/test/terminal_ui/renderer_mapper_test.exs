defmodule TerminalUi.RendererMapperTest do
  use ExUnit.Case, async: true

  alias TerminalUi.Renderer
  alias UnifiedIUR.{Binding, Element, Interaction, Layout}
  alias UnifiedIUR.Widgets.{Foundational, Input, Navigation}

  test "canonical foundational screens map into the native widget surface" do
    element =
      Layout.column(
        [
          Foundational.text("Workspace", id: "title"),
          Input.text_input(
            id: "query",
            placeholder: "Filter",
            binding: %{name: :query, value: "status:ok"},
            interaction: Interaction.submit(intent: :run_query)
          ),
          Foundational.button(
            "Save",
            id: "save",
            interaction: Interaction.click(intent: :save_workspace)
          ),
          Navigation.tabs(
            [%{id: :overview, label: "Overview"}, %{id: :details, label: "Details"}],
            id: "sections",
            active_item: :overview,
            binding: Binding.new(name: :active_section, value: :overview),
            interaction: Interaction.navigation(intent: :switch_section)
          )
        ],
        id: "screen",
        gap: :md
      )

    assert {:ok, widget} = Renderer.render(element)
    assert widget.kind == :column
    assert Enum.map(widget.children, & &1.kind) == [:text, :text_input, :button, :tabs]
    assert Enum.at(widget.children, 1).bindings == %{value: :query}
    assert Enum.at(widget.children, 2).events == %{keypress: %{intent: :save_workspace}}
    assert Enum.at(widget.children, 3).bindings == %{current: :active_section}
  end

  test "canonical screens mount through the same runtime realization model as native screens" do
    element =
      Layout.column(
        [
          Foundational.text("Workspace", id: "title"),
          Input.checkbox(
            id: "enabled",
            label_text: "Enabled",
            binding: %{name: :enabled, value: true},
            interaction: Interaction.change(intent: :toggle_enabled)
          ),
          Navigation.menu(
            [%{id: :home, label: "Home"}, %{id: :jobs, label: "Jobs"}],
            id: "menu",
            active_item: :home,
            binding: %{name: :current_menu, value: :home},
            interaction: Interaction.selection(intent: :select_menu)
          )
        ],
        id: "workspace"
      )

    assert {:ok, runtime_state} = TerminalUi.Runtime.mount_iur_screen(element, backend_mode: :raw)
    assert runtime_state.source_kind == :canonical
    assert runtime_state.root.kind == :column
    assert runtime_state.realization.validation_state == :foundational_ready

    assert runtime_state.realization.binding_index[:enabled] == [
             %{widget_id: "enabled", slot: :checked}
           ]

    assert runtime_state.realization.binding_index[:current_menu] == [
             %{widget_id: "menu", slot: :current}
           ]
  end

  test "unsupported canonical constructs and invalid bindings fail deterministically" do
    unsupported = Element.new(:widget, :table, id: "table")

    assert {:error, %TerminalUi.Renderer.Error{} = unsupported_error} =
             Renderer.render(unsupported)

    assert unsupported_error.reason == :unsupported_canonical_construct

    invalid_binding =
      Element.new(:widget, :text_input,
        id: "query",
        attributes: %{bindings: [%{invalid: true}]}
      )

    assert {:error, %TerminalUi.Renderer.Error{} = binding_error} =
             Renderer.render(invalid_binding)

    assert binding_error.reason == :invalid_canonical_bindings
  end
end
