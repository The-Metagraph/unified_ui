defmodule UnifiedUi.IUR.Builder do
  @moduledoc """
  Builds Intermediate UI Representation (IUR) trees from DSL definitions.

  This module traverses the Spark DSL state and converts DSL entities
  into their corresponding IUR structs. It handles nested structures
  recursively and applies style resolution during the build process.

  ## Usage

  The builder is typically used within the ViewTransformer to generate
  the view/1 function that returns the IUR tree.

      def view(state) do
        Builder.build(dsl_state)
      end

  ## Entity Conversion

  Each DSL entity type has a corresponding build function:

  | DSL Entity | IUR Struct | Build Function |
  |------------|-----------|---------------|
  | button | Widgets.Button | build_button/2 |
  | text | Widgets.Text | build_text/2 |
  | label | Widgets.Label | build_label/2 |
  | text_input | Widgets.TextInput | build_text_input/2 |
  | vbox | Layouts.VBox | build_vbox/2 |
  | hbox | Layouts.HBox | build_hbox/2 |
  | gauge | Widgets.Gauge | build_gauge/2 |
  | sparkline | Widgets.Sparkline | build_sparkline/2 |
  | bar_chart | Widgets.BarChart | build_bar_chart/2 |
  | line_chart | Widgets.LineChart | build_line_chart/2 |
  | table | Widgets.Table | build_table/2 |

  ## Style Handling

  Styles can be specified in multiple ways:
  * Inline keyword list: `style: [fg: :blue, attrs: [:bold]]`
  * Named style reference: `style: :header`
  * Named style with overrides: `style: [:header, fg: :green]`

  The builder resolves all style references to IUR.Style structs.

  ## Nesting

  Layout entities can contain nested widgets and layouts. The builder
  recursively processes children, preserving the hierarchical structure.

  ## Examples

  Given a DSL with:

      ui do
        vbox spacing: 1 do
          text "Welcome"
          button "Start", on_click: :start
        end
      end

  The builder produces:

      %VBox{
        spacing: 1,
        children: [
          %Text{content: "Welcome"},
          %Button{label: "Start", on_click: :start}
        ]
      }
  """

  alias UnifiedIUR.{Style, Widgets, Layouts}
  alias UnifiedUi.Dsl.StyleResolver

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

  alias Spark.Dsl

  @doc """
  Builds an IUR tree from the DSL state.

  Extracts entities from the [:ui] section and converts them to IUR structs.
  Returns the root IUR element (typically a layout).

  ## Examples

      iex> {:ok, iur} = Builder.build(dsl_state)
      iex> is_struct(iur, VBox) or is_struct(iur, HBox)
      true

  """
  @spec build(Dsl.t()) :: struct() | nil
  def build(dsl_state) do
    build(dsl_state, %{})
  end

  @doc """
  Builds an IUR tree from the DSL state using runtime state context.

  Runtime state is used for dynamic theme resolution (for example `state.theme`).
  """
  @spec build(Dsl.t(), map()) :: struct() | nil
  def build(dsl_state, runtime_state) when is_map(runtime_state) do
    dsl_state_with_runtime = Map.put(dsl_state, :__runtime_state__, runtime_state)

    dsl_state_with_runtime
    |> collect_root_entities()
    |> Enum.find_value(fn entity -> build_entity(entity, dsl_state_with_runtime) end)
    |> resolve_state_refs(runtime_state)
  end

  @doc """
  Converts a single DSL entity to its corresponding IUR struct.

  Dispatches to the appropriate build function based on entity type.
  """
  @spec build_entity(map() | struct(), Dsl.t()) :: struct() | nil
  def build_entity(%module{} = entity, _dsl_state)
      when module in [
             Layouts.VBox,
             Layouts.HBox,
             Grid,
             Stack,
             ZBox,
             Widgets.Button,
             Widgets.Text,
             Widgets.Label,
             Widgets.TextInput,
             Widgets.Gauge,
             Widgets.Sparkline,
             Widgets.BarChart,
             Widgets.LineChart,
             Widgets.Table,
             Widgets.Column,
             Widgets.Menu,
             Widgets.MenuItem,
             Widgets.ContextMenu,
             Widgets.Tabs,
             Widgets.Tab,
             Widgets.TreeView,
             Widgets.TreeNode,
             Widgets.DialogButton,
             Widgets.Dialog,
             Widgets.AlertDialog,
             Widgets.Toast,
             Widgets.PickListOption,
             Widgets.PickList,
             Widgets.FormField,
             Widgets.FormBuilder,
             Canvas,
             Command,
             CommandPalette,
             LogViewer,
             StreamWidget,
             ProcessMonitor,
             Viewport,
             SplitPane
           ] do
    entity
  end

  def build_entity(%{name: :button} = entity, dsl_state) do
    build_button(entity, dsl_state)
  end

  def build_entity(%{name: :text} = entity, dsl_state) do
    build_text(entity, dsl_state)
  end

  def build_entity(%{name: :label} = entity, dsl_state) do
    build_label(entity, dsl_state)
  end

  def build_entity(%{name: :text_input} = entity, dsl_state) do
    build_text_input(entity, dsl_state)
  end

  def build_entity(%{name: :vbox} = entity, dsl_state) do
    build_vbox(entity, dsl_state)
  end

  def build_entity(%{name: :hbox} = entity, dsl_state) do
    build_hbox(entity, dsl_state)
  end

  def build_entity(%{name: :grid} = entity, dsl_state) do
    build_grid(entity, dsl_state)
  end

  def build_entity(%{name: :stack} = entity, dsl_state) do
    build_stack(entity, dsl_state)
  end

  def build_entity(%{name: :zbox} = entity, dsl_state) do
    build_zbox(entity, dsl_state)
  end

  def build_entity(%{name: :gauge} = entity, dsl_state) do
    build_gauge(entity, dsl_state)
  end

  def build_entity(%{name: :sparkline} = entity, dsl_state) do
    build_sparkline(entity, dsl_state)
  end

  def build_entity(%{name: :bar_chart} = entity, dsl_state) do
    build_bar_chart(entity, dsl_state)
  end

  def build_entity(%{name: :line_chart} = entity, dsl_state) do
    build_line_chart(entity, dsl_state)
  end

  def build_entity(%{name: :table} = entity, dsl_state) do
    build_table(entity, dsl_state)
  end

  def build_entity(%{name: :column} = entity, dsl_state) do
    build_column(entity, dsl_state)
  end

  def build_entity(%{name: :menu} = entity, dsl_state) do
    build_menu(entity, dsl_state)
  end

  def build_entity(%{name: :context_menu} = entity, dsl_state) do
    build_context_menu(entity, dsl_state)
  end

  def build_entity(%{name: :tabs} = entity, dsl_state) do
    build_tabs(entity, dsl_state)
  end

  def build_entity(%{name: :tree_view} = entity, dsl_state) do
    build_tree_view(entity, dsl_state)
  end

  def build_entity(%{name: :dialog_button} = entity, dsl_state) do
    build_dialog_button(entity, dsl_state)
  end

  def build_entity(%{name: :dialog} = entity, dsl_state) do
    build_dialog(entity, dsl_state)
  end

  def build_entity(%{name: :alert_dialog} = entity, dsl_state) do
    build_alert_dialog(entity, dsl_state)
  end

  def build_entity(%{name: :toast} = entity, dsl_state) do
    build_toast(entity, dsl_state)
  end

  def build_entity(%{name: :pick_list_option} = entity, dsl_state) do
    build_pick_list_option(entity, dsl_state)
  end

  def build_entity(%{name: :pick_list} = entity, dsl_state) do
    build_pick_list(entity, dsl_state)
  end

  def build_entity(%{name: :form_field} = entity, dsl_state) do
    build_form_field(entity, dsl_state)
  end

  def build_entity(%{name: :form_builder} = entity, dsl_state) do
    build_form_builder(entity, dsl_state)
  end

  def build_entity(%{name: :viewport} = entity, dsl_state) do
    build_viewport(entity, dsl_state)
  end

  def build_entity(%{name: :split_pane} = entity, dsl_state) do
    build_split_pane(entity, dsl_state)
  end

  def build_entity(%{name: :canvas} = entity, dsl_state) do
    build_canvas(entity, dsl_state)
  end

  def build_entity(%{name: :command} = entity, dsl_state) do
    build_command(entity, dsl_state)
  end

  def build_entity(%{name: :command_palette} = entity, dsl_state) do
    build_command_palette(entity, dsl_state)
  end

  def build_entity(%{name: :log_viewer} = entity, dsl_state) do
    build_log_viewer(entity, dsl_state)
  end

  def build_entity(%{name: :stream_widget} = entity, dsl_state) do
    build_stream_widget(entity, dsl_state)
  end

  def build_entity(%{name: :process_monitor} = entity, dsl_state) do
    build_process_monitor(entity, dsl_state)
  end

  def build_entity(_entity, _dsl_state) do
    # Unknown entity type, return nil
    nil
  end

  # Widget builders

  @doc """
  Builds a Button IUR struct from a button DSL entity.
  """
  @spec build_button(map(), Dsl.t()) :: Widgets.Button.t()
  def build_button(entity, dsl_state) do
    attrs = get_entity_attrs(entity, dsl_state)

    %Widgets.Button{
      label: Map.get(attrs, :label),
      on_click: Map.get(attrs, :on_click),
      id: Map.get(attrs, :id),
      disabled: Map.get(attrs, :disabled, false),
      visible: Map.get(attrs, :visible, true),
      style: build_style(Map.get(attrs, :style), dsl_state)
    }
  end

  @doc """
  Builds a Text IUR struct from a text DSL entity.
  """
  @spec build_text(map(), Dsl.t()) :: Widgets.Text.t()
  def build_text(entity, dsl_state) do
    attrs = get_entity_attrs(entity, dsl_state)

    %Widgets.Text{
      content: Map.get(attrs, :content),
      id: Map.get(attrs, :id),
      visible: Map.get(attrs, :visible, true),
      style: build_style(Map.get(attrs, :style), dsl_state)
    }
  end

  @doc """
  Builds a Label IUR struct from a label DSL entity.
  """
  @spec build_label(map(), Dsl.t()) :: Widgets.Label.t()
  def build_label(entity, dsl_state) do
    attrs = get_entity_attrs(entity, dsl_state)

    %Widgets.Label{
      for: Map.get(attrs, :for),
      text: Map.get(attrs, :text),
      id: Map.get(attrs, :id),
      visible: Map.get(attrs, :visible, true),
      style: build_style(Map.get(attrs, :style), dsl_state)
    }
  end

  @doc """
  Builds a TextInput IUR struct from a text_input DSL entity.
  """
  @spec build_text_input(map(), Dsl.t()) :: Widgets.TextInput.t()
  def build_text_input(entity, dsl_state) do
    attrs = get_entity_attrs(entity, dsl_state)

    %Widgets.TextInput{
      id: Map.get(attrs, :id),
      value: Map.get(attrs, :value),
      placeholder: Map.get(attrs, :placeholder),
      type: Map.get(attrs, :type, :text),
      on_change: Map.get(attrs, :on_change),
      on_submit: Map.get(attrs, :on_submit),
      form_id: Map.get(attrs, :form_id),
      disabled: Map.get(attrs, :disabled, false),
      visible: Map.get(attrs, :visible, true),
      style: build_style(Map.get(attrs, :style), dsl_state)
    }
  end

  # Data visualization builders

  @doc """
  Builds a Gauge IUR struct from a gauge DSL entity.
  """
  @spec build_gauge(map(), Dsl.t()) :: Widgets.Gauge.t()
  def build_gauge(entity, dsl_state) do
    attrs = get_entity_attrs(entity, dsl_state)

    %Widgets.Gauge{
      id: Map.get(attrs, :id),
      value: Map.get(attrs, :value),
      min: Map.get(attrs, :min, 0),
      max: Map.get(attrs, :max, 100),
      label: Map.get(attrs, :label),
      width: Map.get(attrs, :width),
      height: Map.get(attrs, :height),
      color_zones: Map.get(attrs, :color_zones),
      visible: Map.get(attrs, :visible, true),
      style: build_style(Map.get(attrs, :style), dsl_state)
    }
  end

  @doc """
  Builds a Sparkline IUR struct from a sparkline DSL entity.
  """
  @spec build_sparkline(map(), Dsl.t()) :: Widgets.Sparkline.t()
  def build_sparkline(entity, dsl_state) do
    attrs = get_entity_attrs(entity, dsl_state)

    %Widgets.Sparkline{
      id: Map.get(attrs, :id),
      data: Map.get(attrs, :data),
      width: Map.get(attrs, :width),
      height: Map.get(attrs, :height),
      color: Map.get(attrs, :color),
      show_dots: Map.get(attrs, :show_dots, false),
      show_area: Map.get(attrs, :show_area, false),
      visible: Map.get(attrs, :visible, true),
      style: build_style(Map.get(attrs, :style), dsl_state)
    }
  end

  @doc """
  Builds a BarChart IUR struct from a bar_chart DSL entity.
  """
  @spec build_bar_chart(map(), Dsl.t()) :: Widgets.BarChart.t()
  def build_bar_chart(entity, dsl_state) do
    attrs = get_entity_attrs(entity, dsl_state)

    %Widgets.BarChart{
      id: Map.get(attrs, :id),
      data: Map.get(attrs, :data),
      width: Map.get(attrs, :width),
      height: Map.get(attrs, :height),
      orientation: Map.get(attrs, :orientation, :horizontal),
      show_labels: Map.get(attrs, :show_labels, true),
      visible: Map.get(attrs, :visible, true),
      style: build_style(Map.get(attrs, :style), dsl_state)
    }
  end

  @doc """
  Builds a LineChart IUR struct from a line_chart DSL entity.
  """
  @spec build_line_chart(map(), Dsl.t()) :: Widgets.LineChart.t()
  def build_line_chart(entity, dsl_state) do
    attrs = get_entity_attrs(entity, dsl_state)

    %Widgets.LineChart{
      id: Map.get(attrs, :id),
      data: Map.get(attrs, :data),
      width: Map.get(attrs, :width),
      height: Map.get(attrs, :height),
      show_dots: Map.get(attrs, :show_dots, true),
      show_area: Map.get(attrs, :show_area, false),
      visible: Map.get(attrs, :visible, true),
      style: build_style(Map.get(attrs, :style), dsl_state)
    }
  end

  # Table builders

  @doc """
  Builds a Table IUR struct from a table DSL entity.
  """
  @spec build_table(map(), Dsl.t()) :: Widgets.Table.t()
  def build_table(entity, dsl_state) do
    attrs = get_entity_attrs(entity, dsl_state)

    columns =
      case build_nested_entities(entity, dsl_state, :columns, &build_column/2,
             child_name: :column
           ) do
        [] -> normalize_columns(Map.get(attrs, :columns), dsl_state)
        nested -> nested
      end

    %Widgets.Table{
      id: Map.get(attrs, :id),
      data: Map.get(attrs, :data, []),
      columns: columns,
      selected_row: Map.get(attrs, :selected_row),
      height: Map.get(attrs, :height),
      on_row_select: Map.get(attrs, :on_row_select),
      on_sort: Map.get(attrs, :on_sort),
      sort_column: Map.get(attrs, :sort_column),
      sort_direction: Map.get(attrs, :sort_direction, :asc),
      visible: Map.get(attrs, :visible, true),
      style: build_style(Map.get(attrs, :style), dsl_state)
    }
  end

  @doc """
  Builds a Column IUR struct from a column DSL entity.
  """
  @spec build_column(map(), Dsl.t()) :: Widgets.Column.t()
  def build_column(entity, dsl_state) do
    attrs = get_entity_attrs(entity, dsl_state)

    %Widgets.Column{
      key: Map.get(attrs, :key),
      header: Map.get(attrs, :header),
      sortable: Map.get(attrs, :sortable, true),
      formatter: Map.get(attrs, :formatter),
      width: Map.get(attrs, :width),
      align: Map.get(attrs, :align, :left)
    }
  end

  # Layout builders

  @doc """
  Builds a VBox IUR struct from a vbox DSL entity.

  Recursively builds all children.
  """
  @spec build_vbox(map(), Dsl.t()) :: Layouts.VBox.t()
  def build_vbox(entity, dsl_state) do
    attrs = get_entity_attrs(entity, dsl_state)
    children = build_children(entity, dsl_state)

    %Layouts.VBox{
      id: Map.get(attrs, :id),
      spacing: Map.get(attrs, :spacing, 0),
      align_items: Map.get(attrs, :align_items),
      justify_content: Map.get(attrs, :justify_content),
      padding: Map.get(attrs, :padding),
      visible: Map.get(attrs, :visible, true),
      style: build_style(Map.get(attrs, :style), dsl_state),
      children: children
    }
  end

  @doc """
  Builds an HBox IUR struct from an hbox DSL entity.

  Recursively builds all children.
  """
  @spec build_hbox(map(), Dsl.t()) :: Layouts.HBox.t()
  def build_hbox(entity, dsl_state) do
    attrs = get_entity_attrs(entity, dsl_state)
    children = build_children(entity, dsl_state)

    %Layouts.HBox{
      id: Map.get(attrs, :id),
      spacing: Map.get(attrs, :spacing, 0),
      align_items: Map.get(attrs, :align_items),
      justify_content: Map.get(attrs, :justify_content),
      padding: Map.get(attrs, :padding),
      visible: Map.get(attrs, :visible, true),
      style: build_style(Map.get(attrs, :style), dsl_state),
      children: children
    }
  end

  @doc """
  Builds a Grid layout struct from a grid DSL entity.

  Supports children provided through nested entities and/or `children` args.
  """
  @spec build_grid(map(), Dsl.t()) :: Grid.t()
  def build_grid(entity, dsl_state) do
    attrs = get_entity_attrs(entity, dsl_state)
    children = resolve_advanced_layout_children(entity, dsl_state)

    %Grid{
      id: Map.get(attrs, :id),
      children: children,
      columns: normalize_grid_tracks(Map.get(attrs, :columns, [1])),
      rows: normalize_grid_tracks(Map.get(attrs, :rows, [])),
      gap: normalize_non_negative_integer(Map.get(attrs, :gap, 0), 0),
      visible: Map.get(attrs, :visible, true),
      style: build_style(Map.get(attrs, :style), dsl_state)
    }
  end

  @doc """
  Builds a Stack layout struct from a stack DSL entity.

  Supports children provided through nested entities and/or `children` args.
  """
  @spec build_stack(map(), Dsl.t()) :: Stack.t()
  def build_stack(entity, dsl_state) do
    attrs = get_entity_attrs(entity, dsl_state)
    children = resolve_advanced_layout_children(entity, dsl_state)

    %Stack{
      id: Map.get(attrs, :id),
      children: children,
      active_index: normalize_non_negative_integer(Map.get(attrs, :active_index, 0), 0),
      transition: Map.get(attrs, :transition),
      visible: Map.get(attrs, :visible, true),
      style: build_style(Map.get(attrs, :style), dsl_state)
    }
  end

  @doc """
  Builds a ZBox layout struct from a zbox DSL entity.

  Supports children provided through nested entities and/or `children` args.
  """
  @spec build_zbox(map(), Dsl.t()) :: ZBox.t()
  def build_zbox(entity, dsl_state) do
    attrs = get_entity_attrs(entity, dsl_state)
    children = resolve_advanced_layout_children(entity, dsl_state)

    %ZBox{
      id: Map.get(attrs, :id),
      children: children,
      positions: normalize_zbox_positions(Map.get(attrs, :positions, %{})),
      visible: Map.get(attrs, :visible, true),
      style: build_style(Map.get(attrs, :style), dsl_state)
    }
  end

  # Navigation widget builders

  @doc """
  Builds a Menu IUR struct from a menu DSL entity.

  Recursively builds all menu items.
  """
  @spec build_menu(map(), Dsl.t()) :: Widgets.Menu.t()
  def build_menu(entity, dsl_state) do
    attrs = get_entity_attrs(entity, dsl_state)

    items =
      case build_nested_entities(entity, dsl_state, :items, &build_menu_item/2,
             child_name: :menu_item
           ) do
        [] ->
          # Backward compatibility for older DSL states that nested under :menu_items.
          build_nested_entities(entity, dsl_state, :menu_items, &build_menu_item/2,
            child_name: :menu_item
          )

        nested ->
          nested
      end

    %Widgets.Menu{
      id: Map.get(attrs, :id),
      title: Map.get(attrs, :title),
      position: Map.get(attrs, :position),
      visible: Map.get(attrs, :visible, true),
      style: build_style(Map.get(attrs, :style), dsl_state),
      items: items
    }
  end

  @doc """
  Builds a menu item IUR struct from a menu_item DSL entity.
  """
  @spec build_menu_item(map(), Dsl.t()) :: Widgets.MenuItem.t()
  def build_menu_item(entity, dsl_state) do
    attrs = get_entity_attrs(entity, dsl_state)
    # Menu items can have submenus - check for nested entities
    submenu =
      build_nested_entities(entity, dsl_state, :submenu, &build_menu_item/2,
        child_name: :menu_item
      )

    %Widgets.MenuItem{
      label: Map.get(attrs, :label),
      id: Map.get(attrs, :id),
      action: Map.get(attrs, :action),
      disabled: Map.get(attrs, :disabled, false),
      submenu:
        case submenu do
          [] -> nil
          items -> items
        end,
      icon: Map.get(attrs, :icon),
      shortcut: Map.get(attrs, :shortcut),
      visible: Map.get(attrs, :visible, true)
    }
  end

  @doc """
  Builds a ContextMenu IUR struct from a context_menu DSL entity.
  """
  @spec build_context_menu(map(), Dsl.t()) :: Widgets.ContextMenu.t()
  def build_context_menu(entity, dsl_state) do
    attrs = get_entity_attrs(entity, dsl_state)

    items =
      build_nested_entities(entity, dsl_state, :items, &build_menu_item/2, child_name: :menu_item)

    %Widgets.ContextMenu{
      id: Map.get(attrs, :id),
      trigger_on: Map.get(attrs, :trigger_on, :right_click),
      visible: Map.get(attrs, :visible, true),
      style: build_style(Map.get(attrs, :style), dsl_state),
      items: items
    }
  end

  @doc """
  Builds a Tabs IUR struct from a tabs DSL entity.

  Recursively builds all tabs.
  """
  @spec build_tabs(map(), Dsl.t()) :: Widgets.Tabs.t()
  def build_tabs(entity, dsl_state) do
    attrs = get_entity_attrs(entity, dsl_state)
    tabs = build_nested_entities(entity, dsl_state, :tabs, &build_tab/2, child_name: :tab)

    %Widgets.Tabs{
      id: Map.get(attrs, :id),
      active_tab: Map.get(attrs, :active_tab),
      position: Map.get(attrs, :position),
      on_change: Map.get(attrs, :on_change),
      visible: Map.get(attrs, :visible, true),
      style: build_style(Map.get(attrs, :style), dsl_state),
      tabs: tabs
    }
  end

  @doc """
  Builds a Tab IUR struct from a tab DSL entity.
  """
  @spec build_tab(map(), Dsl.t()) :: Widgets.Tab.t()
  def build_tab(entity, dsl_state) do
    attrs = get_entity_attrs(entity, dsl_state)
    # Tab content is nested children
    content = build_children(entity, dsl_state)

    %Widgets.Tab{
      id: Map.get(attrs, :id),
      label: Map.get(attrs, :label),
      icon: Map.get(attrs, :icon),
      disabled: Map.get(attrs, :disabled, false),
      closable: Map.get(attrs, :closable, false),
      visible: Map.get(attrs, :visible, true),
      content:
        case content do
          [] -> nil
          [single] -> single
          multiple -> multiple
        end
    }
  end

  @doc """
  Builds a TreeView IUR struct from a tree_view DSL entity.

  Recursively builds all tree nodes.
  """
  @spec build_tree_view(map(), Dsl.t()) :: Widgets.TreeView.t()
  def build_tree_view(entity, dsl_state) do
    attrs = get_entity_attrs(entity, dsl_state)

    root_nodes =
      build_nested_entities(entity, dsl_state, :root_nodes, &build_tree_node/2,
        child_name: :tree_node
      )

    %Widgets.TreeView{
      id: Map.get(attrs, :id),
      selected_node: Map.get(attrs, :selected_node),
      expanded_nodes: Map.get(attrs, :expanded_nodes),
      on_select: Map.get(attrs, :on_select),
      on_toggle: Map.get(attrs, :on_toggle),
      show_root: Map.get(attrs, :show_root, true),
      visible: Map.get(attrs, :visible, true),
      style: build_style(Map.get(attrs, :style), dsl_state),
      root_nodes: root_nodes
    }
  end

  @doc """
  Builds a TreeNode IUR struct from a tree_node DSL entity.
  """
  @spec build_tree_node(map(), Dsl.t()) :: Widgets.TreeNode.t()
  def build_tree_node(entity, dsl_state) do
    attrs = get_entity_attrs(entity, dsl_state)
    # Tree nodes can have child nodes
    children =
      build_nested_entities(entity, dsl_state, :children, &build_tree_node/2,
        child_name: :tree_node
      )

    %Widgets.TreeNode{
      id: Map.get(attrs, :id),
      label: Map.get(attrs, :label),
      value: Map.get(attrs, :value),
      expanded: Map.get(attrs, :expanded, false),
      icon: Map.get(attrs, :icon),
      icon_expanded: Map.get(attrs, :icon_expanded),
      selectable: Map.get(attrs, :selectable, true),
      visible: Map.get(attrs, :visible, true),
      children:
        case children do
          [] -> nil
          nodes -> nodes
        end
    }
  end

  # Dialog and feedback builders

  @doc """
  Builds a DialogButton IUR struct from a dialog_button DSL entity.
  """
  @spec build_dialog_button(map(), Dsl.t()) :: Widgets.DialogButton.t()
  def build_dialog_button(entity, dsl_state) do
    attrs = get_entity_attrs(entity, dsl_state)

    %Widgets.DialogButton{
      label: Map.get(attrs, :label),
      id: Map.get(attrs, :id),
      action: Map.get(attrs, :action),
      role: Map.get(attrs, :role, :default),
      disabled: Map.get(attrs, :disabled, false),
      visible: Map.get(attrs, :visible, true),
      style: build_style(Map.get(attrs, :style), dsl_state)
    }
  end

  @doc """
  Builds a Dialog IUR struct from a dialog DSL entity.
  """
  @spec build_dialog(map(), Dsl.t()) :: Widgets.Dialog.t()
  def build_dialog(entity, dsl_state) do
    attrs = get_entity_attrs(entity, dsl_state)

    content =
      case build_nested_entities(entity, dsl_state, :content, &build_entity/2) do
        [] ->
          Map.get(attrs, :content)

        [single] ->
          single

        nested ->
          nested
      end

    buttons =
      case build_nested_entities(entity, dsl_state, :buttons, &build_dialog_button/2,
             child_name: :dialog_button
           ) do
        [] -> normalize_dialog_buttons(Map.get(attrs, :buttons), dsl_state)
        nested -> nested
      end

    %Widgets.Dialog{
      id: Map.get(attrs, :id),
      title: Map.get(attrs, :title),
      content: content,
      buttons: buttons,
      on_close: Map.get(attrs, :on_close),
      width: Map.get(attrs, :width),
      height: Map.get(attrs, :height),
      closable: Map.get(attrs, :closable, true),
      visible: Map.get(attrs, :visible, true),
      style: build_style(Map.get(attrs, :style), dsl_state)
    }
  end

  @doc """
  Builds an AlertDialog IUR struct from an alert_dialog DSL entity.
  """
  @spec build_alert_dialog(map(), Dsl.t()) :: Widgets.AlertDialog.t()
  def build_alert_dialog(entity, dsl_state) do
    attrs = get_entity_attrs(entity, dsl_state)

    %Widgets.AlertDialog{
      id: Map.get(attrs, :id),
      title: Map.get(attrs, :title),
      message: Map.get(attrs, :message),
      severity: Map.get(attrs, :severity, :info),
      on_confirm: Map.get(attrs, :on_confirm),
      on_cancel: Map.get(attrs, :on_cancel),
      visible: Map.get(attrs, :visible, true),
      style: build_style(Map.get(attrs, :style), dsl_state)
    }
  end

  @doc """
  Builds a Toast IUR struct from a toast DSL entity.
  """
  @spec build_toast(map(), Dsl.t()) :: Widgets.Toast.t()
  def build_toast(entity, dsl_state) do
    attrs = get_entity_attrs(entity, dsl_state)

    %Widgets.Toast{
      id: Map.get(attrs, :id),
      message: Map.get(attrs, :message),
      severity: Map.get(attrs, :severity, :info),
      duration: Map.get(attrs, :duration, 3000),
      on_dismiss: Map.get(attrs, :on_dismiss),
      visible: Map.get(attrs, :visible, true),
      style: build_style(Map.get(attrs, :style), dsl_state)
    }
  end

  # Advanced input widget builders

  @doc """
  Builds a PickListOption IUR struct from a pick_list_option DSL entity.
  """
  @spec build_pick_list_option(map(), Dsl.t()) :: Widgets.PickListOption.t()
  def build_pick_list_option(entity, dsl_state) do
    attrs = get_entity_attrs(entity, dsl_state)

    %Widgets.PickListOption{
      value: Map.get(attrs, :value),
      label: Map.get(attrs, :label),
      id: Map.get(attrs, :id),
      disabled: Map.get(attrs, :disabled, false),
      visible: Map.get(attrs, :visible, true)
    }
  end

  @doc """
  Builds a PickList IUR struct from a pick_list DSL entity.
  """
  @spec build_pick_list(map(), Dsl.t()) :: Widgets.PickList.t()
  def build_pick_list(entity, dsl_state) do
    attrs = get_entity_attrs(entity, dsl_state)

    options =
      case build_nested_entities(entity, dsl_state, :opts, &build_pick_list_option/2,
             child_name: :pick_list_option
           ) do
        [] ->
          case build_nested_entities(entity, dsl_state, :option_items, &build_pick_list_option/2,
                 child_name: :pick_list_option
               ) do
            [] ->
              case build_nested_entities(entity, dsl_state, :options, &build_pick_list_option/2,
                     child_name: :pick_list_option
                   ) do
                [] -> normalize_pick_list_options(Map.get(attrs, :options), dsl_state)
                nested -> nested
              end

            nested ->
              nested
          end

        nested ->
          nested
      end

    %Widgets.PickList{
      id: Map.get(attrs, :id),
      options: options,
      selected: Map.get(attrs, :selected),
      placeholder: Map.get(attrs, :placeholder),
      searchable: Map.get(attrs, :searchable, false),
      on_select: Map.get(attrs, :on_select),
      allow_clear: Map.get(attrs, :allow_clear, false),
      visible: Map.get(attrs, :visible, true),
      style: build_style(Map.get(attrs, :style), dsl_state)
    }
  end

  @doc """
  Builds a FormField IUR struct from a form_field DSL entity.
  """
  @spec build_form_field(map(), Dsl.t()) :: Widgets.FormField.t()
  def build_form_field(entity, dsl_state) do
    attrs = get_entity_attrs(entity, dsl_state)

    %Widgets.FormField{
      name: Map.get(attrs, :name),
      type: Map.get(attrs, :type),
      label: Map.get(attrs, :label),
      placeholder: Map.get(attrs, :placeholder),
      required: Map.get(attrs, :required, false),
      default: Map.get(attrs, :default),
      options: Map.get(attrs, :options),
      disabled: Map.get(attrs, :disabled, false),
      visible: Map.get(attrs, :visible, true),
      style: build_style(Map.get(attrs, :style), dsl_state)
    }
  end

  @doc """
  Builds a FormBuilder IUR struct from a form_builder DSL entity.
  """
  @spec build_form_builder(map(), Dsl.t()) :: Widgets.FormBuilder.t()
  def build_form_builder(entity, dsl_state) do
    attrs = get_entity_attrs(entity, dsl_state)

    fields =
      case build_nested_entities(entity, dsl_state, :flds, &build_form_field/2,
             child_name: :form_field
           ) do
        [] ->
          case build_nested_entities(entity, dsl_state, :field_items, &build_form_field/2,
                 child_name: :form_field
               ) do
            [] ->
              case build_nested_entities(entity, dsl_state, :fields, &build_form_field/2,
                     child_name: :form_field
                   ) do
                [] -> normalize_form_fields(Map.get(attrs, :fields), dsl_state)
                nested -> nested
              end

            nested ->
              nested
          end

        nested ->
          nested
      end

    %Widgets.FormBuilder{
      id: Map.get(attrs, :id),
      fields: fields,
      action: Map.get(attrs, :action),
      on_submit: Map.get(attrs, :on_submit),
      submit_label: Map.get(attrs, :submit_label, "Submit"),
      visible: Map.get(attrs, :visible, true),
      style: build_style(Map.get(attrs, :style), dsl_state)
    }
  end

  @doc """
  Builds a Viewport struct from a viewport DSL entity.
  """
  @spec build_viewport(map(), Dsl.t()) :: Viewport.t()
  def build_viewport(entity, dsl_state) do
    attrs = get_entity_attrs(entity, dsl_state)

    content =
      case build_nested_entities(entity, dsl_state, :content, &build_entity/2) do
        [single] ->
          single

        [] ->
          normalize_viewport_content(Map.get(attrs, :content), dsl_state)

        many ->
          %Layouts.VBox{children: many}
      end

    %Viewport{
      id: Map.get(attrs, :id),
      content: content,
      width: Map.get(attrs, :width),
      height: Map.get(attrs, :height),
      scroll_x: Map.get(attrs, :scroll_x, 0),
      scroll_y: Map.get(attrs, :scroll_y, 0),
      on_scroll: Map.get(attrs, :on_scroll),
      border: Map.get(attrs, :border, :none),
      visible: Map.get(attrs, :visible, true),
      style: build_style(Map.get(attrs, :style), dsl_state)
    }
  end

  @doc """
  Builds a SplitPane struct from a split_pane DSL entity.
  """
  @spec build_split_pane(map(), Dsl.t()) :: SplitPane.t()
  def build_split_pane(entity, dsl_state) do
    attrs = get_entity_attrs(entity, dsl_state)

    panes =
      case build_nested_entities(entity, dsl_state, :panes, &build_entity/2) do
        [] -> normalize_split_panes(Map.get(attrs, :panes), dsl_state)
        nested -> nested
      end

    %SplitPane{
      id: Map.get(attrs, :id),
      panes: panes,
      orientation: Map.get(attrs, :orientation, :horizontal),
      initial_split: Map.get(attrs, :initial_split, 50),
      min_size: Map.get(attrs, :min_size, 10),
      on_resize_change: Map.get(attrs, :on_resize_change),
      visible: Map.get(attrs, :visible, true),
      style: build_style(Map.get(attrs, :style), dsl_state)
    }
  end

  @doc """
  Builds a Canvas struct from a canvas DSL entity.
  """
  @spec build_canvas(map(), Dsl.t()) :: Canvas.t()
  def build_canvas(entity, dsl_state) do
    attrs = get_entity_attrs(entity, dsl_state)

    %Canvas{
      id: Map.get(attrs, :id),
      width: Map.get(attrs, :width),
      height: Map.get(attrs, :height),
      draw: Map.get(attrs, :draw),
      on_click: Map.get(attrs, :on_click),
      on_hover: Map.get(attrs, :on_hover),
      visible: Map.get(attrs, :visible, true),
      style: build_style(Map.get(attrs, :style), dsl_state)
    }
  end

  @doc """
  Builds a Command struct from a command DSL entity.
  """
  @spec build_command(map(), Dsl.t()) :: Command.t()
  def build_command(entity, dsl_state) do
    attrs = get_entity_attrs(entity, dsl_state)

    %Command{
      id: Map.get(attrs, :id),
      label: Map.get(attrs, :label),
      description: Map.get(attrs, :description),
      shortcut: Map.get(attrs, :shortcut),
      keywords: Map.get(attrs, :keywords, []) |> List.wrap(),
      disabled: Map.get(attrs, :disabled, false),
      visible: Map.get(attrs, :visible, true)
    }
  end

  @doc """
  Builds a CommandPalette struct from a command_palette DSL entity.
  """
  @spec build_command_palette(map(), Dsl.t()) :: CommandPalette.t()
  def build_command_palette(entity, dsl_state) do
    attrs = get_entity_attrs(entity, dsl_state)

    commands =
      case build_nested_entities(entity, dsl_state, :cmds, &build_command/2, child_name: :command) do
        [] ->
          case build_nested_entities(entity, dsl_state, :commands, &build_command/2,
                 child_name: :command
               ) do
            [] -> normalize_commands(Map.get(attrs, :commands), dsl_state)
            nested -> nested
          end

        nested ->
          nested
      end

    %CommandPalette{
      id: Map.get(attrs, :id),
      commands: commands,
      placeholder: Map.get(attrs, :placeholder, "Type a command..."),
      trigger_shortcut: Map.get(attrs, :trigger_shortcut, "cmd+k"),
      on_select: Map.get(attrs, :on_select),
      visible: Map.get(attrs, :visible, true),
      style: build_style(Map.get(attrs, :style), dsl_state)
    }
  end

  @doc """
  Builds a LogViewer struct from a log_viewer DSL entity.
  """
  @spec build_log_viewer(map(), Dsl.t()) :: LogViewer.t()
  def build_log_viewer(entity, dsl_state) do
    attrs = get_entity_attrs(entity, dsl_state)

    %LogViewer{
      id: Map.get(attrs, :id),
      source: Map.get(attrs, :source),
      lines: Map.get(attrs, :lines, 100),
      auto_scroll: Map.get(attrs, :auto_scroll, true),
      filter: Map.get(attrs, :filter),
      refresh_interval: Map.get(attrs, :refresh_interval, 1_000),
      visible: Map.get(attrs, :visible, true),
      style: build_style(Map.get(attrs, :style), dsl_state)
    }
  end

  @doc """
  Builds a StreamWidget struct from a stream_widget DSL entity.
  """
  @spec build_stream_widget(map(), Dsl.t()) :: StreamWidget.t()
  def build_stream_widget(entity, dsl_state) do
    attrs = get_entity_attrs(entity, dsl_state)

    %StreamWidget{
      id: Map.get(attrs, :id),
      producer: Map.get(attrs, :producer),
      transform: Map.get(attrs, :transform),
      buffer_size: Map.get(attrs, :buffer_size, 100),
      refresh_interval: Map.get(attrs, :refresh_interval, 1_000),
      on_item: Map.get(attrs, :on_item),
      visible: Map.get(attrs, :visible, true),
      style: build_style(Map.get(attrs, :style), dsl_state)
    }
  end

  @doc """
  Builds a ProcessMonitor struct from a process_monitor DSL entity.
  """
  @spec build_process_monitor(map(), Dsl.t()) :: ProcessMonitor.t()
  def build_process_monitor(entity, dsl_state) do
    attrs = get_entity_attrs(entity, dsl_state)

    %ProcessMonitor{
      id: Map.get(attrs, :id),
      node: Map.get(attrs, :node),
      refresh_interval: Map.get(attrs, :refresh_interval, 1_000),
      sort_by: Map.get(attrs, :sort_by, :memory),
      on_process_select: Map.get(attrs, :on_process_select),
      visible: Map.get(attrs, :visible, true),
      style: build_style(Map.get(attrs, :style), dsl_state)
    }
  end

  # Children building

  @doc """
  Builds child elements for a layout entity.

  Extracts nested entities and recursively builds them.
  """
  @spec build_children(map(), Dsl.t()) :: [struct()]
  def build_children(entity, dsl_state) do
    # Get nested entities from the entity
    # Spark stores nested entities in a specific way
    case Map.get(entity, :entities) do
      nil ->
        []

      entities when is_list(entities) ->
        Enum.map(entities, &build_entity(&1, dsl_state))
        |> Enum.reject(&is_nil/1)

      _ ->
        []
    end
  end

  @doc """
  Builds nested entities with a specific key.

  Similar to build_children but for named nested entity collections
  like menu_items, tabs, root_nodes, etc.
  """
  @spec build_nested_entities(map(), Dsl.t(), atom(), fun(), keyword()) :: [struct()]
  def build_nested_entities(entity, dsl_state, key, builder_fn, opts \\ []) do
    child_name = Keyword.get(opts, :child_name)

    case Map.get(entity, :entities) do
      nil ->
        []

      entities when is_list(entities) ->
        entities
        |> Enum.flat_map(&extract_nested_entities(&1, key, child_name))
        |> Enum.map(fn nested -> builder_fn.(nested, dsl_state) end)
        |> Enum.reject(&is_nil/1)

      _ ->
        []
    end
  end

  # Style building

  @doc """
  Converts a style reference to an IUR.Style struct.

  Supports:
  * nil - returns nil
  * [] - returns nil
  * Atom (named style) - resolves from DSL
  * Keyword list (inline styles) - creates Style struct
  * List with atom first (named style + overrides) - resolves with overrides

  Returns nil if no style is provided.
  """
  @spec build_style(keyword() | atom() | nil, Dsl.t()) :: Style.t() | nil
  def build_style(style_ref, dsl_state)

  def build_style(nil, _dsl_state), do: nil
  def build_style([], _dsl_state), do: nil

  def build_style(style_name, dsl_state) when is_atom(style_name) do
    case resolve_theme_style(dsl_state, style_name) do
      %Style{} = themed_style -> themed_style
      nil -> StyleResolver.resolve_style_ref(dsl_state, style_name)
    end
  end

  def build_style(style_keyword, dsl_state) when is_list(style_keyword) do
    case style_keyword do
      [style_name | overrides] when is_atom(style_name) ->
        if Keyword.keyword?(overrides) do
          case resolve_theme_style(dsl_state, style_name) do
            %Style{} = themed_style ->
              Style.merge(themed_style, Style.new(overrides))

            nil ->
              StyleResolver.resolve_style_ref(dsl_state, style_keyword)
          end
        else
          StyleResolver.resolve_style_ref(dsl_state, style_keyword)
        end

      _ ->
        StyleResolver.resolve_style_ref(dsl_state, style_keyword)
    end
  end

  def build_style(%Style{} = style, _dsl_state), do: style

  defp resolve_theme_style(dsl_state, style_name) when is_atom(style_name) do
    dsl_state
    |> active_theme_styles()
    |> Map.get(style_name)
  end

  defp active_theme_styles(dsl_state) do
    case active_theme_name(dsl_state) do
      theme_name when is_atom(theme_name) ->
        StyleResolver.load_theme(dsl_state, theme_name)

      _ ->
        %{}
    end
  end

  defp active_theme_name(dsl_state) do
    runtime_state = Map.get(dsl_state, :__runtime_state__, %{})
    theme_ref = Map.get(runtime_state, :theme) || Map.get(runtime_state, "theme")

    normalize_theme_name(dsl_state, theme_ref)
  end

  defp normalize_theme_name(_dsl_state, theme_name) when is_atom(theme_name), do: theme_name

  defp normalize_theme_name(dsl_state, theme_name) when is_binary(theme_name) do
    known_themes =
      dsl_state
      |> StyleResolver.get_all_themes()
      |> Map.keys()
      |> Kernel.++([:default, :dark, :light])
      |> Enum.uniq()

    Enum.find(known_themes, fn known -> Atom.to_string(known) == theme_name end)
  end

  defp normalize_theme_name(_dsl_state, _theme_name), do: nil

  # Helper functions

  @doc """
  Extracts attributes from a DSL entity.

  Handles different ways Spark stores entity attributes.
  """
  @spec get_entity_attrs(map(), Dsl.t() | map() | term()) :: map()
  def get_entity_attrs(entity, dsl_state \\ %{}) do
    # Spark stores entity attrs in the :attrs field
    attrs =
      case Map.get(entity, :attrs) do
        nil -> %{}
        attrs when is_map(attrs) -> attrs
        attrs when is_list(attrs) -> Enum.into(attrs, %{})
        _ -> %{}
      end

    runtime_state =
      case dsl_state do
        %{} = state -> Map.get(state, :__runtime_state__, %{})
        _ -> %{}
      end

    resolve_state_refs(attrs, runtime_state)
  end

  defp resolve_state_refs({:state, key}, runtime_state)
       when is_atom(key) and is_map(runtime_state) do
    Map.get(runtime_state, key, Map.get(runtime_state, Atom.to_string(key)))
  end

  defp resolve_state_refs(list, runtime_state) when is_list(list) do
    if Keyword.keyword?(list) do
      Enum.map(list, fn {key, value} -> {key, resolve_state_refs(value, runtime_state)} end)
    else
      Enum.map(list, &resolve_state_refs(&1, runtime_state))
    end
  end

  defp resolve_state_refs(%module{} = struct, runtime_state) do
    resolved_map =
      struct
      |> Map.from_struct()
      |> resolve_state_refs(runtime_state)

    struct(module, resolved_map)
  end

  defp resolve_state_refs(map, runtime_state) when is_map(map) do
    Map.new(map, fn {key, value} -> {key, resolve_state_refs(value, runtime_state)} end)
  end

  defp resolve_state_refs(tuple, runtime_state) when is_tuple(tuple) do
    tuple
    |> Tuple.to_list()
    |> Enum.map(&resolve_state_refs(&1, runtime_state))
    |> List.to_tuple()
  end

  defp resolve_state_refs(value, _runtime_state), do: value

  @doc """
  Validates an IUR tree structure.

  Checks that required fields are present and values are valid.
  Returns :ok if valid, {:error, reason} if invalid.

  Note: This validates struct constraints based on how the DSL entities
  define required fields. For Label and TextInput, the struct defines
  these fields as optional, so we accept them.
  """
  @spec validate(struct()) :: :ok | {:error, term()}
  def validate(%Widgets.Button{label: label}) when is_binary(label), do: :ok
  def validate(%Widgets.Button{}), do: {:error, :missing_label}

  def validate(%Widgets.Text{content: content}) when is_binary(content), do: :ok
  def validate(%Widgets.Text{}), do: {:error, :missing_content}

  # Label struct has optional :for and :text fields (defined in [] part of defstruct)
  # So we accept any Label struct as valid from the struct perspective
  def validate(%Widgets.Label{}), do: :ok

  # TextInput struct has optional :id field (defined in [] part of defstruct)
  # So we accept any TextInput struct as valid from the struct perspective
  def validate(%Widgets.TextInput{}), do: :ok
  def validate(%Widgets.Gauge{}), do: :ok
  def validate(%Widgets.Sparkline{}), do: :ok
  def validate(%Widgets.BarChart{}), do: :ok
  def validate(%Widgets.LineChart{}), do: :ok
  def validate(%Widgets.Table{}), do: :ok
  def validate(%Widgets.Column{}), do: :ok
  def validate(%Widgets.Menu{}), do: :ok
  def validate(%Widgets.MenuItem{}), do: :ok
  def validate(%Widgets.ContextMenu{}), do: :ok
  def validate(%Widgets.Tabs{}), do: :ok
  def validate(%Widgets.Tab{}), do: :ok
  def validate(%Widgets.TreeView{}), do: :ok
  def validate(%Widgets.TreeNode{}), do: :ok
  def validate(%Widgets.DialogButton{}), do: :ok
  def validate(%Widgets.Dialog{}), do: :ok
  def validate(%Widgets.AlertDialog{}), do: :ok
  def validate(%Widgets.Toast{}), do: :ok
  def validate(%Widgets.PickListOption{}), do: :ok

  def validate(%Widgets.PickList{options: options}) when is_list(options),
    do: validate_children(options)

  def validate(%Widgets.PickList{}), do: :ok
  def validate(%Widgets.FormField{}), do: :ok

  def validate(%Widgets.FormBuilder{fields: fields}) when is_list(fields),
    do: validate_children(fields)

  def validate(%Widgets.FormBuilder{}), do: :ok
  def validate(%Canvas{}), do: :ok
  def validate(%Command{}), do: :ok

  def validate(%CommandPalette{commands: commands}) when is_list(commands),
    do: validate_children(commands)

  def validate(%CommandPalette{}), do: :ok
  def validate(%LogViewer{}), do: :ok
  def validate(%StreamWidget{}), do: :ok
  def validate(%ProcessMonitor{}), do: :ok

  def validate(%Layouts.VBox{children: children}), do: validate_children(children)
  def validate(%Layouts.HBox{children: children}), do: validate_children(children)
  def validate(%Grid{children: children}), do: validate_children(children)
  def validate(%Stack{children: children}), do: validate_children(children)
  def validate(%ZBox{children: children}), do: validate_children(children)

  def validate(_), do: {:error, :unknown_type}

  @doc """
  Validates all children in a list.
  """
  @spec validate_children([struct()]) :: :ok | {:error, term()}
  def validate_children([]), do: :ok

  def validate_children(children) when is_list(children) do
    Enum.reduce_while(children, :ok, fn child, _acc ->
      case validate(child) do
        :ok -> {:cont, :ok}
        error -> {:halt, error}
      end
    end)
  end

  defp collect_root_entities(dsl_state) do
    [
      safe_get_entities(dsl_state, [:ui]),
      safe_get_entities(dsl_state, :ui)
    ]
    |> List.flatten()
    |> Enum.reject(&is_nil/1)
  end

  defp safe_get_entities(dsl_state, path) do
    Dsl.Transformer.get_entities(dsl_state, path)
  rescue
    _ -> []
  catch
    _, _ -> []
  end

  defp extract_nested_entities(%{name: name, entities: nested}, key, _child_name)
       when name == key and is_list(nested) do
    nested
  end

  defp extract_nested_entities(%{name: name} = entity, _key, child_name)
       when not is_nil(child_name) and name == child_name do
    [entity]
  end

  defp extract_nested_entities(%{name: name} = entity, key, nil) when name == key do
    [entity]
  end

  defp extract_nested_entities(_entity, _key, _child_name), do: []

  defp normalize_columns(nil, _dsl_state), do: nil

  defp normalize_columns(columns, dsl_state) when is_list(columns) do
    Enum.map(columns, fn
      %Widgets.Column{} = column ->
        column

      %{name: :column} = column_entity ->
        build_column(column_entity, dsl_state)

      attrs when is_map(attrs) ->
        build_column(%{attrs: attrs}, dsl_state)

      attrs when is_list(attrs) ->
        build_column(%{attrs: Enum.into(attrs, %{})}, dsl_state)

      other ->
        other
    end)
  end

  defp normalize_columns(other, _dsl_state), do: other

  defp normalize_dialog_buttons(nil, _dsl_state), do: nil

  defp normalize_dialog_buttons(buttons, dsl_state) when is_list(buttons) do
    Enum.map(buttons, fn
      %Widgets.DialogButton{} = button ->
        button

      %{name: :dialog_button} = button_entity ->
        build_dialog_button(button_entity, dsl_state)

      attrs when is_map(attrs) ->
        build_dialog_button(%{attrs: attrs}, dsl_state)

      attrs when is_list(attrs) ->
        build_dialog_button(%{attrs: Enum.into(attrs, %{})}, dsl_state)

      label when is_binary(label) ->
        build_dialog_button(%{attrs: %{label: label}}, dsl_state)

      other ->
        other
    end)
  end

  defp normalize_dialog_buttons(other, _dsl_state), do: other

  defp normalize_pick_list_options(nil, _dsl_state), do: nil

  defp normalize_pick_list_options(options, dsl_state) when is_list(options) do
    Enum.map(options, fn
      %Widgets.PickListOption{} = option ->
        option

      %{name: :pick_list_option} = option_entity ->
        build_pick_list_option(option_entity, dsl_state)

      {value, label} ->
        build_pick_list_option(%{attrs: %{value: value, label: label}}, dsl_state)

      attrs when is_map(attrs) ->
        build_pick_list_option(%{attrs: attrs}, dsl_state)

      attrs when is_list(attrs) ->
        build_pick_list_option(%{attrs: Enum.into(attrs, %{})}, dsl_state)

      other ->
        other
    end)
  end

  defp normalize_pick_list_options(other, _dsl_state), do: other

  defp normalize_form_fields(nil, _dsl_state), do: nil

  defp normalize_form_fields(fields, dsl_state) when is_list(fields) do
    Enum.map(fields, fn
      %Widgets.FormField{} = field ->
        field

      %{name: :form_field} = field_entity ->
        build_form_field(field_entity, dsl_state)

      {name, type} when is_atom(name) and is_atom(type) ->
        build_form_field(%{attrs: %{name: name, type: type}}, dsl_state)

      attrs when is_map(attrs) ->
        build_form_field(%{attrs: attrs}, dsl_state)

      attrs when is_list(attrs) ->
        build_form_field(%{attrs: Enum.into(attrs, %{})}, dsl_state)

      other ->
        other
    end)
  end

  defp normalize_form_fields(other, _dsl_state), do: other

  defp normalize_commands(nil, _dsl_state), do: []

  defp normalize_commands(commands, dsl_state) when is_list(commands) do
    commands
    |> Enum.map(fn
      %Command{} = command ->
        command

      %{name: :command} = command_entity ->
        build_command(command_entity, dsl_state)

      {id, label} when is_atom(id) and is_binary(label) ->
        build_command(%{attrs: %{id: id, label: label}}, dsl_state)

      attrs when is_map(attrs) ->
        build_command(%{attrs: attrs}, dsl_state)

      attrs when is_list(attrs) ->
        build_command(%{attrs: Enum.into(attrs, %{})}, dsl_state)

      _other ->
        nil
    end)
    |> Enum.reject(&is_nil/1)
  end

  defp normalize_commands(_commands, _dsl_state), do: []

  defp normalize_viewport_content(nil, _dsl_state), do: nil

  defp normalize_viewport_content(content, dsl_state) do
    case content do
      %_module{} = widget ->
        if UnifiedIUR.Element.impl_for(widget), do: widget, else: nil

      %{name: _name} = entity ->
        build_entity(entity, dsl_state)

      attrs when is_map(attrs) ->
        case Map.get(attrs, :name) do
          nil -> nil
          _ -> build_entity(attrs, dsl_state)
        end

      _other ->
        nil
    end
  end

  defp normalize_split_panes(nil, _dsl_state), do: []

  defp normalize_split_panes(panes, dsl_state) when is_list(panes) do
    panes
    |> Enum.map(fn
      %_module{} = pane ->
        if UnifiedIUR.Element.impl_for(pane), do: pane, else: nil

      %{name: _name} = pane_entity ->
        build_entity(pane_entity, dsl_state)

      attrs when is_map(attrs) ->
        case Map.get(attrs, :name) do
          nil -> nil
          _ -> build_entity(attrs, dsl_state)
        end

      _other ->
        nil
    end)
    |> Enum.reject(&is_nil/1)
  end

  defp normalize_split_panes(_panes, _dsl_state), do: []

  defp resolve_advanced_layout_children(entity, dsl_state) do
    attrs = get_entity_attrs(entity, dsl_state)

    nested_children =
      case build_nested_entities(entity, dsl_state, :children, &build_entity/2) do
        [] -> build_children(entity, dsl_state)
        nested -> nested
      end

    arg_children = normalize_layout_children(Map.get(attrs, :children), dsl_state)

    case {nested_children, arg_children} do
      {[], children} -> children
      {children, []} -> children
      {nested, arg} -> nested ++ arg
    end
  end

  defp normalize_layout_children(nil, _dsl_state), do: []

  defp normalize_layout_children(children, dsl_state) when is_list(children) do
    children
    |> Enum.map(fn
      %_module{} = child ->
        if UnifiedIUR.Element.impl_for(child), do: child, else: nil

      %{name: _name} = child_entity ->
        build_entity(child_entity, dsl_state)

      attrs when is_map(attrs) ->
        case Map.get(attrs, :name) do
          nil -> nil
          _ -> build_entity(attrs, dsl_state)
        end

      attrs when is_list(attrs) ->
        attrs
        |> Enum.into(%{})
        |> then(fn map ->
          case Map.get(map, :name) do
            nil -> nil
            _ -> build_entity(map, dsl_state)
          end
        end)

      _other ->
        nil
    end)
    |> Enum.reject(&is_nil/1)
  end

  defp normalize_layout_children(_children, _dsl_state), do: []

  defp normalize_grid_tracks(nil), do: []
  defp normalize_grid_tracks([]), do: []

  defp normalize_grid_tracks(tracks) when is_list(tracks) do
    Enum.map(tracks, &normalize_grid_track/1)
  end

  defp normalize_grid_tracks(track), do: [normalize_grid_track(track)]

  defp normalize_grid_track(track) when is_integer(track), do: track
  defp normalize_grid_track(:auto), do: "auto"
  defp normalize_grid_track(track) when is_binary(track), do: track
  defp normalize_grid_track(track), do: track

  defp normalize_non_negative_integer(value, _default) when is_integer(value) and value >= 0,
    do: value

  defp normalize_non_negative_integer(_value, default), do: default

  @position_keys [:x, :y, :z, :z_index, :width, :height]

  defp normalize_zbox_positions(nil), do: %{}

  defp normalize_zbox_positions(positions) when is_map(positions) do
    Enum.reduce(positions, %{}, fn {key, value}, acc ->
      case normalize_zbox_position(value) do
        nil ->
          acc

        position ->
          Map.put(acc, normalize_zbox_position_key(key), position)
      end
    end)
  end

  defp normalize_zbox_positions(positions) when is_list(positions) do
    if Keyword.keyword?(positions) do
      positions
      |> Enum.into(%{})
      |> normalize_zbox_positions()
    else
      positions
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {value, index}, acc ->
        case normalize_zbox_position(value) do
          nil -> acc
          position -> Map.put(acc, index, position)
        end
      end)
    end
  end

  defp normalize_zbox_positions(_positions), do: %{}

  defp normalize_zbox_position(position) when is_map(position) do
    Enum.reduce(@position_keys, %{}, fn key, acc ->
      value = Map.get(position, key) || Map.get(position, Atom.to_string(key))

      if is_integer(value) do
        Map.put(acc, key, value)
      else
        acc
      end
    end)
  end

  defp normalize_zbox_position(position) when is_list(position) do
    position
    |> Enum.into(%{})
    |> normalize_zbox_position()
  end

  defp normalize_zbox_position(_position), do: nil

  defp normalize_zbox_position_key(key) when is_integer(key), do: key
  defp normalize_zbox_position_key(key) when is_atom(key), do: key

  defp normalize_zbox_position_key(key) when is_binary(key) do
    case Integer.parse(key) do
      {int, ""} -> int
      _ -> key
    end
  end

  defp normalize_zbox_position_key(key), do: key
end
