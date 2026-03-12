defmodule UnifiedUi.Dsl.Entities.Specialized do
  @moduledoc """
  Spark DSL entity definitions for specialized widgets.

  This module defines:
  - canvas
  - command (nested)
  - command_palette
  """

  alias UnifiedUi.Widgets.{Canvas, Command, CommandPalette}

  @signal_type {:or, [:atom, {:tuple, [:atom, :map]}, {:tuple, [:atom, :atom, {:list, :any}]}]}

  @canvas_entity %Spark.Dsl.Entity{
    name: :canvas,
    target: Canvas,
    args: [:id],
    schema: [
      id: [
        type: :atom,
        doc: "Unique identifier for the canvas widget.",
        required: true
      ],
      width: [
        type: :integer,
        doc: "Canvas width in character cells or pixels depending on platform.",
        required: false
      ],
      height: [
        type: :integer,
        doc: "Canvas height in character cells or pixels depending on platform.",
        required: false
      ],
      draw: [
        type: {:fun, 1},
        doc: "Drawing function that receives a drawing context.",
        required: false
      ],
      on_click: [
        type: @signal_type,
        doc: "Signal emitted when canvas is clicked.",
        required: false
      ],
      on_hover: [
        type: @signal_type,
        doc: "Signal emitted when pointer hovers over canvas.",
        required: false
      ],
      style: [
        type: :keyword_list,
        doc: "Inline style as keyword list.",
        required: false
      ],
      visible: [
        type: :boolean,
        doc: "Whether the canvas is visible.",
        required: false,
        default: true
      ]
    ],
    describe: """
    A custom drawing widget backed by a platform-specific drawing context.
    """
  }

  @command_entity %Spark.Dsl.Entity{
    name: :command,
    target: Command,
    args: [:id, :label],
    schema: [
      id: [
        type: :atom,
        doc: "Unique identifier for the command.",
        required: true
      ],
      label: [
        type: :string,
        doc: "Command label shown in the palette.",
        required: true
      ],
      description: [
        type: :string,
        doc: "Optional command description.",
        required: false
      ],
      shortcut: [
        type: :string,
        doc: "Optional keyboard shortcut hint (for display).",
        required: false
      ],
      keywords: [
        type: {:list, :string},
        doc: "Search keywords used by command palette filtering.",
        required: false
      ],
      disabled: [
        type: :boolean,
        doc: "Whether the command is disabled.",
        required: false,
        default: false
      ],
      visible: [
        type: :boolean,
        doc: "Whether the command is visible.",
        required: false,
        default: true
      ]
    ],
    describe: """
    A single command entry that can be selected from a command palette.
    """
  }

  @command_palette_entity %Spark.Dsl.Entity{
    name: :command_palette,
    target: CommandPalette,
    args: [:id, :commands],
    schema: [
      id: [
        type: :atom,
        doc: "Unique identifier for the command palette.",
        required: true
      ],
      commands: [
        type: {:list, :any},
        doc: "List of command structs, maps, tuples, or nested command entities.",
        required: true
      ],
      placeholder: [
        type: :string,
        doc: "Input placeholder text for command search.",
        required: false,
        default: "Type a command..."
      ],
      trigger_shortcut: [
        type: :string,
        doc: "Keyboard shortcut hint used to open the command palette.",
        required: false,
        default: "cmd+k"
      ],
      on_select: [
        type: @signal_type,
        doc: "Signal emitted when a command is selected.",
        required: false
      ],
      style: [
        type: :keyword_list,
        doc: "Inline style as keyword list.",
        required: false
      ],
      visible: [
        type: :boolean,
        doc: "Whether the command palette is visible.",
        required: false,
        default: true
      ]
    ],
    entities: [
      cmds: [@command_entity]
    ],
    describe: """
    A searchable command palette for command discovery and quick actions.
    """
  }

  @doc false
  @spec canvas_entity() :: Spark.Dsl.Entity.t()
  def canvas_entity, do: @canvas_entity

  @doc false
  @spec command_entity() :: Spark.Dsl.Entity.t()
  def command_entity, do: @command_entity

  @doc false
  @spec command_palette_entity() :: Spark.Dsl.Entity.t()
  def command_palette_entity, do: @command_palette_entity
end
