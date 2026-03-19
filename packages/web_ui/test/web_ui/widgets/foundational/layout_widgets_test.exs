defmodule WebUi.Widgets.Foundational.LayoutWidgetsTest do
  use ExUnit.Case

  doctest WebUi.Widgets.Foundational.Separator
  doctest WebUi.Widgets.Foundational.Spacer
  doctest WebUi.Widgets.Foundational.Content

  alias WebUi.Widgets.Foundational.Separator
  alias WebUi.Widgets.Foundational.Spacer
  alias WebUi.Widgets.Foundational.Content

  describe "Separator widget" do
    test "id returns :separator" do
      assert Separator.id() == :separator
    end

    test "metadata returns correct info" do
      metadata = Separator.metadata()
      assert metadata.name == "Separator"
      assert metadata.family == :foundational
      assert metadata.version == "1.0.0"
    end

    test "props_schema is empty" do
      assert Separator.props_schema() == %{}
    end

    test "render_server returns safe HTML with hr" do
      assert {:safe, html} = Separator.render_server(%{}, [])
      assert String.contains?(html, "<hr")
      assert String.contains?(html, "webui-separator")
    end

    test "render_frontend returns correct map" do
      assert %{type: "separator"} = Separator.render_frontend(%{}, [])
    end

    test "default_state returns empty map" do
      assert Separator.default_state() == %{}
    end
  end

  describe "Spacer widget" do
    test "id returns :spacer" do
      assert Spacer.id() == :spacer
    end

    test "metadata returns correct info" do
      metadata = Spacer.metadata()
      assert metadata.name == "Spacer"
      assert metadata.family == :foundational
      assert metadata.version == "1.0.0"
    end

    test "props_schema defines size prop with default" do
      schema = Spacer.props_schema()
      assert Map.has_key?(schema, :size)
    end

    test "render_server returns safe HTML with size style" do
      assert {:safe, html} = Spacer.render_server(%{size: :lg}, [])
      assert String.contains?(html, "24px")
      assert String.contains?(html, "webui-spacer")
    end

    test "render_server uses default size when not provided" do
      assert {:safe, html} = Spacer.render_server(%{}, [])
      assert String.contains?(html, "16px")
    end

    test "render_server maps size atoms to pixels" do
      assert {:safe, html_xs} = Spacer.render_server(%{size: :xs}, [])
      assert String.contains?(html_xs, "4px")

      assert {:safe, html_sm} = Spacer.render_server(%{size: :sm}, [])
      assert String.contains?(html_sm, "8px")

      assert {:safe, html_md} = Spacer.render_server(%{size: :md}, [])
      assert String.contains?(html_md, "16px")

      assert {:safe, html_lg} = Spacer.render_server(%{size: :lg}, [])
      assert String.contains?(html_lg, "24px")
    end

    test "render_frontend returns correct map" do
      assert %{type: "spacer", size: :md} = Spacer.render_frontend(%{size: :md}, [])
    end

    test "default_state returns empty map" do
      assert Spacer.default_state() == %{}
    end
  end

  describe "Content widget" do
    test "id returns :content" do
      assert Content.id() == :content
    end

    test "metadata returns correct info" do
      metadata = Content.metadata()
      assert metadata.name == "Content"
      assert metadata.family == :foundational
      assert metadata.version == "1.0.0"
    end

    test "props_schema is empty" do
      assert Content.props_schema() == %{}
    end

    test "render_server returns safe HTML wrapper" do
      assert {:safe, html} = Content.render_server(%{}, [])
      assert String.contains?(html, "webui-content")
      assert String.contains?(html, "<div")
    end

    test "render_server includes children when provided" do
      children = [{:safe, "<span>Child 1</span>"}, {:safe, "<span>Child 2</span>"}]
      assert {:safe, html} = Content.render_server(%{}, children: children)
      assert String.contains?(html, "Child 1")
      assert String.contains?(html, "Child 2")
    end

    test "render_server handles binary children" do
      children = ["Plain text", {:safe, "<span>HTML</span>"}]
      assert {:safe, html} = Content.render_server(%{}, children: children)
      assert String.contains?(html, "Plain text")
      assert String.contains?(html, "HTML")
    end

    test "render_frontend returns correct map" do
      assert %{type: "content"} = Content.render_frontend(%{}, [])
    end

    test "default_state returns empty map" do
      assert Content.default_state() == %{}
    end
  end
end
