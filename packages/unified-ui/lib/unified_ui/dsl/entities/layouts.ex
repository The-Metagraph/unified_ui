defmodule UnifiedUi.Dsl.Entities.Layouts do
  @moduledoc """
  Spark DSL Entity definitions for layout containers.

  This module defines the DSL entities for layout containers:
  - vbox (vertical box)
  - hbox (horizontal box)
  - grid (track-based layout)
  - stack (single-active-child layout)
  - zbox (absolute-positioned layering layout)

  Each entity specifies:
  - Nested entity types (children)
  - Optional options (schema)
  - Target struct for storing the parsed DSL data
  - Documentation for users

  ## Usage

  These entities are automatically available when using `UnifiedUi.Dsl`:

    defmodule MyApp.MyScreen do
      use UnifiedUi.Dsl

      ui do
        vbox do
          text "Welcome"
          hbox do
            button "OK"
            button "Cancel"
          end
        end
      end
    end

  ## Nesting

  Layouts can contain other layouts and widgets, creating complex
  hierarchical UI structures.
  """

  alias UnifiedIUR.Layouts
  alias UnifiedUi.Widgets.{Grid, Stack, ZBox}

  @state_ref_type {:tuple, [:atom, :atom]}

  alias UnifiedUi.Dsl.Entities.{
    Containers,
    DataViz,
    DialogFeedback,
    InputWidgets,
    Monitoring,
    Navigation,
    Specialized,
    Tables,
    Widgets
  }

  @layout_children_base [
    Widgets.button_entity(),
    Widgets.text_entity(),
    Widgets.label_entity(),
    Widgets.text_input_entity(),
    DataViz.gauge_entity(),
    DataViz.sparkline_entity(),
    DataViz.bar_chart_entity(),
    DataViz.line_chart_entity(),
    Tables.table_entity(),
    Navigation.menu_entity(),
    Navigation.context_menu_entity(),
    Navigation.tabs_entity(),
    Navigation.tree_view_entity(),
    DialogFeedback.dialog_entity(),
    DialogFeedback.alert_dialog_entity(),
    DialogFeedback.toast_entity(),
    InputWidgets.pick_list_entity(),
    InputWidgets.form_builder_entity(),
    Containers.viewport_entity(),
    Containers.split_pane_entity(),
    Specialized.canvas_entity(),
    Specialized.command_palette_entity(),
    Monitoring.log_viewer_entity(),
    Monitoring.stream_widget_entity(),
    Monitoring.process_monitor_entity()
  ]

  @grid_entity %Spark.Dsl.Entity{
    name: :grid,
    target: Grid,
    args: [:children],
    schema: [
      children: [
        type: {:list, :any},
        doc: "Grid child elements.",
        required: false,
        default: []
      ],
      id: [
        type: :atom,
        doc: "Unique identifier for the grid layout.",
        required: false
      ],
      columns: [
        type: {:list, :any},
        doc: "Grid column track definitions (integer, \"1fr\", \"auto\").",
        required: false,
        default: [1]
      ],
      rows: [
        type: {:list, :any},
        doc: "Grid row track definitions (integer, \"1fr\", \"auto\").",
        required: false,
        default: []
      ],
      gap: [
        type: :integer,
        doc: "Gap between tracks.",
        required: false,
        default: 0
      ],
      style: [
        type: :keyword_list,
        doc: "Inline style as keyword list.",
        required: false
      ],
      visible: [
        type: {:or, [:boolean, @state_ref_type]},
        doc: "Whether the grid is visible, or `{:state, :key}`.",
        required: false,
        default: true
      ]
    ],
    describe: """
    A grid layout container with configurable columns, rows, and gap.
    """
  }

  @stack_entity %Spark.Dsl.Entity{
    name: :stack,
    target: Stack,
    args: [:id, :children],
    schema: [
      id: [
        type: :atom,
        doc: "Unique identifier for the stack layout.",
        required: true
      ],
      children: [
        type: {:list, :any},
        doc: "Stack child elements.",
        required: false,
        default: []
      ],
      active_index: [
        type: :integer,
        doc: "Zero-based index of the active child.",
        required: false,
        default: 0
      ],
      transition: [
        type: {:or, [:atom, :string]},
        doc: "Transition name used when switching active child.",
        required: false
      ],
      style: [
        type: :keyword_list,
        doc: "Inline style as keyword list.",
        required: false
      ],
      visible: [
        type: {:or, [:boolean, @state_ref_type]},
        doc: "Whether the stack is visible, or `{:state, :key}`.",
        required: false,
        default: true
      ]
    ],
    describe: """
    A stack layout that renders only the active child by index.
    """
  }

  @zbox_entity %Spark.Dsl.Entity{
    name: :zbox,
    target: ZBox,
    args: [:id, :children],
    schema: [
      id: [
        type: :atom,
        doc: "Unique identifier for the zbox layout.",
        required: true
      ],
      children: [
        type: {:list, :any},
        doc: "ZBox child elements.",
        required: false,
        default: []
      ],
      positions: [
        type: :map,
        doc: "Absolute positions keyed by child index or child id.",
        required: false,
        default: %{}
      ],
      style: [
        type: :keyword_list,
        doc: "Inline style as keyword list.",
        required: false
      ],
      visible: [
        type: {:or, [:boolean, @state_ref_type]},
        doc: "Whether the zbox is visible, or `{:state, :key}`.",
        required: false,
        default: true
      ]
    ],
    describe: """
    A layered layout container with absolute positioning metadata.
    """
  }

  @layout_children @layout_children_base ++ [@grid_entity, @stack_entity, @zbox_entity]

  @vbox_entity %Spark.Dsl.Entity{
    name: :vbox,
    target: Layouts.VBox,
    recursive_as: :children,
    args: [],
    schema: [
      id: [
        type: :atom,
        doc: "Unique identifier for the layout.",
        required: false
      ],
      spacing: [
        type: :integer,
        doc: "Space between children.",
        required: false,
        default: 0
      ],
      padding: [
        type: :integer,
        doc: "Internal padding around all children.",
        required: false
      ],
      align_items: [
        type: {:one_of, [:start, :center, :end, :stretch]},
        doc: "Horizontal (cross-axis) alignment of children.",
        required: false
      ],
      justify_content: [
        type: {:one_of, [:start, :center, :end, :stretch, :space_between, :space_around]},
        doc: "Vertical (main-axis) distribution of children.",
        required: false
      ],
      style: [
        type: :keyword_list,
        doc: "Inline style as keyword list.",
        required: false
      ],
      visible: [
        type: {:or, [:boolean, @state_ref_type]},
        doc: "Whether the layout is visible, or `{:state, :key}`.",
        required: false,
        default: true
      ]
    ],
    entities: [
      children: @layout_children
    ],
    describe: """
    A vertical box layout that arranges children top to bottom.

    VBox is the most common layout for stacking widgets vertically.
    Children can be other layouts or widgets.
    """
  }

  @hbox_entity %Spark.Dsl.Entity{
    name: :hbox,
    target: Layouts.HBox,
    recursive_as: :children,
    args: [],
    schema: [
      id: [
        type: :atom,
        doc: "Unique identifier for the layout.",
        required: false
      ],
      spacing: [
        type: :integer,
        doc: "Space between children.",
        required: false,
        default: 0
      ],
      padding: [
        type: :integer,
        doc: "Internal padding around all children.",
        required: false
      ],
      align_items: [
        type: {:one_of, [:start, :center, :end, :stretch]},
        doc: "Vertical (cross-axis) alignment of children.",
        required: false
      ],
      justify_content: [
        type: {:one_of, [:start, :center, :end, :stretch, :space_between, :space_around]},
        doc: "Horizontal (main-axis) distribution of children.",
        required: false
      ],
      style: [
        type: :keyword_list,
        doc: "Inline style as keyword list.",
        required: false
      ],
      visible: [
        type: {:or, [:boolean, @state_ref_type]},
        doc: "Whether the layout is visible, or `{:state, :key}`.",
        required: false,
        default: true
      ]
    ],
    entities: [
      children: @layout_children
    ],
    describe: """
    A horizontal box layout that arranges children left to right.

    HBox is commonly used for form rows, button bars, and any
    horizontal arrangement of widgets. Children can be other layouts
    or widgets.
    """
  }

  @doc false
  @spec vbox_entity() :: Spark.Dsl.Entity.t()
  def vbox_entity, do: @vbox_entity

  @doc false
  @spec hbox_entity() :: Spark.Dsl.Entity.t()
  def hbox_entity, do: @hbox_entity

  @doc false
  @spec grid_entity() :: Spark.Dsl.Entity.t()
  def grid_entity, do: @grid_entity

  @doc false
  @spec stack_entity() :: Spark.Dsl.Entity.t()
  def stack_entity, do: @stack_entity

  @doc false
  @spec zbox_entity() :: Spark.Dsl.Entity.t()
  def zbox_entity, do: @zbox_entity
end
