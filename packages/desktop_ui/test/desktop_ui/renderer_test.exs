defmodule DesktopUi.RendererTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Element

  test "renderer maps foundational canonical widgets and layouts into native desktop widgets" do
    element =
      Element.new(:layout, :column,
        id: "workspace-layout",
        attributes: %{gap: 16},
        children: [
          Element.new(:widget, :text,
            id: "workspace-title",
            attributes: %{content: "Workspace"}
          ),
          Element.new(:widget, :text_input,
            id: "query-input",
            attributes: %{
              value: "status:ok",
              placeholder: "Search",
              binding: %{name: :query, value: "status:ok"},
              interaction: %{family: :submit, intent: :run_query}
            }
          ),
          Element.new(:widget, :tabs,
            id: "workspace-tabs",
            attributes: %{
              items: [%{id: :overview, label: "Overview"}, %{id: :activity, label: "Activity"}],
              current: :overview,
              binding: %{name: :section, value: :overview},
              interaction: %{family: :navigation, intent: :switch_section}
            }
          ),
          Element.new(:widget, :button,
            id: "save-button",
            attributes: %{label: "Save", interaction: %{family: :click, intent: :save_workspace}}
          )
        ]
      )

    assert {:ok, widget} = DesktopUi.Renderer.render(element)
    assert widget.kind == :column
    assert Enum.map(widget.children, & &1.kind) == [:text, :text_input, :tabs, :button]
    assert Enum.at(widget.children, 1).bindings.value == :query
    assert Enum.at(widget.children, 2).bindings.current == :section
    assert Enum.at(widget.children, 3).events.click.intent == :save_workspace
    assert DesktopUi.Renderer.validation_state() == :foundational_mapper_ready
  end

  test "renderer rejects unsupported canonical constructs and invalid bindings deterministically" do
    unsupported = Element.new(:widget, :calendar, id: "unsupported-calendar")

    assert {:error, %DesktopUi.Renderer.Error{} = unsupported_error} =
             DesktopUi.Renderer.render(unsupported)

    assert unsupported_error.reason == :unsupported_canonical_construct
    assert unsupported_error.details.kind == :calendar

    invalid_bindings =
      Element.new(:widget, :text_input,
        id: "query",
        attributes: %{binding: %{invalid: true}}
      )

    assert {:error, %DesktopUi.Renderer.Error{} = invalid_binding_error} =
             DesktopUi.Renderer.render(invalid_bindings)

    assert invalid_binding_error.reason == :invalid_canonical_bindings
    assert invalid_binding_error.details.id == "query"
  end
end
