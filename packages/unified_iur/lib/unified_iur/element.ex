defprotocol UnifiedIUR.Element do
  @moduledoc """
  Protocol for accessing properties of Intermediate UI Representation elements.

  The IUR (Intermediate UI Representation) is a tree of platform-agnostic
  structs that represent UI elements. This protocol provides polymorphic
  access to the structure of these elements, allowing renderers to
  traverse and inspect the UI tree without knowing the specific types.

  ## Protocol Functions

  * `children/1` - Returns a list of child elements for tree traversal
  * `metadata/1` - Returns a map of element properties (id, style, etc.)

  ## Example

  ```elixir
  # For a layout with children
  vbox = %UnifiedIUR.Layouts.VBox{
    children: [%Text{content: "Hello"}],
    id: :container
  }

  UnifiedIUR.Element.children(vbox)
  # => [%UnifiedIUR.Widgets.Text{content: "Hello", ...}]

  UnifiedIUR.Element.metadata(vbox)
  # => %{id: :container, type: :vbox}
  ```

  ## Implementing for Custom Elements

  Custom widgets and layouts should implement this protocol to work
  with the rendering system:

  ```elixir
  defimpl UnifiedIUR.Element, for: MyCustomWidget do
    def children(_widget), do: []
    def metadata(widget), do: %{id: widget.id, type: :custom}
  end
  ```

  ## Renderer Contract

  Platform-specific renderers (Terminal, Desktop, Web) should:
  1. Use `children/1` to traverse the UI tree
  2. Use `metadata/1` to access element properties
  3. Not depend on specific struct implementations
  """

  @doc """
  Returns the list of child elements for this UI element.

  For widgets, this is typically an empty list.
  For layouts, this returns the contained widgets and nested layouts.

  ## Examples

      iex> Element.children(%Text{content: "Hi"})
      []

      iex> Element.children(%VBox{children: [%Text{}, %Button{}]})
      [%Text{...}, %Button{...}]
  """
  @spec children(t()) :: [t()]
  def children(element)

  @doc """
  Returns a map of metadata about this element.

  The metadata map should include:
  * `:id` - The element's identifier (if present)
  * `:type` - The element type (e.g., `:text`, `:button`, `:vbox`)
  * Additional keys as needed for rendering

  ## Examples

      iex> Element.metadata(%Text{id: :greeting})
      %{id: :greeting, type: :text}

      iex> Element.metadata(%VBox{id: :main, spacing: 1})
      %{id: :main, type: :vbox, spacing: 1}
  """
  @spec metadata(t()) :: map()
  def metadata(element)
end

defimpl UnifiedIUR.Element, for: UnifiedIUR.Widgets.Text do
  import UnifiedIUR.ElementHelpers

  def children(_text), do: []

  def metadata(text) do
    build_metadata(%{type: :text, visible: text.visible}, id: text.id, style: text.style)
  end
end

defimpl UnifiedIUR.Element, for: UnifiedIUR.Widgets.Button do
  import UnifiedIUR.ElementHelpers

  def children(_button), do: []

  def metadata(button) do
    %{
      type: :button,
      label: button.label,
      on_click: button.on_click,
      disabled: button.disabled,
      visible: button.visible
    }
    |> build_metadata(id: button.id, style: button.style)
  end
end

defimpl UnifiedIUR.Element, for: UnifiedIUR.Widgets.Label do
  import UnifiedIUR.ElementHelpers

  def children(_label), do: []

  def metadata(label) do
    %{type: :label, for: label.for, text: label.text, visible: label.visible}
    |> build_metadata(id: label.id, style: label.style)
  end
end

defimpl UnifiedIUR.Element, for: UnifiedIUR.Widgets.TextInput do
  import UnifiedIUR.ElementHelpers

  def children(_input), do: []

  def metadata(input) do
    %{
      type: :text_input,
      id: input.id,
      value: input.value,
      placeholder: input.placeholder,
      input_type: input.type,
      on_change: input.on_change,
      on_submit: input.on_submit,
      disabled: input.disabled,
      visible: input.visible
    }
    |> build_metadata(style: input.style)
  end
end

defimpl UnifiedIUR.Element, for: UnifiedIUR.Layouts.VBox do
  import UnifiedIUR.ElementHelpers

  def children(vbox), do: vbox.children

  def metadata(vbox) do
    %{
      type: :vbox,
      spacing: vbox.spacing,
      align_items: vbox.align_items,
      justify_content: vbox.justify_content,
      padding: vbox.padding,
      visible: vbox.visible
    }
    |> build_metadata(id: vbox.id, style: vbox.style)
  end
end

defimpl UnifiedIUR.Element, for: UnifiedIUR.Layouts.HBox do
  import UnifiedIUR.ElementHelpers

  def children(hbox), do: hbox.children

  def metadata(hbox) do
    %{
      type: :hbox,
      spacing: hbox.spacing,
      align_items: hbox.align_items,
      justify_content: hbox.justify_content,
      padding: hbox.padding,
      visible: hbox.visible
    }
    |> build_metadata(id: hbox.id, style: hbox.style)
  end
end

defimpl UnifiedIUR.Element, for: UnifiedIUR.Widgets.Gauge do
  import UnifiedIUR.ElementHelpers

  def children(_gauge), do: []

  def metadata(gauge) do
    %{
      type: :gauge,
      id: gauge.id,
      value: gauge.value,
      min: gauge.min,
      max: gauge.max,
      label: gauge.label,
      width: gauge.width,
      height: gauge.height,
      color_zones: gauge.color_zones,
      visible: gauge.visible
    }
    |> build_metadata(style: gauge.style)
  end
end

defimpl UnifiedIUR.Element, for: UnifiedIUR.Widgets.Sparkline do
  import UnifiedIUR.ElementHelpers

  def children(_sparkline), do: []

  def metadata(sparkline) do
    %{
      type: :sparkline,
      id: sparkline.id,
      data: sparkline.data,
      width: sparkline.width,
      height: sparkline.height,
      color: sparkline.color,
      show_dots: sparkline.show_dots,
      show_area: sparkline.show_area,
      visible: sparkline.visible
    }
    |> build_metadata(style: sparkline.style)
  end
end

defimpl UnifiedIUR.Element, for: UnifiedIUR.Widgets.BarChart do
  import UnifiedIUR.ElementHelpers

  def children(_bar_chart), do: []

  def metadata(bar_chart) do
    %{
      type: :bar_chart,
      id: bar_chart.id,
      data: bar_chart.data,
      width: bar_chart.width,
      height: bar_chart.height,
      orientation: bar_chart.orientation,
      show_labels: bar_chart.show_labels,
      visible: bar_chart.visible
    }
    |> build_metadata(style: bar_chart.style)
  end
end

defimpl UnifiedIUR.Element, for: UnifiedIUR.Widgets.LineChart do
  import UnifiedIUR.ElementHelpers

  def children(_line_chart), do: []

  def metadata(line_chart) do
    %{
      type: :line_chart,
      id: line_chart.id,
      data: line_chart.data,
      width: line_chart.width,
      height: line_chart.height,
      show_dots: line_chart.show_dots,
      show_area: line_chart.show_area,
      visible: line_chart.visible
    }
    |> build_metadata(style: line_chart.style)
  end
end

defimpl UnifiedIUR.Element, for: UnifiedIUR.Widgets.Column do
  import UnifiedIUR.ElementHelpers

  def children(_column), do: []

  def metadata(column) do
    %{
      type: :column,
      key: column.key,
      header: column.header,
      sortable: column.sortable,
      formatter: column.formatter,
      width: column.width,
      align: column.align
    }
  end
end

defimpl UnifiedIUR.Element, for: UnifiedIUR.Widgets.Table do
  import UnifiedIUR.ElementHelpers

  def children(_table), do: []

  def metadata(table) do
    %{
      type: :table,
      id: table.id,
      data: table.data,
      columns: table.columns,
      selected_row: table.selected_row,
      height: table.height,
      on_row_select: table.on_row_select,
      on_sort: table.on_sort,
      sort_column: table.sort_column,
      sort_direction: table.sort_direction,
      visible: table.visible
    }
    |> build_metadata(style: table.style)
  end
end

defimpl UnifiedIUR.Element, for: UnifiedIUR.Widgets.MenuItem do
  def children(menu_item), do: menu_item.submenu || []

  def metadata(menu_item) do
    %{
      type: :menu_item,
      id: menu_item.id,
      label: menu_item.label,
      action: menu_item.action,
      disabled: menu_item.disabled,
      icon: menu_item.icon,
      shortcut: menu_item.shortcut,
      visible: menu_item.visible
    }
  end
end

defimpl UnifiedIUR.Element, for: UnifiedIUR.Widgets.Menu do
  import UnifiedIUR.ElementHelpers

  def children(menu), do: menu.items || []

  def metadata(menu) do
    %{
      type: :menu,
      id: menu.id,
      title: menu.title,
      position: menu.position,
      visible: menu.visible
    }
    |> build_metadata(style: menu.style)
  end
end

defimpl UnifiedIUR.Element, for: UnifiedIUR.Widgets.ContextMenu do
  import UnifiedIUR.ElementHelpers

  def children(menu), do: menu.items || []

  def metadata(menu) do
    %{
      type: :context_menu,
      id: menu.id,
      trigger_on: menu.trigger_on,
      visible: menu.visible
    }
    |> build_metadata(style: menu.style)
  end
end

defimpl UnifiedIUR.Element, for: UnifiedIUR.Widgets.Tab do
  def children(tab) do
    case tab.content do
      nil -> []
      content when is_list(content) -> content
      content -> [content]
    end
  end

  def metadata(tab) do
    %{
      type: :tab,
      id: tab.id,
      label: tab.label,
      icon: tab.icon,
      disabled: tab.disabled,
      closable: tab.closable,
      visible: tab.visible
    }
  end
end

defimpl UnifiedIUR.Element, for: UnifiedIUR.Widgets.Tabs do
  import UnifiedIUR.ElementHelpers

  def children(tabs), do: tabs.tabs || []

  def metadata(tabs) do
    %{
      type: :tabs,
      id: tabs.id,
      active_tab: tabs.active_tab,
      position: tabs.position,
      on_change: tabs.on_change,
      visible: tabs.visible
    }
    |> build_metadata(style: tabs.style)
  end
end

defimpl UnifiedIUR.Element, for: UnifiedIUR.Widgets.TreeNode do
  def children(tree_node), do: tree_node.children || []

  def metadata(tree_node) do
    %{
      type: :tree_node,
      id: tree_node.id,
      label: tree_node.label,
      value: tree_node.value,
      expanded: tree_node.expanded,
      icon: tree_node.icon,
      icon_expanded: tree_node.icon_expanded,
      selectable: tree_node.selectable,
      visible: tree_node.visible
    }
  end
end

defimpl UnifiedIUR.Element, for: UnifiedIUR.Widgets.TreeView do
  import UnifiedIUR.ElementHelpers

  def children(tree_view), do: tree_view.root_nodes || []

  def metadata(tree_view) do
    %{
      type: :tree_view,
      id: tree_view.id,
      selected_node: tree_view.selected_node,
      expanded_nodes: tree_view.expanded_nodes,
      on_select: tree_view.on_select,
      on_toggle: tree_view.on_toggle,
      show_root: tree_view.show_root,
      visible: tree_view.visible
    }
    |> build_metadata(style: tree_view.style)
  end
end

defimpl UnifiedIUR.Element, for: Any do
  def children(_element), do: []

  def metadata(_element), do: %{type: :unknown}
end
