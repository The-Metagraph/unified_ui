defmodule UnifiedUi.Adapters.Desktop do
  @moduledoc """
  Desktop renderer that converts IUR to DesktopUi-style widget trees.

  This renderer implements the `UnifiedUi.Renderer` behaviour and converts
  Intermediate UI Representation (IUR) elements to DesktopUi-compatible widget maps.

  ## Usage

      # Create an IUR tree
      iur = %VBox{
        children: [
          %Text{content: "Hello"},
          %Button{label: "Click Me", on_click: :clicked}
        ]
      }

      # Render to DesktopUi-style widgets
      {:ok, state} = Desktop.render(iur)

      # The state contains the DesktopUi widget tree
      # state.root is the DesktopUi widget tree

  ## Widget Tree Structure

  The renderer produces DesktopUi-style widget maps with:
  * `:type` - Widget type (`:label`, `:button`, `:container`)
  * `:id` - Optional unique identifier
  * `:props` - Widget properties (keyword list)
  * `:children` - Child widgets (for containers)

  ## Style Conversion

  IUR styles are converted to DesktopUi widget properties via `Style.to_props/1`.

  ## Layout Mapping

  * `VBox` → `%{type: :container, direction: :vbox, ...}`
  * `HBox` → `%{type: :container, direction: :hbox, ...}`

  ## Widget Mapping

  * `Text` → `%{type: :label, text: content}` with optional color prop
  * `Button` → `%{type: :button, label: label, on_click: action}` with style props
  * `Label` → `%{type: :label, text: text}` with metadata for `:for` reference
  * `TextInput` → Tagged tuple `{:text_input, widget, metadata}`

  ## DesktopUi Compatibility

  The widget maps produced by this renderer follow the DesktopUi structure:
  - `%{type: :label, id: nil, props: [text: "Hello"], children: []}`
  - `%{type: :button, id: nil, props: [label: "Click", on_click: :clicked], children: []}`
  - `%{type: :container, id: nil, props: [direction: :vbox, spacing: 8], children: [...]}`

  When DesktopUi is added as a dependency, these maps can be passed directly
  to DesktopUI rendering functions.

  """

  @behaviour UnifiedUi.Renderer

  alias UnifiedUi.Adapters.State
  alias UnifiedUi.Adapters.Desktop.Style

  alias UnifiedUi.Widgets.{
    Canvas,
    Command,
    CommandPalette,
    Grid,
    LogViewer,
    ProcessMonitor,
    Stack,
    SplitPane,
    StreamWidget,
    Viewport,
    ZBox
  }

  alias UnifiedIUR.Element
  alias UnifiedIUR.Widgets
  alias UnifiedIUR.Layouts

  @impl true
  @spec render(UnifiedUi.Renderer.iur_tree(), keyword()) ::
          {:ok, State.t()} | {:error, term()}
  def render(iur_tree, opts \\ []) do
    renderer_state = State.new(:desktop, config: opts)

    # Convert IUR tree to DesktopUi widget tree
    root = convert_iur(iur_tree, renderer_state)

    # Update state with root reference and metadata for diff-aware updates
    renderer_state =
      renderer_state
      |> State.put_root(root)
      |> State.put_metadata(:last_iur, iur_tree)

    {:ok, renderer_state}
  end

  @impl true
  @spec update(UnifiedUi.Renderer.iur_tree(), State.t(), keyword()) ::
          {:ok, State.t()} | {:error, term()}
  def update(iur_tree, renderer_state, opts \\ []) do
    merged_config = Keyword.merge(renderer_state.config, opts)
    previous_iur = State.get_metadata(renderer_state, :last_iur, :__missing__)

    config_changed = merged_config != renderer_state.config
    iur_changed = previous_iur != iur_tree

    if iur_changed or config_changed do
      {new_root, incremental_patch} =
        build_updated_root(iur_tree, previous_iur, renderer_state, config_changed)

      root_changed = new_root != renderer_state.root

      updated_state =
        renderer_state
        |> put_config(merged_config)
        |> State.put_metadata(:last_iur, iur_tree)
        |> State.put_metadata(:incremental_patch, incremental_patch)
        |> maybe_put_root(new_root, root_changed)
        |> maybe_bump_version(root_changed or config_changed)

      {:ok, updated_state}
    else
      {:ok, renderer_state}
    end
  end

  @impl true
  @spec destroy(State.t()) :: :ok
  def destroy(_renderer_state) do
    # DesktopUi uses pure data structures, no cleanup needed
    :ok
  end

  @doc """
  Converts an IUR element to a DesktopUi widget tree.

  ## Parameters

  * `iur_element` - The IUR element to convert
  * `renderer_state` - The renderer state (used for tracking)

  ## Returns

  A DesktopUi widget (map with :type key).

  """
  @spec convert_iur(UnifiedUi.Renderer.iur_element(), State.t()) :: term() | nil
  def convert_iur(iur_element, renderer_state \\ %State{}) do
    metadata = Element.metadata(iur_element)
    type = metadata.type
    visible = Map.get(metadata, :visible, true)

    # Skip invisible elements
    if visible == false do
      nil
    else
      convert_by_type(iur_element, type, renderer_state)
    end
  end

  # Widget builders - Construct DesktopUi-style widget maps directly

  defp build_label(text, props \\ []) do
    %{
      type: :label,
      id: nil,
      props: [text: text] ++ props,
      children: []
    }
  end

  defp build_button(label, on_click, props) do
    %{
      type: :button,
      id: nil,
      props: [label: label, on_click: on_click] ++ props,
      children: []
    }
  end

  defp build_container(direction, children, props) do
    %{
      type: :container,
      id: nil,
      props: [direction: direction] ++ props,
      children: children
    }
  end

  # Widget converters

  defp convert_by_type(%Widgets.Text{} = text, :text, _state) do
    content = text.content || ""

    # Build base props
    props = []

    # Add style props if present
    props = Style.add_props(props, text.style)

    # Create DesktopUi-style label widget
    build_label(content, props)
  end

  defp convert_by_type(%Widgets.Button{} = button, :button, _state) do
    label = button.label || ""

    # Build base props
    props = []

    # Add style props if present
    props = Style.add_props(props, button.style)

    # Add disabled state
    props = if button.disabled, do: [{:disabled, true} | props], else: props

    # Create DesktopUi-style button widget
    widget = build_button(label, button.on_click, props)

    # Add ID to widget metadata if present
    if button.id do
      Map.put(widget, :id, button.id)
    else
      widget
    end
  end

  defp convert_by_type(%Widgets.Label{} = label, :label, _state) do
    text = label.text || ""

    # Build base props
    props = []

    # Add style props if present
    props = Style.add_props(props, label.style)

    # Create DesktopUi-style label widget
    widget = build_label(text, props)

    # Store :for reference in metadata
    if label.for do
      widget
      |> Map.put(:label_for, label.for)
      |> Map.put(:id, label.id)
    else
      widget
    end
  end

  defp convert_by_type(%Widgets.TextInput{} = input, :text_input, _state) do
    # Build display text
    display_text =
      cond do
        input.value -> input.value
        input.placeholder -> "[#{input.placeholder}]"
        true -> "[________________]"
      end

    # Build base props
    props = []

    # Add style props if present
    props = Style.add_props(props, input.style)

    # Add input-specific props
    props = if input.disabled, do: [{:disabled, true} | props], else: props

    # Create a label widget to represent the input field
    # DesktopUi doesn't have a dedicated TextInput widget yet
    # We use a label with metadata indicating it's an input
    base_widget = build_label(display_text, props)

    # Wrap with input metadata as a tagged tuple for event handling
    # This follows the same pattern as the Terminal renderer
    {:text_input, base_widget,
     %{
       id: input.id,
       value: input.value,
       placeholder: input.placeholder,
       type: input.type,
       on_change: input.on_change,
       on_submit: input.on_submit,
       disabled: input.disabled,
       form_id: input.form_id
     }}
  end

  # Advanced input widget converters

  defp convert_by_type(%Widgets.PickListOption{} = option, :pick_list_option, _state) do
    label =
      cond do
        is_binary(option.label) -> option.label
        is_nil(option.value) -> ""
        true -> inspect(option.value)
      end

    props = if option.disabled, do: [disabled: true], else: []
    base_widget = build_label(label, props)

    {:pick_list_option, Map.put(base_widget, :id, option.id),
     %{
       id: option.id,
       value: option.value,
       label: option.label,
       disabled: option.disabled
     }}
  end

  defp convert_by_type(%Widgets.PickList{} = pick_list, :pick_list, _state) do
    selected_label =
      Enum.find_value(pick_list.options || [], fn
        %Widgets.PickListOption{value: value, label: label} when value == pick_list.selected ->
          label || inspect(value)

        _ ->
          nil
      end)

    display_text =
      cond do
        is_binary(selected_label) -> selected_label
        not is_nil(pick_list.selected) -> inspect(pick_list.selected)
        is_binary(pick_list.placeholder) -> pick_list.placeholder
        true -> "Select option"
      end

    props =
      []
      |> Style.add_props(pick_list.style)
      |> then(fn props -> [{:searchable, pick_list.searchable} | props] end)
      |> then(fn props -> [{:allow_clear, pick_list.allow_clear} | props] end)

    base_widget =
      %{
        type: :pick_list,
        id: pick_list.id,
        props: [{:selected, pick_list.selected}, {:display_text, display_text} | props],
        children: []
      }

    {:pick_list, base_widget,
     %{
       id: pick_list.id,
       options: pick_list.options,
       selected: pick_list.selected,
       placeholder: pick_list.placeholder,
       searchable: pick_list.searchable,
       on_select: pick_list.on_select,
       allow_clear: pick_list.allow_clear
     }}
  end

  defp convert_by_type(%Widgets.FormField{} = field, :form_field, _state) do
    label =
      cond do
        is_binary(field.label) -> field.label
        is_atom(field.name) -> field.name |> Atom.to_string() |> String.replace("_", " ")
        true -> "Field"
      end

    props =
      []
      |> Style.add_props(field.style)
      |> then(fn props -> [{:field_type, field.type} | props] end)
      |> then(fn props -> [{:required, field.required} | props] end)
      |> then(fn props -> [{:disabled, field.disabled} | props] end)
      |> then(fn props -> [{:placeholder, field.placeholder} | props] end)

    base_widget = build_label(label, props)

    {:form_field, base_widget,
     %{
       name: field.name,
       type: field.type,
       label: field.label,
       placeholder: field.placeholder,
       required: field.required,
       default: field.default,
       options: field.options,
       disabled: field.disabled
     }}
  end

  defp convert_by_type(%Widgets.FormBuilder{} = form_builder, :form_builder, state) do
    field_children =
      form_builder.fields
      |> List.wrap()
      |> Enum.map(fn field -> convert_iur(field, state) end)
      |> Enum.reject(&is_nil/1)

    submit_widget =
      build_button(form_builder.submit_label || "Submit", form_builder.on_submit, [])

    props =
      []
      |> Style.add_props(form_builder.style)
      |> then(fn props -> [{:action, form_builder.action} | props] end)
      |> then(fn props -> [{:submit_label, form_builder.submit_label} | props] end)

    base_widget = %{
      type: :form_builder,
      id: form_builder.id,
      props: props,
      children: field_children ++ [submit_widget]
    }

    {:form_builder, base_widget,
     %{
       id: form_builder.id,
       fields: form_builder.fields,
       action: form_builder.action,
       on_submit: form_builder.on_submit,
       submit_label: form_builder.submit_label
     }}
  end

  # Data visualization converters

  defp convert_by_type(%Widgets.Gauge{} = gauge, :gauge, _state) do
    # Build display text for desktop gauge
    min_val = gauge.min || 0
    max_val = gauge.max || 100
    value = max(min_val, min(max_val, gauge.value))

    label_text = if gauge.label, do: "#{gauge.label}: ", else: ""
    display_text = "#{label_text}#{value}/#{max_val}"

    # Build base props
    props = []

    # Add style props if present
    props = Style.add_props(props, gauge.style)

    # Create desktop widget
    base_widget = build_label(display_text, props)

    # Wrap with metadata
    {:gauge, base_widget,
     %{
       id: gauge.id,
       value: value,
       min: min_val,
       max: max_val,
       label: gauge.label,
       width: gauge.width,
       height: gauge.height,
       color_zones: gauge.color_zones
     }}
  end

  defp convert_by_type(%Widgets.Sparkline{} = sparkline, :sparkline, _state) do
    data = sparkline.data || []

    # Build display text for desktop sparkline
    display_text =
      if data != [] do
        "Sparkline: #{length(data)} points"
      else
        "No data"
      end

    # Build base props
    props = []

    # Add style props if present
    props = Style.add_props(props, sparkline.style)

    # Create desktop widget
    base_widget = build_label(display_text, props)

    # Wrap with metadata
    {:sparkline, base_widget,
     %{
       id: sparkline.id,
       data: data,
       width: sparkline.width,
       height: sparkline.height,
       color: sparkline.color,
       show_dots: sparkline.show_dots,
       show_area: sparkline.show_area
     }}
  end

  defp convert_by_type(%Widgets.BarChart{} = chart, :bar_chart, _state) do
    data = chart.data || []

    # Build display text for desktop bar chart
    display_text =
      if data != [] do
        "Bar Chart: #{length(data)} items"
      else
        "No data"
      end

    # Build base props
    props = []

    # Add style props if present
    props = Style.add_props(props, chart.style)

    # Create desktop widget
    base_widget = build_label(display_text, props)

    # Wrap with metadata
    {:bar_chart, base_widget,
     %{
       id: chart.id,
       data: data,
       width: chart.width,
       height: chart.height,
       orientation: chart.orientation,
       show_labels: chart.show_labels
     }}
  end

  defp convert_by_type(%Widgets.LineChart{} = chart, :line_chart, _state) do
    data = chart.data || []

    # Build display text for desktop line chart
    display_text =
      if data != [] do
        "Line Chart: #{length(data)} points"
      else
        "No data"
      end

    # Build base props
    props = []

    # Add style props if present
    props = Style.add_props(props, chart.style)

    # Create desktop widget
    base_widget = build_label(display_text, props)

    # Wrap with metadata
    {:line_chart, base_widget,
     %{
       id: chart.id,
       data: data,
       width: chart.width,
       height: chart.height,
       show_dots: chart.show_dots,
       show_area: chart.show_area
     }}
  end

  defp convert_by_type(%Widgets.Table{} = table, :table, _state) do
    data = table.data || []
    columns = table.columns || []

    # Auto-generate columns from first row if not provided
    columns =
      if columns == [] and data != [] do
        first_row = hd(data)

        first_row
        |> extract_desktop_keys()
        |> Enum.map(fn key ->
          %Widgets.Column{
            key: key,
            header: to_string(key) |> String.capitalize(),
            sortable: true,
            align: :left
          }
        end)
      else
        columns
      end

    # Build display text for desktop table
    display_text =
      if data != [] do
        "Table: #{length(data)} rows, #{length(columns)} columns"
      else
        "Empty Table"
      end

    # Build base props
    props = []

    # Add style props if present
    props = Style.add_props(props, table.style)

    # Create desktop widget
    base_widget = build_label(display_text, props)

    # Wrap with metadata for event handling
    {:table, base_widget,
     %{
       id: table.id,
       data: data,
       columns: columns,
       selected_row: table.selected_row,
       height: table.height,
       on_row_select: table.on_row_select,
       on_sort: table.on_sort,
       sort_column: table.sort_column,
       sort_direction: table.sort_direction
     }}
  end

  # Navigation widget converters

  defp convert_by_type(%Widgets.MenuItem{} = item, :menu_item, _state) do
    # Build label text with icon and shortcut
    label_text = item.label

    # Build base props
    props = []

    # Add style props if present
    props = Style.add_props(props, nil)

    # Create base widget for menu item
    base_widget = build_label(label_text, props)

    # Wrap with metadata
    {:menu_item, base_widget,
     %{
       id: item.id,
       label: item.label,
       action: item.action,
       disabled: item.disabled,
       icon: item.icon,
       shortcut: item.shortcut,
       has_submenu: item.submenu != nil,
       submenu: item.submenu
     }}
  end

  defp convert_by_type(%Widgets.Menu{} = menu, :menu, state) do
    # Convert menu items
    items =
      Enum.map(menu.items || [], fn item ->
        convert_iur(item, state)
      end)

    # Build container props
    props = []

    # Add style props if present
    props = Style.add_props(props, menu.style)

    # Add position prop
    props = if menu.position, do: [{:position, menu.position} | props], else: props

    # Add title prop if present
    props = if menu.title, do: [{:title, menu.title} | props], else: props

    # Create menu container widget
    base_widget = %{
      type: :menu,
      id: menu.id,
      props: props,
      children: items
    }

    # Wrap with metadata
    {:menu, base_widget,
     %{
       id: menu.id,
       title: menu.title,
       position: menu.position
     }}
  end

  defp convert_by_type(%Widgets.ContextMenu{} = menu, :context_menu, state) do
    # Convert menu items
    items =
      Enum.map(menu.items || [], fn item ->
        convert_iur(item, state)
      end)

    # Build container props
    props = []

    # Add style props if present
    props = Style.add_props(props, menu.style)

    # Add trigger_on prop
    props = [{:trigger_on, menu.trigger_on} | props]

    # Create context menu container widget
    base_widget = %{
      type: :context_menu,
      id: menu.id,
      props: props,
      children: items
    }

    # Wrap with metadata
    {:context_menu, base_widget,
     %{
       id: menu.id,
       trigger_on: menu.trigger_on
     }}
  end

  defp convert_by_type(%Widgets.Tab{} = tab, :tab, _state) do
    # Build label text with icon
    label_text = tab.label

    # Build base props
    props = []

    # Add disabled state
    props = if tab.disabled, do: [{:disabled, true} | props], else: props

    # Add closable state
    props = if tab.closable, do: [{:closable, true} | props], else: props

    # Add icon if present
    props = if tab.icon, do: [{:icon, tab.icon} | props], else: props

    # Create tab header widget
    base_widget = %{
      type: :tab_header,
      id: tab.id,
      props: [label: label_text] ++ props,
      children: []
    }

    # Wrap with metadata
    {:tab, base_widget,
     %{
       id: tab.id,
       label: tab.label,
       icon: tab.icon,
       disabled: tab.disabled,
       closable: tab.closable,
       content: tab.content
     }}
  end

  defp convert_by_type(%Widgets.Tabs{} = tabs, :tabs, state) do
    # Convert tab headers
    tab_headers =
      Enum.map(tabs.tabs || [], fn tab ->
        convert_iur(tab, state)
      end)

    # Get active tab content
    active_content =
      if tabs.active_tab do
        Enum.find(tabs.tabs || [], fn tab -> tab.id == tabs.active_tab end)
        |> case do
          nil ->
            nil

          tab ->
            # Only convert content if it exists
            if tab.content do
              convert_iur(tab.content, state)
            else
              nil
            end
        end
      else
        nil
      end

    # Build container props
    props = []

    # Add style props if present
    props = Style.add_props(props, tabs.style)

    # Add position prop
    props = if tabs.position, do: [{:position, tabs.position} | props], else: props

    # Add active_tab prop
    props = [{:active_tab, tabs.active_tab} | props]

    # Build children list (tab headers + active content)
    children = tab_headers ++ if(active_content, do: [active_content], else: [])

    # Create tabs container widget
    base_widget = %{
      type: :tabs,
      id: tabs.id,
      props: props,
      children: children
    }

    # Wrap with metadata
    {:tabs, base_widget,
     %{
       id: tabs.id,
       active_tab: tabs.active_tab,
       position: tabs.position,
       on_change: tabs.on_change,
       tabs: tabs.tabs
     }}
  end

  defp convert_by_type(%Widgets.TreeNode{} = node, :tree_node, state) do
    # Build label text
    label_text = node.label

    # Build base props
    props = []

    # Add expanded state
    props = [{:expanded, node.expanded} | props]

    # Add selectable state
    props = [{:selectable, node.selectable} | props]

    # Add icon if present
    props = if node.icon, do: [{:icon, node.icon} | props], else: props

    # Add icon_expanded if present
    props = if node.icon_expanded, do: [{:icon_expanded, node.icon_expanded} | props], else: props

    # Convert children if any
    children =
      if node.children do
        Enum.map(node.children, fn child ->
          convert_iur(child, state)
        end)
      else
        []
      end

    # Create tree node widget
    base_widget = %{
      type: :tree_node,
      id: node.id,
      props: [label: label_text] ++ props,
      children: children
    }

    # Wrap with metadata
    {:tree_node, base_widget,
     %{
       id: node.id,
       label: node.label,
       value: node.value,
       expanded: node.expanded,
       icon: node.icon,
       icon_expanded: node.icon_expanded,
       selectable: node.selectable,
       has_children: node.children != nil
     }}
  end

  defp convert_by_type(%Widgets.TreeView{} = tree, :tree_view, state) do
    # Convert root nodes
    root_nodes =
      Enum.map(tree.root_nodes || [], fn node ->
        convert_iur(node, state)
      end)

    # Build container props
    props = []

    # Add style props if present
    props = Style.add_props(props, tree.style)

    # Add selected_node prop
    props = if tree.selected_node, do: [{:selected_node, tree.selected_node} | props], else: props

    # Add expanded_nodes prop
    props =
      if tree.expanded_nodes, do: [{:expanded_nodes, tree.expanded_nodes} | props], else: props

    # Add show_root prop
    props = [{:show_root, tree.show_root} | props]

    # Create tree view container widget
    base_widget = %{
      type: :tree_view,
      id: tree.id,
      props: props,
      children: root_nodes
    }

    # Wrap with metadata
    {:tree_view, base_widget,
     %{
       id: tree.id,
       selected_node: tree.selected_node,
       expanded_nodes: tree.expanded_nodes,
       on_select: tree.on_select,
       on_toggle: tree.on_toggle,
       show_root: tree.show_root
     }}
  end

  # Dialog and feedback converters

  defp convert_by_type(%Widgets.DialogButton{} = button, :dialog_button, _state) do
    props =
      []
      |> Style.add_props(button.style)
      |> then(fn props ->
        if button.disabled, do: [{:disabled, true} | props], else: props
      end)
      |> then(fn props -> [{:role, button.role} | props] end)

    base_widget = build_button(button.label || "", button.action, props)

    {:dialog_button, Map.put(base_widget, :id, button.id),
     %{
       id: button.id,
       label: button.label,
       action: button.action,
       role: button.role,
       disabled: button.disabled
     }}
  end

  defp convert_by_type(%Widgets.Dialog{} = dialog, :dialog, state) do
    content_children =
      case dialog.content do
        nil ->
          []

        content when is_list(content) ->
          Enum.map(content, fn item ->
            if is_binary(item), do: build_label(item), else: convert_iur(item, state)
          end)

        content ->
          [if(is_binary(content), do: build_label(content), else: convert_iur(content, state))]
      end
      |> Enum.reject(&is_nil/1)

    button_children =
      dialog.buttons
      |> List.wrap()
      |> Enum.map(&convert_iur(&1, state))
      |> Enum.reject(&is_nil/1)

    button_bar =
      if button_children == [] do
        []
      else
        [
          %{
            type: :container,
            id: nil,
            props: [direction: :hbox, spacing: 1],
            children: button_children
          }
        ]
      end

    props =
      []
      |> Style.add_props(dialog.style)
      |> then(fn props -> [{:title, dialog.title} | props] end)
      |> then(fn props -> [{:closable, dialog.closable} | props] end)
      |> then(fn props -> [{:modal, dialog.modal} | props] end)
      |> then(fn props -> [{:blocks_background, dialog.modal == true} | props] end)
      |> then(fn props -> if dialog.width, do: [{:width, dialog.width} | props], else: props end)
      |> then(fn props ->
        if dialog.height, do: [{:height, dialog.height} | props], else: props
      end)

    base_widget = %{
      type: :dialog,
      id: dialog.id,
      props: props,
      children: content_children ++ button_bar
    }

    {:dialog, base_widget,
     %{
       id: dialog.id,
       title: dialog.title,
       on_close: dialog.on_close,
       closable: dialog.closable,
       modal: dialog.modal,
       blocks_background: dialog.modal == true,
       width: dialog.width,
       height: dialog.height
     }}
  end

  defp convert_by_type(%Widgets.AlertDialog{} = alert, :alert_dialog, _state) do
    props =
      []
      |> Style.add_props(alert.style)
      |> then(fn props -> [{:title, alert.title} | props] end)
      |> then(fn props -> [{:message, alert.message} | props] end)
      |> then(fn props -> [{:severity, alert.severity} | props] end)
      |> then(fn props -> [{:modal, alert.modal} | props] end)
      |> then(fn props -> [{:blocks_background, alert.modal == true} | props] end)
      |> then(fn props -> [{:closable, alert.closable} | props] end)

    base_widget = %{
      type: :alert_dialog,
      id: alert.id,
      props: props,
      children: []
    }

    {:alert_dialog, base_widget,
     %{
       id: alert.id,
       title: alert.title,
       message: alert.message,
       severity: alert.severity,
       on_confirm: alert.on_confirm,
       on_cancel: alert.on_cancel,
       modal: alert.modal,
       blocks_background: alert.modal == true
     }}
  end

  defp convert_by_type(%Widgets.Toast{} = toast, :toast, _state) do
    dismiss_at = toast_dismiss_at(toast.duration)

    props =
      []
      |> Style.add_props(toast.style)
      |> then(fn props -> [{:message, toast.message} | props] end)
      |> then(fn props -> [{:severity, toast.severity} | props] end)
      |> then(fn props -> [{:duration, toast.duration} | props] end)
      |> then(fn props -> [{:auto_dismiss, not is_nil(dismiss_at)} | props] end)
      |> then(fn props -> if dismiss_at, do: [{:dismiss_at, dismiss_at} | props], else: props end)

    base_widget = %{
      type: :toast,
      id: toast.id,
      props: props,
      children: []
    }

    {:toast, base_widget,
     %{
       id: toast.id,
       message: toast.message,
       severity: toast.severity,
       duration: toast.duration,
       on_dismiss: toast.on_dismiss,
       auto_dismiss: not is_nil(dismiss_at),
       dismiss_at: dismiss_at
     }}
  end

  # Container widget converters

  defp convert_by_type(%Viewport{} = viewport, :viewport, state) do
    content =
      case viewport.content do
        nil -> []
        child -> [convert_iur(child, state)]
      end

    props =
      []
      |> Style.add_props(viewport.style)
      |> then(fn props ->
        if viewport.width, do: [{:width, viewport.width} | props], else: props
      end)
      |> then(fn props ->
        if viewport.height, do: [{:height, viewport.height} | props], else: props
      end)
      |> then(fn props -> [{:scroll_x, viewport.scroll_x} | props] end)
      |> then(fn props -> [{:scroll_y, viewport.scroll_y} | props] end)
      |> then(fn props -> [{:border, viewport.border} | props] end)

    widget = %{
      type: :viewport,
      id: viewport.id,
      props: props,
      children: content
    }

    {:viewport, widget,
     %{
       id: viewport.id,
       width: viewport.width,
       height: viewport.height,
       scroll_x: viewport.scroll_x,
       scroll_y: viewport.scroll_y,
       on_scroll: viewport.on_scroll,
       border: viewport.border
     }}
  end

  defp convert_by_type(%SplitPane{} = split_pane, :split_pane, state) do
    pane_widgets = convert_children(split_pane.panes, state)

    props =
      []
      |> Style.add_props(split_pane.style)
      |> then(fn props -> [{:orientation, split_pane.orientation} | props] end)
      |> then(fn props -> [{:initial_split, split_pane.initial_split} | props] end)
      |> then(fn props -> [{:min_size, split_pane.min_size} | props] end)

    widget = %{
      type: :split_pane,
      id: split_pane.id,
      props: props,
      children: pane_widgets
    }

    {:split_pane, widget,
     %{
       id: split_pane.id,
       orientation: split_pane.orientation,
       initial_split: split_pane.initial_split,
       min_size: split_pane.min_size,
       on_resize_change: split_pane.on_resize_change
     }}
  end

  defp convert_by_type(%Canvas{} = canvas, :canvas, _state) do
    props =
      []
      |> Style.add_props(canvas.style)
      |> then(fn props -> if canvas.width, do: [{:width, canvas.width} | props], else: props end)
      |> then(fn props ->
        if canvas.height, do: [{:height, canvas.height} | props], else: props
      end)

    widget = %{
      type: :canvas,
      id: canvas.id,
      props: props,
      children: []
    }

    {:canvas, widget,
     %{
       id: canvas.id,
       width: canvas.width,
       height: canvas.height,
       draw: canvas.draw,
       on_click: canvas.on_click,
       on_hover: canvas.on_hover
     }}
  end

  defp convert_by_type(%CommandPalette{} = palette, :command_palette, _state) do
    commands =
      palette.commands
      |> List.wrap()
      |> Enum.map(&command_palette_command_map/1)

    props =
      []
      |> Style.add_props(palette.style)
      |> then(fn props ->
        [{:placeholder, palette.placeholder || "Type a command..."} | props]
      end)
      |> then(fn props ->
        if palette.trigger_shortcut,
          do: [{:trigger_shortcut, palette.trigger_shortcut} | props],
          else: props
      end)
      |> then(fn props -> [{:commands, commands} | props] end)

    widget = %{
      type: :command_palette,
      id: palette.id,
      props: props,
      children: []
    }

    {:command_palette, widget,
     %{
       id: palette.id,
       placeholder: palette.placeholder,
       trigger_shortcut: palette.trigger_shortcut,
       on_select: palette.on_select,
       commands: commands
     }}
  end

  defp convert_by_type(%LogViewer{} = log_viewer, :log_viewer, _state) do
    props =
      []
      |> Style.add_props(log_viewer.style)
      |> then(fn props -> [{:source, log_viewer.source} | props] end)
      |> then(fn props -> [{:lines, log_viewer.lines} | props] end)
      |> then(fn props -> [{:auto_scroll, log_viewer.auto_scroll} | props] end)
      |> then(fn props -> [{:filter, log_viewer.filter} | props] end)
      |> then(fn props -> [{:refresh_interval, log_viewer.refresh_interval} | props] end)

    widget = %{type: :log_viewer, id: log_viewer.id, props: props, children: []}

    {:log_viewer, widget,
     %{
       id: log_viewer.id,
       source: log_viewer.source,
       lines: log_viewer.lines,
       auto_scroll: log_viewer.auto_scroll,
       filter: log_viewer.filter,
       refresh_interval: log_viewer.refresh_interval,
       auto_refresh: log_viewer.refresh_interval > 0
     }}
  end

  defp convert_by_type(%StreamWidget{} = stream_widget, :stream_widget, _state) do
    props =
      []
      |> Style.add_props(stream_widget.style)
      |> then(fn props -> [{:producer, stream_widget.producer} | props] end)
      |> then(fn props -> [{:buffer_size, stream_widget.buffer_size} | props] end)
      |> then(fn props -> [{:refresh_interval, stream_widget.refresh_interval} | props] end)

    widget = %{type: :stream_widget, id: stream_widget.id, props: props, children: []}

    {:stream_widget, widget,
     %{
       id: stream_widget.id,
       producer: stream_widget.producer,
       transform: stream_widget.transform,
       buffer_size: stream_widget.buffer_size,
       refresh_interval: stream_widget.refresh_interval,
       auto_refresh: stream_widget.refresh_interval > 0,
       on_item: stream_widget.on_item
     }}
  end

  defp convert_by_type(%ProcessMonitor{} = process_monitor, :process_monitor, _state) do
    props =
      []
      |> Style.add_props(process_monitor.style)
      |> then(fn props -> [{:node, process_monitor.node || node()} | props] end)
      |> then(fn props -> [{:sort_by, process_monitor.sort_by} | props] end)
      |> then(fn props -> [{:refresh_interval, process_monitor.refresh_interval} | props] end)

    widget = %{type: :process_monitor, id: process_monitor.id, props: props, children: []}

    {:process_monitor, widget,
     %{
       id: process_monitor.id,
       node: process_monitor.node || node(),
       refresh_interval: process_monitor.refresh_interval,
       auto_refresh: process_monitor.refresh_interval > 0,
       sort_by: process_monitor.sort_by,
       on_process_select: process_monitor.on_process_select
     }}
  end

  # Layout converters

  defp convert_by_type(%Grid{} = grid, :grid, state) do
    children = convert_children(grid.children, state)
    columns = normalize_grid_tracks(grid.columns)
    rows = normalize_grid_tracks(grid.rows)

    props =
      []
      |> then(fn props -> [{:columns, columns} | props] end)
      |> then(fn props -> [{:rows, rows} | props] end)
      |> then(fn props -> [{:gap, grid.gap} | props] end)
      |> Style.add_props(grid.style)

    widget = %{type: :grid, id: grid.id, props: props, children: children}

    {:grid, widget,
     %{
       id: grid.id,
       columns: columns,
       rows: rows,
       gap: grid.gap
     }}
  end

  defp convert_by_type(%Stack{} = stack, :stack, state) do
    all_children = convert_children(stack.children, state)
    active_index = normalize_active_index(stack.active_index, length(all_children))
    active_children = [Enum.at(all_children, active_index)] |> Enum.reject(&is_nil/1)

    props =
      []
      |> then(fn props -> [{:active_index, active_index} | props] end)
      |> then(fn props -> [{:transition, stack.transition} | props] end)
      |> Style.add_props(stack.style)

    widget = %{type: :stack, id: stack.id, props: props, children: active_children}

    {:stack, widget,
     %{
       id: stack.id,
       active_index: active_index,
       child_count: length(all_children),
       transition: stack.transition
     }}
  end

  defp convert_by_type(%ZBox{} = zbox, :zbox, state) do
    children = convert_children(zbox.children, state)
    positions = normalize_zbox_positions(zbox.positions)

    props =
      []
      |> then(fn props -> [{:positions, positions} | props] end)
      |> Style.add_props(zbox.style)

    widget = %{type: :zbox, id: zbox.id, props: props, children: children}

    {:zbox, widget,
     %{
       id: zbox.id,
       positions: positions,
       child_count: length(children)
     }}
  end

  defp convert_by_type(%Layouts.VBox{} = vbox, :vbox, state) do
    children = convert_children(vbox.children, state)

    # Build container props
    props =
      []
      |> maybe_add_spacing(vbox.spacing)
      |> maybe_add_padding(vbox.padding)
      |> maybe_add_align_items(vbox.align_items)
      |> maybe_add_justify_content(vbox.justify_content)

    # Add style props if present
    props = Style.add_props(props, vbox.style)

    # Create DesktopUi-style container widget
    build_container(:vbox, children, props)
  end

  defp convert_by_type(%Layouts.HBox{} = hbox, :hbox, state) do
    children = convert_children(hbox.children, state)

    # Build container props
    props =
      []
      |> maybe_add_spacing(hbox.spacing)
      |> maybe_add_padding(hbox.padding)
      |> maybe_add_align_items(hbox.align_items)
      |> maybe_add_justify_content(hbox.justify_content)

    # Add style props if present
    props = Style.add_props(props, hbox.style)

    # Create DesktopUi-style container widget
    build_container(:hbox, children, props)
  end

  # Fallback for unknown types
  defp convert_by_type(_element, _type, _state) do
    # Return empty label for unknown element types
    build_label("")
  end

  # Helper functions

  defp convert_children(children, state) when is_list(children) do
    children
    |> Enum.map(fn child -> convert_iur(child, state) end)
    |> Enum.reject(&is_nil/1)
  end

  defp convert_children(_, _state), do: []

  defp command_palette_command_map(%Command{} = command) do
    %{
      id: command.id,
      label: command.label,
      description: command.description,
      shortcut: command.shortcut,
      keywords: command.keywords,
      disabled: command.disabled
    }
  end

  defp command_palette_command_map(command) when is_map(command) do
    disabled =
      cond do
        Map.has_key?(command, :disabled) -> Map.get(command, :disabled) == true
        Map.has_key?(command, "disabled") -> Map.get(command, "disabled") == true
        true -> false
      end

    %{
      id: Map.get(command, :id) || Map.get(command, "id"),
      label: Map.get(command, :label) || Map.get(command, "label"),
      description: Map.get(command, :description) || Map.get(command, "description"),
      shortcut: Map.get(command, :shortcut) || Map.get(command, "shortcut"),
      keywords:
        (Map.get(command, :keywords) || Map.get(command, "keywords") || []) |> List.wrap(),
      disabled: disabled
    }
  end

  defp command_palette_command_map({id, label}) when is_atom(id) and is_binary(label) do
    %{id: id, label: label, description: nil, shortcut: nil, keywords: [], disabled: false}
  end

  defp command_palette_command_map(other) do
    %{
      id: other,
      label: inspect(other),
      description: nil,
      shortcut: nil,
      keywords: [],
      disabled: false
    }
  end

  # Spacing in DesktopUi is in pixels
  defp maybe_add_spacing(props, nil), do: props

  defp maybe_add_spacing(props, spacing) when is_integer(spacing),
    do: [{:spacing, spacing} | props]

  # Padding in DesktopUi is in pixels
  defp maybe_add_padding(props, nil), do: props

  defp maybe_add_padding(props, padding) when is_integer(padding),
    do: [{:padding, padding} | props]

  # Alignment mapping
  # IUR alignment → DesktopUi alignment
  defp maybe_add_align_items(props, nil), do: props
  defp maybe_add_align_items(props, :start), do: [{:align, :left} | props]
  defp maybe_add_align_items(props, :center), do: [{:align, :center} | props]
  defp maybe_add_align_items(props, :end), do: [{:align, :right} | props]
  defp maybe_add_align_items(props, align), do: [{:align, align} | props]

  # Justification mapping
  defp maybe_add_justify_content(props, nil), do: props
  defp maybe_add_justify_content(props, :start), do: [{:justify, :top} | props]
  defp maybe_add_justify_content(props, :center), do: [{:justify, :center} | props]
  defp maybe_add_justify_content(props, :end), do: [{:justify, :bottom} | props]
  defp maybe_add_justify_content(props, justify), do: [{:justify, justify} | props]

  defp normalize_grid_tracks(nil), do: []
  defp normalize_grid_tracks([]), do: []

  defp normalize_grid_tracks(tracks) when is_list(tracks) do
    Enum.map(tracks, &normalize_grid_track/1)
  end

  defp normalize_grid_tracks(track), do: [normalize_grid_track(track)]

  defp normalize_grid_track(track) when is_integer(track) and track > 0,
    do: "#{track}fr"

  defp normalize_grid_track(track) when is_integer(track), do: "#{track}"
  defp normalize_grid_track(:auto), do: "auto"
  defp normalize_grid_track(track) when is_binary(track), do: track
  defp normalize_grid_track(track), do: inspect(track)

  defp normalize_active_index(index, child_count)
       when is_integer(index) and is_integer(child_count) and child_count > 0 do
    index
    |> max(0)
    |> min(child_count - 1)
  end

  defp normalize_active_index(_index, _child_count), do: 0

  defp normalize_zbox_positions(nil), do: %{}
  defp normalize_zbox_positions(positions) when is_map(positions), do: positions

  defp normalize_zbox_positions(positions) when is_list(positions) do
    if Keyword.keyword?(positions) do
      Enum.into(positions, %{})
    else
      positions
      |> Enum.with_index()
      |> Enum.into(%{}, fn {position, index} -> {index, position} end)
    end
  end

  defp normalize_zbox_positions(_positions), do: %{}

  defp toast_dismiss_at(duration) when is_integer(duration) and duration > 0 do
    System.monotonic_time(:millisecond) + duration
  end

  defp toast_dismiss_at(_duration), do: nil

  # Desktop table helpers

  defp extract_desktop_keys(row) when is_map(row) do
    row |> Map.keys() |> Enum.sort()
  end

  defp extract_desktop_keys(row) when is_list(row) do
    Keyword.keys(row)
  end

  defp build_updated_root(iur_tree, previous_iur, renderer_state, config_changed) do
    cond do
      config_changed ->
        {convert_iur(iur_tree, renderer_state), fallback_incremental_patch(:config_changed)}

      previous_iur == :__missing__ ->
        {convert_iur(iur_tree, renderer_state), fallback_incremental_patch(:missing_previous_iur)}

      true ->
        case patch_root_layout_children(iur_tree, previous_iur, renderer_state) do
          {:ok, patched_root, reused_children, re_rendered_children} ->
            {patched_root,
             %{
               applied: true,
               strategy: :root_layout_children,
               reused_children: reused_children,
               re_rendered_children: re_rendered_children
             }}

          :error ->
            {convert_iur(iur_tree, renderer_state),
             fallback_incremental_patch(:full_render_fallback)}
        end
    end
  end

  defp fallback_incremental_patch(reason) when is_atom(reason) do
    %{
      applied: false,
      strategy: nil,
      reused_children: 0,
      re_rendered_children: 0,
      reason: reason
    }
  end

  defp patch_root_layout_children(
         %module{} = iur_tree,
         %module{} = previous_iur,
         %State{} = state
       )
       when module in [Layouts.VBox, Layouts.HBox] do
    with true <- layout_signature(iur_tree) == layout_signature(previous_iur),
         {:ok, rendered_children, rebuild_root} <- extract_layout_children(state.root, module),
         true <- same_child_count?(iur_tree.children, previous_iur.children, rendered_children),
         {:ok, patched_children, reused_children, re_rendered_children} <-
           patch_children(iur_tree.children, previous_iur.children, rendered_children, state) do
      {:ok, rebuild_root.(patched_children), reused_children, re_rendered_children}
    else
      _ -> :error
    end
  end

  defp patch_root_layout_children(_, _, _), do: :error

  defp layout_direction(Layouts.VBox), do: :vbox
  defp layout_direction(Layouts.HBox), do: :hbox

  defp layout_signature(%_{} = layout) do
    layout
    |> Map.from_struct()
    |> Map.drop([:children])
  end

  defp extract_layout_children(rendered_layout, layout_module)
       when is_map(rendered_layout) and layout_module in [Layouts.VBox, Layouts.HBox] do
    expected_direction = layout_direction(layout_module)

    with true <- rendered_layout[:type] == :container,
         rendered_children when is_list(rendered_children) <- rendered_layout[:children],
         props when is_list(props) <- rendered_layout[:props],
         ^expected_direction <- Keyword.get(props, :direction) do
      {:ok, rendered_children,
       fn patched_children -> Map.put(rendered_layout, :children, patched_children) end}
    else
      _ -> :error
    end
  end

  defp extract_layout_children(_, _), do: :error

  defp same_child_count?(new_children, old_children, rendered_children)
       when is_list(new_children) and is_list(old_children) and is_list(rendered_children) do
    length(new_children) == length(old_children) and
      length(old_children) == length(rendered_children)
  end

  defp same_child_count?(_, _, _), do: false

  defp patch_children(new_children, old_children, rendered_children, state) do
    patch_result =
      new_children
      |> Enum.zip(old_children)
      |> Enum.zip(rendered_children)
      |> Enum.reduce_while({[], 0, 0}, fn {{new_child, old_child}, rendered_child},
                                          {children_acc, reused_acc, rerendered_acc} ->
        case patch_child(new_child, old_child, rendered_child, state) do
          {:ok, patched_child, reused_delta, rerendered_delta} ->
            {:cont,
             {[
                patched_child
                | children_acc
              ], reused_acc + reused_delta, rerendered_acc + rerendered_delta}}

          :error ->
            {:halt, :error}
        end
      end)

    case patch_result do
      :error ->
        :error

      {patched_children, reused_children, re_rendered_children} ->
        {:ok, Enum.reverse(patched_children), reused_children, re_rendered_children}
    end
  end

  defp patch_child(new_child, old_child, rendered_child, _state) when new_child == old_child do
    {:ok, rendered_child, 1, 0}
  end

  defp patch_child(new_child, old_child, rendered_child, state) do
    case patch_nested_layout_child(new_child, old_child, rendered_child, state) do
      {:ok, patched_child, reused_children, re_rendered_children} ->
        {:ok, patched_child, reused_children, re_rendered_children}

      :error ->
        case convert_iur(new_child, state) do
          nil -> :error
          new_render -> {:ok, new_render, 0, 1}
        end
    end
  end

  defp patch_nested_layout_child(
         %module{} = new_layout,
         %module{} = old_layout,
         rendered_child,
         state
       )
       when module in [Layouts.VBox, Layouts.HBox] do
    with true <- layout_signature(new_layout) == layout_signature(old_layout),
         {:ok, rendered_children, rebuild_child} <-
           extract_layout_children(rendered_child, module),
         true <- same_child_count?(new_layout.children, old_layout.children, rendered_children),
         {:ok, patched_children, reused_children, re_rendered_children} <-
           patch_children(new_layout.children, old_layout.children, rendered_children, state) do
      {:ok, rebuild_child.(patched_children), reused_children, re_rendered_children}
    else
      _ -> :error
    end
  end

  defp patch_nested_layout_child(_, _, _, _), do: :error

  defp put_config(%State{} = renderer_state, config) when is_list(config) do
    %{renderer_state | config: config}
  end

  defp maybe_put_root(%State{} = renderer_state, _new_root, false) do
    renderer_state
  end

  defp maybe_put_root(%State{} = renderer_state, new_root, true) do
    State.put_root(renderer_state, new_root)
  end

  defp maybe_bump_version(%State{} = renderer_state, false) do
    renderer_state
  end

  defp maybe_bump_version(%State{} = renderer_state, true) do
    State.bump_version(renderer_state)
  end
end
