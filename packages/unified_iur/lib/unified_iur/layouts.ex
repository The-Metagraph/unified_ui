defmodule UnifiedIUR.Layouts do
  @moduledoc """
  Intermediate UI Representation (IUR) layout structs.

  Layouts are container elements that arrange widgets and other layouts
  in specific patterns. They represent internal nodes in the UI tree.

  ## Layout Types

  * `VBox` - Vertical box: arranges children top to bottom
  * `HBox` - Horizontal box: arranges children left to right

  ## Common Fields

  All layouts have:
  * `children` - List of child elements (widgets or nested layouts)
  * `id` - Optional unique identifier
  * `spacing` - Space between children
  * `align_items` - Cross-axis alignment of children
  * `justify_content` - Main-axis distribution of children
  * `padding` - Internal padding around content
  * `style` - Inline style specification
  * `visible` - Whether the layout is visible

  ## Alignment Values

  Both `align_items` and `justify_content` accept:
  * `:start` - Align to the start edge
  * `:center` - Align to the center
  * `:end` - Align to the end edge
  * `:stretch` - Stretch to fill the available space

  Additionally, `justify_content` accepts:
  * `:space_between` - Distribute space between children
  * `:space_around` - Distribute space around children

  ## Examples

  Create a vertical box with text and button:

      iex> %VBox{
      ...>   children: [
      ...>     %Text{content: "Welcome!"},
      ...>     %Button{label: "Start", on_click: :start}
      ...>   ],
      ...>   spacing: 1,
      ...>   align_items: :center
      ... }

  Create a horizontal form row:

      iex> %HBox{
      ...>   children: [
      ...>     %Text{content: "Name:"},
      ...>     %TextInput{id: :name_input}
      ...>   ],
      ...>   spacing: 2,
      ...>   align_items: :center
      ... }
  """

  @type alignment :: :start | :center | :end | :stretch
  @type justification :: alignment() | :space_between | :space_around
  @type child ::
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
          | VBox.t()
          | HBox.t()

  defmodule VBox do
    @moduledoc """
    Vertical box layout container.

    Arranges children vertically from top to bottom.

    ## Fields

    * `children` - List of child elements (widgets or nested layouts)
    * `spacing` - Space between children (integer, default: 0)
    * `align_items` - Horizontal (cross-axis) alignment of children
    * `justify_content` - Vertical (main-axis) distribution of children
    * `padding` - Internal padding around all children (integer, optional)
    * `id` - Optional unique identifier
    * `style` - Optional inline style
    * `visible` - Whether the layout is visible (default: true)

    ## Alignment Examples

    For `align_items` (horizontal alignment):
    * `:start` - Children align to the left
    * `:center` - Children are horizontally centered
    * `:end` - Children align to the right
    * `:stretch` - Children stretch to fill the width

    For `justify_content` (vertical distribution):
    * `:start` - Children start at the top
    * `:center` - Children are vertically centered
    * `:end` - Children end at the bottom
    * `:stretch` - Children stretch to fill the height
    * `:space_between` - Space distributed between children
    * `:space_around` - Space distributed around children

    ## Examples

        iex> %VBox{children: [%Text{content: "A"}, %Text{content: "B"}], spacing: 1}
        %VBox{children: [...], spacing: 1, align_items: nil, ...}
    """

    defstruct [
      :id,
      :padding,
      children: [],
      spacing: 0,
      align_items: nil,
      justify_content: nil,
      style: nil,
      visible: true
    ]

    @type t :: %__MODULE__{
            id: atom() | nil,
            children: [UnifiedIUR.Layouts.child()],
            spacing: integer(),
            align_items: UnifiedIUR.Layouts.alignment() | nil,
            justify_content: UnifiedIUR.Layouts.justification() | nil,
            padding: integer() | nil,
            style: UnifiedIUR.Style.t() | nil,
            visible: boolean()
          }
  end

  defmodule HBox do
    @moduledoc """
    Horizontal box layout container.

    Arranges children horizontally from left to right.

    ## Fields

    * `children` - List of child elements (widgets or nested layouts)
    * `spacing` - Space between children (integer, default: 0)
    * `align_items` - Vertical (cross-axis) alignment of children
    * `justify_content` - Horizontal (main-axis) distribution of children
    * `padding` - Internal padding around all children (integer, optional)
    * `id` - Optional unique identifier
    * `style` - Optional inline style
    * `visible` - Whether the layout is visible (default: true)

    ## Alignment Examples

    For `align_items` (vertical alignment):
    * `:start` - Children align to the top
    * `:center` - Children are vertically centered
    * `:end` - Children align to the bottom
    * `:stretch` - Children stretch to fill the height

    For `justify_content` (horizontal distribution):
    * `:start` - Children start at the left
    * `:center` - Children are horizontally centered
    * `:end` - Children end at the right
    * `:stretch` - Children stretch to fill the width
    * `:space_between` - Space distributed between children
    * `:space_around` - Space distributed around children

    ## Examples

        iex> %HBox{children: [%Text{content: "A"}, %Text{content: "B"}], spacing: 2}
        %HBox{children: [...], spacing: 2, align_items: nil, ...}
    """

    defstruct [
      :id,
      :padding,
      children: [],
      spacing: 0,
      align_items: nil,
      justify_content: nil,
      style: nil,
      visible: true
    ]

    @type t :: %__MODULE__{
            id: atom() | nil,
            children: [UnifiedIUR.Layouts.child()],
            spacing: integer(),
            align_items: UnifiedIUR.Layouts.alignment() | nil,
            justify_content: UnifiedIUR.Layouts.justification() | nil,
            padding: integer() | nil,
            style: UnifiedIUR.Style.t() | nil,
            visible: boolean()
          }
  end
end
