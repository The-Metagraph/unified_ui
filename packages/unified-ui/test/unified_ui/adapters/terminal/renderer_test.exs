defmodule UnifiedUi.Adapters.TerminalTest do
  @moduledoc """
  Tests for UnifiedUi.Adapters.Terminal
  """

  use ExUnit.Case, async: true

  alias UnifiedUi.Adapters.Terminal
  alias UnifiedUi.Adapters.State

  alias UnifiedUi.Widgets.{
    Canvas,
    Command,
    CommandPalette,
    Grid,
    LogViewer,
    ProcessMonitor,
    Stack,
    StreamWidget,
    Viewport,
    SplitPane,
    ZBox
  }

  alias UnifiedIUR.Widgets
  alias UnifiedIUR.Layouts
  alias UnifiedIUR.Style

  describe "render/2" do
    test "renders a simple text widget" do
      iur = %Widgets.Text{content: "Hello, World!"}

      assert {:ok, state} = Terminal.render(iur)
      assert State.platform?(state, :terminal)
      assert {:ok, _root} = State.get_root(state)
    end

    test "renders a tree with multiple widgets" do
      iur = %Layouts.VBox{
        children: [
          %Widgets.Text{content: "Title"},
          %Widgets.Button{label: "Click Me"}
        ]
      }

      assert {:ok, state} = Terminal.render(iur)
      assert {:ok, _root} = State.get_root(state)
    end

    test "accepts render options" do
      iur = %Widgets.Text{content: "Test"}

      assert {:ok, state} = Terminal.render(iur, window_title: "My App")
      assert State.get_config(state, :window_title) == "My App"
    end
  end

  describe "update/3" do
    test "updates an existing render state" do
      iur = %Widgets.Text{content: "Original"}

      assert {:ok, state} = Terminal.render(iur)

      updated_iur = %Widgets.Text{content: "Updated"}
      assert {:ok, updated_state} = Terminal.update(updated_iur, state)
      assert {:ok, _root} = State.get_root(updated_state)
    end

    test "returns the same state for unchanged iur and config" do
      iur = %Widgets.Text{content: "Unchanged"}
      assert {:ok, state} = Terminal.render(iur)

      assert {:ok, updated_state} = Terminal.update(iur, state)
      assert updated_state == state
    end

    test "bumps version and updates root when iur changes" do
      iur = %Widgets.Text{content: "Original"}
      assert {:ok, state} = Terminal.render(iur)
      assert {:ok, initial_root} = State.get_root(state)

      updated_iur = %Widgets.Text{content: "Updated"}
      assert {:ok, updated_state} = Terminal.update(updated_iur, state)
      assert {:ok, updated_root} = State.get_root(updated_state)

      assert updated_state.version == state.version + 1
      assert updated_root != initial_root
      assert State.get_metadata(updated_state, :last_iur) == updated_iur
    end

    test "bumps version when config changes" do
      iur = %Widgets.Text{content: "Config"}
      assert {:ok, state} = Terminal.render(iur, window_title: "Original")

      assert {:ok, updated_state} = Terminal.update(iur, state, window_title: "Updated")

      assert updated_state.version == state.version + 1
      assert State.get_config(updated_state, :window_title) == "Updated"

      assert %{
               applied: false,
               reason: :config_changed
             } = State.get_metadata(updated_state, :incremental_patch)
    end

    test "applies root child incremental patch for stable vbox layouts" do
      iur = %Layouts.VBox{
        spacing: 1,
        children: [
          %Widgets.Text{id: :headline, content: "Original"},
          %Widgets.Button{id: :save, label: "Save", on_click: :save}
        ]
      }

      assert {:ok, state} = Terminal.render(iur)
      assert {:ok, initial_root} = State.get_root(state)
      assert %{type: :stack, children: initial_children} = initial_root

      updated_iur = %Layouts.VBox{
        spacing: 1,
        children: [
          %Widgets.Text{id: :headline, content: "Updated"},
          %Widgets.Button{id: :save, label: "Save", on_click: :save}
        ]
      }

      assert {:ok, updated_state} = Terminal.update(updated_iur, state)
      assert {:ok, updated_root} = State.get_root(updated_state)
      assert %{type: :stack, children: updated_children} = updated_root

      assert %{
               applied: true,
               strategy: :root_layout_children,
               reused_children: 1,
               re_rendered_children: 1
             } = State.get_metadata(updated_state, :incremental_patch)

      assert Enum.at(updated_children, 1) == Enum.at(initial_children, 1)
      assert Enum.at(updated_children, 0) != Enum.at(initial_children, 0)
    end

    test "applies nested incremental patch and reuses unchanged grandchildren" do
      iur = %Layouts.VBox{
        spacing: 1,
        children: [
          %Layouts.HBox{
            spacing: 2,
            style: %Style{fg: :yellow},
            children: [
              %Widgets.Text{id: :left, content: "Left"},
              %Widgets.Text{id: :right, content: "Right"}
            ]
          },
          %Widgets.Button{id: :save, label: "Save", on_click: :save}
        ]
      }

      assert {:ok, state} = Terminal.render(iur)
      assert {:ok, initial_root} = State.get_root(state)
      assert %{type: :stack, children: initial_children} = initial_root

      initial_nested = Enum.at(initial_children, 0)

      assert %{type: :box, children: [%{type: :stack, children: initial_nested_children}]} =
               initial_nested

      initial_left = Enum.at(initial_nested_children, 0)
      initial_right = Enum.at(initial_nested_children, 1)
      initial_button = Enum.at(initial_children, 1)

      updated_iur = %Layouts.VBox{
        spacing: 1,
        children: [
          %Layouts.HBox{
            spacing: 2,
            style: %Style{fg: :yellow},
            children: [
              %Widgets.Text{id: :left, content: "Left"},
              %Widgets.Text{id: :right, content: "Right Updated"}
            ]
          },
          %Widgets.Button{id: :save, label: "Save", on_click: :save}
        ]
      }

      assert {:ok, updated_state} = Terminal.update(updated_iur, state)
      assert {:ok, updated_root} = State.get_root(updated_state)
      assert %{type: :stack, children: updated_children} = updated_root

      updated_nested = Enum.at(updated_children, 0)

      assert %{type: :box, children: [%{type: :stack, children: updated_nested_children}]} =
               updated_nested

      assert %{
               applied: true,
               strategy: :root_layout_children,
               reused_children: 2,
               re_rendered_children: 1
             } = State.get_metadata(updated_state, :incremental_patch)

      assert Enum.at(updated_children, 1) == initial_button
      assert Enum.at(updated_nested_children, 0) == initial_left
      assert Enum.at(updated_nested_children, 1) != initial_right
    end

    test "rerenders changed nested child when nested shape changes" do
      iur = %Layouts.VBox{
        spacing: 1,
        children: [
          %Layouts.HBox{
            spacing: 2,
            children: [
              %Widgets.Text{id: :left, content: "Left"},
              %Widgets.Text{id: :right, content: "Right"}
            ]
          },
          %Widgets.Button{id: :save, label: "Save", on_click: :save}
        ]
      }

      assert {:ok, state} = Terminal.render(iur)
      assert {:ok, initial_root} = State.get_root(state)
      assert %{type: :stack, children: initial_children} = initial_root

      initial_nested = Enum.at(initial_children, 0)
      initial_button = Enum.at(initial_children, 1)

      updated_iur = %Layouts.VBox{
        spacing: 1,
        children: [
          %Layouts.HBox{
            spacing: 2,
            children: [
              %Widgets.Text{id: :left, content: "Left"},
              %Widgets.Text{id: :right, content: "Right"},
              %Widgets.Text{id: :added, content: "Added"}
            ]
          },
          %Widgets.Button{id: :save, label: "Save", on_click: :save}
        ]
      }

      assert {:ok, updated_state} = Terminal.update(updated_iur, state)
      assert {:ok, updated_root} = State.get_root(updated_state)
      assert %{type: :stack, children: updated_children} = updated_root

      updated_nested = Enum.at(updated_children, 0)
      assert %{type: :stack, children: updated_nested_children} = updated_nested

      assert %{
               applied: true,
               strategy: :root_layout_children,
               reused_children: 1,
               re_rendered_children: 1
             } = State.get_metadata(updated_state, :incremental_patch)

      assert Enum.at(updated_children, 1) == initial_button
      assert updated_nested != initial_nested
      assert length(updated_nested_children) == 3
    end

    test "falls back to full render when root child shape changes" do
      iur = %Layouts.VBox{
        children: [
          %Widgets.Text{id: :headline, content: "Original"}
        ]
      }

      assert {:ok, state} = Terminal.render(iur)

      updated_iur = %Layouts.VBox{
        children: [
          %Widgets.Text{id: :headline, content: "Original"},
          %Widgets.Text{id: :new_item, content: "Added"}
        ]
      }

      assert {:ok, updated_state} = Terminal.update(updated_iur, state)

      assert %{
               applied: false,
               reason: :full_render_fallback
             } = State.get_metadata(updated_state, :incremental_patch)
    end
  end

  describe "destroy/1" do
    test "cleans up renderer state" do
      iur = %Widgets.Text{content: "Test"}

      assert {:ok, state} = Terminal.render(iur)
      assert :ok = Terminal.destroy(state)
    end
  end

  describe "convert_iur/2 - Text widget" do
    test "converts text widget to TermUI text node" do
      text = %Widgets.Text{content: "Hello"}

      result = Terminal.convert_iur(text)

      # Result should be a TermUI text node
      assert result != nil
    end

    test "converts text with style" do
      text = %Widgets.Text{
        content: "Styled",
        style: %Style{fg: :cyan, attrs: [:bold]}
      }

      result = Terminal.convert_iur(text)

      assert result != nil
    end

    test "converts text with nil content" do
      text = %Widgets.Text{content: nil}

      result = Terminal.convert_iur(text)

      assert result != nil
    end

    test "skips invisible text" do
      text = %Widgets.Text{content: "Hidden", visible: false}

      result = Terminal.convert_iur(text)

      assert result == nil
    end
  end

  describe "convert_iur/2 - Button widget" do
    test "converts button widget" do
      button = %Widgets.Button{label: "Submit", on_click: :submit}

      result = Terminal.convert_iur(button)

      assert result != nil
    end

    test "converts disabled button" do
      button = %Widgets.Button{
        label: "Disabled",
        on_click: :noop,
        disabled: true
      }

      result = Terminal.convert_iur(button)

      assert result != nil
    end

    test "converts button with style" do
      button = %Widgets.Button{
        label: "Styled",
        on_click: :click,
        style: %Style{fg: :green}
      }

      result = Terminal.convert_iur(button)

      assert result != nil
    end

    test "converts button with nil label" do
      button = %Widgets.Button{label: nil, on_click: :noop}

      result = Terminal.convert_iur(button)

      assert result != nil
    end
  end

  describe "convert_iur/2 - Label widget" do
    test "converts label widget" do
      label = %Widgets.Label{text: "Email:", for: :email_input}

      result = Terminal.convert_iur(label)

      assert result != nil
    end

    test "converts label without for reference" do
      label = %Widgets.Label{text: "Just text"}

      result = Terminal.convert_iur(label)

      assert result != nil
    end

    test "converts label with style" do
      label = %Widgets.Label{
        text: "Styled Label",
        for: :input,
        style: %Style{fg: :yellow}
      }

      result = Terminal.convert_iur(label)

      assert result != nil
    end
  end

  describe "convert_iur/2 - TextInput widget" do
    test "converts text input with value" do
      input = %Widgets.TextInput{id: :email, value: "test@example.com"}

      result = Terminal.convert_iur(input)

      assert result != nil
    end

    test "converts text input with placeholder" do
      input = %Widgets.TextInput{
        id: :email,
        placeholder: "user@example.com"
      }

      result = Terminal.convert_iur(input)

      assert result != nil
    end

    test "converts password input" do
      input = %Widgets.TextInput{id: :password, type: :password}

      result = Terminal.convert_iur(input)

      assert result != nil
    end

    test "converts email input" do
      input = %Widgets.TextInput{id: :email, type: :email}

      result = Terminal.convert_iur(input)

      assert result != nil
    end

    test "converts disabled input" do
      input = %Widgets.TextInput{id: :name, disabled: true}

      result = Terminal.convert_iur(input)

      assert result != nil
    end
  end

  describe "convert_iur/2 - LineChart widget" do
    test "converts line chart metadata without unsupported fields" do
      chart = %Widgets.LineChart{
        id: :trend,
        data: [{"Mon", 20}, {"Tue", 22}, {"Wed", 19}],
        show_dots: true,
        show_area: false
      }

      result = Terminal.convert_iur(chart)

      assert {:line_chart, _node, meta} = result
      assert meta.id == :trend
      assert meta.show_dots == true
      assert meta.show_area == false
      assert meta.data == [{"Mon", 20}, {"Tue", 22}, {"Wed", 19}]
    end
  end

  describe "convert_iur/2 - VBox layout" do
    test "converts vbox with children" do
      vbox = %Layouts.VBox{
        children: [
          %Widgets.Text{content: "First"},
          %Widgets.Text{content: "Second"}
        ]
      }

      result = Terminal.convert_iur(vbox)

      assert result != nil
    end

    test "converts vbox with spacing" do
      vbox = %Layouts.VBox{
        spacing: 2,
        children: [%Widgets.Text{content: "A"}]
      }

      result = Terminal.convert_iur(vbox)

      assert result != nil
    end

    test "converts vbox with padding" do
      vbox = %Layouts.VBox{
        padding: 1,
        children: [%Widgets.Text{content: "Padded"}]
      }

      result = Terminal.convert_iur(vbox)

      assert result != nil
    end

    test "converts vbox with alignment" do
      vbox = %Layouts.VBox{
        align_items: :center,
        children: [%Widgets.Text{content: "Centered"}]
      }

      result = Terminal.convert_iur(vbox)

      assert result != nil
    end

    test "converts vbox with style" do
      vbox = %Layouts.VBox{
        style: %Style{fg: :cyan},
        children: [%Widgets.Text{content: "Styled"}]
      }

      result = Terminal.convert_iur(vbox)

      assert result != nil
    end

    test "converts empty vbox" do
      vbox = %Layouts.VBox{children: []}

      result = Terminal.convert_iur(vbox)

      assert result != nil
    end
  end

  describe "convert_iur/2 - HBox layout" do
    test "converts hbox with children" do
      hbox = %Layouts.HBox{
        children: [
          %Widgets.Text{content: "Left"},
          %Widgets.Text{content: "Right"}
        ]
      }

      result = Terminal.convert_iur(hbox)

      assert result != nil
    end

    test "converts hbox with spacing" do
      hbox = %Layouts.HBox{
        spacing: 2,
        children: [%Widgets.Text{content: "A"}]
      }

      result = Terminal.convert_iur(hbox)

      assert result != nil
    end

    test "converts hbox with style" do
      hbox = %Layouts.HBox{
        style: %Style{bg: :blue},
        children: [%Widgets.Text{content: "Styled"}]
      }

      result = Terminal.convert_iur(hbox)

      assert result != nil
    end
  end

  describe "convert_iur/2 - advanced layouts" do
    test "converts grid with flexible tracks metadata" do
      grid = %Grid{
        id: :grid_main,
        columns: [1, "2fr", "auto"],
        rows: [1, 1],
        gap: 1,
        children: [
          %Widgets.Text{content: "A"},
          %Widgets.Text{content: "B"},
          %Widgets.Text{content: "C"}
        ]
      }

      assert {:grid, _node, meta} = Terminal.convert_iur(grid)
      assert meta.id == :grid_main
      assert meta.columns == ["1fr", "2fr", "auto"]
      assert meta.rows == ["1fr", "1fr"]
      assert meta.gap == 1
      assert meta.column_count == 3
    end

    test "converts stack and exposes active child index" do
      stack = %Stack{
        id: :panel_stack,
        active_index: 1,
        transition: :fade,
        children: [
          %Widgets.Text{content: "First"},
          %Widgets.Text{content: "Second"}
        ]
      }

      assert {:stack, _node, meta} = Terminal.convert_iur(stack)
      assert meta.id == :panel_stack
      assert meta.active_index == 1
      assert meta.child_count == 2
      assert meta.transition == :fade
    end

    test "converts zbox and preserves absolute position metadata" do
      zbox = %ZBox{
        id: :overlay,
        positions: %{0 => %{x: 0, y: 0}, panel: %{x: 6, y: 2, z: 3}},
        children: [
          %Widgets.Text{content: "Base"},
          %Widgets.Text{id: :panel, content: "Panel"}
        ]
      }

      assert {:zbox, _node, meta} = Terminal.convert_iur(zbox)
      assert meta.id == :overlay
      assert meta.positions[0] == %{x: 0, y: 0}
      assert meta.positions[:panel] == %{x: 6, y: 2, z: 3}
      assert meta.child_count == 2
    end
  end

  describe "nested layouts" do
    test "converts nested vbox and hbox" do
      iur = %Layouts.VBox{
        children: [
          %Widgets.Text{content: "Title"},
          %Layouts.HBox{
            children: [
              %Widgets.Text{content: "Left"},
              %Widgets.Text{content: "Right"}
            ]
          },
          %Widgets.Button{label: "Submit"}
        ]
      }

      result = Terminal.convert_iur(iur)

      assert result != nil
    end

    test "converts deeply nested layouts" do
      iur = %Layouts.VBox{
        children: [
          %Layouts.HBox{
            children: [
              %Layouts.VBox{
                children: [
                  %Widgets.Text{content: "Deep"}
                ]
              }
            ]
          }
        ]
      }

      result = Terminal.convert_iur(iur)

      assert result != nil
    end
  end

  describe "integration tests" do
    test "renders a complete form" do
      iur = %Layouts.VBox{
        spacing: 1,
        children: [
          %Widgets.Label{text: "Email:", for: :email},
          %Widgets.TextInput{id: :email, placeholder: "user@example.com"},
          %Widgets.Label{text: "Password:", for: :password},
          %Widgets.TextInput{id: :password, type: :password},
          %Widgets.Button{label: "Submit", on_click: :submit_form}
        ]
      }

      assert {:ok, state} = Terminal.render(iur)
      assert {:ok, _root} = State.get_root(state)
    end

    test "renders a complex UI with all widget types" do
      iur = %Layouts.VBox{
        spacing: 1,
        children: [
          %Widgets.Text{content: "Welcome", style: %Style{fg: :cyan, attrs: [:bold]}},
          %Layouts.HBox{
            spacing: 2,
            children: [
              %Widgets.Button{label: "OK", on_click: :ok},
              %Widgets.Button{label: "Cancel", on_click: :cancel}
            ]
          }
        ]
      }

      assert {:ok, state} = Terminal.render(iur)
      assert {:ok, _root} = State.get_root(state)
    end
  end

  # ============================================================================
  # Navigation Widget Tests
  # ============================================================================

  describe "convert_iur/2 - MenuItem" do
    test "converts menu item without options" do
      item = %Widgets.MenuItem{label: "Open"}

      result = Terminal.convert_iur(item)

      assert result != nil
      assert {:menu_item, _node, _meta} = result
    end

    test "converts menu item with action" do
      item = %Widgets.MenuItem{label: "Save", action: :save_file}

      result = Terminal.convert_iur(item)

      assert result != nil
      assert {:menu_item, _node, meta} = result
      assert meta.action == :save_file
    end

    test "converts menu item with icon and shortcut" do
      item = %Widgets.MenuItem{
        label: "Save",
        icon: :floppy,
        shortcut: "Ctrl+S"
      }

      result = Terminal.convert_iur(item)

      assert result != nil
      assert {:menu_item, _node, meta} = result
      assert meta.icon == :floppy
      assert meta.shortcut == "Ctrl+S"
    end

    test "converts disabled menu item" do
      item = %Widgets.MenuItem{label: "Exit", disabled: true}

      result = Terminal.convert_iur(item)

      assert result != nil
      assert {:menu_item, _node, meta} = result
      assert meta.disabled == true
    end

    test "converts menu item with submenu" do
      item = %Widgets.MenuItem{
        label: "File",
        submenu: [
          %Widgets.MenuItem{label: "New"},
          %Widgets.MenuItem{label: "Open"}
        ]
      }

      result = Terminal.convert_iur(item)

      assert result != nil
      assert {:menu_item, _node, meta} = result
      assert meta.has_submenu == true
      assert length(meta.submenu) == 2
    end
  end

  describe "convert_iur/2 - Menu" do
    test "converts menu without title" do
      menu = %Widgets.Menu{
        id: :file_menu,
        items: [
          %Widgets.MenuItem{label: "New"}
        ]
      }

      result = Terminal.convert_iur(menu)

      assert result != nil
      assert {:menu, _node, meta} = result
      assert meta.id == :file_menu
    end

    test "converts menu with title" do
      menu = %Widgets.Menu{
        id: :edit_menu,
        title: "Edit",
        items: [
          %Widgets.MenuItem{label: "Undo"}
        ]
      }

      result = Terminal.convert_iur(menu)

      assert result != nil
      assert {:menu, _node, meta} = result
      assert meta.title == "Edit"
    end

    test "converts menu with position" do
      menu = %Widgets.Menu{
        id: :top_menu,
        position: :top,
        items: []
      }

      result = Terminal.convert_iur(menu)

      assert result != nil
      assert {:menu, _node, meta} = result
      assert meta.position == :top
    end

    test "converts menu with multiple items" do
      menu = %Widgets.Menu{
        id: :main_menu,
        items: [
          %Widgets.MenuItem{label: "File", action: :file},
          %Widgets.MenuItem{label: "Edit", action: :edit},
          %Widgets.MenuItem{label: "View", action: :view}
        ]
      }

      result = Terminal.convert_iur(menu)

      assert result != nil
    end
  end

  describe "convert_iur/2 - ContextMenu" do
    test "converts context menu" do
      menu = %Widgets.ContextMenu{
        id: :context_menu,
        items: [
          %Widgets.MenuItem{label: "Copy", action: :copy},
          %Widgets.MenuItem{label: "Paste", action: :paste}
        ]
      }

      result = Terminal.convert_iur(menu)

      assert result != nil
      assert {:context_menu, _node, meta} = result
      assert meta.id == :context_menu
    end

    test "converts context menu with trigger_on" do
      menu = %Widgets.ContextMenu{
        id: :right_click_menu,
        trigger_on: :right_click,
        items: []
      }

      result = Terminal.convert_iur(menu)

      assert result != nil
      assert {:context_menu, _node, meta} = result
      assert meta.trigger_on == :right_click
    end

    test "converts context menu with long_press trigger" do
      menu = %Widgets.ContextMenu{
        id: :long_press_menu,
        trigger_on: :long_press,
        items: []
      }

      result = Terminal.convert_iur(menu)

      assert result != nil
      assert {:context_menu, _node, meta} = result
      assert meta.trigger_on == :long_press
    end
  end

  describe "convert_iur/2 - Tab" do
    test "converts tab without options" do
      tab = %Widgets.Tab{id: :home, label: "Home"}

      result = Terminal.convert_iur(tab)

      assert result != nil
      assert {:tab, _node, meta} = result
      assert meta.id == :home
      assert meta.label == "Home"
    end

    test "converts tab with icon" do
      tab = %Widgets.Tab{
        id: :settings,
        label: "Settings",
        icon: :gear
      }

      result = Terminal.convert_iur(tab)

      assert result != nil
      assert {:tab, _node, meta} = result
      assert meta.icon == :gear
    end

    test "converts disabled tab" do
      tab = %Widgets.Tab{
        id: :locked,
        label: "Locked",
        disabled: true
      }

      result = Terminal.convert_iur(tab)

      assert result != nil
      assert {:tab, _node, meta} = result
      assert meta.disabled == true
    end

    test "converts closable tab" do
      tab = %Widgets.Tab{
        id: :document,
        label: "Document.txt",
        closable: true
      }

      result = Terminal.convert_iur(tab)

      assert result != nil
      assert {:tab, _node, meta} = result
      assert meta.closable == true
    end

    test "converts tab with content" do
      tab = %Widgets.Tab{
        id: :dashboard,
        label: "Dashboard",
        content: %Widgets.Text{content: "Dashboard content"}
      }

      result = Terminal.convert_iur(tab)

      assert result != nil
      assert {:tab, _node, meta} = result
      assert meta.content != nil
    end
  end

  describe "convert_iur/2 - Tabs" do
    test "converts tabs with active tab" do
      tabs = %Widgets.Tabs{
        id: :main_tabs,
        active_tab: :home,
        tabs: [
          %Widgets.Tab{id: :home, label: "Home"},
          %Widgets.Tab{id: :about, label: "About"}
        ]
      }

      result = Terminal.convert_iur(tabs)

      assert result != nil
      assert {:tabs, _node, meta} = result
      assert meta.id == :main_tabs
      assert meta.active_tab == :home
    end

    test "converts tabs with position" do
      tabs = %Widgets.Tabs{
        id: :side_tabs,
        position: :left,
        tabs: [
          %Widgets.Tab{id: :tab1, label: "Tab 1"}
        ]
      }

      result = Terminal.convert_iur(tabs)

      assert result != nil
      assert {:tabs, _node, meta} = result
      assert meta.position == :left
    end

    test "converts tabs with on_change handler" do
      tabs = %Widgets.Tabs{
        id: :switchable_tabs,
        on_change: :tab_changed,
        tabs: []
      }

      result = Terminal.convert_iur(tabs)

      assert result != nil
      assert {:tabs, _node, meta} = result
      assert meta.on_change == :tab_changed
    end

    test "converts tabs with content" do
      tabs = %Widgets.Tabs{
        id: :content_tabs,
        active_tab: :home,
        tabs: [
          %Widgets.Tab{
            id: :home,
            label: "Home",
            content: %Widgets.Text{content: "Home content"}
          }
        ]
      }

      result = Terminal.convert_iur(tabs)

      assert result != nil
    end
  end

  describe "convert_iur/2 - TreeNode" do
    test "converts leaf node" do
      node = %Widgets.TreeNode{
        id: :file1,
        label: "main.ex"
      }

      result = Terminal.convert_iur(node)

      assert result != nil
      assert {:tree_node, _node, meta} = result
      assert meta.id == :file1
      assert meta.label == "main.ex"
      assert meta.has_children == false
    end

    test "converts node with children" do
      node = %Widgets.TreeNode{
        id: :src,
        label: "src",
        children: [
          %Widgets.TreeNode{id: :file1, label: "main.ex"}
        ]
      }

      result = Terminal.convert_iur(node)

      assert result != nil
      assert {:tree_node, _node, meta} = result
      assert meta.has_children == true
    end

    test "converts expanded node" do
      node = %Widgets.TreeNode{
        id: :lib,
        label: "lib",
        expanded: true,
        children: []
      }

      result = Terminal.convert_iur(node)

      assert result != nil
      assert {:tree_node, _node, meta} = result
      assert meta.expanded == true
    end

    test "converts collapsed node" do
      node = %Widgets.TreeNode{
        id: :config,
        label: "config",
        expanded: false,
        children: []
      }

      result = Terminal.convert_iur(node)

      assert result != nil
      assert {:tree_node, _node, meta} = result
      assert meta.expanded == false
    end

    test "converts node with icon" do
      node = %Widgets.TreeNode{
        id: :folder,
        label: "My Folder",
        icon: :folder,
        icon_expanded: :folder_open,
        children: []
      }

      result = Terminal.convert_iur(node)

      assert result != nil
      assert {:tree_node, _node, meta} = result
      assert meta.icon == :folder
      assert meta.icon_expanded == :folder_open
    end

    test "converts non-selectable node" do
      node = %Widgets.TreeNode{
        id: :readonly,
        label: "Read Only",
        selectable: false
      }

      result = Terminal.convert_iur(node)

      assert result != nil
      assert {:tree_node, _node, meta} = result
      assert meta.selectable == false
    end
  end

  describe "convert_iur/2 - TreeView" do
    test "converts tree view with root nodes" do
      tree = %Widgets.TreeView{
        id: :file_tree,
        root_nodes: [
          %Widgets.TreeNode{id: :src, label: "src"},
          %Widgets.TreeNode{id: :test, label: "test"}
        ]
      }

      result = Terminal.convert_iur(tree)

      assert result != nil
      assert {:tree_view, _node, meta} = result
      assert meta.id == :file_tree
    end

    test "converts tree view with selected node" do
      tree = %Widgets.TreeView{
        id: :project_tree,
        selected_node: :main_file,
        root_nodes: []
      }

      result = Terminal.convert_iur(tree)

      assert result != nil
      assert {:tree_view, _node, meta} = result
      assert meta.selected_node == :main_file
    end

    test "converts tree view with expanded nodes" do
      tree = %Widgets.TreeView{
        id: :config_tree,
        expanded_nodes: [:database, :server],
        root_nodes: []
      }

      result = Terminal.convert_iur(tree)

      assert result != nil
      assert {:tree_view, _node, meta} = result
      assert meta.expanded_nodes == [:database, :server]
    end

    test "converts tree view with on_select handler" do
      tree = %Widgets.TreeView{
        id: :selectable_tree,
        on_select: :node_selected,
        root_nodes: []
      }

      result = Terminal.convert_iur(tree)

      assert result != nil
      assert {:tree_view, _node, meta} = result
      assert meta.on_select == :node_selected
    end

    test "converts tree view with on_toggle handler" do
      tree = %Widgets.TreeView{
        id: :toggleable_tree,
        on_toggle: :node_toggled,
        root_nodes: []
      }

      result = Terminal.convert_iur(tree)

      assert result != nil
      assert {:tree_view, _node, meta} = result
      assert meta.on_toggle == :node_toggled
    end

    test "converts tree view without showing root" do
      tree = %Widgets.TreeView{
        id: :hidden_root_tree,
        show_root: false,
        root_nodes: []
      }

      result = Terminal.convert_iur(tree)

      assert result != nil
      assert {:tree_view, _node, meta} = result
      assert meta.show_root == false
    end

    test "converts nested tree structure" do
      tree = %Widgets.TreeView{
        id: :project_tree,
        root_nodes: [
          %Widgets.TreeNode{
            id: :src,
            label: "src",
            expanded: true,
            children: [
              %Widgets.TreeNode{
                id: :my_app,
                label: "my_app",
                expanded: true,
                children: [
                  %Widgets.TreeNode{id: :app, label: "app.ex"}
                ]
              }
            ]
          }
        ]
      }

      result = Terminal.convert_iur(tree)

      assert result != nil
    end
  end

  describe "convert_iur/2 - additional data visualization widgets" do
    test "converts gauge and sparkline tuples with metadata" do
      gauge = %Widgets.Gauge{id: :cpu, label: "CPU", value: 130, min: 0, max: 100}
      sparkline = %Widgets.Sparkline{id: :trend, data: [1, 4, 2], show_dots: true}

      assert {:gauge, _node, gauge_meta} = Terminal.convert_iur(gauge)
      assert gauge_meta.id == :cpu
      assert gauge_meta.min == 0
      assert gauge_meta.max == 100
      assert gauge_meta.label == "CPU"

      assert {:sparkline, _node, sparkline_meta} = Terminal.convert_iur(sparkline)
      assert sparkline_meta.id == :trend
      assert sparkline_meta.data == [1, 4, 2]
      assert sparkline_meta.show_dots == true
    end

    test "converts bar charts in horizontal and vertical modes" do
      horizontal = %Widgets.BarChart{
        id: :hbars,
        orientation: :horizontal,
        data: [{"A", 5}, {"B", 8}]
      }

      vertical = %Widgets.BarChart{
        id: :vbars,
        orientation: :vertical,
        data: [{"A", 2}, {"B", 1}]
      }

      assert {:bar_chart, _node, horizontal_meta} = Terminal.convert_iur(horizontal)
      assert horizontal_meta.orientation == :horizontal
      assert horizontal_meta.data == [{"A", 5}, {"B", 8}]

      assert {:bar_chart, _node, vertical_meta} = Terminal.convert_iur(vertical)
      assert vertical_meta.orientation == :vertical
      assert vertical_meta.data == [{"A", 2}, {"B", 1}]
    end

    test "converts table metadata including generated columns and sort settings" do
      table = %Widgets.Table{
        id: :users,
        data: [%{name: "Alice", score: 10}, %{name: "Bob", score: 5}],
        sort_column: :score,
        sort_direction: :desc,
        on_row_select: :select_row,
        on_sort: :sort_by
      }

      assert {:table, _node, meta} = Terminal.convert_iur(table)
      assert meta.id == :users
      assert :name in Enum.map(meta.columns, & &1.key)
      assert :score in Enum.map(meta.columns, & &1.key)
      assert meta.sort_column == :score
      assert meta.sort_direction == :desc
      assert meta.on_row_select == :select_row
      assert meta.on_sort == :sort_by
    end
  end

  describe "convert_iur/2 - container widgets" do
    test "converts viewport with clipping metadata" do
      viewport = %Viewport{
        id: :main_viewport,
        width: 80,
        height: 20,
        scroll_x: 4,
        scroll_y: 9,
        on_scroll: :viewport_scrolled,
        border: :solid,
        content: %Widgets.Text{content: "Scrollable content"}
      }

      assert {:viewport, _node, meta} = Terminal.convert_iur(viewport)
      assert meta.id == :main_viewport
      assert meta.width == 80
      assert meta.height == 20
      assert meta.scroll_x == 4
      assert meta.scroll_y == 9
      assert meta.on_scroll == :viewport_scrolled
      assert meta.border == :solid
    end

    test "converts split pane with pane and resize metadata" do
      split_pane = %SplitPane{
        id: :main_split,
        orientation: :vertical,
        initial_split: 60,
        min_size: 15,
        on_resize_change: :split_resized,
        panes: [
          %Widgets.Text{content: "Left"},
          %Widgets.Text{content: "Right"}
        ]
      }

      assert {:split_pane, _node, meta} = Terminal.convert_iur(split_pane)
      assert meta.id == :main_split
      assert meta.orientation == :vertical
      assert meta.initial_split == 60
      assert meta.min_size == 15
      assert meta.on_resize_change == :split_resized
    end

    test "converts canvas with drawing and pointer metadata" do
      canvas = %Canvas{
        id: :chart_canvas,
        width: 120,
        height: 40,
        draw: fn _ctx -> :ok end,
        on_click: :canvas_clicked,
        on_hover: :canvas_hovered
      }

      assert {:canvas, _node, meta} = Terminal.convert_iur(canvas)
      assert meta.id == :chart_canvas
      assert meta.width == 120
      assert meta.height == 40
      assert is_function(meta.draw, 1)
      assert meta.on_click == :canvas_clicked
      assert meta.on_hover == :canvas_hovered
    end

    test "converts command_palette with command metadata" do
      command_palette = %CommandPalette{
        id: :main_commands,
        placeholder: "Search commands",
        trigger_shortcut: "ctrl+k",
        on_select: :command_selected,
        commands: [
          %Command{id: :open, label: "Open File", shortcut: "ctrl+o"},
          %Command{id: :save, label: "Save File", shortcut: "ctrl+s"}
        ]
      }

      assert {:command_palette, _node, meta} = Terminal.convert_iur(command_palette)
      assert meta.id == :main_commands
      assert meta.placeholder == "Search commands"
      assert meta.trigger_shortcut == "ctrl+k"
      assert meta.on_select == :command_selected
      assert [%{id: :open, label: "Open File"}, %{id: :save, label: "Save File"}] = meta.commands
    end

    test "converts log_viewer with auto-refresh metadata" do
      log_viewer = %LogViewer{
        id: :logs,
        source: "/tmp/app.log",
        lines: 200,
        auto_scroll: true,
        filter: "error",
        refresh_interval: 500
      }

      assert {:log_viewer, _node, meta} = Terminal.convert_iur(log_viewer)
      assert meta.id == :logs
      assert meta.lines == 200
      assert meta.auto_scroll == true
      assert meta.filter == "error"
      assert meta.refresh_interval == 500
      assert meta.auto_refresh == true
    end

    test "converts stream_widget with producer metadata" do
      stream_widget = %StreamWidget{
        id: :events,
        producer: :event_source,
        buffer_size: 64,
        refresh_interval: 250,
        on_item: :stream_item
      }

      assert {:stream_widget, _node, meta} = Terminal.convert_iur(stream_widget)
      assert meta.id == :events
      assert meta.producer == :event_source
      assert meta.buffer_size == 64
      assert meta.refresh_interval == 250
      assert meta.auto_refresh == true
      assert meta.on_item == :stream_item
    end

    test "converts process_monitor with polling metadata" do
      process_monitor = %ProcessMonitor{
        id: :processes,
        node: :nonode@nohost,
        refresh_interval: 1_500,
        sort_by: :reductions,
        on_process_select: :process_selected
      }

      assert {:process_monitor, _node, meta} = Terminal.convert_iur(process_monitor)
      assert meta.id == :processes
      assert meta.node == :nonode@nohost
      assert meta.refresh_interval == 1_500
      assert meta.auto_refresh == true
      assert meta.sort_by == :reductions
      assert meta.on_process_select == :process_selected
    end
  end
end
