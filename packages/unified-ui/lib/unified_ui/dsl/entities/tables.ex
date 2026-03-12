defmodule UnifiedUi.Dsl.Entities.Tables do
  @moduledoc """
  Spark DSL Entity definitions for table widgets.

  This module defines the DSL entities for displaying tabular data:
  table (container) and column (nested definition).

  Each entity specifies:
  - Required arguments (args)
  - Optional options (schema)
  - Target struct for storing the parsed DSL data
  - Documentation for users

  ## Usage

  These entities are automatically available when using `UnifiedUi.Dsl`:

      defmodule MyApp.MyDashboard do
        use UnifiedUi.Dsl

        @users [
          %{id: 1, name: "Alice", age: 30, active: true},
          %{id: 2, name: "Bob", age: 25, active: false},
          %{id: 3, name: "Charlie", age: 35, active: true}
        ]

        ui do
          vbox do
            table :users_table, @users do
              column :id, "ID", width: 5, align: :right

              column :name, "Name",
                sortable: true,
                width: 20

              column :age, "Age",
                sortable: true,
                align: :right

              column :active, "Active",
                formatter: fn
                  true -> "✓"
                  false -> "✗"
                end
            end
          end
        end
      end
  """

  alias UnifiedIUR.Widgets

  @column_entity %Spark.Dsl.Entity{
    name: :column,
    target: Widgets.Column,
    args: [:key, :header],
    schema: [
      key: [
        type: :atom,
        doc: "The key to access data from each row.",
        required: true
      ],
      header: [
        type: :string,
        doc: "The header text to display for this column.",
        required: true
      ],
      sortable: [
        type: :boolean,
        doc: "Whether this column can be sorted.",
        required: false,
        default: true
      ],
      formatter: [
        type: {:fun, 1},
        doc: """
        Optional function to format cell values for display.
        Receives the raw value and should return a string.
        Example: fn date -> Calendar.strftime(date, "%Y-%m-%d") end
        """,
        required: false
      ],
      width: [
        type: :integer,
        doc: """
        Width of the column in characters (terminal) or percentage/pixels (desktop/web).
        If not specified, column width is auto-calculated based on content.
        """,
        required: false
      ],
      align: [
        type: {:one_of, [:left, :center, :right]},
        doc: "Text alignment within the column.",
        required: false,
        default: :left
      ]
    ],
    describe: """
    Defines a single column in a table.

    Columns specify how to extract and display data from each row.
    They can be configured with custom formatters, alignment, and width.

    ## Examples

        column :id, "ID", width: 5, align: :right

        column :name, "Name", sortable: true

        column :created_at, "Created",
          formatter: fn dt -> Calendar.strftime(dt, "%Y-%m-%d %H:%M") end
    """
  }

  @table_entity %Spark.Dsl.Entity{
    name: :table,
    target: Widgets.Table,
    args: [:id, :data],
    schema: [
      id: [
        type: :atom,
        doc: "Unique identifier for the table.",
        required: true
      ],
      data: [
        type: {:list, :any},
        doc: """
        The data to display in the table.
        Can be a list of maps, keyword lists, or structs.

        ## Examples

            # List of maps
            [%{id: 1, name: "Alice"}, %{id: 2, name: "Bob"}]

            # List of keyword lists
            [[id: 1, name: "Alice"], [id: 2, name: "Bob"]]

            # List of structs
            [%User{id: 1, name: "Alice"}, %User{id: 2, name: "Bob"}]
        """,
        required: true
      ],
      columns: [
        type: {:list, :any},
        doc: """
        List of column definitions. If not provided, columns will be
        auto-generated from the keys of the first data row.
        """,
        required: false
      ],
      selected_row: [
        type: :integer,
        doc: """
        Index of the currently selected row (0-based).
        Use -1 or nil for no selection.
        """,
        required: false
      ],
      height: [
        type: :integer,
        doc: """
        Visible height of the table in rows.
        If the data has more rows, the table becomes scrollable.
        """,
        required: false
      ],
      on_row_select: [
        type: {:or, [:atom, {:tuple, [:atom, :map]}, {:tuple, [:atom, :atom, {:list, :any}]}]},
        doc: """
        Signal to emit when a row is selected.
        Can be an atom, a tuple with payload, or an MFA tuple.
        The signal will include the row index and row data.
        """,
        required: false
      ],
      on_sort: [
        type: {:or, [:atom, {:tuple, [:atom, :map]}, {:tuple, [:atom, :atom, {:list, :any}]}]},
        doc: """
        Signal to emit when a column is sorted.
        Can be an atom, a tuple with payload, or an MFA tuple.
        The signal will include the column key and sort direction.
        """,
        required: false
      ],
      sort_column: [
        type: :atom,
        doc: "The column key to sort by.",
        required: false
      ],
      sort_direction: [
        type: {:one_of, [:asc, :desc]},
        doc: "The sort direction (:asc or :desc).",
        required: false,
        default: :asc
      ],
      style: [
        type: :keyword_list,
        doc: "Inline style as keyword list.",
        required: false
      ],
      visible: [
        type: :boolean,
        doc: "Whether the table is visible.",
        required: false,
        default: true
      ]
    ],
    entities: [
      columns: [@column_entity]
    ],
    describe: """
    A table widget for displaying tabular data.

    Tables are ideal for displaying structured data in rows and columns.
    They support sorting, selection, and scrolling for large datasets.

    ## Features

    * **Sorting**: Click column headers to sort (if sortable: true)
    * **Selection**: Click rows to select them (emits on_row_select signal)
    * **Scrolling**: Set height to enable scrolling for large datasets
    * **Formatting**: Use formatter functions to customize cell display
    * **Alignment**: Control text alignment per column

    ## Examples

        # Basic table with auto-generated columns
        table :users, @users_data

        # Table with explicit columns
        table :products, @products do
          column :id, "ID", width: 5, align: :right
          column :name, "Name", sortable: true
          column :price, "Price",
            formatter: &Money.to_string/1,
            align: :right
        end

        # Table with sorting and selection
        table :orders, @orders,
          height: 10,
          on_row_select: :order_selected,
          on_sort: :table_sorted do
          column :id, "Order #"
          column :customer, "Customer", sortable: true
          column :total, "Total", align: :right
        end
    """
  }

  @doc """
  Returns the Spark DSL entity definition for `column`.
  """
  @spec column_entity() :: Spark.Dsl.Entity.t()
  def column_entity, do: @column_entity

  @doc """
  Returns the Spark DSL entity definition for `table`.
  """
  @spec table_entity() :: Spark.Dsl.Entity.t()
  def table_entity, do: @table_entity
end
