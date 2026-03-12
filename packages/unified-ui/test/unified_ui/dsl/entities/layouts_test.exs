defmodule UnifiedUi.Dsl.Entities.LayoutsTest do
  @moduledoc """
  Tests for the layout DSL entities.

  These tests verify that:
  - All layout entities are defined correctly
  - Layout entities create the correct target structs
  - Layout options are validated properly
  - Required arguments are enforced
  """

  use ExUnit.Case, async: true

  alias UnifiedUi.Dsl.Entities.Layouts, as: LayoutEntities
  alias UnifiedIUR.Layouts
  alias UnifiedUi.Widgets.{Grid, Stack, ZBox}

  describe "vbox_entity/0" do
    test "returns a valid Spark.Dsl.Entity" do
      entity = LayoutEntities.vbox_entity()

      assert %Spark.Dsl.Entity{name: :vbox} = entity
      assert entity.target == Layouts.VBox
    end

    test "has no positional args (children via do block)" do
      entity = LayoutEntities.vbox_entity()
      assert entity.args == []
    end

    test "has optional id option" do
      entity = LayoutEntities.vbox_entity()

      id_schema = Keyword.get(entity.schema, :id)
      assert id_schema != nil
      assert Keyword.get(id_schema, :required) == false
    end

    test "has spacing option with default" do
      entity = LayoutEntities.vbox_entity()

      spacing_schema = Keyword.get(entity.schema, :spacing)
      assert spacing_schema != nil
      assert Keyword.get(spacing_schema, :default) == 0
    end

    test "has padding option" do
      entity = LayoutEntities.vbox_entity()

      padding_schema = Keyword.get(entity.schema, :padding)
      assert padding_schema != nil
      assert Keyword.get(padding_schema, :required) == false
    end

    test "has align_items option with correct values" do
      entity = LayoutEntities.vbox_entity()

      align_items_schema = Keyword.get(entity.schema, :align_items)
      assert align_items_schema != nil

      assert {:one_of, [:start, :center, :end, :stretch]} = Keyword.get(align_items_schema, :type)
    end

    test "has justify_content option with correct values" do
      entity = LayoutEntities.vbox_entity()

      justify_content_schema = Keyword.get(entity.schema, :justify_content)
      assert justify_content_schema != nil

      assert {:one_of, [:start, :center, :end, :stretch, :space_between, :space_around]} =
               Keyword.get(justify_content_schema, :type)
    end

    test "has style option" do
      entity = LayoutEntities.vbox_entity()

      style_schema = Keyword.get(entity.schema, :style)
      assert style_schema != nil
      assert Keyword.get(style_schema, :type) == :keyword_list
    end

    test "has visible option with default" do
      entity = LayoutEntities.vbox_entity()

      visible_schema = Keyword.get(entity.schema, :visible)
      assert visible_schema != nil
      assert Keyword.get(visible_schema, :default) == true
    end

    test "supports state references for visible" do
      entity = LayoutEntities.vbox_entity()

      assert {:or, [:boolean, {:tuple, [:atom, :atom]}]} ==
               entity.schema |> Keyword.fetch!(:visible) |> Keyword.fetch!(:type)
    end
  end

  describe "hbox_entity/0" do
    test "returns a valid Spark.Dsl.Entity" do
      entity = LayoutEntities.hbox_entity()

      assert %Spark.Dsl.Entity{name: :hbox} = entity
      assert entity.target == Layouts.HBox
    end

    test "has no positional args (children via do block)" do
      entity = LayoutEntities.hbox_entity()
      assert entity.args == []
    end

    test "has optional id option" do
      entity = LayoutEntities.hbox_entity()

      id_schema = Keyword.get(entity.schema, :id)
      assert id_schema != nil
      assert Keyword.get(id_schema, :required) == false
    end

    test "has spacing option with default" do
      entity = LayoutEntities.hbox_entity()

      spacing_schema = Keyword.get(entity.schema, :spacing)
      assert spacing_schema != nil
      assert Keyword.get(spacing_schema, :default) == 0
    end

    test "has padding option" do
      entity = LayoutEntities.hbox_entity()

      padding_schema = Keyword.get(entity.schema, :padding)
      assert padding_schema != nil
      assert Keyword.get(padding_schema, :required) == false
    end

    test "has align_items option with correct values" do
      entity = LayoutEntities.hbox_entity()

      align_items_schema = Keyword.get(entity.schema, :align_items)
      assert align_items_schema != nil

      assert {:one_of, [:start, :center, :end, :stretch]} = Keyword.get(align_items_schema, :type)
    end

    test "has justify_content option with correct values" do
      entity = LayoutEntities.hbox_entity()

      justify_content_schema = Keyword.get(entity.schema, :justify_content)
      assert justify_content_schema != nil

      assert {:one_of, [:start, :center, :end, :stretch, :space_between, :space_around]} =
               Keyword.get(justify_content_schema, :type)
    end

    test "has style option" do
      entity = LayoutEntities.hbox_entity()

      style_schema = Keyword.get(entity.schema, :style)
      assert style_schema != nil
      assert Keyword.get(style_schema, :type) == :keyword_list
    end

    test "has visible option with default" do
      entity = LayoutEntities.hbox_entity()

      visible_schema = Keyword.get(entity.schema, :visible)
      assert visible_schema != nil
      assert Keyword.get(visible_schema, :default) == true
    end

    test "supports state references for visible" do
      entity = LayoutEntities.hbox_entity()

      assert {:or, [:boolean, {:tuple, [:atom, :atom]}]} ==
               entity.schema |> Keyword.fetch!(:visible) |> Keyword.fetch!(:type)
    end
  end

  describe "grid_entity/0" do
    test "returns a valid Spark.Dsl.Entity" do
      entity = LayoutEntities.grid_entity()

      assert %Spark.Dsl.Entity{name: :grid} = entity
      assert entity.target == Grid
      assert entity.args == [:children]
      assert Keyword.has_key?(entity.schema, :children)
      assert Keyword.has_key?(entity.schema, :id)
      assert Keyword.has_key?(entity.schema, :columns)
      assert Keyword.has_key?(entity.schema, :rows)
      assert Keyword.has_key?(entity.schema, :gap)
      assert Keyword.has_key?(entity.schema, :style)
      assert Keyword.has_key?(entity.schema, :visible)
    end

    test "supports state references for visible" do
      entity = LayoutEntities.grid_entity()

      assert {:or, [:boolean, {:tuple, [:atom, :atom]}]} ==
               entity.schema |> Keyword.fetch!(:visible) |> Keyword.fetch!(:type)
    end
  end

  describe "stack_entity/0" do
    test "returns a valid Spark.Dsl.Entity" do
      entity = LayoutEntities.stack_entity()

      assert %Spark.Dsl.Entity{name: :stack} = entity
      assert entity.target == Stack
      assert entity.args == [:id, :children]
      assert Keyword.has_key?(entity.schema, :id)
      assert Keyword.has_key?(entity.schema, :children)
      assert Keyword.has_key?(entity.schema, :active_index)
      assert Keyword.has_key?(entity.schema, :transition)
      assert Keyword.has_key?(entity.schema, :style)
      assert Keyword.has_key?(entity.schema, :visible)
    end

    test "supports state references for visible" do
      entity = LayoutEntities.stack_entity()

      assert {:or, [:boolean, {:tuple, [:atom, :atom]}]} ==
               entity.schema |> Keyword.fetch!(:visible) |> Keyword.fetch!(:type)
    end
  end

  describe "zbox_entity/0" do
    test "returns a valid Spark.Dsl.Entity" do
      entity = LayoutEntities.zbox_entity()

      assert %Spark.Dsl.Entity{name: :zbox} = entity
      assert entity.target == ZBox
      assert entity.args == [:id, :children]
      assert Keyword.has_key?(entity.schema, :id)
      assert Keyword.has_key?(entity.schema, :children)
      assert Keyword.has_key?(entity.schema, :positions)
      assert Keyword.has_key?(entity.schema, :style)
      assert Keyword.has_key?(entity.schema, :visible)
    end

    test "supports state references for visible" do
      entity = LayoutEntities.zbox_entity()

      assert {:or, [:boolean, {:tuple, [:atom, :atom]}]} ==
               entity.schema |> Keyword.fetch!(:visible) |> Keyword.fetch!(:type)
    end
  end

  describe "IUR Layout Structs" do
    test "VBox struct can be created with all fields" do
      vbox = %Layouts.VBox{
        id: :main,
        children: [],
        spacing: 2,
        align_items: :center,
        justify_content: :space_between,
        padding: 1,
        style: %UnifiedIUR.Style{fg: :blue},
        visible: true
      }

      assert vbox.id == :main
      assert vbox.spacing == 2
      assert vbox.align_items == :center
      assert vbox.justify_content == :space_between
      assert vbox.padding == 1
      assert match?(%UnifiedIUR.Style{}, vbox.style)
      assert vbox.visible == true
    end

    test "VBox struct has correct defaults" do
      vbox = %Layouts.VBox{}

      assert vbox.id == nil
      assert vbox.children == []
      assert vbox.spacing == 0
      assert vbox.align_items == nil
      assert vbox.justify_content == nil
      assert vbox.padding == nil
      assert vbox.style == nil
      assert vbox.visible == true
    end

    test "HBox struct can be created with all fields" do
      hbox = %Layouts.HBox{
        id: :row,
        children: [],
        spacing: 3,
        align_items: :center,
        justify_content: :space_around,
        padding: 2,
        style: %UnifiedIUR.Style{bg: :white},
        visible: true
      }

      assert hbox.id == :row
      assert hbox.spacing == 3
      assert hbox.align_items == :center
      assert hbox.justify_content == :space_around
      assert hbox.padding == 2
      assert match?(%UnifiedIUR.Style{}, hbox.style)
      assert hbox.visible == true
    end

    test "HBox struct has correct defaults" do
      hbox = %Layouts.HBox{}

      assert hbox.id == nil
      assert hbox.children == []
      assert hbox.spacing == 0
      assert hbox.align_items == nil
      assert hbox.justify_content == nil
      assert hbox.padding == nil
      assert hbox.style == nil
      assert hbox.visible == true
    end

    test "VBox supports all align_items values" do
      for align <- [:start, :center, :end, :stretch] do
        vbox = %Layouts.VBox{align_items: align}
        assert vbox.align_items == align
      end
    end

    test "VBox supports all justify_content values" do
      for justify <- [:start, :center, :end, :stretch, :space_between, :space_around] do
        vbox = %Layouts.VBox{justify_content: justify}
        assert vbox.justify_content == justify
      end
    end

    test "HBox supports all align_items values" do
      for align <- [:start, :center, :end, :stretch] do
        hbox = %Layouts.HBox{align_items: align}
        assert hbox.align_items == align
      end
    end

    test "HBox supports all justify_content values" do
      for justify <- [:start, :center, :end, :stretch, :space_between, :space_around] do
        hbox = %Layouts.HBox{justify_content: justify}
        assert hbox.justify_content == justify
      end
    end

    test "Grid struct exposes metadata and children" do
      child = %UnifiedIUR.Widgets.Text{content: "A"}

      grid = %Grid{
        id: :grid_main,
        columns: [1, "2fr", "auto"],
        rows: [1, 1],
        gap: 2,
        children: [child]
      }

      assert [^child] = UnifiedIUR.Element.children(grid)

      assert %{
               type: :grid,
               id: :grid_main,
               columns: [1, "2fr", "auto"],
               rows: [1, 1],
               gap: 2
             } = UnifiedIUR.Element.metadata(grid)
    end

    test "Stack struct exposes active_index metadata" do
      child = %UnifiedIUR.Widgets.Text{content: "Active"}

      stack = %Stack{
        id: :main_stack,
        children: [child],
        active_index: 0,
        transition: :fade
      }

      assert [^child] = UnifiedIUR.Element.children(stack)

      assert %{type: :stack, id: :main_stack, active_index: 0, transition: :fade} =
               UnifiedIUR.Element.metadata(stack)
    end

    test "ZBox struct exposes positioning metadata" do
      child = %UnifiedIUR.Widgets.Text{content: "Layer"}
      positions = %{0 => %{x: 4, y: 2, z: 3}}

      zbox = %ZBox{id: :overlay, children: [child], positions: positions}

      assert [^child] = UnifiedIUR.Element.children(zbox)

      assert %{type: :zbox, id: :overlay, positions: ^positions} =
               UnifiedIUR.Element.metadata(zbox)
    end
  end

  describe "Entity Descriptions" do
    test "vbox_entity has a description" do
      entity = LayoutEntities.vbox_entity()
      assert is_binary(entity.describe)
      assert String.length(entity.describe) > 0
    end

    test "hbox_entity has a description" do
      entity = LayoutEntities.hbox_entity()
      assert is_binary(entity.describe)
      assert String.length(entity.describe) > 0
    end

    test "grid_entity has a description" do
      entity = LayoutEntities.grid_entity()
      assert is_binary(entity.describe)
      assert String.length(entity.describe) > 0
    end

    test "stack_entity has a description" do
      entity = LayoutEntities.stack_entity()
      assert is_binary(entity.describe)
      assert String.length(entity.describe) > 0
    end

    test "zbox_entity has a description" do
      entity = LayoutEntities.zbox_entity()
      assert is_binary(entity.describe)
      assert String.length(entity.describe) > 0
    end
  end

  describe "Entity Args" do
    test "vbox_entity has no positional args" do
      entity = LayoutEntities.vbox_entity()
      assert entity.args == []
    end

    test "hbox_entity has no positional args" do
      entity = LayoutEntities.hbox_entity()
      assert entity.args == []
    end

    test "grid_entity has children positional args" do
      entity = LayoutEntities.grid_entity()
      assert entity.args == [:children]
    end

    test "stack_entity has id and children positional args" do
      entity = LayoutEntities.stack_entity()
      assert entity.args == [:id, :children]
    end

    test "zbox_entity has id and children positional args" do
      entity = LayoutEntities.zbox_entity()
      assert entity.args == [:id, :children]
    end
  end
end
