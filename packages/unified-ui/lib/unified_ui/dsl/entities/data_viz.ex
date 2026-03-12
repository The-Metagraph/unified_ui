defmodule UnifiedUi.Dsl.Entities.DataViz do
  @moduledoc """
  Spark DSL Entity definitions for data visualization widgets.

  This module defines the DSL entities for widgets that display quantitative data:
  gauge, sparkline, bar_chart, and line_chart.

  Each entity specifies:
  - Required arguments (args)
  - Optional options (schema)
  - Target struct for storing the parsed DSL data
  - Documentation for users

  ## Usage

  These entities are automatically available when using `UnifiedUi.Dsl`:

      defmodule MyApp.MyDashboard do
        use UnifiedUi.Dsl

        ui do
          vbox do
            gauge :cpu_usage, 75, min: 0, max: 100, label: "CPU Usage"

            sparkline :memory_trend, [1024, 2048, 1536, 3072, 2560],
              width: 40, height: 5, color: :cyan

            bar_chart :sales_data, [
              {"Jan", 100},
              {"Feb", 150},
              {"Mar", 200}
            ], width: 50, height: 10

            line_chart :temperature, [
              {"Mon", 20},
              {"Tue", 22},
              {"Wed", 18},
              {"Thu", 25}
            ], show_dots: true, show_area: true
          end
        end
      end
  """

  alias UnifiedIUR.Widgets

  @gauge_entity %Spark.Dsl.Entity{
    name: :gauge,
    target: Widgets.Gauge,
    args: [:id, :value],
    schema: [
      id: [
        type: :atom,
        doc: "Unique identifier for the gauge.",
        required: true
      ],
      value: [
        type: :integer,
        doc: "Current value of the gauge.",
        required: true
      ],
      min: [
        type: :integer,
        doc: "Minimum value of the gauge range.",
        required: false,
        default: 0
      ],
      max: [
        type: :integer,
        doc: "Maximum value of the gauge range.",
        required: false,
        default: 100
      ],
      label: [
        type: :string,
        doc: "Optional label to display with the gauge.",
        required: false
      ],
      width: [
        type: :integer,
        doc: "Width of the gauge in characters (terminal) or pixels (desktop/web).",
        required: false
      ],
      height: [
        type: :integer,
        doc: "Height of the gauge in characters (terminal) or pixels (desktop/web).",
        required: false
      ],
      color_zones: [
        type: :keyword_list,
        doc: """
        Optional color zones as keyword list: [{low, color}, {high, color}].
        Example: [0 => :red, 50 => :yellow, 80 => :green]
        """,
        required: false
      ],
      style: [
        type: :keyword_list,
        doc: "Inline style as keyword list.",
        required: false
      ],
      visible: [
        type: :boolean,
        doc: "Whether the gauge is visible.",
        required: false,
        default: true
      ]
    ],
    describe: """
    A gauge widget for displaying a value within a range.

    Gauges are useful for showing progress, percentage completion,
    or any value that exists within a defined range. They can be
    configured with color zones to indicate different levels
    (e.g., red for low, yellow for medium, green for high).

    ## Examples

        gauge :cpu, 75, min: 0, max: 100, label: "CPU %"

        gauge :storage, 45, min: 0, max: 100,
          color_zones: [0 => :red, 20 => :yellow, 70 => :green]
    """
  }

  @sparkline_entity %Spark.Dsl.Entity{
    name: :sparkline,
    target: Widgets.Sparkline,
    args: [:id, :data],
    schema: [
      id: [
        type: :atom,
        doc: "Unique identifier for the sparkline.",
        required: true
      ],
      data: [
        type: {:list, :integer},
        doc: "List of numeric values to display as a sparkline.",
        required: true
      ],
      width: [
        type: :integer,
        doc: "Width of the sparkline in characters (terminal) or pixels (desktop/web).",
        required: false
      ],
      height: [
        type: :integer,
        doc: "Height of the sparkline in characters (terminal) or pixels (desktop/web).",
        required: false
      ],
      color: [
        type: :atom,
        doc: "Color for the sparkline line.",
        required: false
      ],
      show_dots: [
        type: :boolean,
        doc: "Whether to show dots at each data point.",
        required: false,
        default: false
      ],
      show_area: [
        type: :boolean,
        doc: "Whether to fill the area under the line.",
        required: false,
        default: false
      ],
      style: [
        type: :keyword_list,
        doc: "Inline style as keyword list.",
        required: false
      ],
      visible: [
        type: :boolean,
        doc: "Whether the sparkline is visible.",
        required: false,
        default: true
      ]
    ],
    describe: """
    A sparkline widget for displaying trend data in a compact format.

    Sparklines are small, word-sized graphs that provide a quick
    visual representation of quantitative data over time. They're
    ideal for showing trends in dashboards, tables, and summary views.

    ## Examples

        sparkline :cpu_trend, [10, 25, 20, 35, 30, 45, 40],
          width: 30, height: 5, color: :cyan

        sparkline :memory, [1024, 2048, 1536, 3072],
          show_dots: true, show_area: true
    """
  }

  @bar_chart_entity %Spark.Dsl.Entity{
    name: :bar_chart,
    target: Widgets.BarChart,
    args: [:id, :data],
    schema: [
      id: [
        type: :atom,
        doc: "Unique identifier for the bar chart.",
        required: true
      ],
      data: [
        type: {:list, {:tuple, [:string, :integer]}},
        doc: """
        List of {label, value} tuples for the bars.
        Example: [{"Jan", 100}, {"Feb", 150}, {"Mar", 200}]
        """,
        required: true
      ],
      width: [
        type: :integer,
        doc: "Width of the bar chart in characters (terminal) or pixels (desktop/web).",
        required: false
      ],
      height: [
        type: :integer,
        doc: "Height of the bar chart in characters (terminal) or pixels (desktop/web).",
        required: false
      ],
      orientation: [
        type: {:one_of, [:horizontal, :vertical]},
        doc: "Orientation of the bars.",
        required: false,
        default: :horizontal
      ],
      show_labels: [
        type: :boolean,
        doc: "Whether to show labels on the bars.",
        required: false,
        default: true
      ],
      style: [
        type: :keyword_list,
        doc: "Inline style as keyword list.",
        required: false
      ],
      visible: [
        type: :boolean,
        doc: "Whether the bar chart is visible.",
        required: false,
        default: true
      ]
    ],
    describe: """
    A bar chart widget for displaying categorical data comparison.

    Bar charts are ideal for comparing values across different categories.
    They can be oriented horizontally or vertically depending on the
    data and available space.

    ## Examples

        bar_chart :monthly_sales, [
          {"Jan", 100},
          {"Feb", 150},
          {"Mar", 200}
        ], orientation: :horizontal

        bar_chart :department_counts, [
          {"Engineering", 25},
          {"Sales", 15},
          {"Marketing", 10}
        ], orientation: :vertical, show_labels: true
    """
  }

  @line_chart_entity %Spark.Dsl.Entity{
    name: :line_chart,
    target: Widgets.LineChart,
    args: [:id, :data],
    schema: [
      id: [
        type: :atom,
        doc: "Unique identifier for the line chart.",
        required: true
      ],
      data: [
        type: {:list, {:tuple, [:string, :integer]}},
        doc: """
        List of {label, value} tuples for the data points.
        Example: [{"Mon", 20}, {"Tue", 22}, {"Wed", 18}, {"Thu", 25}]
        """,
        required: true
      ],
      width: [
        type: :integer,
        doc: "Width of the line chart in characters (terminal) or pixels (desktop/web).",
        required: false
      ],
      height: [
        type: :integer,
        doc: "Height of the line chart in characters (terminal) or pixels (desktop/web).",
        required: false
      ],
      show_dots: [
        type: :boolean,
        doc: "Whether to show dots at each data point.",
        required: false,
        default: true
      ],
      show_area: [
        type: :boolean,
        doc: "Whether to fill the area under the line.",
        required: false,
        default: false
      ],
      style: [
        type: :keyword_list,
        doc: "Inline style as keyword list.",
        required: false
      ],
      visible: [
        type: :boolean,
        doc: "Whether the line chart is visible.",
        required: false,
        default: true
      ]
    ],
    describe: """
    A line chart widget for displaying time series or sequential data.

    Line charts are ideal for showing trends over time or sequential data.
    They connect data points with lines, making it easy to see patterns
    and changes in values.

    ## Examples

        line_chart :temperature, [
          {"Mon", 20},
          {"Tue", 22},
          {"Wed", 18},
          {"Thu", 25}
        ], show_dots: true

        line_chart :revenue, [
          {"Q1", 1000},
          {"Q2", 1500},
          {"Q3", 1300},
          {"Q4", 2000}
        ], show_area: true, show_dots: false
    """
  }

  @doc """
  Returns the Spark DSL entity definition for `gauge`.
  """
  @spec gauge_entity() :: Spark.Dsl.Entity.t()
  def gauge_entity, do: @gauge_entity

  @doc """
  Returns the Spark DSL entity definition for `sparkline`.
  """
  @spec sparkline_entity() :: Spark.Dsl.Entity.t()
  def sparkline_entity, do: @sparkline_entity

  @doc """
  Returns the Spark DSL entity definition for `bar_chart`.
  """
  @spec bar_chart_entity() :: Spark.Dsl.Entity.t()
  def bar_chart_entity, do: @bar_chart_entity

  @doc """
  Returns the Spark DSL entity definition for `line_chart`.
  """
  @spec line_chart_entity() :: Spark.Dsl.Entity.t()
  def line_chart_entity, do: @line_chart_entity
end
