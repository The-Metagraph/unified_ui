defmodule UnifiedUi.Integration.Phase4Test do
  @moduledoc """
  Integration tests for Phase 4 of UnifiedUi.

  These tests verify that navigation widgets (Menu, ContextMenu, Tabs, TreeView)
  work correctly with the IUR system and all three platform adapters.

  Test Sections:
  - 4.3.1: Menu system with nested items
  - 4.3.2: Context menu triggering
  - 4.3.3: Tabs with content switching
  - 4.3.4: Tree view with expand/collapse
  - 4.3.5: Keyboard navigation signals
  - 4.3.6: Complex navigation UI
  """

  use ExUnit.Case, async: false

  alias UnifiedUi.Dsl.Style, as: DslStyle
  alias UnifiedUi.Dsl.Theme, as: DslTheme

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

  alias UnifiedIUR.{Layouts, Widgets}
  alias UnifiedUi.Adapters.{Terminal, Desktop, Web}
  alias UnifiedUi.Agent
  alias UnifiedUi.IUR.Builder
  alias UnifiedUi.Signals

  # ============================================================================
  # 4.3.1: Menu System Tests
  # ============================================================================

  describe "4.3.1 - Menu System" do
    test "Menu with items renders correctly" do
      menu = %Widgets.Menu{
        id: :file_menu,
        title: "File",
        position: :top,
        items: [
          %Widgets.MenuItem{label: "New", action: :new_file, shortcut: "Ctrl+N"},
          %Widgets.MenuItem{label: "Open", action: :open_file, shortcut: "Ctrl+O"},
          %Widgets.MenuItem{label: "Save", action: :save_file, shortcut: "Ctrl+S", disabled: true}
        ]
      }

      # Terminal renderer
      assert {:ok, terminal_state} = Terminal.render(menu)
      assert {:ok, _root} = UnifiedUi.Adapters.State.get_root(terminal_state)

      # Desktop renderer
      assert {:ok, desktop_state} = Desktop.render(menu)
      assert {:ok, _root} = UnifiedUi.Adapters.State.get_root(desktop_state)

      # Web renderer
      assert {:ok, web_state} = Web.render(menu)
      assert {:ok, _root} = UnifiedUi.Adapters.State.get_root(web_state)
    end

    test "Menu with nested submenu items" do
      menu = %Widgets.Menu{
        id: :main_menu,
        items: [
          %Widgets.MenuItem{
            label: "File",
            action: :file_menu,
            submenu: [
              %Widgets.MenuItem{label: "New", action: :new},
              %Widgets.MenuItem{label: "Open", action: :open}
            ]
          },
          %Widgets.MenuItem{
            label: "Edit",
            action: :edit_menu,
            submenu: [
              %Widgets.MenuItem{label: "Undo", action: :undo},
              %Widgets.MenuItem{label: "Redo", action: :redo}
            ]
          }
        ]
      }

      # Verify menu structure
      assert length(menu.items) == 2
      file_item = Enum.at(menu.items, 0)
      assert file_item.submenu != nil
      assert length(file_item.submenu) == 2

      # Terminal renderer
      assert {:ok, _state} = Terminal.render(menu)

      # Desktop renderer
      assert {:ok, _state} = Desktop.render(menu)

      # Web renderer
      assert {:ok, _state} = Web.render(menu)
    end

    test "Menu with icons and shortcuts displays correctly" do
      menu = %Widgets.Menu{
        id: :icon_menu,
        items: [
          %Widgets.MenuItem{
            label: "Save",
            action: :save,
            icon: :floppy,
            shortcut: "Ctrl+S"
          },
          %Widgets.MenuItem{
            label: "Print",
            action: :print,
            icon: :printer,
            shortcut: "Ctrl+P"
          }
        ]
      }

      # Verify item properties
      save_item = Enum.at(menu.items, 0)
      assert save_item.icon == :floppy
      assert save_item.shortcut == "Ctrl+S"

      # All renderers
      assert {:ok, _} = Terminal.render(menu)
      assert {:ok, _} = Desktop.render(menu)
      assert {:ok, _} = Web.render(menu)
    end
  end

  # ============================================================================
  # 4.3.2: Context Menu Tests
  # ============================================================================

  describe "4.3.2 - Context Menu" do
    test "Context menu with right-click trigger" do
      menu = %Widgets.ContextMenu{
        id: :text_context,
        trigger_on: :right_click,
        items: [
          %Widgets.MenuItem{label: "Copy", action: :copy},
          %Widgets.MenuItem{label: "Paste", action: :paste},
          %Widgets.MenuItem{label: "Cut", action: :cut}
        ]
      }

      assert menu.trigger_on == :right_click
      assert length(menu.items) == 3

      # All renderers
      assert {:ok, _} = Terminal.render(menu)
      assert {:ok, _} = Desktop.render(menu)
      assert {:ok, _} = Web.render(menu)
    end

    test "Context menu with long-press trigger" do
      menu = %Widgets.ContextMenu{
        id: :touch_context,
        trigger_on: :long_press,
        items: [
          %Widgets.MenuItem{label: "Select All", action: :select_all}
        ]
      }

      assert menu.trigger_on == :long_press

      # All renderers
      assert {:ok, _} = Terminal.render(menu)
      assert {:ok, _} = Desktop.render(menu)
      assert {:ok, _} = Web.render(menu)
    end

    test "Context menu with double-click trigger" do
      menu = %Widgets.ContextMenu{
        id: :double_click_context,
        trigger_on: :double_click,
        items: []
      }

      assert menu.trigger_on == :double_click

      # All renderers
      assert {:ok, _} = Terminal.render(menu)
      assert {:ok, _} = Desktop.render(menu)
      assert {:ok, _} = Web.render(menu)
    end
  end

  # ============================================================================
  # 4.3.3: Tabs System Tests
  # ============================================================================

  describe "4.3.3 - Tabs System" do
    test "Tabs with active tab selection" do
      tabs = %Widgets.Tabs{
        id: :main_tabs,
        active_tab: :home,
        position: :top,
        on_change: :tab_changed,
        tabs: [
          %Widgets.Tab{id: :home, label: "Home", content: %Widgets.Text{content: "Home Page"}},
          %Widgets.Tab{id: :about, label: "About", content: %Widgets.Text{content: "About Page"}},
          %Widgets.Tab{
            id: :contact,
            label: "Contact",
            content: %Widgets.Text{content: "Contact Page"}
          }
        ]
      }

      assert tabs.active_tab == :home
      assert length(tabs.tabs) == 3

      # All renderers
      assert {:ok, _} = Terminal.render(tabs)
      assert {:ok, _} = Desktop.render(tabs)
      assert {:ok, _} = Web.render(tabs)
    end

    test "Tabs with side position" do
      tabs = %Widgets.Tabs{
        id: :side_tabs,
        active_tab: :tab1,
        position: :left,
        tabs: [
          %Widgets.Tab{
            id: :tab1,
            label: "Section 1",
            content: %Widgets.Text{content: "Content 1"}
          },
          %Widgets.Tab{
            id: :tab2,
            label: "Section 2",
            content: %Widgets.Text{content: "Content 2"}
          }
        ]
      }

      assert tabs.position == :left

      # All renderers
      assert {:ok, _} = Terminal.render(tabs)
      assert {:ok, _} = Desktop.render(tabs)
      assert {:ok, _} = Web.render(tabs)
    end

    test "Tabs with icons" do
      tabs = %Widgets.Tabs{
        id: :icon_tabs,
        active_tab: :dashboard,
        tabs: [
          %Widgets.Tab{id: :dashboard, label: "Dashboard", icon: :chart},
          %Widgets.Tab{id: :settings, label: "Settings", icon: :gear},
          %Widgets.Tab{id: :profile, label: "Profile", icon: :user}
        ]
      }

      # Verify tab icons
      dashboard_tab = Enum.at(tabs.tabs, 0)
      assert dashboard_tab.icon == :chart

      # All renderers
      assert {:ok, _} = Terminal.render(tabs)
      assert {:ok, _} = Desktop.render(tabs)
      assert {:ok, _} = Web.render(tabs)
    end

    test "Tabs with disabled and closable tabs" do
      tabs = %Widgets.Tabs{
        id: :mixed_tabs,
        active_tab: :tab1,
        tabs: [
          %Widgets.Tab{id: :tab1, label: "Normal Tab"},
          %Widgets.Tab{id: :tab2, label: "Disabled Tab", disabled: true},
          %Widgets.Tab{id: :tab3, label: "Closable Tab", closable: true}
        ]
      }

      # Verify tab properties
      tab2 = Enum.at(tabs.tabs, 1)
      assert tab2.disabled == true

      tab3 = Enum.at(tabs.tabs, 2)
      assert tab3.closable == true

      # All renderers
      assert {:ok, _} = Terminal.render(tabs)
      assert {:ok, _} = Desktop.render(tabs)
      assert {:ok, _} = Web.render(tabs)
    end

    test "Tabs with nested content" do
      tabs = %Widgets.Tabs{
        id: :nested_tabs,
        active_tab: :form_tab,
        tabs: [
          %Widgets.Tab{
            id: :form_tab,
            label: "Form",
            content: %Layouts.VBox{
              spacing: 1,
              children: [
                %Widgets.Label{text: "Name:", for: :name_input},
                %Widgets.TextInput{id: :name_input, placeholder: "Enter name"},
                %Widgets.Button{label: "Submit", on_click: :submit}
              ]
            }
          }
        ]
      }

      # Verify nested structure
      form_tab = Enum.at(tabs.tabs, 0)
      assert %Layouts.VBox{} = form_tab.content
      assert length(form_tab.content.children) == 3

      # All renderers
      assert {:ok, _} = Terminal.render(tabs)
      assert {:ok, _} = Desktop.render(tabs)
      assert {:ok, _} = Web.render(tabs)
    end
  end

  # ============================================================================
  # 4.3.4: Tree View Tests
  # ============================================================================

  describe "4.3.4 - Tree View" do
    test "Tree view with simple structure" do
      tree = %Widgets.TreeView{
        id: :file_tree,
        root_nodes: [
          %Widgets.TreeNode{id: :src, label: "src"},
          %Widgets.TreeNode{id: :test, label: "test"}
        ]
      }

      assert length(tree.root_nodes) == 2

      # All renderers
      assert {:ok, _} = Terminal.render(tree)
      assert {:ok, _} = Desktop.render(tree)
      assert {:ok, _} = Web.render(tree)
    end

    test "Tree view with nested nodes" do
      tree = %Widgets.TreeView{
        id: :project_tree,
        root_nodes: [
          %Widgets.TreeNode{
            id: :lib,
            label: "lib",
            expanded: true,
            children: [
              %Widgets.TreeNode{
                id: :my_app,
                label: "my_app",
                expanded: true,
                children: [
                  %Widgets.TreeNode{id: :app, label: "app.ex"},
                  %Widgets.TreeNode{id: :application, label: "application.ex"}
                ]
              }
            ]
          }
        ]
      }

      # Verify nested structure
      lib_node = Enum.at(tree.root_nodes, 0)
      assert lib_node.expanded == true
      assert length(lib_node.children) == 1

      my_app_node = Enum.at(lib_node.children, 0)
      assert length(my_app_node.children) == 2

      # All renderers
      assert {:ok, _} = Terminal.render(tree)
      assert {:ok, _} = Desktop.render(tree)
      assert {:ok, _} = Web.render(tree)
    end

    test "Tree view with selection" do
      tree = %Widgets.TreeView{
        id: :selectable_tree,
        selected_node: :node2,
        on_select: :node_selected,
        root_nodes: [
          %Widgets.TreeNode{id: :node1, label: "Node 1"},
          %Widgets.TreeNode{id: :node2, label: "Node 2"},
          %Widgets.TreeNode{id: :node3, label: "Node 3"}
        ]
      }

      assert tree.selected_node == :node2
      assert tree.on_select == :node_selected

      # All renderers
      assert {:ok, _} = Terminal.render(tree)
      assert {:ok, _} = Desktop.render(tree)
      assert {:ok, _} = Web.render(tree)
    end

    test "Tree view with toggle handlers" do
      tree = %Widgets.TreeView{
        id: :toggle_tree,
        on_toggle: :node_toggled,
        root_nodes: [
          %Widgets.TreeNode{
            id: :parent,
            label: "Parent",
            children: [
              %Widgets.TreeNode{id: :child, label: "Child"}
            ]
          }
        ]
      }

      assert tree.on_toggle == :node_toggled

      # All renderers
      assert {:ok, _} = Terminal.render(tree)
      assert {:ok, _} = Desktop.render(tree)
      assert {:ok, _} = Web.render(tree)
    end

    test "Tree view with icons" do
      tree = %Widgets.TreeView{
        id: :icon_tree,
        root_nodes: [
          %Widgets.TreeNode{
            id: :folder,
            label: "My Folder",
            icon: :folder,
            icon_expanded: :folder_open,
            expanded: true,
            children: [
              %Widgets.TreeNode{id: :file, label: "file.txt", icon: :document}
            ]
          }
        ]
      }

      # Verify icons
      folder_node = Enum.at(tree.root_nodes, 0)
      assert folder_node.icon == :folder
      assert folder_node.icon_expanded == :folder_open

      # All renderers
      assert {:ok, _} = Terminal.render(tree)
      assert {:ok, _} = Desktop.render(tree)
      assert {:ok, _} = Web.render(tree)
    end

    test "Tree view with non-selectable nodes" do
      tree = %Widgets.TreeView{
        id: :mixed_selectable,
        root_nodes: [
          %Widgets.TreeNode{id: :selectable, label: "Can Select", selectable: true},
          %Widgets.TreeNode{id: :readonly, label: "Read Only", selectable: false}
        ]
      }

      readonly_node = Enum.at(tree.root_nodes, 1)
      assert readonly_node.selectable == false

      # All renderers
      assert {:ok, _} = Terminal.render(tree)
      assert {:ok, _} = Desktop.render(tree)
      assert {:ok, _} = Web.render(tree)
    end
  end

  # ============================================================================
  # 4.3.5: Keyboard Navigation
  # ============================================================================

  describe "4.3.5 - Keyboard Navigation" do
    test "navigation keys map to normalized actions across adapters" do
      adapter_platforms = [
        {Terminal.Events, :terminal},
        {Desktop.Events, :desktop},
        {Web.Events, :web}
      ]

      Enum.each(adapter_platforms, fn {events_module, platform} ->
        assert {:ok, signal} = events_module.navigation_key(:main_tabs, :right)
        assert signal.type == "unified.key.pressed"
        assert signal.data.widget_id == :main_tabs
        assert signal.data.key == :right
        assert signal.data.action == :navigate_right
        assert signal.data.platform == platform
      end)
    end

    test "activation and dismiss keys map consistently for navigation widgets" do
      adapter_platforms = [
        {Terminal.Events, :terminal},
        {Desktop.Events, :desktop},
        {Web.Events, :web}
      ]

      Enum.each(adapter_platforms, fn {events_module, platform} ->
        assert {:ok, activate_signal} = events_module.navigation_key(:main_menu, :enter)
        assert activate_signal.data.action == :activate
        assert activate_signal.data.platform == platform

        assert {:ok, dismiss_signal} = events_module.navigation_key(:context_menu, :escape)
        assert dismiss_signal.data.action == :dismiss
        assert dismiss_signal.data.platform == platform
      end)
    end
  end

  # ============================================================================
  # 4.3.6: Complex Navigation UI
  # ============================================================================

  describe "4.3.6 - Complex Navigation UI" do
    test "Full application layout with all navigation widgets" do
      ui = %Layouts.VBox{
        id: :app_layout,
        spacing: 1,
        children: [
          # Menu bar
          %Widgets.Menu{
            id: :menu_bar,
            position: :top,
            items: [
              %Widgets.MenuItem{label: "File", action: :file_menu},
              %Widgets.MenuItem{label: "Edit", action: :edit_menu},
              %Widgets.MenuItem{label: "View", action: :view_menu}
            ]
          },
          # Tabs container
          %Widgets.Tabs{
            id: :main_tabs,
            active_tab: :dashboard,
            tabs: [
              %Widgets.Tab{
                id: :dashboard,
                label: "Dashboard",
                content: %Widgets.Text{content: "Dashboard content"}
              },
              %Widgets.Tab{
                id: :files,
                label: "Files",
                content: %Widgets.TreeView{
                  id: :file_browser,
                  root_nodes: [
                    %Widgets.TreeNode{
                      id: :documents,
                      label: "Documents",
                      children: [
                        %Widgets.TreeNode{id: :doc1, label: "Report.txt"}
                      ]
                    }
                  ]
                }
              }
            ]
          },
          # Status bar
          %Widgets.Text{content: "Ready", id: :status}
        ]
      }

      # Verify structure
      assert length(ui.children) == 3

      menu = Enum.at(ui.children, 0)
      assert %Widgets.Menu{} = menu

      tabs = Enum.at(ui.children, 1)
      assert %Widgets.Tabs{} = tabs

      # All renderers
      assert {:ok, terminal_state} = Terminal.render(ui)
      assert {:ok, _} = UnifiedUi.Adapters.State.get_root(terminal_state)

      assert {:ok, desktop_state} = Desktop.render(ui)
      assert {:ok, _} = UnifiedUi.Adapters.State.get_root(desktop_state)

      assert {:ok, web_state} = Web.render(ui)
      assert {:ok, _} = UnifiedUi.Adapters.State.get_root(web_state)
    end

    test "Split pane with tree and context menu" do
      ui = %Layouts.HBox{
        id: :split_view,
        spacing: 2,
        children: [
          # Left panel: tree view
          %Widgets.TreeView{
            id: :nav_tree,
            root_nodes: [
              %Widgets.TreeNode{
                id: :root,
                label: "Root",
                expanded: true,
                children: [
                  %Widgets.TreeNode{id: :branch1, label: "Branch 1"},
                  %Widgets.TreeNode{id: :branch2, label: "Branch 2"}
                ]
              }
            ]
          },
          # Right panel: content with context menu
          %Layouts.VBox{
            children: [
              %Widgets.Text{content: "Content area"},
              %Widgets.ContextMenu{
                id: :content_context,
                items: [
                  %Widgets.MenuItem{label: "Copy", action: :copy},
                  %Widgets.MenuItem{label: "Paste", action: :paste}
                ]
              }
            ]
          }
        ]
      }

      # Verify structure
      assert length(ui.children) == 2

      # All renderers
      assert {:ok, _} = Terminal.render(ui)
      assert {:ok, _} = Desktop.render(ui)
      assert {:ok, _} = Web.render(ui)
    end

    test "Tab bar with all navigation features combined" do
      ui = %Widgets.Tabs{
        id: :full_nav,
        active_tab: :home,
        position: :top,
        tabs: [
          %Widgets.Tab{
            id: :home,
            label: "Home",
            icon: :house,
            content: %Layouts.VBox{
              children: [
                %Widgets.Menu{
                  id: :home_menu,
                  items: [
                    %Widgets.MenuItem{label: "Refresh", action: :refresh}
                  ]
                },
                %Widgets.Text{content: "Home content"}
              ]
            }
          },
          %Widgets.Tab{
            id: :settings,
            label: "Settings",
            icon: :gear,
            closable: true,
            content: %Widgets.TreeView{
              id: :settings_tree,
              root_nodes: [
                %Widgets.TreeNode{
                  id: :general,
                  label: "General",
                  children: [
                    %Widgets.TreeNode{id: :appearance, label: "Appearance"}
                  ]
                }
              ]
            }
          }
        ]
      }

      # Verify complex nesting
      home_tab = Enum.at(ui.tabs, 0)
      assert %Layouts.VBox{} = home_tab.content

      settings_tab = Enum.at(ui.tabs, 1)
      assert settings_tab.closable == true
      assert %Widgets.TreeView{} = settings_tab.content

      # All renderers
      assert {:ok, _} = Terminal.render(ui)
      assert {:ok, _} = Desktop.render(ui)
      assert {:ok, _} = Web.render(ui)
    end
  end

  # ============================================================================
  # 4.4: Dialog and Feedback Widgets
  # ============================================================================

  describe "4.4 - Dialog and Feedback Widgets" do
    test "Dialog with nested content and close signal" do
      dialog = %Widgets.Dialog{
        id: :settings_dialog,
        title: "Settings",
        content: %Layouts.VBox{
          spacing: 1,
          children: [
            %Widgets.Text{content: "Update settings"},
            %Widgets.TextInput{id: :name, placeholder: "Name"}
          ]
        },
        on_close: :close_settings,
        buttons: [
          %Widgets.DialogButton{label: "Cancel", action: :close_settings, role: :cancel},
          %Widgets.DialogButton{label: "Save", action: :save_settings, role: :confirm}
        ]
      }

      assert dialog.on_close == :close_settings
      assert length(dialog.buttons) == 2

      assert {:ok, _} = Terminal.render(dialog)
      assert {:ok, _} = Desktop.render(dialog)
      assert {:ok, _} = Web.render(dialog)
    end

    test "Modal behavior marks background as blocked across adapters" do
      modal_dialog = %Widgets.Dialog{
        id: :blocking_dialog,
        title: "Blocking Dialog",
        content: "Modal content",
        modal: true
      }

      non_modal_dialog = %Widgets.Dialog{
        id: :non_blocking_dialog,
        title: "Non-Blocking Dialog",
        content: "Overlay content",
        modal: false
      }

      assert {:dialog, _node, terminal_modal_meta} = Terminal.convert_iur(modal_dialog)
      assert terminal_modal_meta.blocks_background == true

      assert {:dialog, _node, terminal_non_modal_meta} = Terminal.convert_iur(non_modal_dialog)
      assert terminal_non_modal_meta.blocks_background == false

      assert {:dialog, desktop_modal_widget, desktop_modal_meta} =
               Desktop.convert_iur(modal_dialog)

      assert desktop_modal_meta.blocks_background == true
      assert desktop_modal_widget.props[:blocks_background] == true

      assert {:dialog, desktop_non_modal_widget, desktop_non_modal_meta} =
               Desktop.convert_iur(non_modal_dialog)

      assert desktop_non_modal_meta.blocks_background == false
      assert desktop_non_modal_widget.props[:blocks_background] == false

      modal_html = Web.convert_iur(modal_dialog)
      non_modal_html = Web.convert_iur(non_modal_dialog)

      assert modal_html =~ "data-blocks-background=\"true\""
      assert non_modal_html =~ "data-blocks-background=\"false\""
    end

    test "Alert dialog severity metadata is preserved" do
      alert = %Widgets.AlertDialog{
        id: :delete_alert,
        title: "Delete Item",
        message: "This action cannot be undone.",
        severity: :warning,
        on_confirm: :confirm_delete,
        on_cancel: :cancel_delete
      }

      assert alert.severity == :warning
      assert alert.on_confirm == :confirm_delete
      assert alert.on_cancel == :cancel_delete

      assert {:ok, _} = Terminal.render(alert)
      assert {:ok, _} = Desktop.render(alert)
      assert {:ok, _} = Web.render(alert)
    end

    test "Toast auto-dismiss metadata is generated when duration is positive" do
      toast = %Widgets.Toast{
        id: :save_toast,
        message: "Saved successfully",
        severity: :success,
        duration: 1500,
        on_dismiss: :dismiss_save_toast
      }

      assert toast.duration == 1500
      assert toast.on_dismiss == :dismiss_save_toast

      assert {:toast, _node, terminal_meta} = Terminal.convert_iur(toast)
      assert terminal_meta.auto_dismiss == true
      assert is_integer(terminal_meta.dismiss_at)

      assert {:toast, desktop_widget, desktop_meta} = Desktop.convert_iur(toast)
      assert desktop_widget.props[:auto_dismiss] == true
      assert is_integer(desktop_widget.props[:dismiss_at])
      assert desktop_meta.auto_dismiss == true
      assert is_integer(desktop_meta.dismiss_at)

      web_html = Web.convert_iur(toast)
      assert web_html =~ "data-auto-dismiss=\"true\""
      assert web_html =~ "data-dismiss-at=\""
    end

    test "Toast duration 0 disables auto-dismiss" do
      persistent_toast = %Widgets.Toast{
        id: :persistent_toast,
        message: "Requires manual dismiss",
        duration: 0
      }

      assert {:toast, _node, terminal_meta} = Terminal.convert_iur(persistent_toast)
      assert terminal_meta.auto_dismiss == false
      assert terminal_meta.dismiss_at == nil

      assert {:toast, desktop_widget, desktop_meta} = Desktop.convert_iur(persistent_toast)
      assert desktop_widget.props[:auto_dismiss] == false
      refute Keyword.has_key?(desktop_widget.props, :dismiss_at)
      assert desktop_meta.auto_dismiss == false
      assert desktop_meta.dismiss_at == nil

      web_html = Web.convert_iur(persistent_toast)
      assert web_html =~ "data-auto-dismiss=\"false\""
      refute web_html =~ "data-dismiss-at=\""
    end

    test "All dialog widgets render on all platforms" do
      widgets = [
        %Widgets.Dialog{
          id: :dialog_a,
          title: "Dialog",
          content: "Body",
          buttons: [%Widgets.DialogButton{label: "OK", action: :ok}]
        },
        %Widgets.AlertDialog{
          id: :alert_a,
          title: "Alert",
          message: "Attention",
          severity: :error
        },
        %Widgets.Toast{id: :toast_a, message: "Done", duration: 1000}
      ]

      Enum.each(widgets, fn widget ->
        assert {:ok, _} = Terminal.render(widget)
        assert {:ok, _} = Desktop.render(widget)
        assert {:ok, _} = Web.render(widget)
      end)
    end
  end

  # ============================================================================
  # 4.5: Input Widgets
  # ============================================================================

  describe "4.5 - Input Widgets" do
    test "PickList renders with options and selection metadata" do
      pick_list = %Widgets.PickList{
        id: :country_select,
        options: [
          %Widgets.PickListOption{value: "us", label: "United States"},
          %Widgets.PickListOption{value: "ca", label: "Canada"}
        ],
        selected: "ca",
        searchable: true,
        on_select: :country_selected
      }

      assert {:pick_list, _terminal_node, terminal_meta} = Terminal.convert_iur(pick_list)
      assert terminal_meta.id == :country_select
      assert terminal_meta.selected == "ca"
      assert terminal_meta.searchable == true
      assert terminal_meta.on_select == :country_selected

      assert {:pick_list, desktop_widget, desktop_meta} = Desktop.convert_iur(pick_list)
      assert desktop_widget.type == :pick_list
      assert desktop_meta.selected == "ca"

      web_html = Web.convert_iur(pick_list)
      assert web_html =~ ~s(id="country_select")
      assert web_html =~ ~s(data-searchable="true")
      assert web_html =~ "Canada"
      assert web_html =~ ~s(phx-change="country-selected")
    end

    test "FormBuilder renders fields and submit metadata" do
      form_builder = %Widgets.FormBuilder{
        id: :profile_form,
        fields: [
          %Widgets.FormField{
            name: :email,
            type: :email,
            label: "Email",
            required: true,
            placeholder: "user@example.com"
          },
          %Widgets.FormField{name: :newsletter, type: :checkbox, label: "Subscribe"}
        ],
        action: :save_profile,
        on_submit: :profile_saved,
        submit_label: "Save Profile"
      }

      assert {:form_builder, _terminal_node, terminal_meta} = Terminal.convert_iur(form_builder)
      assert terminal_meta.id == :profile_form
      assert terminal_meta.on_submit == :profile_saved

      assert {:form_builder, desktop_widget, desktop_meta} = Desktop.convert_iur(form_builder)
      assert desktop_widget.type == :form_builder
      assert desktop_meta.submit_label == "Save Profile"

      web_html = Web.convert_iur(form_builder)
      assert web_html =~ ~s(<form)
      assert web_html =~ ~s(id="profile_form")
      assert web_html =~ ~s(phx-submit="profile-saved")
      assert web_html =~ ~s(type="email")
      assert web_html =~ ~s(required="true")
      assert web_html =~ "Save Profile"
    end

    test "All input widgets render on all platforms" do
      widgets = [
        %Widgets.PickList{
          id: :status_select,
          options: [
            %Widgets.PickListOption{value: :open, label: "Open"},
            %Widgets.PickListOption{value: :closed, label: "Closed"}
          ],
          allow_clear: true
        },
        %Widgets.FormBuilder{
          id: :task_form,
          fields: [
            %Widgets.FormField{name: :title, type: :text, required: true},
            %Widgets.FormField{
              name: :priority,
              type: :select,
              options: [{"low", "Low"}, {"high", "High"}]
            }
          ]
        }
      ]

      Enum.each(widgets, fn widget ->
        assert {:ok, _} = Terminal.render(widget)
        assert {:ok, _} = Desktop.render(widget)
        assert {:ok, _} = Web.render(widget)
      end)
    end
  end

  # ============================================================================
  # 4.6: Container Widgets
  # ============================================================================

  describe "4.6 - Container Widgets" do
    test "viewport carries clipping metadata and renders on all platforms" do
      viewport = %Viewport{
        id: :main_viewport,
        width: 80,
        height: 20,
        scroll_x: 3,
        scroll_y: 6,
        border: :solid,
        content: %Widgets.Text{content: "Scrollable content"}
      }

      assert {:viewport, _terminal_node, terminal_meta} = Terminal.convert_iur(viewport)
      assert terminal_meta.width == 80
      assert terminal_meta.height == 20
      assert terminal_meta.scroll_x == 3
      assert terminal_meta.scroll_y == 6

      assert_renders_on_all_platforms(viewport)
    end

    test "viewport scrolling signal updates container state through generated update route" do
      module =
        compile_phase4_fixture("""
        vbox do
          viewport :main_viewport, %{name: :text, attrs: %{content: "Scrollable"}},
            on_scroll: :viewport_scrolled
        end
        """)

      state = module.init([])

      scroll_signal = %{
        type: "unified.input.changed",
        data: %{widget_id: :main_viewport, value: %{scroll_x: 4, scroll_y: 12}}
      }

      updated = module.update(state, scroll_signal)
      assert updated.main_viewport == %{scroll_x: 4, scroll_y: 12}
    end

    test "split pane holds two panes and renders on all platforms" do
      split_pane = %SplitPane{
        id: :main_split,
        panes: [%Widgets.Text{content: "Left"}, %Widgets.Text{content: "Right"}],
        orientation: :horizontal,
        initial_split: 55,
        min_size: 20
      }

      assert {:split_pane, _terminal_node, terminal_meta} = Terminal.convert_iur(split_pane)
      assert terminal_meta.orientation == :horizontal
      assert terminal_meta.initial_split == 55
      assert terminal_meta.min_size == 20

      assert_renders_on_all_platforms(split_pane)
    end

    test "split pane resize signal updates container state through generated update route" do
      module =
        compile_phase4_fixture("""
        vbox do
          split_pane :main_split, [
            %{name: :text, attrs: %{content: "Left"}},
            %{name: :text, attrs: %{content: "Right"}}
          ], on_resize_change: :split_resized
        end
        """)

      state = module.init([])

      resize_signal = %{
        type: "unified.input.changed",
        data: %{widget_id: :main_split, value: %{split: 65}}
      }

      updated = module.update(state, resize_signal)
      assert updated.main_split == %{split: 65}
    end
  end

  # ============================================================================
  # 4.7: Specialized Widgets
  # ============================================================================

  describe "4.7 - Specialized Widgets" do
    test "canvas carries drawing metadata and renders on all platforms" do
      canvas = %Canvas{
        id: :chart_canvas,
        width: 120,
        height: 40,
        draw: fn _ctx -> :ok end,
        on_click: :canvas_clicked,
        on_hover: :canvas_hovered
      }

      assert {:canvas, _terminal_node, terminal_meta} = Terminal.convert_iur(canvas)
      assert terminal_meta.width == 120
      assert terminal_meta.height == 40
      assert terminal_meta.on_click == :canvas_clicked
      assert terminal_meta.on_hover == :canvas_hovered
      assert is_function(terminal_meta.draw, 1)

      assert_renders_on_all_platforms(canvas)
    end

    test "canvas click signal updates state through generated click route" do
      module =
        compile_phase4_fixture("""
        vbox do
          canvas :chart_canvas, on_click: {:canvas_clicked, %{canvas_clicked: true}}
        end
        """)

      state = module.init([])

      click_signal = %{
        type: "unified.button.clicked",
        data: %{widget_id: :chart_canvas, action: :canvas_clicked}
      }

      updated = module.update(state, click_signal)
      assert updated.canvas_clicked == true
    end

    test "command palette carries command metadata and renders on all platforms" do
      command_palette = %CommandPalette{
        id: :main_commands,
        placeholder: "Search commands",
        trigger_shortcut: "ctrl+k",
        on_select: :command_selected,
        commands: [
          %Command{id: :open, label: "Open File", keywords: ["open", "file"]},
          %Command{id: :save, label: "Save File", keywords: ["save", "write"]}
        ]
      }

      assert {:command_palette, _terminal_node, terminal_meta} =
               Terminal.convert_iur(command_palette)

      assert terminal_meta.id == :main_commands
      assert terminal_meta.on_select == :command_selected

      assert [%{id: :open, label: "Open File"}, %{id: :save, label: "Save File"}] =
               terminal_meta.commands

      assert_renders_on_all_platforms(command_palette)
    end

    test "command palette search signal updates filtered command state through generated route" do
      module =
        compile_phase4_fixture("""
        vbox do
          command_palette :main_commands, [
            %{id: :open, label: "Open File", keywords: ["open", "file"]},
            %{id: :save, label: "Save File", keywords: ["save", "write"]}
          ], on_select: :command_selected
        end
        """)

      state = module.init([])

      search_signal = %{
        type: "unified.input.changed",
        data: %{widget_id: :main_commands, query: "sav"}
      }

      updated = module.update(state, search_signal)

      assert updated.main_commands_search_query == "sav"
      assert [%{id: :save, label: "Save File"}] = updated.main_commands_filtered_commands
    end
  end

  # ============================================================================
  # 4.8: Monitoring Widgets
  # ============================================================================

  describe "4.8 - Monitoring Widgets" do
    test "log viewer carries source and auto-scroll metadata and renders on all platforms" do
      log_viewer = %LogViewer{
        id: :app_logs,
        source: "/tmp/app.log",
        lines: 200,
        auto_scroll: true,
        filter: "error",
        refresh_interval: 500
      }

      assert {:log_viewer, _terminal_node, terminal_meta} = Terminal.convert_iur(log_viewer)
      assert terminal_meta.id == :app_logs
      assert terminal_meta.source == "/tmp/app.log"
      assert terminal_meta.lines == 200
      assert terminal_meta.auto_scroll == true
      assert terminal_meta.filter == "error"
      assert terminal_meta.auto_refresh == true

      assert_renders_on_all_platforms(log_viewer)
    end

    test "stream widget on_item signal updates state through generated change route" do
      module =
        compile_phase4_fixture("""
        vbox do
          stream_widget :events, :event_source, on_item: :stream_item
        end
        """)

      state = module.init([])

      item_signal = %{
        type: "unified.input.changed",
        data: %{widget_id: :events, value: %{event: "updated"}}
      }

      updated = module.update(state, item_signal)
      assert updated.events == %{event: "updated"}
    end

    test "process monitor selection signal updates state through generated click route" do
      module =
        compile_phase4_fixture("""
        vbox do
          process_monitor :processes, on_process_select: {:process_selected, %{selected: true}}
        end
        """)

      state = module.init([])

      select_signal = %{
        type: "unified.button.clicked",
        data: %{widget_id: :processes, action: :process_selected}
      }

      updated = module.update(state, select_signal)
      assert updated.selected == true
    end

    test "monitoring widgets expose refresh metadata across renderers" do
      stream_widget = %StreamWidget{
        id: :events,
        producer: :event_source,
        buffer_size: 50,
        refresh_interval: 250,
        on_item: :stream_item
      }

      process_monitor = %ProcessMonitor{
        id: :processes,
        node: :nonode@nohost,
        refresh_interval: 1_250,
        sort_by: :memory,
        on_process_select: :process_selected
      }

      assert {:stream_widget, _terminal_node, stream_meta} = Terminal.convert_iur(stream_widget)
      assert stream_meta.auto_refresh == true
      assert stream_meta.refresh_interval == 250

      assert {:process_monitor, _terminal_node, process_meta} =
               Terminal.convert_iur(process_monitor)

      assert process_meta.auto_refresh == true
      assert process_meta.refresh_interval == 1_250

      assert_renders_on_all_platforms(stream_widget)
      assert_renders_on_all_platforms(process_monitor)
    end
  end

  # ============================================================================
  # 4.9: Advanced Layout System
  # ============================================================================

  describe "4.9 - Advanced Layout System" do
    test "grid layout preserves flexible track sizing and renders on all platforms" do
      grid = %Grid{
        id: :main_grid,
        columns: [1, "2fr", "auto"],
        rows: [1, 1],
        gap: 2,
        children: [
          %Widgets.Text{content: "A"},
          %Widgets.Text{content: "B"},
          %Widgets.Text{content: "C"}
        ]
      }

      assert {:grid, _node, terminal_meta} = Terminal.convert_iur(grid)
      assert terminal_meta.columns == ["1fr", "2fr", "auto"]
      assert terminal_meta.rows == ["1fr", "1fr"]
      assert terminal_meta.gap == 2

      assert {:grid, desktop_widget, desktop_meta} = Desktop.convert_iur(grid)
      assert desktop_widget.type == :grid
      assert desktop_meta.columns == ["1fr", "2fr", "auto"]

      web_html = Web.convert_iur(grid)
      assert web_html =~ "grid-template-columns: 1fr 2fr auto"
      assert web_html =~ "grid-template-rows: 1fr 1fr"
      assert web_html =~ "gap: 2px"

      assert_renders_on_all_platforms(grid)
    end

    test "stack layout switches active child via active_index" do
      stack = %Stack{
        id: :main_stack,
        active_index: 1,
        transition: :fade,
        children: [
          %Widgets.Text{content: "First Panel"},
          %Widgets.Text{content: "Second Panel"}
        ]
      }

      assert {:stack, _node, terminal_meta} = Terminal.convert_iur(stack)
      assert terminal_meta.active_index == 1

      assert {:stack, desktop_widget, desktop_meta} = Desktop.convert_iur(stack)
      assert desktop_widget.type == :stack
      assert length(desktop_widget.children) == 1
      assert desktop_meta.active_index == 1

      web_html = Web.convert_iur(stack)
      assert web_html =~ ~s(data-active-index="1")
      refute web_html =~ "First Panel"
      assert web_html =~ "Second Panel"

      assert_renders_on_all_platforms(stack)
    end

    test "zbox layout preserves absolute positioning metadata and nested advanced layouts render" do
      nested = %Grid{
        id: :nested_grid,
        columns: [1, 1],
        children: [%Widgets.Text{content: "Nested A"}, %Widgets.Text{content: "Nested B"}]
      }

      zbox = %ZBox{
        id: :overlay,
        positions: %{0 => %{x: 0, y: 0, z: 0}, content: %{x: 8, y: 3, z_index: 4}},
        children: [
          %Widgets.Text{content: "Base Layer"},
          %Layouts.VBox{id: :content, children: [nested]}
        ]
      }

      assert {:zbox, _node, terminal_meta} = Terminal.convert_iur(zbox)
      assert terminal_meta.positions[0] == %{x: 0, y: 0, z: 0}
      assert terminal_meta.positions[:content] == %{x: 8, y: 3, z_index: 4}

      assert {:zbox, desktop_widget, desktop_meta} = Desktop.convert_iur(zbox)
      assert desktop_widget.type == :zbox
      assert desktop_meta.child_count == 2

      web_html = Web.convert_iur(zbox)
      assert web_html =~ "position: relative"
      assert web_html =~ "position: absolute"
      assert web_html =~ "left: 8px"
      assert web_html =~ "top: 3px"
      assert web_html =~ "z-index: 4"
      assert web_html =~ "Nested A"
      assert web_html =~ "Nested B"

      assert_renders_on_all_platforms(zbox)
    end
  end

  # ============================================================================
  # 4.11: Theming and Form Integration
  # ============================================================================

  describe "4.11 - Theming and Form Integration" do
    test "theme switching updates themed styles and renders on all platforms" do
      module =
        compile_phase4_fixture("""
        vbox do
          pick_list :theme, [{:light, "Light"}, {:dark, "Dark"}], on_select: :theme_changed
        end
        """)

      dsl_state = themed_dsl_state()
      light_state = module.init([]) |> Map.put(:theme, :light)
      light_iur = Builder.build(dsl_state, light_state)

      assert %Layouts.VBox{children: [%Widgets.Text{style: %UnifiedIUR.Style{fg: :black}}]} =
               light_iur

      signal = %{type: "unified.input.changed", data: %{widget_id: :theme, value: "dark"}}
      dark_state = module.update(light_state, signal)

      assert dark_state.theme == "dark"

      dark_iur = Builder.build(dsl_state, dark_state)

      assert %Layouts.VBox{children: [%Widgets.Text{style: %UnifiedIUR.Style{fg: :white}}]} =
               dark_iur

      assert {:ok, _} = Terminal.render(dark_iur)
      assert {:ok, _} = Desktop.render(dark_iur)
      assert {:ok, _} = Web.render(dark_iur)
    end

    test "form_builder submission populates validation metadata end-to-end" do
      module =
        compile_phase4_fixture("""
        vbox do
          form_builder :profile_form, [
            %{name: :email, type: :email, required: true},
            %{name: :age, type: :number, required: true},
            %{name: :country, type: :select, options: [{:us, "United States"}, {:ca, "Canada"}]}
          ],
            on_submit: :profile_saved
        end
        """)

      state = module.init([])

      invalid_signal = %{
        type: "unified.form.submitted",
        data: %{form_id: :profile_form, data: %{email: "bad", age: "abc", country: :xx}}
      }

      invalid_state = module.update(state, invalid_signal)

      assert invalid_state.profile_form_valid == false
      assert invalid_state.profile_form_errors.email == [:invalid_email]
      assert invalid_state.profile_form_errors.age == [:invalid_number]
      assert invalid_state.profile_form_errors.country == [:invalid_option]

      valid_signal = %{
        type: "unified.form.submitted",
        data: %{
          form_id: :profile_form,
          data: %{email: "user@example.com", age: "42", country: :ca}
        }
      }

      valid_state = module.update(invalid_state, valid_signal)

      assert valid_state.profile_form_valid == true
      assert valid_state.profile_form_errors == %{}
    end

    test "complex dashboard with implemented phase 4 widgets compiles and renders on all platforms" do
      module = compile_phase4_dashboard_module()
      state = module.init([])
      iur = module.view(state)

      assert %Layouts.VBox{id: :phase4_dashboard, children: children} = iur
      assert length(children) == 7

      assert_renders_on_all_platforms(iur)
    end

    test "live telemetry updates refresh data visualization widgets end-to-end" do
      module = compile_phase4_live_data_module()
      component_id = :phase4_live_data_dashboard

      assert {:ok, _pid} =
               Agent.start_component(module, component_id, platforms: [:terminal, :desktop, :web])

      on_exit(fn ->
        _ = Agent.stop_component(component_id)
      end)

      assert {:ok, %{cpu: 35}} = Agent.current_state(component_id)

      telemetry_signal =
        Signals.create!("unified.telemetry.tick", %{
          cpu: 82,
          trend: [31, 45, 53, 61, 82],
          throughput: [{"api", 74}, {"db", 63}, {"worker", 58}],
          latency: [{"09:00", 120}, {"09:01", 108}, {"09:02", 95}, {"09:03", 88}]
        })

      assert :ok = Agent.signal_component(component_id, telemetry_signal)
      Process.sleep(25)

      assert {:ok, %{cpu: 82, trend: [31, 45, 53, 61, 82]}} = Agent.current_state(component_id)

      assert {:ok,
              %Layouts.VBox{
                children: [
                  %Widgets.Gauge{value: 82},
                  %Widgets.Sparkline{data: [31, 45, 53, 61, 82]},
                  %Widgets.BarChart{data: [{"api", 74}, {"db", 63}, {"worker", 58}]},
                  %Widgets.LineChart{
                    data: [{"09:00", 120}, {"09:01", 108}, {"09:02", 95}, {"09:03", 88}]
                  }
                ]
              }} = Agent.current_iur(component_id)

      assert {:ok, render_results} = Agent.render_results(component_id)

      assert Enum.all?([:terminal, :desktop, :web], fn platform ->
               match?({:ok, _}, Map.fetch!(render_results, platform))
             end)
    end

    test "dashboard rendering stays responsive with 200+ elements" do
      element_count = 240
      threshold_ms = 8_000
      large_ui = large_phase4_dashboard_iur(element_count)

      assert %Layouts.VBox{children: children} = large_ui
      assert length(children) == element_count

      started_at_ms = System.monotonic_time(:millisecond)
      assert_renders_on_all_platforms(large_ui)
      elapsed_ms = System.monotonic_time(:millisecond) - started_at_ms

      assert elapsed_ms < threshold_ms
    end

    test "implemented advanced widgets render on all platforms" do
      Enum.each(implemented_advanced_widgets(), fn widget ->
        assert_renders_on_all_platforms(widget)
      end)
    end

    test "phase 4 live-data dashboard memory usage stays bounded under sustained updates" do
      module = compile_phase4_live_data_module()
      component_id = :phase4_memory_stability
      signal_count = 1_200
      max_total_growth_bytes = 140 * 1024 * 1024
      max_process_growth_bytes = 12 * 1024 * 1024

      assert {:ok, _pid} =
               Agent.start_component(module, component_id, platforms: [:terminal, :desktop, :web])

      on_exit(fn ->
        _ = Agent.stop_component(component_id)
      end)

      assert {:ok, pid} = Agent.whereis(component_id)
      baseline_total_memory = :erlang.memory(:total)
      baseline_process_memory = process_memory(pid)

      last_cpu =
        Enum.reduce(1..signal_count, nil, fn index, _acc ->
          cpu_value = rem(index * 7, 100)
          signal = Signals.create!("unified.telemetry.tick", telemetry_payload(index, cpu_value))

          assert :ok = Agent.signal_component(component_id, signal)
          cpu_value
        end)

      assert {:ok, %{cpu: ^last_cpu}} = Agent.current_state(component_id)
      assert {:ok, _} = Agent.current_iur(component_id)
      assert {:ok, _} = Agent.render_results(component_id)

      :erlang.garbage_collect(pid)
      Process.sleep(25)

      total_growth = non_negative_growth(:erlang.memory(:total), baseline_total_memory)
      process_growth = non_negative_growth(process_memory(pid), baseline_process_memory)

      assert total_growth < max_total_growth_bytes
      assert process_growth < max_process_growth_bytes
    end
  end

  # ============================================================================
  # Cross-Platform Rendering Parity
  # ============================================================================

  describe "Cross-Platform Rendering" do
    test "All navigation widgets render on all platforms" do
      widgets = [
        %Widgets.Menu{id: :test_menu, items: [%Widgets.MenuItem{label: "Test"}]},
        %Widgets.ContextMenu{id: :test_ctx, items: []},
        %Widgets.Tabs{id: :test_tabs, tabs: [%Widgets.Tab{id: :t1, label: "T1"}]},
        %Widgets.TreeView{id: :test_tree, root_nodes: [%Widgets.TreeNode{id: :n1, label: "N1"}]}
      ]

      Enum.each(widgets, fn widget ->
        assert {:ok, _} = Terminal.render(widget)
        assert {:ok, _} = Desktop.render(widget)
        assert {:ok, _} = Web.render(widget)
      end)
    end

    test "Complex nested navigation renders on all platforms" do
      complex_ui = %Layouts.VBox{
        children: [
          %Widgets.Menu{
            id: :top_menu,
            items: [
              %Widgets.MenuItem{
                label: "File",
                submenu: [
                  %Widgets.MenuItem{label: "New", action: :new}
                ]
              }
            ]
          },
          %Widgets.Tabs{
            id: :main_tabs,
            active_tab: :tab1,
            tabs: [
              %Widgets.Tab{
                id: :tab1,
                label: "Tab 1",
                content: %Widgets.TreeView{
                  id: :tab1_tree,
                  root_nodes: [
                    %Widgets.TreeNode{
                      id: :root,
                      label: "Root",
                      children: [
                        %Widgets.TreeNode{id: :child1, label: "Child 1"}
                      ]
                    }
                  ]
                }
              }
            ]
          }
        ]
      }

      # All platforms should handle the complex nested structure
      assert {:ok, terminal_state} = Terminal.render(complex_ui)
      assert {:ok, _} = UnifiedUi.Adapters.State.get_root(terminal_state)

      assert {:ok, desktop_state} = Desktop.render(complex_ui)
      assert {:ok, _} = UnifiedUi.Adapters.State.get_root(desktop_state)

      assert {:ok, web_state} = Web.render(complex_ui)
      assert {:ok, _} = UnifiedUi.Adapters.State.get_root(web_state)
    end
  end

  defp compile_phase4_fixture(body) do
    module =
      Module.concat([
        UnifiedUi,
        Integration,
        Phase4Fixture,
        :"M#{System.unique_integer([:positive])}"
      ])

    source = """
    defmodule #{inspect(module)} do
      @behaviour UnifiedUi.ElmArchitecture
      use UnifiedUi.Dsl

      #{body}
    end
    """

    Code.compile_string(source)
    module
  end

  defp themed_dsl_state do
    light_text = %DslStyle{name: :light_text, attributes: [fg: :black]}
    dark_text = %DslStyle{name: :dark_text, attributes: [fg: :white]}
    light_theme = %DslTheme{name: :light, styles: [text: :light_text]}
    dark_theme = %DslTheme{name: :dark, styles: [text: :dark_text]}

    %{
      [:ui] => %{
        entities: [
          %{
            name: :vbox,
            attrs: %{},
            entities: [
              %{name: :text, attrs: %{content: "Theme Aware", style: :text}}
            ]
          }
        ]
      },
      :styles => %{entities: [light_text, dark_text, light_theme, dark_theme]},
      persist: %{module: __MODULE__}
    }
  end

  defp assert_renders_on_all_platforms(iur) do
    assert {:ok, terminal_state} = Terminal.render(iur)
    assert {:ok, _} = UnifiedUi.Adapters.State.get_root(terminal_state)

    assert {:ok, desktop_state} = Desktop.render(iur)
    assert {:ok, _} = UnifiedUi.Adapters.State.get_root(desktop_state)

    assert {:ok, web_state} = Web.render(iur)
    assert {:ok, _} = UnifiedUi.Adapters.State.get_root(web_state)
  end

  defp compile_phase4_dashboard_module do
    module =
      Module.concat([
        UnifiedUi,
        Integration,
        Phase4Dashboard,
        :"M#{System.unique_integer([:positive])}"
      ])

    dashboard = phase4_dashboard_iur()

    quoted =
      quote do
        defmodule unquote(module) do
          @behaviour UnifiedUi.ElmArchitecture

          @impl true
          def init(_opts), do: %{loaded: true}

          @impl true
          def update(state, _signal), do: state

          @impl true
          def view(_state), do: unquote(Macro.escape(dashboard))
        end
      end

    Code.compile_quoted(quoted)
    module
  end

  defp compile_phase4_live_data_module do
    module =
      Module.concat([
        UnifiedUi,
        Integration,
        Phase4LiveData,
        :"M#{System.unique_integer([:positive])}"
      ])

    quoted =
      quote do
        defmodule unquote(module) do
          @behaviour UnifiedUi.ElmArchitecture

          alias UnifiedIUR.{Layouts, Widgets}

          @impl true
          def init(_opts) do
            %{
              cpu: 35,
              trend: [20, 25, 29, 35],
              throughput: [{"api", 40}, {"db", 32}, {"worker", 28}],
              latency: [{"09:00", 170}, {"09:01", 145}, {"09:02", 132}, {"09:03", 121}]
            }
          end

          @impl true
          def update(state, %{type: "unified.telemetry.tick", data: data}) do
            %{
              state
              | cpu: Map.get(data, :cpu, state.cpu),
                trend: Map.get(data, :trend, state.trend),
                throughput: Map.get(data, :throughput, state.throughput),
                latency: Map.get(data, :latency, state.latency)
            }
          end

          def update(state, _signal), do: state

          @impl true
          def view(state) do
            %Layouts.VBox{
              id: :live_data_dashboard,
              spacing: 1,
              children: [
                %Widgets.Gauge{id: :cpu_live, label: "CPU", value: state.cpu, min: 0, max: 100},
                %Widgets.Sparkline{id: :cpu_trend_live, data: state.trend, show_dots: true},
                %Widgets.BarChart{id: :throughput_live, data: state.throughput},
                %Widgets.LineChart{id: :latency_live, data: state.latency, show_dots: true}
              ]
            }
          end
        end
      end

    Code.compile_quoted(quoted)
    module
  end

  defp phase4_dashboard_iur do
    %Layouts.VBox{
      id: :phase4_dashboard,
      spacing: 1,
      children: [
        %Widgets.Menu{
          id: :main_menu,
          items: [
            %Widgets.MenuItem{label: "File", action: :file_menu},
            %Widgets.MenuItem{label: "View", action: :view_menu}
          ]
        },
        %Layouts.HBox{
          id: :metrics,
          spacing: 2,
          children: [
            %Widgets.Gauge{id: :cpu, label: "CPU", value: 72, min: 0, max: 100},
            %Widgets.Sparkline{id: :mem_trend, data: [48, 52, 57, 54, 61], show_dots: true},
            %Widgets.BarChart{id: :requests, data: [{"api", 42}, {"db", 33}, {"jobs", 17}]},
            %Widgets.LineChart{id: :latency, data: [{"1m", 80}, {"2m", 64}, {"3m", 59}]}
          ]
        },
        %Widgets.Table{
          id: :services_table,
          data: [
            %{service: "api", status: "ok", p95: 88},
            %{service: "db", status: "ok", p95: 102},
            %{service: "jobs", status: "warn", p95: 143}
          ],
          columns: [
            %Widgets.Column{key: :service, header: "Service"},
            %Widgets.Column{key: :status, header: "Status"},
            %Widgets.Column{key: :p95, header: "P95"}
          ]
        },
        %Layouts.HBox{
          id: :inputs,
          spacing: 2,
          children: [
            %Widgets.PickList{
              id: :time_range,
              options: [
                %Widgets.PickListOption{value: :h1, label: "Last Hour"},
                %Widgets.PickListOption{value: :h24, label: "Last 24h"}
              ],
              selected: :h1,
              searchable: true
            },
            %Widgets.FormBuilder{
              id: :filters_form,
              fields: [
                %Widgets.FormField{name: :service, type: :text, required: true},
                %Widgets.FormField{
                  name: :severity,
                  type: :select,
                  options: [{"info", "Info"}, {"warn", "Warn"}, {"error", "Error"}]
                }
              ],
              submit_label: "Apply"
            }
          ]
        },
        %Widgets.Tabs{
          id: :main_tabs,
          active_tab: :overview,
          tabs: [
            %Widgets.Tab{
              id: :overview,
              label: "Overview",
              content: %Widgets.Text{content: "Cluster healthy"}
            },
            %Widgets.Tab{
              id: :tree,
              label: "Services",
              content: %Widgets.TreeView{
                id: :service_tree,
                root_nodes: [
                  %Widgets.TreeNode{
                    id: :backend,
                    label: "backend",
                    expanded: true,
                    children: [
                      %Widgets.TreeNode{id: :api_node, label: "api"},
                      %Widgets.TreeNode{id: :jobs_node, label: "jobs"}
                    ]
                  }
                ]
              }
            }
          ]
        },
        %Widgets.ContextMenu{
          id: :dashboard_ctx,
          items: [
            %Widgets.MenuItem{label: "Refresh", action: :refresh},
            %Widgets.MenuItem{label: "Inspect", action: :inspect}
          ]
        },
        %Layouts.HBox{
          id: :feedback,
          spacing: 2,
          children: [
            %Widgets.Dialog{id: :settings_dialog, title: "Settings", content: "Settings panel"},
            %Widgets.AlertDialog{
              id: :alerts_dialog,
              title: "Action Required",
              message: "A service is degraded",
              severity: :warning
            },
            %Widgets.Toast{id: :saved_toast, message: "Filters updated", duration: 1200}
          ]
        }
      ]
    }
  end

  defp large_phase4_dashboard_iur(element_count)
       when is_integer(element_count) and element_count > 0 do
    %Layouts.VBox{
      id: :phase4_large_dashboard,
      spacing: 1,
      children:
        Enum.map(1..element_count, fn index ->
          %Widgets.Text{id: :"metric_#{index}", content: "Metric #{index}"}
        end)
    }
  end

  defp implemented_advanced_widgets do
    [
      %Widgets.Gauge{id: :gauge_widget, value: 55, min: 0, max: 100, label: "Gauge"},
      %Widgets.Sparkline{id: :sparkline_widget, data: [10, 20, 30], show_dots: true},
      %Widgets.BarChart{id: :bar_chart_widget, data: [{"A", 1}, {"B", 2}]},
      %Widgets.LineChart{id: :line_chart_widget, data: [{"T1", 12}, {"T2", 8}]},
      %Widgets.Table{
        id: :table_widget,
        data: [%{id: 1, name: "alpha"}, %{id: 2, name: "beta"}],
        columns: [
          %Widgets.Column{key: :id, header: "ID"},
          %Widgets.Column{key: :name, header: "Name"}
        ]
      },
      %Widgets.Menu{
        id: :menu_widget,
        items: [%Widgets.MenuItem{label: "Open", action: :open}]
      },
      %Widgets.ContextMenu{
        id: :context_menu_widget,
        items: [%Widgets.MenuItem{label: "Inspect", action: :inspect}]
      },
      %Widgets.Tabs{
        id: :tabs_widget,
        active_tab: :one,
        tabs: [%Widgets.Tab{id: :one, label: "One", content: %Widgets.Text{content: "Tab One"}}]
      },
      %Widgets.TreeView{
        id: :tree_view_widget,
        root_nodes: [%Widgets.TreeNode{id: :root, label: "Root"}]
      },
      %Widgets.Dialog{id: :dialog_widget, title: "Dialog", content: "Body"},
      %Widgets.AlertDialog{
        id: :alert_dialog_widget,
        title: "Alert",
        message: "Warning",
        severity: :warning
      },
      %Widgets.Toast{id: :toast_widget, message: "Saved", duration: 800},
      %Widgets.PickList{
        id: :pick_list_widget,
        options: [%Widgets.PickListOption{value: :a, label: "A"}],
        selected: :a
      },
      %Widgets.FormBuilder{
        id: :form_builder_widget,
        fields: [%Widgets.FormField{name: :name, type: :text, required: true}],
        submit_label: "Submit"
      }
    ]
  end

  defp telemetry_payload(index, cpu_value) do
    %{
      cpu: cpu_value,
      trend: [
        cpu_value,
        rem(cpu_value + 7, 100),
        rem(cpu_value + 13, 100),
        rem(cpu_value + 19, 100)
      ],
      throughput: [
        {"api", rem(index * 3, 120)},
        {"db", rem(index * 5, 120)},
        {"worker", rem(index * 7, 120)}
      ],
      latency: [
        {"09:00", 80 + rem(index, 40)},
        {"09:01", 90 + rem(index * 2, 40)},
        {"09:02", 100 + rem(index * 3, 40)},
        {"09:03", 110 + rem(index * 4, 40)}
      ]
    }
  end

  defp process_memory(pid) do
    case Process.info(pid, :memory) do
      {:memory, bytes} -> bytes
      _ -> 0
    end
  end

  defp non_negative_growth(current, baseline) when current >= baseline, do: current - baseline
  defp non_negative_growth(_current, _baseline), do: 0
end
