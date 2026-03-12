defmodule UnifiedUi.Adapters.DesktopTest do
  @moduledoc """
  Tests for UnifiedUi.Adapters.Desktop
  """

  use ExUnit.Case, async: true

  alias UnifiedUi.Adapters.Desktop
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

      assert {:ok, state} = Desktop.render(iur)
      assert State.platform?(state, :desktop)
      assert {:ok, _root} = State.get_root(state)
    end

    test "renders a tree with multiple widgets" do
      iur = %Layouts.VBox{
        children: [
          %Widgets.Text{content: "Title"},
          %Widgets.Button{label: "Click Me"}
        ]
      }

      assert {:ok, state} = Desktop.render(iur)
      assert {:ok, _root} = State.get_root(state)
    end

    test "accepts render options" do
      iur = %Widgets.Text{content: "Test"}

      assert {:ok, state} = Desktop.render(iur, window_title: "My App")
      assert State.get_config(state, :window_title) == "My App"
    end
  end

  describe "update/3" do
    test "updates an existing render state" do
      iur = %Widgets.Text{content: "Original"}

      assert {:ok, state} = Desktop.render(iur)

      updated_iur = %Widgets.Text{content: "Updated"}
      assert {:ok, updated_state} = Desktop.update(updated_iur, state)
      assert {:ok, _root} = State.get_root(updated_state)
    end

    test "returns the same state for unchanged iur and config" do
      iur = %Widgets.Text{content: "Unchanged"}
      assert {:ok, state} = Desktop.render(iur)

      assert {:ok, updated_state} = Desktop.update(iur, state)
      assert updated_state == state
    end

    test "bumps version and updates root when iur changes" do
      iur = %Widgets.Text{content: "Original"}
      assert {:ok, state} = Desktop.render(iur)
      assert {:ok, initial_root} = State.get_root(state)

      updated_iur = %Widgets.Text{content: "Updated"}
      assert {:ok, updated_state} = Desktop.update(updated_iur, state)
      assert {:ok, updated_root} = State.get_root(updated_state)

      assert updated_state.version == state.version + 1
      assert updated_root != initial_root
      assert State.get_metadata(updated_state, :last_iur) == updated_iur
    end

    test "bumps version when config changes" do
      iur = %Widgets.Text{content: "Config"}
      assert {:ok, state} = Desktop.render(iur, window_title: "Original")

      assert {:ok, updated_state} = Desktop.update(iur, state, window_title: "Updated")

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

      assert {:ok, state} = Desktop.render(iur)
      assert {:ok, initial_root} = State.get_root(state)

      updated_iur = %Layouts.VBox{
        spacing: 1,
        children: [
          %Widgets.Text{id: :headline, content: "Updated"},
          %Widgets.Button{id: :save, label: "Save", on_click: :save}
        ]
      }

      assert {:ok, updated_state} = Desktop.update(updated_iur, state)
      assert {:ok, updated_root} = State.get_root(updated_state)

      assert %{
               applied: true,
               strategy: :root_layout_children,
               reused_children: 1,
               re_rendered_children: 1
             } = State.get_metadata(updated_state, :incremental_patch)

      assert Enum.at(updated_root.children, 1) == Enum.at(initial_root.children, 1)
      assert Enum.at(updated_root.children, 0) != Enum.at(initial_root.children, 0)
    end

    test "applies nested incremental patch and reuses unchanged grandchildren" do
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

      assert {:ok, state} = Desktop.render(iur)
      assert {:ok, initial_root} = State.get_root(state)

      initial_nested = Enum.at(initial_root.children, 0)
      initial_left = Enum.at(initial_nested.children, 0)
      initial_right = Enum.at(initial_nested.children, 1)
      initial_button = Enum.at(initial_root.children, 1)

      updated_iur = %Layouts.VBox{
        spacing: 1,
        children: [
          %Layouts.HBox{
            spacing: 2,
            children: [
              %Widgets.Text{id: :left, content: "Left"},
              %Widgets.Text{id: :right, content: "Right Updated"}
            ]
          },
          %Widgets.Button{id: :save, label: "Save", on_click: :save}
        ]
      }

      assert {:ok, updated_state} = Desktop.update(updated_iur, state)
      assert {:ok, updated_root} = State.get_root(updated_state)

      updated_nested = Enum.at(updated_root.children, 0)

      assert %{
               applied: true,
               strategy: :root_layout_children,
               reused_children: 2,
               re_rendered_children: 1
             } = State.get_metadata(updated_state, :incremental_patch)

      assert Enum.at(updated_root.children, 1) == initial_button
      assert Enum.at(updated_nested.children, 0) == initial_left
      assert Enum.at(updated_nested.children, 1) != initial_right
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

      assert {:ok, state} = Desktop.render(iur)
      assert {:ok, initial_root} = State.get_root(state)

      initial_nested = Enum.at(initial_root.children, 0)
      initial_button = Enum.at(initial_root.children, 1)

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

      assert {:ok, updated_state} = Desktop.update(updated_iur, state)
      assert {:ok, updated_root} = State.get_root(updated_state)

      updated_nested = Enum.at(updated_root.children, 0)

      assert %{
               applied: true,
               strategy: :root_layout_children,
               reused_children: 1,
               re_rendered_children: 1
             } = State.get_metadata(updated_state, :incremental_patch)

      assert Enum.at(updated_root.children, 1) == initial_button
      assert updated_nested != initial_nested
      assert length(updated_nested.children) == 3
    end

    test "falls back to full render when root child shape changes" do
      iur = %Layouts.VBox{
        children: [
          %Widgets.Text{id: :headline, content: "Original"}
        ]
      }

      assert {:ok, state} = Desktop.render(iur)

      updated_iur = %Layouts.VBox{
        children: [
          %Widgets.Text{id: :headline, content: "Original"},
          %Widgets.Text{id: :new_item, content: "Added"}
        ]
      }

      assert {:ok, updated_state} = Desktop.update(updated_iur, state)

      assert %{
               applied: false,
               reason: :full_render_fallback
             } = State.get_metadata(updated_state, :incremental_patch)
    end
  end

  describe "destroy/1" do
    test "cleans up renderer state" do
      iur = %Widgets.Text{content: "Test"}

      assert {:ok, state} = Desktop.render(iur)
      assert :ok = Desktop.destroy(state)
    end
  end

  describe "convert_iur/2 - Text widget" do
    test "converts text widget to DesktopUi label" do
      text = %Widgets.Text{content: "Hello"}

      result = Desktop.convert_iur(text)

      # Result should be a DesktopUi widget map
      assert result.type == :label
      assert result.props[:text] == "Hello"
    end

    test "converts text with style" do
      text = %Widgets.Text{
        content: "Styled",
        style: %Style{fg: :cyan, attrs: [:bold]}
      }

      result = Desktop.convert_iur(text)

      assert result.type == :label
      assert result.props[:color] == :cyan
      assert result.props[:font_style] == :bold
    end

    test "converts text with nil content" do
      text = %Widgets.Text{content: nil}

      result = Desktop.convert_iur(text)

      assert result.type == :label
      assert result.props[:text] == ""
    end

    test "skips invisible text" do
      text = %Widgets.Text{content: "Hidden", visible: false}

      result = Desktop.convert_iur(text)

      assert result == nil
    end
  end

  describe "convert_iur/2 - Button widget" do
    test "converts button widget" do
      button = %Widgets.Button{label: "Submit", on_click: :submit}

      result = Desktop.convert_iur(button)

      assert result.type == :button
      assert result.props[:label] == "Submit"
    end

    test "converts disabled button" do
      button = %Widgets.Button{
        label: "Disabled",
        on_click: :noop,
        disabled: true
      }

      result = Desktop.convert_iur(button)

      assert result.type == :button
      assert result.props[:disabled] == true
    end

    test "converts button with style" do
      button = %Widgets.Button{
        label: "Styled",
        on_click: :click,
        style: %Style{fg: :green}
      }

      result = Desktop.convert_iur(button)

      assert result.type == :button
      assert result.props[:color] == :green
    end

    test "converts button with nil label" do
      button = %Widgets.Button{label: nil, on_click: :noop}

      result = Desktop.convert_iur(button)

      assert result.type == :button
    end

    test "converts button with id" do
      button = %Widgets.Button{
        label: "Click",
        on_click: :click,
        id: :my_button
      }

      result = Desktop.convert_iur(button)

      assert result.type == :button
      assert result.id == :my_button
    end
  end

  describe "convert_iur/2 - Label widget" do
    test "converts label widget" do
      label = %Widgets.Label{text: "Email:", for: :email_input}

      result = Desktop.convert_iur(label)

      assert result.type == :label
      assert result.props[:text] == "Email:"
      assert result.label_for == :email_input
    end

    test "converts label without for reference" do
      label = %Widgets.Label{text: "Just text"}

      result = Desktop.convert_iur(label)

      assert result.type == :label
      assert result.props[:text] == "Just text"
      refute Map.has_key?(result, :label_for)
    end

    test "converts label with style" do
      label = %Widgets.Label{
        text: "Styled Label",
        for: :input,
        style: %Style{fg: :yellow}
      }

      result = Desktop.convert_iur(label)

      assert result.type == :label
      assert result.props[:color] == :yellow
    end
  end

  describe "convert_iur/2 - TextInput widget" do
    test "converts text input with value" do
      input = %Widgets.TextInput{id: :email, value: "test@example.com"}

      result = Desktop.convert_iur(input)

      # Should be a tagged tuple with label widget and metadata
      assert {:text_input, widget, metadata} = result
      assert widget.type == :label
      assert metadata.id == :email
      assert metadata.value == "test@example.com"
    end

    test "converts text input with placeholder" do
      input = %Widgets.TextInput{
        id: :email,
        placeholder: "user@example.com"
      }

      result = Desktop.convert_iur(input)

      assert {:text_input, _widget, metadata} = result
      assert metadata.placeholder == "user@example.com"
    end

    test "converts password input" do
      input = %Widgets.TextInput{id: :password, type: :password}

      result = Desktop.convert_iur(input)

      assert {:text_input, _widget, metadata} = result
      assert metadata.type == :password
    end

    test "converts email input" do
      input = %Widgets.TextInput{id: :email, type: :email}

      result = Desktop.convert_iur(input)

      assert {:text_input, _widget, metadata} = result
      assert metadata.type == :email
    end

    test "converts disabled input" do
      input = %Widgets.TextInput{id: :name, disabled: true}

      result = Desktop.convert_iur(input)

      assert {:text_input, _widget, metadata} = result
      assert metadata.disabled == true
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

      result = Desktop.convert_iur(vbox)

      assert result.type == :container
      assert result.props[:direction] == :vbox
      assert length(result.children) == 2
    end

    test "converts vbox with spacing" do
      vbox = %Layouts.VBox{
        spacing: 10,
        children: [%Widgets.Text{content: "A"}]
      }

      result = Desktop.convert_iur(vbox)

      assert result.type == :container
      assert result.props[:spacing] == 10
    end

    test "converts vbox with padding" do
      vbox = %Layouts.VBox{
        padding: 16,
        children: [%Widgets.Text{content: "Padded"}]
      }

      result = Desktop.convert_iur(vbox)

      assert result.type == :container
      assert result.props[:padding] == 16
    end

    test "converts vbox with alignment" do
      vbox = %Layouts.VBox{
        align_items: :center,
        children: [%Widgets.Text{content: "Centered"}]
      }

      result = Desktop.convert_iur(vbox)

      assert result.type == :container
      assert result.props[:align] == :center
    end

    test "converts vbox with style" do
      vbox = %Layouts.VBox{
        style: %Style{fg: :cyan},
        children: [%Widgets.Text{content: "Styled"}]
      }

      result = Desktop.convert_iur(vbox)

      assert result.type == :container
      assert result.props[:color] == :cyan
    end

    test "converts empty vbox" do
      vbox = %Layouts.VBox{children: []}

      result = Desktop.convert_iur(vbox)

      assert result.type == :container
      assert result.children == []
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

      result = Desktop.convert_iur(hbox)

      assert result.type == :container
      assert result.props[:direction] == :hbox
      assert length(result.children) == 2
    end

    test "converts hbox with spacing" do
      hbox = %Layouts.HBox{
        spacing: 20,
        children: [%Widgets.Text{content: "A"}]
      }

      result = Desktop.convert_iur(hbox)

      assert result.type == :container
      assert result.props[:spacing] == 20
    end

    test "converts hbox with style" do
      hbox = %Layouts.HBox{
        style: %Style{bg: :blue},
        children: [%Widgets.Text{content: "Styled"}]
      }

      result = Desktop.convert_iur(hbox)

      assert result.type == :container
      assert result.props[:background] == :blue
    end
  end

  describe "convert_iur/2 - advanced layouts" do
    test "converts grid with track metadata" do
      grid = %Grid{
        id: :grid_main,
        columns: [1, "2fr", "auto"],
        rows: [1, 1],
        gap: 8,
        children: [
          %Widgets.Text{content: "A"},
          %Widgets.Text{content: "B"}
        ]
      }

      assert {:grid, widget, meta} = Desktop.convert_iur(grid)
      assert widget.type == :grid
      assert widget.id == :grid_main
      assert meta.columns == ["1fr", "2fr", "auto"]
      assert meta.rows == ["1fr", "1fr"]
      assert meta.gap == 8
    end

    test "converts stack and renders active child only" do
      stack = %Stack{
        id: :panel_stack,
        active_index: 1,
        transition: :fade,
        children: [
          %Widgets.Text{content: "First"},
          %Widgets.Text{content: "Second"}
        ]
      }

      assert {:stack, widget, meta} = Desktop.convert_iur(stack)
      assert widget.type == :stack
      assert widget.id == :panel_stack
      assert length(widget.children) == 1
      assert meta.active_index == 1
      assert meta.child_count == 2
      assert meta.transition == :fade
    end

    test "converts zbox and keeps positioning metadata" do
      zbox = %ZBox{
        id: :overlay,
        positions: %{0 => %{x: 1, y: 2}, panel: %{x: 8, y: 4, z_index: 6}},
        children: [
          %Widgets.Text{content: "Base"},
          %Widgets.Text{id: :panel, content: "Panel"}
        ]
      }

      assert {:zbox, widget, meta} = Desktop.convert_iur(zbox)
      assert widget.type == :zbox
      assert widget.id == :overlay
      assert meta.positions[0] == %{x: 1, y: 2}
      assert meta.positions[:panel] == %{x: 8, y: 4, z_index: 6}
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

      result = Desktop.convert_iur(iur)

      assert result.type == :container
      assert result.props[:direction] == :vbox
      assert length(result.children) == 3
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

      result = Desktop.convert_iur(iur)

      assert result.type == :container
      # Should have nested structure
      assert length(result.children) == 1
    end
  end

  describe "integration tests" do
    test "renders a complete form" do
      iur = %Layouts.VBox{
        spacing: 8,
        children: [
          %Widgets.Label{text: "Email:", for: :email},
          %Widgets.TextInput{id: :email, placeholder: "user@example.com"},
          %Widgets.Label{text: "Password:", for: :password},
          %Widgets.TextInput{id: :password, type: :password},
          %Widgets.Button{label: "Submit", on_click: :submit_form}
        ]
      }

      assert {:ok, state} = Desktop.render(iur)
      assert {:ok, root} = State.get_root(state)
      assert root.type == :container
    end

    test "renders a complex UI with all widget types" do
      iur = %Layouts.VBox{
        spacing: 8,
        children: [
          %Widgets.Text{content: "Welcome", style: %Style{fg: :cyan, attrs: [:bold]}},
          %Layouts.HBox{
            spacing: 16,
            children: [
              %Widgets.Button{label: "OK", on_click: :ok},
              %Widgets.Button{label: "Cancel", on_click: :cancel}
            ]
          }
        ]
      }

      assert {:ok, state} = Desktop.render(iur)
      assert {:ok, root} = State.get_root(state)
      assert root.type == :container
    end
  end

  describe "convert_iur/2 - data visualization widgets" do
    test "converts gauge and sparkline with metadata" do
      gauge = %Widgets.Gauge{id: :cpu, label: "CPU", value: 130, min: 0, max: 100}
      sparkline = %Widgets.Sparkline{id: :trend, data: [1, 3, 2], show_dots: true}

      assert {:gauge, gauge_widget, gauge_meta} = Desktop.convert_iur(gauge)
      assert gauge_widget.type == :label
      assert gauge_meta.value == 100
      assert gauge_meta.max == 100
      assert gauge_meta.label == "CPU"

      assert {:sparkline, sparkline_widget, sparkline_meta} = Desktop.convert_iur(sparkline)
      assert sparkline_widget.type == :label
      assert sparkline_meta.data == [1, 3, 2]
      assert sparkline_meta.show_dots == true
    end

    test "converts bar chart and line chart with chart metadata" do
      bar_chart = %Widgets.BarChart{
        id: :sales,
        data: [{"Mon", 10}, {"Tue", 20}],
        orientation: :horizontal
      }

      line_chart = %Widgets.LineChart{
        id: :visits,
        data: [{"Mon", 1}, {"Tue", 3}, {"Wed", 2}],
        show_dots: true,
        show_area: true
      }

      assert {:bar_chart, bar_widget, bar_meta} = Desktop.convert_iur(bar_chart)
      assert bar_widget.type == :label
      assert bar_meta.orientation == :horizontal
      assert bar_meta.data == [{"Mon", 10}, {"Tue", 20}]

      assert {:line_chart, line_widget, line_meta} = Desktop.convert_iur(line_chart)
      assert line_widget.type == :label
      assert line_meta.show_dots == true
      assert line_meta.show_area == true
    end

    test "converts table and auto-generates columns from row keys" do
      table = %Widgets.Table{
        id: :users,
        data: [%{name: "Alice", age: 31}, %{name: "Bob", age: 28}],
        on_row_select: :select_row,
        on_sort: :sort_by
      }

      assert {:table, table_widget, table_meta} = Desktop.convert_iur(table)
      assert table_widget.type == :label
      assert length(table_meta.columns) == 2
      assert :name in Enum.map(table_meta.columns, & &1.key)
      assert :age in Enum.map(table_meta.columns, & &1.key)
      assert table_meta.on_row_select == :select_row
      assert table_meta.on_sort == :sort_by
    end
  end

  describe "convert_iur/2 - navigation widgets" do
    test "converts menu item, menu, and context menu structures" do
      item = %Widgets.MenuItem{
        id: :save_item,
        label: "Save",
        action: :save_file,
        icon: :save,
        shortcut: "Ctrl+S",
        submenu: [%Widgets.MenuItem{label: "Recent"}]
      }

      menu = %Widgets.Menu{
        id: :file_menu,
        title: "File",
        position: :top,
        items: [item]
      }

      context = %Widgets.ContextMenu{id: :ctx, trigger_on: :right_click, items: [item]}

      assert {:menu_item, item_widget, item_meta} = Desktop.convert_iur(item)
      assert item_widget.type == :label
      assert item_meta.has_submenu == true
      assert item_meta.shortcut == "Ctrl+S"

      assert {:menu, menu_widget, menu_meta} = Desktop.convert_iur(menu)
      assert menu_widget.type == :menu
      assert menu_meta.title == "File"
      assert menu_meta.position == :top

      assert {:context_menu, context_widget, context_meta} = Desktop.convert_iur(context)
      assert context_widget.type == :context_menu
      assert context_meta.trigger_on == :right_click
    end

    test "converts tabs and tree widgets with metadata and nested content" do
      tabs = %Widgets.Tabs{
        id: :main_tabs,
        active_tab: :home,
        position: :top,
        on_change: :tab_changed,
        tabs: [
          %Widgets.Tab{id: :home, label: "Home", content: %Widgets.Text{content: "Home panel"}},
          %Widgets.Tab{id: :about, label: "About", icon: :info, disabled: true, closable: true}
        ]
      }

      tree = %Widgets.TreeView{
        id: :project_tree,
        selected_node: :root,
        expanded_nodes: [:root],
        on_select: :select_node,
        on_toggle: :toggle_node,
        root_nodes: [
          %Widgets.TreeNode{
            id: :root,
            label: "root",
            expanded: true,
            icon: :folder,
            icon_expanded: :folder_open,
            children: [%Widgets.TreeNode{id: :child, label: "child"}]
          }
        ]
      }

      assert {:tabs, tabs_widget, tabs_meta} = Desktop.convert_iur(tabs)
      assert tabs_widget.type == :tabs
      assert tabs_meta.active_tab == :home
      assert tabs_meta.on_change == :tab_changed
      assert length(tabs_widget.children) == 3

      assert {:tree_view, tree_widget, tree_meta} = Desktop.convert_iur(tree)
      assert tree_widget.type == :tree_view
      assert tree_meta.selected_node == :root
      assert tree_meta.on_select == :select_node
      assert tree_meta.on_toggle == :toggle_node
      assert length(tree_widget.children) == 1
    end
  end

  describe "convert_iur/2 - container widgets" do
    test "converts viewport with metadata and nested child" do
      viewport = %Viewport{
        id: :main_viewport,
        width: 90,
        height: 24,
        scroll_x: 2,
        scroll_y: 5,
        on_scroll: :viewport_scrolled,
        border: :solid,
        content: %Widgets.Text{content: "Scrollable desktop content"}
      }

      assert {:viewport, widget, meta} = Desktop.convert_iur(viewport)
      assert widget.type == :viewport
      assert meta.id == :main_viewport
      assert meta.width == 90
      assert meta.height == 24
      assert meta.scroll_x == 2
      assert meta.scroll_y == 5
      assert meta.on_scroll == :viewport_scrolled
      assert meta.border == :solid
    end

    test "converts split pane with orientation and resize metadata" do
      split_pane = %SplitPane{
        id: :main_split,
        orientation: :horizontal,
        initial_split: 55,
        min_size: 20,
        on_resize_change: :split_resized,
        panes: [%Widgets.Text{content: "Left"}, %Widgets.Text{content: "Right"}]
      }

      assert {:split_pane, widget, meta} = Desktop.convert_iur(split_pane)
      assert widget.type == :split_pane
      assert meta.id == :main_split
      assert meta.orientation == :horizontal
      assert meta.initial_split == 55
      assert meta.min_size == 20
      assert meta.on_resize_change == :split_resized
    end

    test "converts canvas with draw and pointer metadata" do
      canvas = %Canvas{
        id: :chart_canvas,
        width: 128,
        height: 48,
        draw: fn _ctx -> :ok end,
        on_click: :canvas_clicked,
        on_hover: :canvas_hovered
      }

      assert {:canvas, widget, meta} = Desktop.convert_iur(canvas)
      assert widget.type == :canvas
      assert meta.id == :chart_canvas
      assert meta.width == 128
      assert meta.height == 48
      assert is_function(meta.draw, 1)
      assert meta.on_click == :canvas_clicked
      assert meta.on_hover == :canvas_hovered
    end

    test "converts command_palette with command list metadata" do
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

      assert {:command_palette, widget, meta} = Desktop.convert_iur(command_palette)
      assert widget.type == :command_palette
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
        lines: 250,
        auto_scroll: true,
        filter: "warn",
        refresh_interval: 600
      }

      assert {:log_viewer, widget, meta} = Desktop.convert_iur(log_viewer)
      assert widget.type == :log_viewer
      assert meta.id == :logs
      assert meta.lines == 250
      assert meta.auto_scroll == true
      assert meta.filter == "warn"
      assert meta.refresh_interval == 600
      assert meta.auto_refresh == true
    end

    test "converts stream_widget with producer and refresh metadata" do
      stream_widget = %StreamWidget{
        id: :events,
        producer: :event_source,
        buffer_size: 32,
        refresh_interval: 300,
        on_item: :stream_item
      }

      assert {:stream_widget, widget, meta} = Desktop.convert_iur(stream_widget)
      assert widget.type == :stream_widget
      assert meta.id == :events
      assert meta.producer == :event_source
      assert meta.buffer_size == 32
      assert meta.refresh_interval == 300
      assert meta.auto_refresh == true
      assert meta.on_item == :stream_item
    end

    test "converts process_monitor with polling metadata" do
      process_monitor = %ProcessMonitor{
        id: :processes,
        node: :nonode@nohost,
        refresh_interval: 1_250,
        sort_by: :memory,
        on_process_select: :process_selected
      }

      assert {:process_monitor, widget, meta} = Desktop.convert_iur(process_monitor)
      assert widget.type == :process_monitor
      assert meta.id == :processes
      assert meta.node == :nonode@nohost
      assert meta.refresh_interval == 1_250
      assert meta.auto_refresh == true
      assert meta.sort_by == :memory
      assert meta.on_process_select == :process_selected
    end
  end
end
