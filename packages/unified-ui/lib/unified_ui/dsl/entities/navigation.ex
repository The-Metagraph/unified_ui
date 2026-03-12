defmodule UnifiedUi.Dsl.Entities.Navigation do
  @moduledoc """
  Spark DSL Entity definitions for navigation widgets.

  This module defines the DSL entities for navigation:
  menu, context_menu, tabs, and tree_view.

  Each entity specifies:
  - Required arguments (args)
  - Optional options (schema)
  - Target struct for storing the parsed DSL data
  - Nested entities for complex structures

  ## Usage

  These entities are automatically available when using `UnifiedUi.Dsl`:

      defmodule MyApp.MyDashboard do
        use UnifiedUi.Dsl

        ui do
          vbox do
            # Menu bar
            menu :file_menu, title: "File" do
              menu_item "New", action: :new_file
              menu_item "Open", action: :open_file
            end

            # Tabs
            tabs :main_tabs, active_tab: :home do
              tab :home, "Home" do
                text "Welcome to the dashboard"
              end

              tab :settings, "Settings", icon: :gear do
                text "Settings panel"
              end
            end

            # Tree view
            tree_view :file_tree do
              tree_node :src, "src" do
                tree_node :main, "main.ex"
              end
            end
          end
        end
      end
  """

  alias UnifiedIUR.Widgets
  alias UnifiedUi.Dsl.Entities.{DataViz, InputWidgets, Tables}
  alias UnifiedUi.Dsl.Entities.Widgets, as: WidgetEntities

  # ============================================================================
  # Menu Item Entity (Nested)
  # ============================================================================

  @menu_item_entity %Spark.Dsl.Entity{
    name: :menu_item,
    target: Widgets.MenuItem,
    args: [:label],
    schema: [
      label: [
        type: :string,
        doc: "The text displayed for the menu item.",
        required: true
      ],
      id: [
        type: :atom,
        doc: "Optional unique identifier for the item.",
        required: false
      ],
      action: [
        type: {:or, [:atom, {:tuple, [:atom, :map]}, {:tuple, [:atom, :atom, {:list, :any}]}]},
        doc: """
        Signal to emit when the menu item is clicked.
        Can be an atom signal name, a tuple with payload, or an MFA tuple.
        """,
        required: false
      ],
      disabled: [
        type: :boolean,
        doc: "Whether the menu item is disabled.",
        required: false,
        default: false
      ],
      icon: [
        type: :atom,
        doc: "Optional icon identifier to display next to the label.",
        required: false
      ],
      shortcut: [
        type: :string,
        doc: "Optional keyboard shortcut hint to display.",
        required: false
      ],
      visible: [
        type: :boolean,
        doc: "Whether the menu item is visible.",
        required: false,
        default: true
      ]
    ],
    describe: """
    A single menu item that can be clicked to trigger an action.

    Menu items are defined within a menu or context menu.
    Items can be disabled, have icons, and display keyboard shortcuts.

    ## Examples

        menu_item "Open", action: :open_file

        menu_item "Save",
          action: :save_file,
          shortcut: "Ctrl+S",
          icon: :save
    """
  }

  # ============================================================================
  # Menu Entity
  # ============================================================================

  @menu_entity %Spark.Dsl.Entity{
    name: :menu,
    target: Widgets.Menu,
    args: [:id],
    schema: [
      id: [
        type: :atom,
        doc: "Unique identifier for the menu.",
        required: true
      ],
      title: [
        type: :string,
        doc: "Optional title for the menu (displayed in menu bars).",
        required: false
      ],
      position: [
        type: {:one_of, [:top, :bottom, :left, :right]},
        doc: "Position hint for where the menu appears.",
        required: false
      ],
      style: [
        type: :keyword_list,
        doc: "Inline style as keyword list.",
        required: false
      ],
      visible: [
        type: :boolean,
        doc: "Whether the menu is visible.",
        required: false,
        default: true
      ]
    ],
    entities: [
      items: [@menu_item_entity]
    ],
    describe: """
    A menu container for organizing commands hierarchically.

    Menus can be displayed as menu bars, dropdown menus, or popup menus.
    Menu items are defined within the menu using the do-block syntax.

    ## Examples

        # Menu with title for menu bar
        menu :file_menu, title: "File" do
          menu_item "New", action: :new_file, shortcut: "Ctrl+N"
          menu_item "Open", action: :open_file, shortcut: "Ctrl+O"
          menu_item "Save", action: :save_file, shortcut: "Ctrl+S"
        end

        # Dropdown menu
        menu :edit_menu, title: "Edit" do
          menu_item "Undo", action: :undo
          menu_item "Redo", action: :redo
          menu_item "Find", action: :find
        end
    """
  }

  # ============================================================================
  # Context Menu Entity
  # ============================================================================

  @context_menu_entity %Spark.Dsl.Entity{
    name: :context_menu,
    target: Widgets.ContextMenu,
    args: [:id],
    schema: [
      id: [
        type: :atom,
        doc: "Unique identifier for the context menu.",
        required: true
      ],
      trigger_on: [
        type: {:one_of, [:right_click, :long_press, :double_click]},
        doc: "Event that triggers the context menu to appear.",
        required: false,
        default: :right_click
      ],
      style: [
        type: :keyword_list,
        doc: "Inline style as keyword list.",
        required: false
      ],
      visible: [
        type: :boolean,
        doc: "Whether the context menu is visible.",
        required: false,
        default: true
      ]
    ],
    entities: [
      items: [@menu_item_entity]
    ],
    describe: """
    A context menu that appears at the cursor position on trigger.

    Context menus are typically triggered by right-clicking and show
    actions relevant to the current context.

    ## Examples

        context_menu :file_context, trigger_on: :right_click do
          menu_item "Copy", action: :copy
          menu_item "Paste", action: :paste
          menu_item "Delete", action: :delete
        end

        context_menu :text_context do
          menu_item "Cut", action: :cut
          menu_item "Copy", action: :copy
          menu_item "Paste", action: :paste
        end
    """
  }

  # ============================================================================
  # Tab Entity (Nested)
  # ============================================================================

  @tab_content_entities [
    WidgetEntities.button_entity(),
    WidgetEntities.text_entity(),
    WidgetEntities.label_entity(),
    WidgetEntities.text_input_entity(),
    DataViz.gauge_entity(),
    DataViz.sparkline_entity(),
    DataViz.bar_chart_entity(),
    DataViz.line_chart_entity(),
    Tables.table_entity(),
    InputWidgets.pick_list_entity(),
    InputWidgets.form_builder_entity()
  ]

  @tab_entity %Spark.Dsl.Entity{
    name: :tab,
    target: Widgets.Tab,
    args: [:id, :label],
    schema: [
      id: [
        type: :atom,
        doc: "Unique identifier for the tab.",
        required: true
      ],
      label: [
        type: :string,
        doc: "The text displayed on the tab.",
        required: true
      ],
      icon: [
        type: :atom,
        doc: "Optional icon identifier to display on the tab.",
        required: false
      ],
      disabled: [
        type: :boolean,
        doc: "Whether the tab is disabled and cannot be activated.",
        required: false,
        default: false
      ],
      closable: [
        type: :boolean,
        doc: "Whether the tab can be closed by the user.",
        required: false,
        default: false
      ],
      visible: [
        type: :boolean,
        doc: "Whether the tab is visible.",
        required: false,
        default: true
      ]
    ],
    entities: [
      content: @tab_content_entities
    ],
    describe: """
    A single tab in a tabs container.

    Tabs are defined within a tabs container. Tab content is defined
    using the do-block syntax and can contain any IUR element.

    ## Examples

        tab :home, "Home" do
          text "Welcome to the home page"
        end

        tab :settings, "Settings", icon: :gear

        tab :profile, "Profile", disabled: false
    """
  }

  # ============================================================================
  # Tabs Entity
  # ============================================================================

  @tabs_entity %Spark.Dsl.Entity{
    name: :tabs,
    target: Widgets.Tabs,
    args: [:id],
    schema: [
      id: [
        type: :atom,
        doc: "Unique identifier for the tabs container.",
        required: true
      ],
      active_tab: [
        type: :atom,
        doc: "ID of the currently active tab.",
        required: false
      ],
      position: [
        type: {:one_of, [:top, :bottom, :left, :right]},
        doc: "Position where tabs are displayed.",
        required: false,
        default: :top
      ],
      on_change: [
        type: {:or, [:atom, {:tuple, [:atom, :map]}, {:tuple, [:atom, :atom, {:list, :any}]}]},
        doc: """
        Signal to emit when a tab is changed.
        The signal includes the new active tab ID.
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
        doc: "Whether the tabs are visible.",
        required: false,
        default: true
      ]
    ],
    entities: [
      tabs: [@tab_entity]
    ],
    describe: """
    A tabs container for organizing content into switchable panels.

    Only the active tab's content is displayed at a time. Tabs can be
    positioned at the top, bottom, left, or right of the content area.

    ## Features

    * **Positioning**: Tabs can be positioned on any side
    * **Switching**: Click a tab to activate it and show its content
    * **Disabled**: Individual tabs can be disabled
    * **Icons**: Tabs can display icons alongside labels
    * **Closable**: Tabs can be marked as closable

    ## Examples

        # Basic tabs with content
        tabs :content_tabs, active_tab: :home do
          tab :home, "Home" do
            vbox do
              text "Welcome to the home page"
              button "Get Started", on_click: :start
            end
          end

          tab :settings, "Settings", icon: :gear do
            text "Settings configuration"
          end
        end

        # Side-positioned tabs
        tabs :side_tabs, position: :left, active_tab: :tab1 do
          tab :tab1, "Section 1" do
            text "Section 1 content"
          end

          tab :tab2, "Section 2" do
            text "Section 2 content"
          end
        end
    """
  }

  # ============================================================================
  # Tree Node Entity (Nested)
  # ============================================================================

  @tree_node_entity %Spark.Dsl.Entity{
    name: :tree_node,
    target: Widgets.TreeNode,
    args: [:id, :label],
    schema: [
      id: [
        type: :atom,
        doc: "Unique identifier for the node.",
        required: true
      ],
      label: [
        type: :string,
        doc: "The text displayed for the node.",
        required: true
      ],
      value: [
        type: :any,
        doc: "Optional associated value for the node.",
        required: false
      ],
      expanded: [
        type: :boolean,
        doc: "Whether the node is expanded by default.",
        required: false,
        default: false
      ],
      icon: [
        type: :atom,
        doc: "Optional icon identifier for collapsed state.",
        required: false
      ],
      icon_expanded: [
        type: :atom,
        doc: "Optional icon identifier for expanded state.",
        required: false
      ],
      selectable: [
        type: :boolean,
        doc: "Whether the node can be selected.",
        required: false,
        default: true
      ],
      visible: [
        type: :boolean,
        doc: "Whether the node is visible.",
        required: false,
        default: true
      ]
    ],
    describe: """
    A single node in a tree hierarchy.

    Tree nodes can contain child nodes to create hierarchical structures.
    Each node can be expanded or collapsed to show or hide its children.

    ## Examples

        # Leaf node
        tree_node :file, "main.ex"

        # Node with children (using do-block)
        tree_node :src, "src", expanded: true do
          tree_node :main, "main.ex"
          tree_node :config, "config.exs"
        end

        # Node with icons
        tree_node :project, "My Project",
          expanded: true,
          icon: :folder,
          icon_expanded: :folder_open do
          tree_node :lib, "lib"
          tree_node :test, "test"
        end
    """
  }

  # ============================================================================
  # Tree View Entity
  # ============================================================================

  @tree_view_entity %Spark.Dsl.Entity{
    name: :tree_view,
    target: Widgets.TreeView,
    args: [:id],
    schema: [
      id: [
        type: :atom,
        doc: "Unique identifier for the tree view.",
        required: true
      ],
      selected_node: [
        type: :atom,
        doc: "ID of the currently selected node.",
        required: false
      ],
      expanded_nodes: [
        type: {:or, [:atom, {:list, :atom}, {:struct, MapSet}]},
        doc: """
        Set of expanded node IDs, or :all to expand all nodes by default.
        Can be a list of atom IDs or a MapSet.
        """,
        required: false
      ],
      on_select: [
        type: {:or, [:atom, {:tuple, [:atom, :map]}, {:tuple, [:atom, :atom, {:list, :any}]}]},
        doc: """
        Signal to emit when a node is selected.
        The signal includes the selected node ID and value.
        """,
        required: false
      ],
      on_toggle: [
        type: {:or, [:atom, {:tuple, [:atom, :map]}, {:tuple, [:atom, :atom, {:list, :any}]}]},
        doc: """
        Signal to emit when a node is expanded or collapsed.
        The signal includes the node ID and new expanded state.
        """,
        required: false
      ],
      show_root: [
        type: :boolean,
        doc: "Whether to show icons for root nodes.",
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
        doc: "Whether the tree view is visible.",
        required: false,
        default: true
      ]
    ],
    entities: [
      root_nodes: [@tree_node_entity]
    ],
    describe: """
    A tree view for displaying hierarchical data.

    Tree views display tree nodes in a hierarchical structure with
    expand/collapse functionality. Nodes can be selected and emit signals.

    ## Features

    * **Hierarchical Display**: Shows nested data as a tree
    * **Expand/Collapse**: Nodes can be expanded to show children
    * **Selection**: Click nodes to select them
    * **Icons**: Display icons for different node types and states
    * **Signals**: Emit signals on selection and toggle

    ## Examples

        # Simple tree view
        tree_view :file_tree do
          tree_node :src, "src" do
            tree_node :main, "main.ex"
            tree_node :config, "config.exs"
          end
        end

        # Tree view with selection
        tree_view :project_tree, on_select: :node_selected do
          tree_node :lib, "lib", expanded: true do
            tree_node :my_app, "my_app" do
              tree_node :app, "app.ex"
            end
          end
        end

        # Tree view with pre-selected node
        tree_view :config_tree,
          selected_node: :database do
          tree_node :database, "Database" do
            tree_node :postgres, "PostgreSQL"
            tree_node :mysql, "MySQL"
          end
        end
    """
  }

  # ============================================================================
  # Entity Accessors
  # ============================================================================

  @doc """
  Returns the Spark DSL entity definition for `menu_item`.
  """
  @spec menu_item_entity() :: Spark.Dsl.Entity.t()
  def menu_item_entity, do: @menu_item_entity

  @doc """
  Returns the Spark DSL entity definition for `menu`.
  """
  @spec menu_entity() :: Spark.Dsl.Entity.t()
  def menu_entity, do: @menu_entity

  @doc """
  Returns the Spark DSL entity definition for `context_menu`.
  """
  @spec context_menu_entity() :: Spark.Dsl.Entity.t()
  def context_menu_entity, do: @context_menu_entity

  @doc """
  Returns the Spark DSL entity definition for `tab`.
  """
  @spec tab_entity() :: Spark.Dsl.Entity.t()
  def tab_entity, do: @tab_entity

  @doc """
  Returns the Spark DSL entity definition for `tabs`.
  """
  @spec tabs_entity() :: Spark.Dsl.Entity.t()
  def tabs_entity, do: @tabs_entity

  @doc """
  Returns the Spark DSL entity definition for `tree_node`.
  """
  @spec tree_node_entity() :: Spark.Dsl.Entity.t()
  def tree_node_entity, do: @tree_node_entity

  @doc """
  Returns the Spark DSL entity definition for `tree_view`.
  """
  @spec tree_view_entity() :: Spark.Dsl.Entity.t()
  def tree_view_entity, do: @tree_view_entity
end
