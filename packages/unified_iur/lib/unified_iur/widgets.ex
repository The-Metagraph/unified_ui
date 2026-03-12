defmodule UnifiedIUR.Widgets do
  @moduledoc """
  Intermediate UI Representation (IUR) widget structs.

  Widgets are the basic building blocks of a user interface.
  Each widget is a simple data container (struct) with no business logic.
  They represent leaf nodes in the UI tree - widgets do not contain children.

  ## Widget Types

  * `Text` - Display text content
  * `Button` - Clickable button with label
  * `Label` - Label for form inputs
  * `TextInput` - Text input field for data entry
  * `Gauge` - Display a value within a range
  * `Sparkline` - Display trend data in a compact format
  * `BarChart` - Display categorical data comparison
  * `LineChart` - Display time series or sequential data
  * `Column` - Table column definition (nested within Table)
  * `Table` - Display tabular data with rows and columns
  * `MenuItem` - Single selectable menu entry
  * `Menu` - Menu container with menu items
  * `ContextMenu` - Context-triggered menu container
  * `Tab` - Single tab descriptor with optional content
  * `Tabs` - Tabs container for switching content
  * `TreeNode` - Node in a hierarchical tree
  * `TreeView` - Hierarchical tree container
  * `DialogButton` - Action button for dialog widgets
  * `Dialog` - Modal dialog container
  * `AlertDialog` - Alert dialog with severity and confirm/cancel handlers
  * `Toast` - Transient notification widget
  * `PickListOption` - Option entry used by pick list widgets
  * `PickList` - Single-select input list
  * `FormField` - Field descriptor for dynamic forms
  * `FormBuilder` - Dynamic form widget

  ## Common Fields

  All widgets have:
  * `id` - Optional unique identifier for the widget
  * `style` - Optional style struct for visual appearance
  * `visible` - Whether the widget is visible (default: true)

  ## Examples

  Create a text widget:

      iex> %Text{content: "Hello, World!", id: :greeting}
      %Text{content: "Hello, World!", id: :greeting, style: nil}

  Create a button widget:

      iex> %Button{label: "Click Me", on_click: :submit, id: :submit_btn}
      %Button{label: "Click Me", on_click: :submit, id: :submit_btn, ...}

  Create a label widget:

      iex> %Label{for: :email_input, text: "Email:"}
      %Label{for: :email_input, text: "Email:", id: nil, style: nil}

  Create a text input widget:

      iex> %TextInput{id: :email, placeholder: "user@example.com"}
      %TextInput{id: :email, placeholder: "user@example.com", type: :text, ...}
  """

  defmodule Text do
    @moduledoc """
    Text widget for displaying text content.
    """

    defstruct [:content, :id, style: nil, visible: true]

    @type t :: %__MODULE__{
            content: String.t() | nil,
            id: atom() | nil,
            style: UnifiedIUR.Style.t() | nil,
            visible: boolean()
          }
  end

  defmodule Button do
    @moduledoc """
    Button widget for user interaction.

    ## Fields

    * `label` - The text displayed on the button
    * `on_click` - Signal to emit when clicked (atom, tuple, or function reference)
    * `disabled` - Whether the button is disabled (default: false)
    * `style` - Optional `UnifiedIUR.Style` struct
    * `id` - Optional unique identifier
    * `visible` - Whether the button is visible (default: true)

    ## Signal Format

    The `on_click` field can be:
    * An atom signal name: `:submit`
    * A tuple with payload: `{:submit, %{data: "value"}}`
    * A function reference (stored for later evaluation)

    ## Examples

        iex> %Button{label: "Submit", on_click: :submit}
        %Button{label: "Submit", on_click: :submit, disabled: false, ...}

        iex> %Button{label: "Disabled", on_click: :noop, disabled: true}
        %Button{label: "Disabled", on_click: :noop, disabled: true, ...}
    """

    defstruct [:label, :on_click, :id, style: nil, disabled: false, visible: true]

    @type t :: %__MODULE__{
            label: String.t() | nil,
            on_click: atom() | {atom(), any()} | nil,
            id: atom() | nil,
            style: UnifiedIUR.Style.t() | nil,
            disabled: boolean(),
            visible: boolean()
          }
  end

  defmodule Label do
    @moduledoc """
    Label widget for form inputs.

    Associates descriptive text with a form input widget.

    ## Fields

    * `for` - The id of the input this label is for
    * `text` - The label text to display
    * `id` - Optional unique identifier
    * `style` - Optional style struct
    * `visible` - Whether the label is visible (default: true)

    ## Examples

        iex> %Label{for: :email_input, text: "Email:"}
        %Label{for: :email_input, text: "Email:", id: nil, style: nil}

        iex> %Label{for: :password, text: "Password:", id: :pwd_label}
        %Label{for: :password, text: "Password:", id: :pwd_label, ...}
    """

    defstruct [:for, :text, :id, style: nil, visible: true]

    @type t :: %__MODULE__{
            for: atom(),
            text: String.t(),
            id: atom() | nil,
            style: UnifiedIUR.Style.t() | nil,
            visible: boolean()
          }
  end

  defmodule TextInput do
    @moduledoc """
    Text input widget for user data entry.

    ## Fields

    * `id` - Required identifier for the input
    * `value` - Initial value (optional)
    * `placeholder` - Placeholder text when empty
    * `type` - Input type (:text, :password, :email, :number, :tel)
    * `on_change` - Signal to emit when value changes
    * `on_submit` - Signal to emit on Enter key
    * `form_id` - Optional form identifier for grouping inputs
    * `disabled` - Whether the input is disabled
    * `style` - Optional style struct
    * `visible` - Whether the input is visible

    ## Input Types

    * `:text` - Plain text input (default)
    * `:password` - Password input (characters hidden)
    * `:email` - Email input (with validation hint)
    * `:number` - Numeric input
    * `:tel` - Telephone number input

    ## Signal Format

    The `on_change` and `on_submit` fields can be:
    * An atom signal name: `:value_changed`
    * A tuple with payload: `{:value_changed, %{value: "new"}}`
    * A function reference (stored for later evaluation)

    ## Examples

        iex> %TextInput{id: :email, placeholder: "user@example.com"}
        %TextInput{id: :email, placeholder: "user@example.com", type: :text, ...}

        iex> %TextInput{id: :password, type: :password}
        %TextInput{id: :password, type: :password, ...}

        iex> %TextInput{id: :age, type: :number, placeholder: "Age"}
        %TextInput{id: :age, type: :number, placeholder: "Age", ...}
    """

    @type input_type :: :text | :password | :email | :number | :tel

    defstruct [
      :id,
      :value,
      :placeholder,
      :type,
      :on_change,
      :on_submit,
      :form_id,
      :disabled,
      :style,
      visible: true
    ]

    @type t :: %__MODULE__{
            id: atom(),
            value: String.t() | nil,
            placeholder: String.t() | nil,
            type: input_type(),
            on_change: atom() | {atom(), any()} | nil,
            on_submit: atom() | {atom(), any()} | nil,
            form_id: atom() | nil,
            disabled: boolean(),
            style: UnifiedIUR.Style.t() | nil,
            visible: boolean()
          }
  end

  defmodule Gauge do
    @moduledoc """
    Gauge widget for displaying a value within a range.

    ## Fields

    * `id` - Required identifier for the gauge
    * `value` - Current value of the gauge
    * `min` - Minimum value of the range (default: 0)
    * `max` - Maximum value of the range (default: 100)
    * `label` - Optional label to display with the gauge
    * `width` - Width of the gauge
    * `height` - Height of the gauge
    * `color_zones` - Optional color zones as keyword list
    * `style` - Optional style struct
    * `visible` - Whether the gauge is visible (default: true)

    ## Examples

        iex> %Gauge{id: :cpu, value: 75, min: 0, max: 100}
        %Gauge{id: :cpu, value: 75, min: 0, max: 100, ...}
    """

    @type color_zone :: [{integer(), atom()}]

    defstruct [
      :id,
      :value,
      :min,
      :max,
      :label,
      :width,
      :height,
      :color_zones,
      style: nil,
      visible: true
    ]

    @type t :: %__MODULE__{
            id: atom(),
            value: integer(),
            min: integer() | nil,
            max: integer() | nil,
            label: String.t() | nil,
            width: integer() | nil,
            height: integer() | nil,
            color_zones: color_zone() | nil,
            style: UnifiedIUR.Style.t() | nil,
            visible: boolean()
          }
  end

  defmodule Sparkline do
    @moduledoc """
    Sparkline widget for displaying trend data in a compact format.

    ## Fields

    * `id` - Required identifier for the sparkline
    * `data` - List of numeric values to display
    * `width` - Width of the sparkline
    * `height` - Height of the sparkline
    * `color` - Color for the sparkline line
    * `show_dots` - Whether to show dots at each data point (default: false)
    * `show_area` - Whether to fill the area under the line (default: false)
    * `style` - Optional style struct
    * `visible` - Whether the sparkline is visible (default: true)

    ## Examples

        iex> %Sparkline{id: :cpu_trend, data: [10, 25, 20, 35, 30]}
        %Sparkline{id: :cpu_trend, data: [10, 25, 20, 35, 30], ...}
    """

    defstruct [
      :id,
      :data,
      :width,
      :height,
      :color,
      show_dots: false,
      show_area: false,
      style: nil,
      visible: true
    ]

    @type t :: %__MODULE__{
            id: atom(),
            data: [integer()],
            width: integer() | nil,
            height: integer() | nil,
            color: atom() | nil,
            show_dots: boolean(),
            show_area: boolean(),
            style: UnifiedIUR.Style.t() | nil,
            visible: boolean()
          }
  end

  defmodule BarChart do
    @moduledoc """
    Bar chart widget for displaying categorical data comparison.

    ## Fields

    * `id` - Required identifier for the bar chart
    * `data` - List of {label, value} tuples for the bars
    * `width` - Width of the bar chart
    * `height` - Height of the bar chart
    * `orientation` - Orientation of bars (:horizontal or :vertical, default: :horizontal)
    * `show_labels` - Whether to show labels on the bars (default: true)
    * `style` - Optional style struct
    * `visible` - Whether the bar chart is visible (default: true)

    ## Examples

        iex> %BarChart{id: :sales, data: [{"Jan", 100}, {"Feb", 150}]}
        %BarChart{id: :sales, data: [{"Jan", 100}, {"Feb", 150}], ...}
    """

    @type orientation :: :horizontal | :vertical
    @type data_point :: {String.t(), integer()}

    defstruct [
      :id,
      :data,
      :width,
      :height,
      orientation: :horizontal,
      show_labels: true,
      style: nil,
      visible: true
    ]

    @type t :: %__MODULE__{
            id: atom(),
            data: [data_point()],
            width: integer() | nil,
            height: integer() | nil,
            orientation: orientation(),
            show_labels: boolean(),
            style: UnifiedIUR.Style.t() | nil,
            visible: boolean()
          }
  end

  defmodule LineChart do
    @moduledoc """
    Line chart widget for displaying time series or sequential data.

    ## Fields

    * `id` - Required identifier for the line chart
    * `data` - List of {label, value} tuples for the data points
    * `width` - Width of the line chart
    * `height` - Height of the line chart
    * `show_dots` - Whether to show dots at each data point (default: true)
    * `show_area` - Whether to fill the area under the line (default: false)
    * `style` - Optional style struct
    * `visible` - Whether the line chart is visible (default: true)

    ## Examples

        iex> %LineChart{id: :temp, data: [{"Mon", 20}, {"Tue", 22}]}
        %LineChart{id: :temp, data: [{"Mon", 20}, {"Tue", 22}], ...}
    """

    @type data_point :: {String.t(), integer()}

    defstruct [
      :id,
      :data,
      :width,
      :height,
      show_dots: true,
      show_area: false,
      style: nil,
      visible: true
    ]

    @type t :: %__MODULE__{
            id: atom(),
            data: [data_point()],
            width: integer() | nil,
            height: integer() | nil,
            show_dots: boolean(),
            show_area: boolean(),
            style: UnifiedIUR.Style.t() | nil,
            visible: boolean()
          }
  end

  defmodule Column do
    @moduledoc """
    Column widget for table column definitions.

    Columns define how to extract and display data from each row in a table.
    They are nested within Table widgets and specify column properties.

    ## Fields

    * `key` - The atom key to access data from each row
    * `header` - The header text to display for this column
    * `sortable` - Whether this column can be sorted (default: true)
    * `formatter` - Optional function to format cell values for display
    * `width` - Width of the column in characters/percentage (optional)
    * `align` - Text alignment (:left, :center, :right, default: :left)

    ## Formatter Function

    The formatter is an arity-1 function that receives the raw value
    and should return a string for display:

        formatter: fn date -> Calendar.strftime(date, "%Y-%m-%d") end

    ## Examples

        iex> %Column{key: :id, header: "ID", width: 5, align: :right}
        %Column{key: :id, header: "ID", width: 5, align: :right, sortable: true, ...}

        iex> %Column{key: :name, header: "Name", sortable: true}
        %Column{key: :name, header: "Name", sortable: true, align: :left, ...}
    """

    @type formatter :: (any() -> String.t())
    @type alignment :: :left | :center | :right

    defstruct [:key, :header, :formatter, :width, sortable: true, align: :left]

    @type t :: %__MODULE__{
            key: atom(),
            header: String.t(),
            sortable: boolean(),
            formatter: formatter() | nil,
            width: integer() | nil,
            align: alignment()
          }
  end

  defmodule Table do
    @moduledoc """
    Table widget for displaying tabular data.

    Tables are ideal for displaying structured data in rows and columns.
    They support sorting, selection, and scrolling for large datasets.

    ## Fields

    * `id` - Required identifier for the table
    * `data` - The data to display (list of maps, keyword lists, or structs)
    * `columns` - List of column definitions (auto-generated if not provided)
    * `selected_row` - Index of currently selected row (0-based, nil for none)
    * `height` - Visible height in rows (enables scrolling if set)
    * `on_row_select` - Signal to emit when a row is selected
    * `on_sort` - Signal to emit when a column is sorted
    * `sort_column` - The column key to sort by
    * `sort_direction` - Sort direction (:asc or :desc, default: :asc)
    * `style` - Optional style struct
    * `visible` - Whether the table is visible (default: true)

    ## Data Format

    The table accepts data as a list of maps, keyword lists, or structs:

        # List of maps
        [%{id: 1, name: "Alice"}, %{id: 2, name: "Bob"}]

        # List of keyword lists
        [[id: 1, name: "Alice"], [id: 2, name: "Bob"]]

        # List of structs
        [%User{id: 1, name: "Alice"}, %User{id: 2, name: "Bob"}]

    ## Signal Format

    The `on_row_select` and `on_sort` fields can be:
    * An atom signal name: `:row_selected`
    * A tuple with payload: `{:row_selected, %{index: 0, data: row}}`
    * An MFA tuple: `{Module, :function, [args]}`

    ## Examples

        iex> %Table{id: :users, data: [%{id: 1, name: "Alice"}]}
        %Table{id: :users, data: [%{id: 1, name: "Alice"}], columns: nil, ...}

        iex> %Table{id: :orders, data: @orders, height: 10, on_row_select: :order_selected}
        %Table{id: :orders, data: @orders, height: 10, on_row_select: :order_selected, ...}
    """

    @type row_data :: map() | keyword()
    @type signal :: atom() | {atom(), map()} | {atom(), atom(), list()}

    defstruct [
      :id,
      :data,
      :columns,
      :selected_row,
      :height,
      :on_row_select,
      :on_sort,
      :sort_column,
      sort_direction: :asc,
      style: nil,
      visible: true
    ]

    @type t :: %__MODULE__{
            id: atom(),
            data: [row_data()],
            columns: [Column.t()] | nil,
            selected_row: integer() | nil,
            height: integer() | nil,
            on_row_select: signal() | nil,
            on_sort: signal() | nil,
            sort_column: atom() | nil,
            sort_direction: :asc | :desc,
            style: UnifiedIUR.Style.t() | nil,
            visible: boolean()
          }
  end

  defmodule MenuItem do
    @moduledoc """
    Menu item widget for menu and context menu entries.
    """

    @type signal :: atom() | {atom(), map()} | {atom(), atom(), list()}

    defstruct [
      :label,
      :id,
      :action,
      :submenu,
      :icon,
      :shortcut,
      disabled: false,
      visible: true
    ]

    @type t :: %__MODULE__{
            label: String.t() | nil,
            id: atom() | nil,
            action: signal() | nil,
            disabled: boolean(),
            submenu: [t()] | nil,
            icon: atom() | nil,
            shortcut: String.t() | nil,
            visible: boolean()
          }
  end

  defmodule Menu do
    @moduledoc """
    Menu widget for organizing menu items.
    """

    @type position :: :top | :bottom | :left | :right

    defstruct [:id, :title, :position, :items, :style, visible: true]

    @type t :: %__MODULE__{
            id: atom() | nil,
            title: String.t() | nil,
            position: position() | nil,
            items: [MenuItem.t()] | nil,
            style: UnifiedIUR.Style.t() | nil,
            visible: boolean()
          }
  end

  defmodule ContextMenu do
    @moduledoc """
    Context menu widget shown by trigger gestures.
    """

    @type trigger :: :right_click | :long_press | :double_click

    defstruct [:id, :trigger_on, :items, :style, visible: true]

    @type t :: %__MODULE__{
            id: atom() | nil,
            trigger_on: trigger() | nil,
            items: [MenuItem.t()] | nil,
            style: UnifiedIUR.Style.t() | nil,
            visible: boolean()
          }
  end

  defmodule Tab do
    @moduledoc """
    Tab widget describing one tab and its content.
    """

    defstruct [:id, :label, :icon, :content, disabled: false, closable: false, visible: true]

    @type content ::
            UnifiedIUR.Widgets.Text.t()
            | UnifiedIUR.Widgets.Button.t()
            | UnifiedIUR.Widgets.Label.t()
            | UnifiedIUR.Widgets.TextInput.t()
            | UnifiedIUR.Widgets.Gauge.t()
            | UnifiedIUR.Widgets.Sparkline.t()
            | UnifiedIUR.Widgets.BarChart.t()
            | UnifiedIUR.Widgets.LineChart.t()
            | UnifiedIUR.Widgets.Table.t()
            | UnifiedIUR.Widgets.Menu.t()
            | UnifiedIUR.Widgets.ContextMenu.t()
            | UnifiedIUR.Widgets.Tabs.t()
            | UnifiedIUR.Widgets.TreeView.t()
            | UnifiedIUR.Widgets.Dialog.t()
            | UnifiedIUR.Widgets.AlertDialog.t()
            | UnifiedIUR.Widgets.Toast.t()
            | UnifiedIUR.Widgets.PickList.t()
            | UnifiedIUR.Widgets.FormBuilder.t()
            | UnifiedIUR.Layouts.VBox.t()
            | UnifiedIUR.Layouts.HBox.t()
            | [any()]
            | nil

    @type t :: %__MODULE__{
            id: atom() | nil,
            label: String.t() | nil,
            icon: atom() | nil,
            disabled: boolean(),
            closable: boolean(),
            visible: boolean(),
            content: content()
          }
  end

  defmodule Tabs do
    @moduledoc """
    Tabs container widget for grouping and switching tab content.
    """

    @type position :: :top | :bottom | :left | :right
    @type signal :: atom() | {atom(), map()} | {atom(), atom(), list()}

    defstruct [:id, :active_tab, :position, :on_change, :tabs, :style, visible: true]

    @type t :: %__MODULE__{
            id: atom() | nil,
            active_tab: atom() | nil,
            position: position() | nil,
            on_change: signal() | nil,
            tabs: [Tab.t()] | nil,
            style: UnifiedIUR.Style.t() | nil,
            visible: boolean()
          }
  end

  defmodule TreeNode do
    @moduledoc """
    Tree node widget used inside tree views.
    """

    defstruct [
      :id,
      :label,
      :value,
      :icon,
      :icon_expanded,
      :children,
      expanded: false,
      selectable: true,
      visible: true
    ]

    @type t :: %__MODULE__{
            id: atom() | nil,
            label: String.t() | nil,
            value: any(),
            expanded: boolean(),
            icon: atom() | nil,
            icon_expanded: atom() | nil,
            selectable: boolean(),
            visible: boolean(),
            children: [t()] | nil
          }
  end

  defmodule TreeView do
    @moduledoc """
    Tree view widget for hierarchical node display.
    """

    @type signal :: atom() | {atom(), map()} | {atom(), atom(), list()}
    @type expanded_nodes :: :all | [atom()] | MapSet.t(atom()) | nil

    defstruct [
      :id,
      :selected_node,
      :expanded_nodes,
      :on_select,
      :on_toggle,
      :root_nodes,
      :style,
      show_root: true,
      visible: true
    ]

    @type t :: %__MODULE__{
            id: atom() | nil,
            selected_node: atom() | nil,
            expanded_nodes: expanded_nodes(),
            on_select: signal() | nil,
            on_toggle: signal() | nil,
            show_root: boolean(),
            visible: boolean(),
            style: UnifiedIUR.Style.t() | nil,
            root_nodes: [TreeNode.t()] | nil
          }
  end
end
