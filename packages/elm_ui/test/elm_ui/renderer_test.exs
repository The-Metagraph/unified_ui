defmodule ElmUi.RendererTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Element
  alias UnifiedIUR.Style
  alias ElmUi.Renderer.Error
  alias ElmUi.Widget

  test "renderer accepts canonical iur input and maps it to native widgets" do
    element = Element.new(:widget, :text, id: :headline, attributes: %{content: "Hello"})

    assert {:ok, %Widget{kind: :text, attributes: %{content: "Hello"}}} =
             ElmUi.Renderer.render(element)
  end

  test "renderer produces deterministic output for equivalent canonical input" do
    element = Element.new(:widget, :button, id: :cta, attributes: %{label: "Open"})

    assert ElmUi.Renderer.render(element) == ElmUi.Renderer.render(element)
  end

  test "renderer realizes CSS-derived canonical style without parsing authored CSS" do
    element =
      Element.new(:widget, :text,
        id: :css_copy,
        attributes: %{
          content: "CSS-derived",
          style:
            Style.new(%{
              foreground: "#2563eb",
              background: "#eff6ff",
              border_color: "#1d4ed8",
              text: %{underline?: true},
              spacing: %{padding_top: "4px"},
              state_variants: %{focused: %{foreground: "#ffffff"}},
              extra: %{
                css: %{
                  properties: ["color"],
                  declarations: [%{selector: "#css-copy", property: "color"}]
                }
              }
            })
        }
      )

    assert {:ok, %Widget{} = widget} = ElmUi.Renderer.render(element)

    assert widget.styles.foreground == "#2563eb"
    assert widget.styles.background == "#eff6ff"
    assert widget.styles.border_color == "#1d4ed8"
    assert widget.styles.text == %{underline?: true}
    assert widget.styles.spacing == %{padding_top: "4px"}
    assert widget.styles.state_variants.focused.foreground == "#ffffff"
    refute Map.has_key?(widget.styles, :css)
    refute inspect(widget.styles) =~ "declarations"
  end

  test "renderer rejects unsupported canonical kinds with structured diagnostics" do
    element =
      Element.new(:widget, :timeline, id: :timeline_root, attributes: %{title: "Unsupported"})

    assert {:error, %Error{code: :unsupported_kind, details: %{kind: :timeline}}} =
             ElmUi.Renderer.render(element)
  end
end
