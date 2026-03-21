defmodule WebUi.RendererTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Element
  alias WebUi.Renderer.Error
  alias WebUi.Widget

  test "renderer accepts canonical iur input and maps it to native widgets" do
    element = Element.new(:widget, :text, id: :headline, attributes: %{content: "Hello"})

    assert {:ok, %Widget{kind: :text, attributes: %{content: "Hello"}}} =
             WebUi.Renderer.render(element)
  end

  test "renderer produces deterministic output for equivalent canonical input" do
    element = Element.new(:widget, :button, id: :cta, attributes: %{label: "Open"})

    assert WebUi.Renderer.render(element) == WebUi.Renderer.render(element)
  end

  test "renderer rejects unsupported canonical kinds with structured diagnostics" do
    element = Element.new(:widget, :dialog, id: :dialog_root, attributes: %{title: "Unsupported"})

    assert {:error, %Error{code: :unsupported_kind, details: %{kind: :dialog}}} =
             WebUi.Renderer.render(element)
  end
end
