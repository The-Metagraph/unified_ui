defmodule UnifiedUi.Dsl.Entities.Containers do
  @moduledoc """
  Spark DSL Entity definitions for container widgets.
  """

  alias UnifiedUi.Widgets.{Viewport, SplitPane}

  @viewport_entity %Spark.Dsl.Entity{
    name: :viewport,
    target: Viewport,
    args: [:id, :content],
    schema: [
      id: [
        type: :atom,
        doc: "Unique identifier for the viewport.",
        required: true
      ],
      content: [
        type: :any,
        doc: "Content rendered inside the viewport.",
        required: true
      ],
      width: [
        type: :integer,
        doc: "Viewport width in character cells/pixels depending on platform.",
        required: false
      ],
      height: [
        type: :integer,
        doc: "Viewport height in character cells/pixels depending on platform.",
        required: false
      ],
      scroll_x: [
        type: :integer,
        doc: "Horizontal scroll offset.",
        required: false,
        default: 0
      ],
      scroll_y: [
        type: :integer,
        doc: "Vertical scroll offset.",
        required: false,
        default: 0
      ],
      on_scroll: [
        type: :atom,
        doc: "Signal emitted when scroll position changes.",
        required: false
      ],
      border: [
        type: {:or, [{:one_of, [:none, :solid, :dashed, :double]}, :boolean]},
        doc: "Whether and how to render a border around the viewport.",
        required: false,
        default: :none
      ],
      style: [
        type: :keyword_list,
        doc: "Inline style as keyword list.",
        required: false
      ],
      visible: [
        type: :boolean,
        doc: "Whether the viewport is visible.",
        required: false,
        default: true
      ]
    ],
    describe: """
    A scrollable viewport container that can clip and offset its content.
    """
  }

  @split_pane_entity %Spark.Dsl.Entity{
    name: :split_pane,
    target: SplitPane,
    args: [:id, :panes],
    schema: [
      id: [
        type: :atom,
        doc: "Unique identifier for the split pane.",
        required: true
      ],
      panes: [
        type: :any,
        doc: "Two pane contents to render.",
        required: true
      ],
      orientation: [
        type: {:one_of, [:horizontal, :vertical]},
        doc: "Split direction for panes.",
        required: false,
        default: :horizontal
      ],
      initial_split: [
        type: :integer,
        doc: "Initial split percentage (0-100).",
        required: false,
        default: 50
      ],
      min_size: [
        type: :integer,
        doc: "Minimum pane size percentage.",
        required: false,
        default: 10
      ],
      on_resize_change: [
        type: :atom,
        doc: "Signal emitted when split percentage changes.",
        required: false
      ],
      style: [
        type: :keyword_list,
        doc: "Inline style as keyword list.",
        required: false
      ],
      visible: [
        type: :boolean,
        doc: "Whether the split pane is visible.",
        required: false,
        default: true
      ]
    ],
    describe: """
    A two-pane container with configurable split direction and resize metadata.
    """
  }

  @doc false
  @spec viewport_entity() :: Spark.Dsl.Entity.t()
  def viewport_entity, do: @viewport_entity

  @doc false
  @spec split_pane_entity() :: Spark.Dsl.Entity.t()
  def split_pane_entity, do: @split_pane_entity
end
