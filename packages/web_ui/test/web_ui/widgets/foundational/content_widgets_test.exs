defmodule WebUi.Widgets.Foundational.ContentWidgetsTest do
  use ExUnit.Case

  doctest WebUi.Widgets.Foundational.Text
  doctest WebUi.Widgets.Foundational.Label
  doctest WebUi.Widgets.Foundational.Icon
  doctest WebUi.Widgets.Foundational.Image

  alias WebUi.Widgets.Foundational.Text
  alias WebUi.Widgets.Foundational.Label
  alias WebUi.Widgets.Foundational.Icon
  alias WebUi.Widgets.Foundational.Image

  describe "Text widget" do
    test "id returns :text" do
      assert Text.id() == :text
    end

    test "metadata returns correct info" do
      metadata = Text.metadata()
      assert metadata.name == "Text"
      assert metadata.family == :foundational
      assert metadata.version == "1.0.0"
    end

    test "props_schema defines value prop" do
      schema = Text.props_schema()
      assert Map.has_key?(schema, :value)
    end

    test "render_server returns safe HTML with value" do
      assert {:safe, html} = Text.render_server(%{value: "Hello"}, [])
      assert String.contains?(html, "Hello")
      assert String.contains?(html, "webui-text")
    end

    test "render_frontend returns correct map" do
      assert %{type: "text", value: "test"} = Text.render_frontend(%{value: "test"}, [])
    end

    test "default_state returns empty map" do
      assert Text.default_state() == %{}
    end
  end

  describe "Label widget" do
    test "id returns :label" do
      assert Label.id() == :label
    end

    test "metadata returns correct info" do
      metadata = Label.metadata()
      assert metadata.name == "Label"
      assert metadata.family == :foundational
    end

    test "render_server returns safe HTML with value" do
      assert {:safe, html} = Label.render_server(%{value: "Username"}, [])
      assert String.contains?(html, "Username")
      assert String.contains?(html, "webui-label")
    end

    test "render_server includes for attribute when htmlFor is provided" do
      assert {:safe, html} = Label.render_server(%{value: "Username", html_for: "user-input"}, [])
      assert String.contains?(html, "for=\"user-input\"")
    end

    test "render_frontend returns correct map" do
      assert %{type: "label", value: "test"} = Label.render_frontend(%{value: "test"}, [])
    end
  end

  describe "Icon widget" do
    test "id returns :icon" do
      assert Icon.id() == :icon
    end

    test "metadata returns correct info" do
      metadata = Icon.metadata()
      assert metadata.name == "Icon"
      assert metadata.family == :foundational
    end

    test "render_server returns safe HTML with name" do
      assert {:safe, html} = Icon.render_server(%{name: "star"}, [])
      assert String.contains?(html, "star")
      assert String.contains?(html, "webui-icon")
    end

    test "render_frontend returns correct map" do
      assert %{type: "icon", name: "star"} = Icon.render_frontend(%{name: "star"}, [])
    end
  end

  describe "Image widget" do
    test "id returns :image" do
      assert Image.id() == :image
    end

    test "metadata returns correct info" do
      metadata = Image.metadata()
      assert metadata.name == "Image"
      assert metadata.family == :foundational
    end

    test "render_server returns safe HTML with src and alt" do
      assert {:safe, html} = Image.render_server(%{source: "/photo.jpg", alt_text: "A photo"}, [])
      assert String.contains?(html, "src=\"/photo.jpg\"")
      assert String.contains?(html, "alt=\"A photo\"")
      assert String.contains?(html, "webui-image")
    end

    test "render_frontend returns correct map" do
      assert %{type: "image", source: "/img.jpg", alt_text: "An image"} =
               Image.render_frontend(%{source: "/img.jpg", alt_text: "An image"}, [])
    end
  end
end
