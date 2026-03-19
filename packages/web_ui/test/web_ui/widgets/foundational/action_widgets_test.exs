defmodule WebUi.Widgets.Foundational.ActionWidgetsTest do
  use ExUnit.Case

  doctest WebUi.Widgets.Foundational.Button
  doctest WebUi.Widgets.Foundational.Link

  alias WebUi.Widgets.Foundational.Button
  alias WebUi.Widgets.Foundational.Link

  describe "Button widget" do
    test "id returns :button" do
      assert Button.id() == :button
    end

    test "metadata returns correct info" do
      metadata = Button.metadata()
      assert metadata.name == "Button"
      assert metadata.family == :foundational
      assert metadata.version == "1.0.0"
    end

    test "props_schema defines label prop" do
      schema = Button.props_schema()
      assert Map.has_key?(schema, :label)
    end

    test "render_server returns safe HTML with label" do
      assert {:safe, html} = Button.render_server(%{label: "Click Me"}, [])
      assert String.contains?(html, "Click Me")
      assert String.contains?(html, "webui-button")
      assert String.contains?(html, "<button")
    end

    test "render_frontend returns correct map" do
      assert %{type: "button", label: "Submit"} = Button.render_frontend(%{label: "Submit"}, [])
    end

    test "default_state returns empty map" do
      assert Button.default_state() == %{}
    end

    test "handle_event returns ok with assigns unchanged" do
      assert {:ok, %{key: :value}} = Button.handle_event(:handle_click, %{}, %{key: :value})
    end
  end

  describe "Link widget" do
    test "id returns :link" do
      assert Link.id() == :link
    end

    test "metadata returns correct info" do
      metadata = Link.metadata()
      assert metadata.name == "Link"
      assert metadata.family == :foundational
      assert metadata.version == "1.0.0"
    end

    test "props_schema defines label and target props" do
      schema = Link.props_schema()
      assert Map.has_key?(schema, :label)
      assert Map.has_key?(schema, :target)
    end

    test "render_server returns safe HTML with href and label" do
      assert {:safe, html} = Link.render_server(%{label: "Home", target: "/"}, [])
      assert String.contains?(html, "href=\"/\"")
      assert String.contains?(html, "Home")
      assert String.contains?(html, "webui-link")
      assert String.contains?(html, "<a")
    end

    test "render_frontend returns correct map" do
      assert %{type: "link", label: "About", target: "/about"} =
               Link.render_frontend(%{label: "About", target: "/about"}, [])
    end

    test "default_state returns empty map" do
      assert Link.default_state() == %{}
    end
  end
end
