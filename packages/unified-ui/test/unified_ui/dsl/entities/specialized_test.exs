defmodule UnifiedUi.Dsl.Entities.SpecializedTest do
  use ExUnit.Case, async: true

  alias UnifiedUi.Dsl.Entities.Specialized
  alias UnifiedUi.Widgets.{Canvas, Command, CommandPalette}

  describe "canvas_entity/0" do
    test "returns a valid canvas entity definition" do
      entity = Specialized.canvas_entity()

      assert %Spark.Dsl.Entity{name: :canvas} = entity
      assert entity.target == Canvas
      assert entity.args == [:id]
      assert Keyword.has_key?(entity.schema, :width)
      assert Keyword.has_key?(entity.schema, :height)
      assert Keyword.has_key?(entity.schema, :draw)
      assert Keyword.has_key?(entity.schema, :on_click)
      assert Keyword.has_key?(entity.schema, :on_hover)
    end
  end

  describe "command_entity/0" do
    test "returns a valid command entity definition" do
      entity = Specialized.command_entity()

      assert %Spark.Dsl.Entity{name: :command} = entity
      assert entity.target == Command
      assert entity.args == [:id, :label]
      assert Keyword.has_key?(entity.schema, :description)
      assert Keyword.has_key?(entity.schema, :shortcut)
      assert Keyword.has_key?(entity.schema, :keywords)
      assert Keyword.has_key?(entity.schema, :disabled)
    end
  end

  describe "command_palette_entity/0" do
    test "returns a valid command_palette entity definition" do
      entity = Specialized.command_palette_entity()

      assert %Spark.Dsl.Entity{name: :command_palette} = entity
      assert entity.target == CommandPalette
      assert entity.args == [:id, :commands]
      assert Keyword.has_key?(entity.schema, :placeholder)
      assert Keyword.has_key?(entity.schema, :trigger_shortcut)
      assert Keyword.has_key?(entity.schema, :on_select)
      assert [cmds: nested] = entity.entities
      assert Enum.any?(nested, &(&1.name == :command))
    end
  end

  describe "specialized widget structs" do
    test "canvas and command_palette implement UnifiedIUR.Element metadata" do
      canvas = %Canvas{id: :chart_canvas, width: 120, height: 30, on_click: :canvas_clicked}

      command_palette = %CommandPalette{
        id: :cmd_palette,
        commands: [%Command{id: :open, label: "Open File"}],
        on_select: :command_selected
      }

      canvas_meta = UnifiedIUR.Element.metadata(canvas)
      command_palette_meta = UnifiedIUR.Element.metadata(command_palette)

      assert canvas_meta.type == :canvas
      assert canvas_meta.id == :chart_canvas
      assert canvas_meta.width == 120
      assert canvas_meta.height == 30
      assert canvas_meta.on_click == :canvas_clicked

      assert command_palette_meta.type == :command_palette
      assert command_palette_meta.id == :cmd_palette
      assert command_palette_meta.on_select == :command_selected
      assert [%Command{id: :open}] = UnifiedIUR.Element.children(command_palette)
    end
  end

  describe "drawing context behaviour" do
    test "noop drawing context implements all callbacks" do
      noop = UnifiedUi.Widgets.DrawingContext.Noop

      assert :ok == noop.draw_text("hello", 1, 2)
      assert :ok == noop.draw_line(0, 0, 10, 10, [])
      assert :ok == noop.draw_rect(1, 1, 20, 10)
      assert :ok == noop.clear()
    end
  end
end
