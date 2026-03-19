defmodule WebUi.Integration.FoundationalReferenceExamplesTest do
  use ExUnit.Case

  @moduletag :integration
  @moduletag :foundational_examples

  alias UnifiedIUR.Widgets.Foundational
  alias WebUi.Renderer.Canonical
  alias WebUi.Widgets.Native.Widget
  alias WebUi.Widgets.Foundational, as: NativeFoundational

  describe "native widget rendering examples" do
    test "text widget renders with value" do
      {:ok, widget} = Widget.create(NativeFoundational.Text, %{value: "Hello, World!"})

      assert {:safe, html} = NativeFoundational.Text.render_server(widget.props, [])
      assert String.contains?(html, "Hello, World!")
      assert String.contains?(html, "webui-text")
    end

    test "button widget renders with label" do
      {:ok, widget} = Widget.create(NativeFoundational.Button, %{label: "Click Me"})

      assert {:safe, html} = NativeFoundational.Button.render_server(widget.props, [])
      assert String.contains?(html, "Click Me")
      assert String.contains?(html, "webui-button")
    end

    test "content widget renders children" do
      {:ok, child1} = Widget.create(NativeFoundational.Text, %{value: "First"})
      {:ok, child2} = Widget.create(NativeFoundational.Text, %{value: "Second"})

      children = [
        {:safe, NativeFoundational.Text.render_server(child1.props, []) |> elem(1)},
        {:safe, NativeFoundational.Text.render_server(child2.props, []) |> elem(1)}
      ]

      {:safe, html} = NativeFoundational.Content.render_server(%{}, children: children)

      assert String.contains?(html, "First")
      assert String.contains?(html, "Second")
      assert String.contains?(html, "webui-content")
    end
  end

  describe "canonical widget rendering examples" do
    test "text widget from IUR renders equivalent HTML" do
      iur_element = Foundational.text("Hello, World!")
      {:ok, widget} = Canonical.render(iur_element)

      assert {:safe, html} = NativeFoundational.Text.render_server(widget.props, [])
      assert String.contains?(html, "Hello, World!")
      assert String.contains?(html, "webui-text")
    end

    test "button widget from IUR renders equivalent HTML" do
      iur_element = Foundational.button("Click Me")
      {:ok, widget} = Canonical.render(iur_element)

      assert {:safe, html} = NativeFoundational.Button.render_server(widget.props, [])
      assert String.contains?(html, "Click Me")
      assert String.contains?(html, "webui-button")
    end

    test "content widget from IUR renders children" do
      iur_element = Foundational.content([Foundational.text("First"), Foundational.text("Second")])
      {:ok, widget} = Canonical.render(iur_element)

      assert widget.id == :content
      assert length(widget.slots.content) == 2
    end
  end

  describe "native vs canonical rendering comparison" do
    test "text widget produces identical HTML from both paths" do
      # Native path
      {:ok, native_widget} = Widget.create(NativeFoundational.Text, %{value: "Test"})
      {:safe, native_html} = NativeFoundational.Text.render_server(native_widget.props, [])

      # Canonical path
      iur_element = Foundational.text("Test")
      {:ok, canonical_widget} = Canonical.render(iur_element)
      {:safe, canonical_html} = NativeFoundational.Text.render_server(canonical_widget.props, [])

      assert native_html == canonical_html
    end

    test "button widget produces identical HTML from both paths" do
      # Native path
      {:ok, native_widget} = Widget.create(NativeFoundational.Button, %{label: "Submit"})
      {:safe, native_html} = NativeFoundational.Button.render_server(native_widget.props, [])

      # Canonical path
      iur_element = Foundational.button("Submit")
      {:ok, canonical_widget} = Canonical.render(iur_element)
      {:safe, canonical_html} = NativeFoundational.Button.render_server(canonical_widget.props, [])

      assert native_html == canonical_html
    end

    test "link widget produces identical HTML from both paths" do
      # Native path
      {:ok, native_widget} = Widget.create(NativeFoundational.Link, %{label: "Home", target: "/"})
      {:safe, native_html} = NativeFoundational.Link.render_server(native_widget.props, [])

      # Canonical path
      iur_element = Foundational.link("Home", "/")
      {:ok, canonical_widget} = Canonical.render(iur_element)
      {:safe, canonical_html} = NativeFoundational.Link.render_server(canonical_widget.props, [])

      assert native_html == canonical_html
    end
  end

  describe "complex widget composition examples" do
    test "nested content structure renders correctly" do
      # Create a nested structure: content -> [text, button, spacer]
      iur_element = Foundational.content([
        Foundational.text("Welcome!"),
        Foundational.button("Get Started"),
        Foundational.spacer(size: :lg)
      ])

      {:ok, widget} = Canonical.render(iur_element)

      assert widget.id == :content
      assert length(widget.slots.content) == 3

      # Verify each child
      [text_widget, button_widget, spacer_widget] = widget.slots.content

      assert text_widget.id == :text
      assert text_widget.props.value == "Welcome!"

      assert button_widget.id == :button
      assert button_widget.props.label == "Get Started"

      assert spacer_widget.id == :spacer
      assert spacer_widget.props.size == :lg
    end

    test "label with htmlFor association renders correctly" do
      iur_element = Foundational.label("Email", label: %{html_for: "email_input"})
      {:ok, widget} = Canonical.render(iur_element)

      assert {:safe, html} = NativeFoundational.Label.render_server(widget.props, [])
      assert String.contains?(html, "for=\"email_input\"")
      assert String.contains?(html, "Email")
    end
  end

  describe "frontend rendering map examples" do
    test "text widget produces correct frontend map" do
      {:ok, widget} = Widget.create(NativeFoundational.Text, %{value: "Test"})
      frontend_map = NativeFoundational.Text.render_frontend(widget.props, [])

      assert frontend_map.type == "text"
      assert frontend_map.value == "Test"
    end

    test "button widget produces correct frontend map" do
      {:ok, widget} = Widget.create(NativeFoundational.Button, %{label: "Click"})
      frontend_map = NativeFoundational.Button.render_frontend(widget.props, [])

      assert frontend_map.type == "button"
      assert frontend_map.label == "Click"
    end

    test "canonical path produces same frontend maps" do
      iur_text = Foundational.text("Hello")
      {:ok, canonical_widget} = Canonical.render(iur_text)
      canonical_frontend = NativeFoundational.Text.render_frontend(canonical_widget.props, [])

      {:ok, native_widget} = Widget.create(NativeFoundational.Text, %{value: "Hello"})
      native_frontend = NativeFoundational.Text.render_frontend(native_widget.props, [])

      assert canonical_frontend == native_frontend
    end
  end

  describe "error handling examples" do
    test "canonical renderer returns actionable error for unsupported type" do
      unsupported_element = %UnifiedIUR.Element{
        type: :widget,
        kind: :custom_widget,
        id: nil,
        metadata: %{},
        attributes: %{},
        children: []
      }

      assert {:error, {:unsupported_widget_kind, :custom_widget}} =
               Canonical.render(unsupported_element)
    end

    test "canonical renderer returns actionable error for unsupported element type" do
      unsupported_element = %UnifiedIUR.Element{
        type: :unknown_type,
        kind: :text,
        id: nil,
        metadata: %{},
        attributes: %{},
        children: []
      }

      assert {:error, {:unsupported_element_type, :unknown_type}} =
               Canonical.render(unsupported_element)
    end
  end
end
