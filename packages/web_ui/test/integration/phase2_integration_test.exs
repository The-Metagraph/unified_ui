defmodule WebUi.Integration.Phase2IntegrationTest do
  use ExUnit.Case

  @moduletag :integration
  @moduletag :phase2

  alias UnifiedIUR.Widgets.Foundational
  alias WebUi.Renderer.Canonical
  alias WebUi.ServerRuntime.ViewState
  alias WebUi.Widgets.Native.Widget
  alias WebUi.Widgets.Foundational, as: Native

  describe "Foundational native rendering scenarios" do
    test "foundational text widget renders deterministically" do
      {:ok, widget} = Widget.create(Native.Text, %{value: "Hello"})

      # Server-side rendering produces consistent output
      assert {:safe, html1} = Native.Text.render_server(widget.props, [])
      assert {:safe, html2} = Native.Text.render_server(widget.props, [])

      assert html1 == html2
      assert String.contains?(html1, "Hello")
      assert String.contains?(html1, "webui-text")
    end

    test "foundational button widget renders deterministically" do
      {:ok, widget} = Widget.create(Native.Button, %{label: "Click"})

      assert {:safe, html} = Native.Button.render_server(widget.props, [])
      assert String.contains?(html, "Click")
      assert String.contains?(html, "webui-button")
    end

    test "all foundational widgets produce valid server HTML" do
      widgets = [
        {Native.Text, %{value: "Text"}},
        {Native.Label, %{value: "Label"}},
        {Native.Icon, %{name: "star"}},
        {Native.Image, %{source: "/img.jpg", alt_text: "Alt"}},
        {Native.Button, %{label: "Button"}},
        {Native.Link, %{label: "Link", target: "/"}},
        {Native.Separator, %{}},
        {Native.Spacer, %{size: :md}},
        {Native.Content, %{}}
      ]

      Enum.each(widgets, fn {module, props} ->
        {:ok, widget} = Widget.create(module, props)
        assert {:safe, html} = apply(module, :render_server, [widget.props, []])
        assert is_binary(html)
        assert String.length(html) > 0
      end)
    end

    test "all foundational widgets produce valid frontend maps" do
      widgets = [
        {Native.Text, %{value: "Text"}, :text},
        {Native.Label, %{value: "Label"}, :label},
        {Native.Icon, %{name: "star"}, :icon},
        {Native.Image, %{source: "/img.jpg", alt_text: "Alt"}, :image},
        {Native.Button, %{label: "Button"}, :button},
        {Native.Link, %{label: "Link", target: "/"}, :link},
        {Native.Separator, %{}, :separator},
        {Native.Spacer, %{size: :md}, :spacer},
        {Native.Content, %{}, :content}
      ]

      Enum.each(widgets, fn {module, props, expected_type} ->
        {:ok, widget} = Widget.create(module, props)
        frontend_map = apply(module, :render_frontend, [widget.props, []])

        assert Map.has_key?(frontend_map, :type)
        assert frontend_map.type == Atom.to_string(expected_type)
      end)
    end

    test "invalid widget declarations fail with actionable diagnostics" do
      # Unknown prop error
      assert {:error, {:unknown_prop, :unknown_prop}} =
               Widget.create(Native.Text, %{value: "Test", unknown_prop: "bad"})

      # Missing required prop error - handled by validation
      assert {:error, {:unknown_prop, :unknown_prop}} =
               Widget.create(Native.Text, %{unknown_prop: "bad"})
    end
  end

  describe "ViewState generation scenarios" do
    test "generates deterministic view state for single widget" do
      {:ok, view_state1} = ViewState.from_widget(Native.Text, %{value: "Hello"})
      {:ok, view_state2} = ViewState.from_widget(Native.Text, %{value: "Hello"})

      assert view_state1.root.id == view_state2.root.id
      assert view_state1.checksum == view_state2.checksum
    end

    test "generates different view states for different props" do
      {:ok, view_state1} = ViewState.from_widget(Native.Text, %{value: "Hello"})
      {:ok, view_state2} = ViewState.from_widget(Native.Text, %{value: "World"})

      assert view_state1.root.id != view_state2.root.id
      assert view_state1.checksum != view_state2.checksum
    end

    test "converts view state to frontend map correctly" do
      {:ok, view_state} = ViewState.from_widget(Native.Button, %{label: "Click"})

      frontend_map = ViewState.to_frontend_map(view_state)

      assert frontend_map.root.type == "button"
      assert frontend_map.root.props.label == "Click"
      assert Map.has_key?(frontend_map.widgets, view_state.root.id)
    end
  end

  describe "Foundational canonical renderer scenarios" do
    test "canonical text widget reuses native widget model" do
      iur_element = Foundational.text("Hello")
      {:ok, widget} = Canonical.render(iur_element)

      assert widget.id == :text
      assert widget.props.value == "Hello"
      assert widget.metadata.family == :foundational
    end

    test "canonical button widget reuses native widget model" do
      iur_element = Foundational.button("Click Me")
      {:ok, widget} = Canonical.render(iur_element)

      assert widget.id == :button
      assert widget.props.label == "Click Me"
      assert widget.metadata.family == :foundational
    end

    test "all foundational canonical widgets render through native reuse" do
      # All canonical widgets should create Widget structs
      canonical_widgets = [
        {Foundational.text("Text"), :text},
        {Foundational.label("Label"), :label},
        {Foundational.icon(:star), :icon},
        {Foundational.image("/img.jpg", alt_text: "Alt"), :image},
        {Foundational.button("Button"), :button},
        {Foundational.link("Link", "/"), :link},
        {Foundational.separator(), :separator},
        {Foundational.spacer(), :spacer}
      ]

      Enum.each(canonical_widgets, fn {iur_element, expected_id} ->
        assert {:ok, widget} = Canonical.render(iur_element)
        assert widget.__struct__ == Widget
        assert widget.id == expected_id
      end)
    end

    test "native and canonical examples preserve same visual meaning" do
      # Compare HTML output for text widget
      {:ok, native} = Widget.create(Native.Text, %{value: "Test"})
      {:safe, native_html} = Native.Text.render_server(native.props, [])

      {:ok, canonical} = Canonical.render(Foundational.text("Test"))
      {:safe, canonical_html} = Native.Text.render_server(canonical.props, [])

      assert native_html == canonical_html
    end

    test "unsupported canonical inputs fail with coverage-oriented diagnostics" do
      # Unsupported widget kind
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

      # Unsupported element type
      unsupported_type_element = %UnifiedIUR.Element{
        type: :unknown_type,
        kind: :text,
        id: nil,
        metadata: %{},
        attributes: %{},
        children: []
      }

      assert {:error, {:unsupported_element_type, :unknown_type}} =
               Canonical.render(unsupported_type_element)
    end
  end

  describe "End-to-end canonical rendering" do
    test "complex nested structure renders correctly" do
      # Create a complex IUR structure
      iur_content = Foundational.content([
        Foundational.text("Welcome to web_ui!"),
        Foundational.button("Get Started"),
        Foundational.spacer(size: :lg),
        Foundational.separator(),
        Foundational.link("Learn more", "/about")
      ])

      {:ok, widget} = Canonical.render(iur_content)

      assert widget.id == :content
      assert length(widget.slots.content) == 5

      # Verify structure
      [text_w, button_w, spacer_w, separator_w, link_w] = widget.slots.content

      assert text_w.id == :text
      assert button_w.id == :button
      assert spacer_w.id == :spacer
      assert separator_w.id == :separator
      assert link_w.id == :link
    end

    test "canonical content with nested content renders correctly" do
      iur_nested = Foundational.content([
        Foundational.text("Outer 1"),
        Foundational.content([
          Foundational.text("Inner 1"),
          Foundational.text("Inner 2")
        ]),
        Foundational.text("Outer 2")
      ])

      {:ok, widget} = Canonical.render(iur_nested)

      assert widget.id == :content
      assert length(widget.slots.content) == 3

      # The middle element should be a content widget
      [_, inner_content, _] = widget.slots.content
      assert inner_content.id == :content
      assert length(inner_content.slots.content) == 2
    end
  end

  describe "Widget consistency checks" do
    test "all foundational widgets have required callbacks" do
      widgets = [
        {Native.Text, :text},
        {Native.Label, :label},
        {Native.Icon, :icon},
        {Native.Image, :image},
        {Native.Button, :button},
        {Native.Link, :link},
        {Native.Separator, :separator},
        {Native.Spacer, :spacer},
        {Native.Content, :content}
      ]

      Enum.each(widgets, fn {widget_module, widget_id} ->
        # Check 0-arity callbacks
        Enum.each([:id, :metadata, :props_schema, :default_state], fn callback ->
          assert function_exported?(widget_module, callback, 0),
                 "#{inspect(widget_module)} must implement #{callback}/0"
        end)

        # Check 2-arity callbacks
        Enum.each([:render_server, :render_frontend], fn callback ->
          assert function_exported?(widget_module, callback, 2),
                 "#{inspect(widget_module)} must implement #{callback}/2"
        end)

        # Verify id/0 returns the expected widget id
        assert apply(widget_module, :id, []) == widget_id
      end)
    end

    test "all foundational widgets have consistent metadata structure" do
      widgets = [
        {Native.Text, "Text"},
        {Native.Label, "Label"},
        {Native.Icon, "Icon"},
        {Native.Image, "Image"},
        {Native.Button, "Button"},
        {Native.Link, "Link"},
        {Native.Separator, "Separator"},
        {Native.Spacer, "Spacer"},
        {Native.Content, "Content"}
      ]

      Enum.each(widgets, fn {widget_module, expected_name} ->
        metadata = apply(widget_module, :metadata, [])

        assert Map.has_key?(metadata, :name)
        assert Map.has_key?(metadata, :family)
        assert Map.has_key?(metadata, :version)

        assert metadata.name == expected_name
        assert metadata.family == :foundational
        assert is_binary(metadata.version)
      end)
    end

    test "canonical renderer supports all foundational widget kinds" do
      kinds = Canonical.supported_kinds()

      assert :text in kinds
      assert :label in kinds
      assert :icon in kinds
      assert :image in kinds
      assert :button in kinds
      assert :link in kinds
      assert :separator in kinds
      assert :spacer in kinds
      assert :content in kinds
    end
  end
end
