defmodule UnifiedUi.Dsl.Entities.ContainersTest do
  use ExUnit.Case, async: true

  alias UnifiedUi.Dsl.Entities.Containers
  alias UnifiedUi.Widgets.{Viewport, SplitPane}

  describe "viewport_entity/0" do
    test "returns a valid viewport entity definition" do
      entity = Containers.viewport_entity()

      assert %Spark.Dsl.Entity{name: :viewport} = entity
      assert entity.target == Viewport
      assert entity.args == [:id, :content]
      assert entity.recursive_as == nil
      assert entity.entities == []
      assert Keyword.has_key?(entity.schema, :width)
      assert Keyword.has_key?(entity.schema, :height)
      assert Keyword.has_key?(entity.schema, :scroll_x)
      assert Keyword.has_key?(entity.schema, :scroll_y)
      assert Keyword.has_key?(entity.schema, :on_scroll)
      assert Keyword.has_key?(entity.schema, :border)
    end
  end

  describe "split_pane_entity/0" do
    test "returns a valid split pane entity definition" do
      entity = Containers.split_pane_entity()

      assert %Spark.Dsl.Entity{name: :split_pane} = entity
      assert entity.target == SplitPane
      assert entity.args == [:id, :panes]
      assert entity.recursive_as == nil
      assert entity.entities == []
      assert Keyword.has_key?(entity.schema, :orientation)
      assert Keyword.has_key?(entity.schema, :initial_split)
      assert Keyword.has_key?(entity.schema, :min_size)
      assert Keyword.has_key?(entity.schema, :on_resize_change)
    end
  end

  describe "container widget structs" do
    test "viewport and split pane implement UnifiedIUR.Element metadata" do
      viewport = %Viewport{id: :vp, width: 80, height: 20, scroll_x: 1, scroll_y: 2}
      split_pane = %SplitPane{id: :sp, orientation: :vertical, initial_split: 60, min_size: 20}

      viewport_meta = UnifiedIUR.Element.metadata(viewport)
      split_meta = UnifiedIUR.Element.metadata(split_pane)

      assert viewport_meta.type == :viewport
      assert viewport_meta.id == :vp
      assert viewport_meta.width == 80
      assert viewport_meta.height == 20
      assert viewport_meta.scroll_x == 1
      assert viewport_meta.scroll_y == 2

      assert split_meta.type == :split_pane
      assert split_meta.id == :sp
      assert split_meta.orientation == :vertical
      assert split_meta.initial_split == 60
      assert split_meta.min_size == 20
    end
  end
end
