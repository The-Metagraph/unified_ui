defmodule WebUi.Renderer.CanonicalTest do
  use ExUnit.Case

  alias UnifiedIUR.Widgets.Foundational
  alias WebUi.Renderer.Canonical
  alias WebUi.Widgets.Native.Widget

  describe "render/1" do
    test "renders IUR text widget to native text widget" do
      iur_element = Foundational.text("Hello, World!")

      assert {:ok, widget} = Canonical.render(iur_element)
      assert widget.id == :text
      assert widget.props.value == "Hello, World!"
      assert widget.metadata.family == :foundational
    end

    test "renders IUR label widget to native label widget" do
      iur_element = Foundational.label("Username")

      assert {:ok, widget} = Canonical.render(iur_element)
      assert widget.id == :label
      assert widget.props.value == "Username"
      assert widget.metadata.family == :foundational
    end

    test "renders IUR label with html_for" do
      iur_element = Foundational.label("Password", label: %{html_for: "password_input"})

      assert {:ok, widget} = Canonical.render(iur_element)
      assert widget.props.html_for == "password_input"
    end

    test "renders IUR icon widget to native icon widget" do
      iur_element = Foundational.icon(:star)

      assert {:ok, widget} = Canonical.render(iur_element)
      assert widget.id == :icon
      assert widget.props.name == "star"
      assert widget.metadata.family == :foundational
    end

    test "renders IUR image widget to native image widget" do
      iur_element = Foundational.image("/photo.jpg", alt_text: "A nice photo")

      assert {:ok, widget} = Canonical.render(iur_element)
      assert widget.id == :image
      assert widget.props.source == "/photo.jpg"
      assert widget.props.alt_text == "A nice photo"
      assert widget.metadata.family == :foundational
    end

    test "renders IUR button widget to native button widget" do
      iur_element = Foundational.button("Click Me")

      assert {:ok, widget} = Canonical.render(iur_element)
      assert widget.id == :button
      assert widget.props.label == "Click Me"
      assert widget.metadata.family == :foundational
    end

    test "renders IUR link widget to native link widget" do
      iur_element = Foundational.link("Home", "/")

      assert {:ok, widget} = Canonical.render(iur_element)
      assert widget.id == :link
      assert widget.props.label == "Home"
      assert widget.props.target == "/"
      assert widget.metadata.family == :foundational
    end

    test "renders IUR separator widget to native separator widget" do
      iur_element = Foundational.separator()

      assert {:ok, widget} = Canonical.render(iur_element)
      assert widget.id == :separator
      assert widget.metadata.family == :foundational
    end

    test "renders IUR spacer widget to native spacer widget" do
      iur_element = Foundational.spacer(size: :lg)

      assert {:ok, widget} = Canonical.render(iur_element)
      assert widget.id == :spacer
      assert widget.props.size == :lg
      assert widget.metadata.family == :foundational
    end

    test "renders IUR spacer with default size" do
      iur_element = Foundational.spacer()

      assert {:ok, widget} = Canonical.render(iur_element)
      assert widget.props.size == :md
    end

    test "renders IUR content widget to native content widget" do
      iur_element = Foundational.content([Foundational.text("Child 1"), Foundational.text("Child 2")])

      assert {:ok, widget} = Canonical.render(iur_element)
      assert widget.id == :content
      assert widget.metadata.family == :foundational
      assert length(widget.slots.content) == 2
    end

    test "returns error for unsupported widget type" do
      # Create a mock element with an unsupported kind
      unsupported_element = %UnifiedIUR.Element{
        type: :widget,
        kind: :unsupported_type,
        id: nil,
        metadata: %{},
        attributes: %{},
        children: []
      }

      assert {:error, {:unsupported_widget_kind, :unsupported_type}} =
               Canonical.render(unsupported_element)
    end

    test "returns error for unsupported element kind" do
      # Create a mock element with an unsupported type
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

  describe "compare_rendering/3" do
    test "confirms native and canonical text rendering are equivalent" do
      native_props = %{value: "Hello"}
      canonical_element = Foundational.text("Hello")

      assert {:ok, :equivalent} =
               Canonical.compare_rendering(
                 WebUi.Widgets.Foundational.Text,
                 native_props,
                 canonical_element
               )
    end

    test "confirms native and canonical button rendering are equivalent" do
      native_props = %{label: "Click"}
      canonical_element = Foundational.button("Click")

      assert {:ok, :equivalent} =
               Canonical.compare_rendering(
                 WebUi.Widgets.Foundational.Button,
                 native_props,
                 canonical_element
               )
    end

  end

  describe "supported_kinds/0" do
    test "returns all foundational widget kinds" do
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

  describe "supports_kind?/1" do
    test "returns true for supported kinds" do
      assert Canonical.supports_kind?(:text)
      assert Canonical.supports_kind?(:button)
      assert Canonical.supports_kind?(:content)
    end

    test "returns false for unsupported kinds" do
      refute Canonical.supports_kind?(:unsupported)
      refute Canonical.supports_kind?(:form)
    end
  end
end
