defmodule WebUi.RendererTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Element
  alias WebUi.Widget

  test "renderer accepts canonical iur input and maps it to native widgets" do
    element = Element.new(:widget, :text, id: :headline, attributes: %{content: "Hello"})

    assert %Widget{kind: :text, attributes: %{content: "Hello"}} = WebUi.Renderer.render(element)
  end

  test "renderer produces deterministic output for equivalent canonical input" do
    element = Element.new(:widget, :button, id: :cta, attributes: %{label: "Open"})

    assert WebUi.Renderer.render(element) == WebUi.Renderer.render(element)
  end

  test "renderer preserves unsupported canonical kinds as deterministic diagnostics" do
    element = Element.new(:widget, :dialog, id: :dialog_root, attributes: %{title: "Unsupported"})

    assert %Widget{kind: :text, attributes: %{canonical_kind: :dialog}} =
             WebUi.Renderer.render(element)
  end
end
