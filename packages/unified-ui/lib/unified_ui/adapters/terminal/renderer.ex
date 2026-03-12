defmodule UnifiedUi.Adapters.Terminal do
  @moduledoc """
  Terminal renderer that converts IUR to TermUI render trees.

  This renderer implements the `UnifiedUi.Renderer` behaviour and converts
  Intermediate UI Representation (IUR) elements to TermUI render nodes.

  ## Usage

      # Create an IUR tree
      iur = %VBox{
        children: [
          %Text{content: "Hello"},
          %Button{label: "Click Me", on_click: :clicked}
        ]
      }

      # Render to TermUI
      {:ok, state} = Terminal.render(iur)

      # The state contains the TermUI render tree
      # state.root is the TermUI render tree

  ## Render Tree Structure

  The renderer produces TermUI render trees using:
  * `TermUI.Component.Helpers.text/2` - Text nodes
  * `TermUI.Component.Helpers.stack/3` - Layout containers
  * Custom nodes for buttons, labels, inputs

  ## Style Conversion

  IUR styles are converted to TermUI styles via `Style.convert_style/1`.

  ## Layout Mapping

  * `VBox` → `stack(:vertical, children, opts)`
  * `HBox` → `stack(:horizontal, children, opts)`

  ## Widget Mapping

  * `Text` → Text node with content and style
  * `Button` → Custom button node with label, style, and on_click handler
  * `Label` → Text node with `:for` reference
  * `TextInput` → Custom input node with value, placeholder, type

  """

  @behaviour UnifiedUi.Renderer

  alias UnifiedUi.Adapters.State
  alias UnifiedUi.Adapters.Terminal.Style

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
    renderer_state = State.new(:terminal, config: opts)

    # Convert IUR tree to TermUI render tree
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
    # TermUI uses pure data structures, no cleanup needed
    :ok
  end

  @doc """
  Converts an IUR element to a TermUI render tree.

  ## Parameters

  * `iur_element` - The IUR element to convert
  * `renderer_state` - The renderer state (used for tracking)

  ## Returns

  A TermUI render tree (tagged tuple or RenderNode struct).

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

  # Widget converters

  defp convert_by_type(%Widgets.Text{} = text, :text, _state) do
    content = text.content || ""
    style = Style.convert_style(text.style)

    # Create text node with optional style
    if style do
      TermUI.Component.Helpers.text(content, style)
    else
      TermUI.Component.Helpers.text(content)
    end
  end

  defp convert_by_type(%Widgets.Button{} = button, :button, _state) do
    label = button.label || ""
    style = Style.convert_style(button.style)

    # Create button text representation
    button_text = "[ #{label} ]"

    # Create text node first
    text_node = TermUI.Component.Helpers.text(button_text)

    # Apply style if present
    styled_node =
      if style do
        TermUI.Component.Helpers.styled(text_node, style)
      else
        text_node
      end

    # Add metadata for event handling
    if button.on_click do
      {:button, styled_node,
       %{
         on_click: button.on_click,
         id: button.id,
         disabled: button.disabled
       }}
    else
      styled_node
    end
  end

  defp convert_by_type(%Widgets.Label{} = label, :label, _state) do
    text = label.text || ""
    style = Style.convert_style(label.style)

    # Create text node
    text_node = TermUI.Component.Helpers.text(text)

    # Apply style if present
    styled_node =
      if style do
        TermUI.Component.Helpers.styled(text_node, style)
      else
        text_node
      end

    # Add for reference if present
    if label.for do
      {:label, styled_node, %{for: label.for, id: label.id}}
    else
      styled_node
    end
  end

  defp convert_by_type(%Widgets.TextInput{} = input, :text_input, _state) do
    # Build placeholder/value display
    display_value =
      cond do
        input.value -> input.value
        input.placeholder -> "[#{input.placeholder}]"
        true -> "[________________]"
      end

    # Add visual indicator for input type
    type_indicator =
      case input.type do
        :password -> "*"
        :email -> "@"
        :number -> "#"
        :tel -> "T"
        _ -> ":"
      end

    display = "#{type_indicator} #{display_value}"

    # Create text node for the input display
    text_node = TermUI.Component.Helpers.text(display)

    # Apply style if present
    style = Style.convert_style(input.style)

    styled_node =
      if style do
        TermUI.Component.Helpers.styled(text_node, style)
      else
        text_node
      end

    # Wrap with input metadata
    {:text_input, styled_node,
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
        true -> to_string(option.value)
      end

    prefix = if option.disabled, do: "(x) ", else: "• "
    TermUI.Component.Helpers.text("#{prefix}#{label}")
  end

  defp convert_by_type(%Widgets.PickList{} = pick_list, :pick_list, state) do
    options = pick_list.options || []

    selected_label =
      Enum.find_value(options, fn
        %Widgets.PickListOption{value: value, label: label} when value == pick_list.selected ->
          label || to_string(value)

        _ ->
          nil
      end)

    title =
      cond do
        is_binary(selected_label) -> "▼ #{selected_label}"
        not is_nil(pick_list.selected) -> "▼ #{inspect(pick_list.selected)}"
        is_binary(pick_list.placeholder) -> "▼ [#{pick_list.placeholder}]"
        true -> "▼ [Select]"
      end

    title_node = TermUI.Component.Helpers.text(title)

    search_node =
      if pick_list.searchable do
        TermUI.Component.Helpers.text("Search: [type to filter]")
      else
        nil
      end

    option_nodes =
      options
      |> Enum.map(fn option -> convert_iur(option, state) end)
      |> Enum.reject(&is_nil/1)

    clear_node =
      if pick_list.allow_clear do
        TermUI.Component.Helpers.text("• (clear selection)")
      else
        nil
      end

    children =
      [title_node, search_node]
      |> Enum.reject(&is_nil/1)
      |> Kernel.++(option_nodes)
      |> then(fn nodes ->
        if clear_node, do: nodes ++ [clear_node], else: nodes
      end)

    pick_list_node = TermUI.Component.Helpers.stack(:vertical, children, spacing: 0)

    styled_node =
      case Style.convert_style(pick_list.style) do
        nil -> pick_list_node
        style -> TermUI.Component.Helpers.styled(pick_list_node, style)
      end

    {:pick_list, styled_node,
     %{
       id: pick_list.id,
       selected: pick_list.selected,
       placeholder: pick_list.placeholder,
       searchable: pick_list.searchable,
       on_select: pick_list.on_select,
       allow_clear: pick_list.allow_clear,
       options: options
     }}
  end

  defp convert_by_type(%Widgets.FormField{} = field, :form_field, _state) do
    label =
      cond do
        is_binary(field.label) -> field.label
        is_atom(field.name) -> field.name |> Atom.to_string() |> String.replace("_", " ")
        true -> "Field"
      end

    required_suffix = if field.required, do: " *", else: ""

    type_hint =
      case field.type do
        :checkbox -> "[ ]"
        :select -> "<select>"
        :password -> "<password>"
        :email -> "<email>"
        :number -> "<number>"
        _ -> "<text>"
      end

    placeholder_hint =
      case field.placeholder do
        nil -> ""
        placeholder -> " #{placeholder}"
      end

    text_node =
      TermUI.Component.Helpers.text("#{label}#{required_suffix}: #{type_hint}#{placeholder_hint}")

    styled_node =
      case Style.convert_style(field.style) do
        nil -> text_node
        style -> TermUI.Component.Helpers.styled(text_node, style)
      end

    {:form_field, styled_node,
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
    field_nodes =
      form_builder.fields
      |> List.wrap()
      |> Enum.map(fn field -> convert_iur(field, state) end)
      |> Enum.reject(&is_nil/1)

    submit_node = TermUI.Component.Helpers.text("[ #{form_builder.submit_label || "Submit"} ]")

    form_node =
      TermUI.Component.Helpers.stack(:vertical, field_nodes ++ [submit_node], spacing: 1)

    styled_node =
      case Style.convert_style(form_builder.style) do
        nil -> form_node
        style -> TermUI.Component.Helpers.styled(form_node, style)
      end

    {:form_builder, styled_node,
     %{
       id: form_builder.id,
       action: form_builder.action,
       on_submit: form_builder.on_submit,
       submit_label: form_builder.submit_label,
       fields: form_builder.fields
     }}
  end

  # Data visualization converters

  defp convert_by_type(%Widgets.Gauge{} = gauge, :gauge, _state) do
    # Calculate percentage and bar width
    min_val = gauge.min || 0
    max_val = gauge.max || 100
    value = max(min_val, min(max_val, gauge.value))
    range = max_val - min_val
    percentage = if range > 0, do: (value - min_val) / range, else: 0
    # 20 character bar
    bar_width = round(percentage * 20)

    # Build the bar string
    filled = String.duplicate("=", bar_width)
    empty = String.duplicate(" ", 20 - bar_width)
    bar = "[#{filled}#{empty}]"

    # Add label if present
    label_text = if gauge.label, do: "#{gauge.label}: ", else: ""

    # Build display text
    display_text = "#{label_text}#{bar} #{gauge.value}/#{max_val}"

    # Create text node
    text_node = TermUI.Component.Helpers.text(display_text)

    # Apply style if present
    style = Style.convert_style(gauge.style)

    styled_node =
      if style do
        TermUI.Component.Helpers.styled(text_node, style)
      else
        text_node
      end

    # Wrap with metadata
    {:gauge, styled_node,
     %{
       id: gauge.id,
       value: gauge.value,
       min: min_val,
       max: max_val,
       label: gauge.label
     }}
  end

  defp convert_by_type(%Widgets.Sparkline{} = sparkline, :sparkline, _state) do
    data = sparkline.data || []

    # Generate ASCII sparkline
    sparkline_text =
      if length(data) > 1 do
        min_val = Enum.min(data)
        max_val = Enum.max(data)
        range = max_val - min_val

        chars = ["_", "", "-", ".", "o", "O", "@", "#"]

        points =
          Enum.map(data, fn val ->
            if range > 0 do
              normalized = (val - min_val) / range
              index = min(trunc(normalized * length(chars)), length(chars) - 1)
              Enum.at(chars, index)
            else
              ""
            end
          end)

        Enum.join(points)
      else
        ""
      end

    # Create text node
    text_node = TermUI.Component.Helpers.text(sparkline_text)

    # Apply style if present
    style = Style.convert_style(sparkline.style)

    styled_node =
      if style do
        TermUI.Component.Helpers.styled(text_node, style)
      else
        text_node
      end

    # Wrap with metadata
    {:sparkline, styled_node,
     %{
       id: sparkline.id,
       data: data,
       show_dots: sparkline.show_dots,
       show_area: sparkline.show_area
     }}
  end

  defp convert_by_type(%Widgets.BarChart{} = chart, :bar_chart, _state) do
    data = chart.data || []

    # Find max value for scaling
    max_val =
      if data != [] do
        data |> Enum.map(fn {_, v} -> v end) |> Enum.max(fn -> 0 end)
      else
        0
      end

    # Build bar lines based on orientation
    lines =
      if chart.orientation == :horizontal do
        # Horizontal bars
        Enum.map(data, fn {label, value} ->
          bar_width = if max_val > 0, do: round(value / max_val * 20), else: 0
          bar = String.duplicate("=", bar_width)
          formatted_label = String.pad_trailing(label, 10)
          "#{formatted_label} [#{bar}] #{value}"
        end)
      else
        # Vertical bars (simplified ASCII representation)
        if data != [] do
          max_value = max_val
          num_bars = min(length(data), 10)

          # Build from top to bottom
          Enum.map(max_value..0//-1, fn y ->
            bars_at_level =
              Enum.map(0..(num_bars - 1), fn i ->
                if i < length(data) do
                  {_, val} = Enum.at(data, i)
                  threshold = (y + 1) * max_value / 5
                  if val >= threshold, do: "|", else: " "
                else
                  " "
                end
              end)

            "#{String.pad_leading(Integer.to_string(y * 20), 4)} |#{Enum.join(bars_at_level, " ")}|"
          end) ++ ["      #{Enum.map_join(0..(num_bars - 1), " ", fn _ -> "--" end)}"]
        else
          ["No data"]
        end
      end

    display_text = Enum.join(lines, "\n")

    # Create text node
    text_node = TermUI.Component.Helpers.text(display_text)

    # Apply style if present
    style = Style.convert_style(chart.style)

    styled_node =
      if style do
        TermUI.Component.Helpers.styled(text_node, style)
      else
        text_node
      end

    # Wrap with metadata
    {:bar_chart, styled_node,
     %{
       id: chart.id,
       data: data,
       orientation: chart.orientation,
       show_labels: chart.show_labels
     }}
  end

  defp convert_by_type(%Widgets.LineChart{} = chart, :line_chart, _state) do
    data = chart.data || []

    # Generate ASCII line chart
    chart_text =
      if length(data) > 1 do
        min_val = Enum.map(data, fn {_, v} -> v end) |> Enum.min()
        max_val = Enum.map(data, fn {_, v} -> v end) |> Enum.max()
        range = max_val - min_val

        # Create a simple line chart with height of 5 lines
        height = 5
        width = length(data)

        # Build grid
        grid =
          for y <- (height - 1)..0//-1 do
            row =
              for x <- 0..(width - 1) do
                if x < length(data) do
                  {_, val} = Enum.at(data, x)

                  y_level =
                    if range > 0 do
                      round((val - min_val) / range * (height - 1))
                    else
                      0
                    end

                  if y == y_level do
                    if chart.show_dots, do: "o", else: "*"
                  else
                    " "
                  end
                else
                  " "
                end
              end

            Enum.join(row)
          end

        # Include compact X-axis labels for consistency with other adapters.
        x_labels =
          Enum.map_join(data, "", fn {label, _} ->
            String.slice(label, 0, 3) |> String.pad_trailing(4)
          end)

        Enum.join(grid, "\n") <> "\n" <> x_labels
      else
        "No data"
      end

    # Create text node
    text_node = TermUI.Component.Helpers.text(chart_text)

    # Apply style if present
    style = Style.convert_style(chart.style)

    styled_node =
      if style do
        TermUI.Component.Helpers.styled(text_node, style)
      else
        text_node
      end

    # Wrap with metadata
    {:line_chart, styled_node,
     %{
       id: chart.id,
       data: data,
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
        |> extract_keys()
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

    # Sort data if sort_column is specified
    data =
      if table.sort_column do
        UnifiedUi.Table.Sort.sort_data(data, table.sort_column, table.sort_direction)
      else
        data
      end

    # Build ASCII table
    table_text =
      if columns != [] do
        # Calculate column widths
        col_widths =
          Enum.map(columns, fn col ->
            header_width = String.length(col.header || "")

            max_data_width =
              data
              |> Enum.map(fn row ->
                value = UnifiedUi.Table.Sort.get_value(row, col.key)
                formatted = apply_formatter(col.formatter, value)
                String.length(formatted)
              end)
              |> Enum.max(fn -> 0 end)

            max(header_width, max_data_width)
            |> min(col.width || 999)
          end)

        # Build header row
        header_cells =
          Enum.zip(columns, col_widths)
          |> Enum.map(fn {col, width} ->
            sort_indicator =
              if table.sort_column == col.key do
                if table.sort_direction == :asc, do: " ↑", else: " ↓"
              else
                ""
              end

            align_text(col.header || "", width, col.align) <> sort_indicator
          end)

        # Build separator
        separator =
          Enum.map_join(col_widths, "+", fn width ->
            String.duplicate("-", width + 2)
          end)

        # Build data rows
        data_rows =
          Enum.with_index(data)
          |> Enum.map(fn {row, idx} ->
            cells =
              Enum.zip(columns, col_widths)
              |> Enum.map(fn {col, width} ->
                value = UnifiedUi.Table.Sort.get_value(row, col.key)
                formatted = apply_formatter(col.formatter, value)
                align_text(formatted, width, col.align)
              end)

            # Highlight selected row
            row_text = "| " <> Enum.join(cells, " | ") <> " |"

            if table.selected_row == idx do
              # Use reverse attribute for selection (would need style support)
              row_text
            else
              row_text
            end
          end)

        # Combine all parts
        header = "| " <> Enum.join(header_cells, " | ") <> " |"
        rows = [separator, header, separator] ++ data_rows ++ [separator]

        Enum.join(rows, "\n")
      else
        "No columns defined"
      end

    # Create text node
    text_node = TermUI.Component.Helpers.text(table_text)

    # Apply style if present
    style = Style.convert_style(table.style)

    styled_node =
      if style do
        TermUI.Component.Helpers.styled(text_node, style)
      else
        text_node
      end

    # Wrap with metadata for event handling
    {:table, styled_node,
     %{
       id: table.id,
       columns: columns,
       data: data,
       selected_row: table.selected_row,
       on_row_select: table.on_row_select,
       on_sort: table.on_sort,
       sort_column: table.sort_column,
       sort_direction: table.sort_direction
     }}
  end

  # Navigation widget converters

  defp convert_by_type(%Widgets.MenuItem{} = item, :menu_item, _state) do
    # Build label with optional icon and shortcut
    icon_part = if item.icon, do: "[#{item.icon}] ", else: ""
    shortcut_part = if item.shortcut, do: " (#{item.shortcut})", else: ""
    disabled_indicator = if item.disabled, do: "× ", else: ""
    submenu_indicator = if item.submenu != nil, do: " >", else: ""

    label_text =
      "#{disabled_indicator}#{icon_part}#{item.label}#{shortcut_part}#{submenu_indicator}"

    # Create text node
    text_node = TermUI.Component.Helpers.text(label_text)

    # Wrap with metadata
    {:menu_item, text_node,
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

    # Build menu title line if present
    title_line =
      if menu.title do
        title_text =
          if menu.position == :top do
            "── #{menu.title} ──"
          else
            "#{menu.title}"
          end

        [TermUI.Component.Helpers.text(title_text)]
      else
        []
      end

    # Combine title and items
    all_children = title_line ++ items

    # Create vertical stack for menu
    menu_node = TermUI.Component.Helpers.stack(:vertical, all_children, spacing: 0)

    # Apply style if present
    style = Style.convert_style(menu.style)

    styled_node =
      if style do
        TermUI.Component.Helpers.styled(menu_node, style)
      else
        menu_node
      end

    # Wrap with metadata
    {:menu, styled_node,
     %{
       id: menu.id,
       title: menu.title,
       position: menu.position
     }}
  end

  defp convert_by_type(%Widgets.ContextMenu{} = menu, :context_menu, state) do
    # Convert menu items (same as regular menu)
    items =
      Enum.map(menu.items || [], fn item ->
        convert_iur(item, state)
      end)

    # Create vertical stack for context menu
    menu_node = TermUI.Component.Helpers.stack(:vertical, items, spacing: 0)

    # Apply style if present
    style = Style.convert_style(menu.style)

    styled_node =
      if style do
        TermUI.Component.Helpers.styled(menu_node, style)
      else
        menu_node
      end

    # Wrap with metadata for context menu handling
    {:context_menu, styled_node,
     %{
       id: menu.id,
       trigger_on: menu.trigger_on
     }}
  end

  defp convert_by_type(%Widgets.Tab{} = tab, :tab, _state) do
    # Build tab label with icon
    icon_part = if tab.icon, do: "[#{tab.icon}] ", else: ""
    disabled_indicator = if tab.disabled, do: "(×) ", else: ""
    closable_indicator = if tab.closable, do: " ×", else: ""

    label_text = "#{disabled_indicator}#{icon_part}#{tab.label}#{closable_indicator}"

    # Create text node for tab
    text_node = TermUI.Component.Helpers.text(label_text)

    # Wrap with metadata
    {:tab, text_node,
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
    # Convert tab headers only
    tab_headers =
      Enum.map(tabs.tabs || [], fn tab ->
        convert_iur(tab, state)
      end)

    # Build tab bar as horizontal stack
    tab_bar = TermUI.Component.Helpers.stack(:horizontal, tab_headers, spacing: 2)

    # Apply style if present
    style = Style.convert_style(tabs.style)

    styled_tab_bar =
      if style do
        TermUI.Component.Helpers.styled(tab_bar, style)
      else
        tab_bar
      end

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

    # Combine tab bar and active content
    children = [styled_tab_bar | if(active_content, do: [active_content], else: [])]

    tabs_node = TermUI.Component.Helpers.stack(:vertical, children, spacing: 1)

    # Wrap with metadata
    {:tabs, tabs_node,
     %{
       id: tabs.id,
       active_tab: tabs.active_tab,
       position: tabs.position,
       on_change: tabs.on_change,
       tabs: tabs.tabs
     }}
  end

  defp convert_by_type(%Widgets.TreeNode{} = node, :tree_node, state) do
    # Build tree node label with expand/collapse indicator
    expand_indicator =
      if node.children != nil do
        if node.expanded, do: "[-] ", else: "[+] "
      else
        "    "
      end

    icon_part =
      if node.icon do
        icon_to_use =
          if node.expanded and node.icon_expanded do
            node.icon_expanded
          else
            node.icon
          end

        "[#{icon_to_use}] "
      else
        ""
      end

    label_text = "#{expand_indicator}#{icon_part}#{node.label}"

    # Create text node for tree node
    text_node = TermUI.Component.Helpers.text(label_text)

    # Convert children if expanded
    child_nodes =
      if node.expanded and node.children != nil do
        Enum.map(node.children, fn child ->
          # Indent child nodes
          child_node = convert_iur(child, state)
          # Add indentation by wrapping in a styled container
          child_node
        end)
      else
        []
      end

    # Wrap with metadata
    {:tree_node, text_node,
     %{
       id: node.id,
       label: node.label,
       value: node.value,
       expanded: node.expanded,
       icon: node.icon,
       icon_expanded: node.icon_expanded,
       selectable: node.selectable,
       has_children: node.children != nil,
       children: child_nodes
     }}
  end

  defp convert_by_type(%Widgets.TreeView{} = tree, :tree_view, state) do
    # Convert root nodes
    root_nodes =
      Enum.map(tree.root_nodes || [], fn node ->
        convert_iur(node, state)
      end)

    # Create vertical stack for tree
    tree_node = TermUI.Component.Helpers.stack(:vertical, root_nodes, spacing: 0)

    # Apply style if present
    style = Style.convert_style(tree.style)

    styled_node =
      if style do
        TermUI.Component.Helpers.styled(tree_node, style)
      else
        tree_node
      end

    # Wrap with metadata
    {:tree_view, styled_node,
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
    role_prefix =
      case button.role do
        :confirm -> "✓ "
        :cancel -> "↩ "
        :destructive -> "! "
        _ -> ""
      end

    disabled_prefix = if button.disabled, do: "(×) ", else: ""
    text_node = TermUI.Component.Helpers.text("[#{disabled_prefix}#{role_prefix}#{button.label}]")

    styled_node =
      case Style.convert_style(button.style) do
        nil -> text_node
        style -> TermUI.Component.Helpers.styled(text_node, style)
      end

    {:dialog_button, styled_node,
     %{
       id: button.id,
       label: button.label,
       action: button.action,
       role: button.role,
       disabled: button.disabled
     }}
  end

  defp convert_by_type(%Widgets.Dialog{} = dialog, :dialog, state) do
    title_node = TermUI.Component.Helpers.text("┌ #{dialog.title || "Dialog"} ┐")

    content_node =
      case dialog.content do
        nil ->
          nil

        content when is_list(content) ->
          converted =
            content
            |> Enum.map(fn item ->
              if is_binary(item),
                do: TermUI.Component.Helpers.text(item),
                else: convert_iur(item, state)
            end)
            |> Enum.reject(&is_nil/1)

          TermUI.Component.Helpers.stack(:vertical, converted, spacing: 0)

        content ->
          if is_binary(content),
            do: TermUI.Component.Helpers.text(content),
            else: convert_iur(content, state)
      end

    button_nodes =
      dialog.buttons
      |> List.wrap()
      |> Enum.map(&convert_iur(&1, state))
      |> Enum.reject(&is_nil/1)

    buttons_row =
      if button_nodes == [] do
        nil
      else
        TermUI.Component.Helpers.stack(:horizontal, button_nodes, spacing: 1)
      end

    children =
      [title_node, content_node, buttons_row]
      |> Enum.reject(&is_nil/1)

    dialog_node = TermUI.Component.Helpers.stack(:vertical, children, spacing: 1)

    styled_node =
      case Style.convert_style(dialog.style) do
        nil -> dialog_node
        style -> TermUI.Component.Helpers.styled(dialog_node, style)
      end

    {:dialog, styled_node,
     %{
       id: dialog.id,
       title: dialog.title,
       on_close: dialog.on_close,
       width: dialog.width,
       height: dialog.height,
       closable: dialog.closable,
       modal: dialog.modal,
       blocks_background: dialog.modal == true
     }}
  end

  defp convert_by_type(%Widgets.AlertDialog{} = alert, :alert_dialog, _state) do
    severity_label =
      case alert.severity do
        :success -> "SUCCESS"
        :warning -> "WARNING"
        :error -> "ERROR"
        _ -> "INFO"
      end

    lines = [
      "[#{severity_label}] #{alert.title || "Alert"}",
      alert.message || ""
    ]

    text_node = TermUI.Component.Helpers.text(Enum.join(lines, "\n"))

    styled_node =
      case Style.convert_style(alert.style) do
        nil -> text_node
        style -> TermUI.Component.Helpers.styled(text_node, style)
      end

    {:alert_dialog, styled_node,
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

    prefix =
      case toast.severity do
        :success -> "✓ "
        :warning -> "! "
        :error -> "✖ "
        _ -> "i "
      end

    text_node = TermUI.Component.Helpers.text("#{prefix}#{toast.message || ""}")

    styled_node =
      case Style.convert_style(toast.style) do
        nil -> text_node
        style -> TermUI.Component.Helpers.styled(text_node, style)
      end

    {:toast, styled_node,
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
    content_node =
      case viewport.content do
        nil -> TermUI.Component.Helpers.empty()
        content -> convert_iur(content, state)
      end

    viewport_node =
      if viewport.border in [true, :solid, :dashed, :double] do
        TermUI.Component.Helpers.stack(:vertical, [content_node], spacing: 0)
      else
        content_node
      end

    styled_node =
      case Style.convert_style(viewport.style) do
        nil -> viewport_node
        style -> TermUI.Component.Helpers.styled(viewport_node, style)
      end

    {:viewport, styled_node,
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
    pane_nodes = convert_children(split_pane.panes, state)
    direction = if split_pane.orientation == :vertical, do: :vertical, else: :horizontal
    split_node = TermUI.Component.Helpers.stack(direction, pane_nodes, spacing: 0)

    styled_node =
      case Style.convert_style(split_pane.style) do
        nil -> split_node
        style -> TermUI.Component.Helpers.styled(split_node, style)
      end

    {:split_pane, styled_node,
     %{
       id: split_pane.id,
       orientation: split_pane.orientation,
       initial_split: split_pane.initial_split,
       min_size: split_pane.min_size,
       on_resize_change: split_pane.on_resize_change
     }}
  end

  defp convert_by_type(%Canvas{} = canvas, :canvas, _state) do
    base_node =
      TermUI.Component.Helpers.stack(:vertical, [TermUI.Component.Helpers.empty()], spacing: 0)

    styled_node =
      case Style.convert_style(canvas.style) do
        nil -> base_node
        style -> TermUI.Component.Helpers.styled(base_node, style)
      end

    {:canvas, styled_node,
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

    text_node =
      TermUI.Component.Helpers.text(palette.placeholder || "Type a command...")

    styled_node =
      case Style.convert_style(palette.style) do
        nil -> text_node
        style -> TermUI.Component.Helpers.styled(text_node, style)
      end

    {:command_palette, styled_node,
     %{
       id: palette.id,
       placeholder: palette.placeholder,
       trigger_shortcut: palette.trigger_shortcut,
       on_select: palette.on_select,
       commands: commands
     }}
  end

  defp convert_by_type(%LogViewer{} = log_viewer, :log_viewer, _state) do
    label = "Log Viewer (#{log_viewer.lines} lines)"
    text_node = TermUI.Component.Helpers.text(label)

    styled_node =
      case Style.convert_style(log_viewer.style) do
        nil -> text_node
        style -> TermUI.Component.Helpers.styled(text_node, style)
      end

    {:log_viewer, styled_node,
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
    text_node = TermUI.Component.Helpers.text("Stream Widget")

    styled_node =
      case Style.convert_style(stream_widget.style) do
        nil -> text_node
        style -> TermUI.Component.Helpers.styled(text_node, style)
      end

    {:stream_widget, styled_node,
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
    node_label = if process_monitor.node, do: process_monitor.node, else: node()
    text_node = TermUI.Component.Helpers.text("Process Monitor (#{node_label})")

    styled_node =
      case Style.convert_style(process_monitor.style) do
        nil -> text_node
        style -> TermUI.Component.Helpers.styled(text_node, style)
      end

    {:process_monitor, styled_node,
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
    tracks = normalize_grid_tracks(grid.columns)
    column_count = max(length(tracks), 1)

    row_nodes =
      children
      |> Enum.chunk_every(column_count)
      |> Enum.map(fn row ->
        TermUI.Component.Helpers.stack(:horizontal, row, spacing: grid.gap)
      end)

    grid_node = TermUI.Component.Helpers.stack(:vertical, row_nodes, spacing: grid.gap)

    styled_node =
      case Style.convert_style(grid.style) do
        nil -> grid_node
        style -> TermUI.Component.Helpers.styled(grid_node, style)
      end

    {:grid, styled_node,
     %{
       id: grid.id,
       columns: tracks,
       rows: normalize_grid_tracks(grid.rows),
       gap: grid.gap,
       column_count: column_count
     }}
  end

  defp convert_by_type(%Stack{} = stack, :stack, state) do
    children = convert_children(stack.children, state)
    active_index = normalize_active_index(stack.active_index, length(children))

    active_child =
      case Enum.at(children, active_index) do
        nil -> TermUI.Component.Helpers.empty()
        child -> child
      end

    stack_node = TermUI.Component.Helpers.stack(:vertical, [active_child], spacing: 0)

    styled_node =
      case Style.convert_style(stack.style) do
        nil -> stack_node
        style -> TermUI.Component.Helpers.styled(stack_node, style)
      end

    {:stack, styled_node,
     %{
       id: stack.id,
       active_index: active_index,
       child_count: length(children),
       transition: stack.transition
     }}
  end

  defp convert_by_type(%ZBox{} = zbox, :zbox, state) do
    children = convert_children(zbox.children, state)
    stacked = TermUI.Component.Helpers.stack(:vertical, children, spacing: 0)

    styled_node =
      case Style.convert_style(zbox.style) do
        nil -> stacked
        style -> TermUI.Component.Helpers.styled(stacked, style)
      end

    {:zbox, styled_node,
     %{
       id: zbox.id,
       positions: normalize_zbox_positions(zbox.positions),
       child_count: length(children)
     }}
  end

  defp convert_by_type(%Layouts.VBox{} = vbox, :vbox, state) do
    children = convert_children(vbox.children, state)

    # Build stack options
    opts =
      []
      |> maybe_add_spacing(vbox.spacing)
      |> maybe_add_padding(vbox.padding)
      |> maybe_add_align(vbox.align_items)
      |> maybe_add_justify(vbox.justify_content)

    # Add style if present
    style = Style.convert_style(vbox.style)

    stack_node = TermUI.Component.Helpers.stack(:vertical, children, opts)

    if style do
      TermUI.Component.Helpers.styled(stack_node, style)
    else
      stack_node
    end
  end

  defp convert_by_type(%Layouts.HBox{} = hbox, :hbox, state) do
    children = convert_children(hbox.children, state)

    # Build stack options
    opts =
      []
      |> maybe_add_spacing(hbox.spacing)
      |> maybe_add_padding(hbox.padding)
      |> maybe_add_align(hbox.align_items)
      |> maybe_add_justify(hbox.justify_content)

    # Add style if present
    style = Style.convert_style(hbox.style)

    stack_node = TermUI.Component.Helpers.stack(:horizontal, children, opts)

    if style do
      TermUI.Component.Helpers.styled(stack_node, style)
    else
      stack_node
    end
  end

  # Fallback for unknown types
  defp convert_by_type(_element, _type, _state) do
    # Return empty node for unknown element types
    TermUI.Component.Helpers.empty()
  end

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

  # Helper functions

  defp convert_children(children, state) when is_list(children) do
    children
    |> Enum.map(fn child -> convert_iur(child, state) end)
    |> Enum.reject(&is_nil/1)
  end

  defp convert_children(_, _state), do: []

  defp maybe_add_spacing(opts, nil), do: opts

  defp maybe_add_spacing(opts, spacing) when is_integer(spacing),
    do: Keyword.put(opts, :spacing, spacing)

  defp maybe_add_padding(opts, nil), do: opts

  defp maybe_add_padding(opts, padding) when is_integer(padding),
    do: Keyword.put(opts, :padding, padding)

  defp maybe_add_align(opts, nil), do: opts
  defp maybe_add_align(opts, align), do: Keyword.put(opts, :align, align)

  defp maybe_add_justify(opts, nil), do: opts
  defp maybe_add_justify(opts, justify), do: Keyword.put(opts, :justify, justify)

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

  # Table rendering helpers

  defp extract_keys(row) when is_map(row) do
    row |> Map.keys() |> Enum.sort()
  end

  defp extract_keys(row) when is_list(row) do
    Keyword.keys(row)
  end

  defp apply_formatter(nil, value), do: format_value(value)
  defp apply_formatter(formatter, value) when is_function(formatter, 1), do: formatter.(value)
  defp apply_formatter(_formatter, value), do: format_value(value)

  defp format_value(nil), do: ""
  defp format_value(value) when is_binary(value), do: value
  defp format_value(value) when is_atom(value), do: to_string(value)
  defp format_value(value), do: inspect(value, limit: 50)

  defp align_text(text, width, :left), do: String.pad_trailing(to_string(text), width)
  defp align_text(text, width, :right), do: String.pad_leading(to_string(text), width)

  defp align_text(text, width, :center) do
    str = to_string(text)
    padding = width - String.length(str)
    left_pad = div(padding, 2)
    right_pad = padding - left_pad
    String.duplicate(" ", left_pad) <> str <> String.duplicate(" ", right_pad)
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
    expected_direction = layout_direction(module)

    with true <- layout_signature(iur_tree) == layout_signature(previous_iur),
         {:ok, rendered_children, rebuild_root} <-
           extract_layout_children(state.root, expected_direction),
         true <- same_child_count?(iur_tree.children, previous_iur.children, rendered_children),
         {:ok, patched_children, reused_children, re_rendered_children} <-
           patch_children(iur_tree.children, previous_iur.children, rendered_children, state) do
      {:ok, rebuild_root.(patched_children), reused_children, re_rendered_children}
    else
      _ -> :error
    end
  end

  defp patch_root_layout_children(_, _, _), do: :error

  defp layout_direction(Layouts.VBox), do: :vertical
  defp layout_direction(Layouts.HBox), do: :horizontal

  defp layout_signature(%_{} = layout) do
    layout
    |> Map.from_struct()
    |> Map.drop([:children])
  end

  defp extract_layout_children(
         %{type: :stack, direction: direction, children: rendered_children} = root,
         expected_direction
       )
       when direction == expected_direction and is_list(rendered_children) do
    {:ok, rendered_children,
     fn patched_children -> Map.put(root, :children, patched_children) end}
  end

  defp extract_layout_children(
         %{
           type: :box,
           children: [
             %{type: :stack, direction: direction, children: rendered_children} = stack | rest
           ]
         } =
           root,
         expected_direction
       )
       when direction == expected_direction and is_list(rendered_children) do
    {:ok, rendered_children,
     fn patched_children ->
       patched_stack = Map.put(stack, :children, patched_children)
       Map.put(root, :children, [patched_stack | rest])
     end}
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
    expected_direction = layout_direction(module)

    with true <- layout_signature(new_layout) == layout_signature(old_layout),
         {:ok, rendered_children, rebuild_child} <-
           extract_layout_children(rendered_child, expected_direction),
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
