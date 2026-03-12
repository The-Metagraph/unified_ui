defmodule UnifiedUi.Adapters.WebTest do
  @moduledoc """
  Tests for UnifiedUi.Adapters.Web
  """

  use ExUnit.Case, async: true

  alias UnifiedUi.Adapters.Web
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

      assert {:ok, state} = Web.render(iur)
      assert State.platform?(state, :web)
      assert {:ok, root} = State.get_root(state)
      assert root =~ "Hello, World!"
      assert root =~ "<span"
    end

    test "renders a tree with multiple widgets" do
      iur = %Layouts.VBox{
        children: [
          %Widgets.Text{content: "Title"},
          %Widgets.Button{label: "Click Me"}
        ]
      }

      assert {:ok, state} = Web.render(iur)
      assert {:ok, root} = State.get_root(state)
      assert root =~ "Title"
      assert root =~ "Click Me"
    end

    test "accepts render options" do
      iur = %Widgets.Text{content: "Test"}

      assert {:ok, state} = Web.render(iur, window_title: "My App")
      assert State.get_config(state, :window_title) == "My App"
    end

    test "supports HEEx output format via format option" do
      iur = %Widgets.Button{id: :save_btn, label: "Save", on_click: :save}

      assert {:ok, state} = Web.render(iur, format: :heex)
      assert {:ok, root} = State.get_root(state)

      assert State.get_metadata(state, :output_format) == :heex
      assert root =~ "<button"
      assert root =~ "phx-click=\"save\""
      assert root =~ "id=\"save_btn\""
    end

    test "supports HEEx output format via template option alias" do
      iur = %Widgets.Text{content: "Alias check"}

      assert {:ok, state} = Web.render(iur, template: :heex)
      assert {:ok, root} = State.get_root(state)

      assert State.get_metadata(state, :output_format) == :heex
      assert root =~ "<span"
      assert root =~ "Alias check"
    end
  end

  describe "render_heex/2" do
    test "returns HEEx-compatible template string" do
      iur = %Layouts.VBox{
        children: [
          %Widgets.Text{id: :title, content: "Hello HEEx"},
          %Widgets.Button{id: :submit, label: "Submit", on_click: :submit_form}
        ]
      }

      assert {:ok, template} = Web.render_heex(iur)
      assert is_binary(template)
      assert template =~ "<div"
      assert template =~ "Hello HEEx"
      assert template =~ "phx-click=\"submit-form\""
    end
  end

  describe "update/3" do
    test "updates an existing render state" do
      iur = %Widgets.Text{content: "Original"}

      assert {:ok, state} = Web.render(iur)

      updated_iur = %Widgets.Text{content: "Updated"}
      assert {:ok, updated_state} = Web.update(updated_iur, state)
      assert {:ok, _root} = State.get_root(updated_state)
    end

    test "returns the same state for unchanged iur and config" do
      iur = %Widgets.Text{content: "Unchanged"}
      assert {:ok, state} = Web.render(iur)

      assert {:ok, updated_state} = Web.update(iur, state)
      assert updated_state == state
    end

    test "bumps version and updates root when iur changes" do
      iur = %Widgets.Text{content: "Original"}
      assert {:ok, state} = Web.render(iur)
      assert {:ok, initial_root} = State.get_root(state)

      updated_iur = %Widgets.Text{content: "Updated"}
      assert {:ok, updated_state} = Web.update(updated_iur, state)
      assert {:ok, updated_root} = State.get_root(updated_state)

      assert updated_state.version == state.version + 1
      assert updated_root != initial_root
      assert State.get_metadata(updated_state, :last_iur) == updated_iur
    end

    test "bumps version when config changes" do
      iur = %Widgets.Text{content: "Config"}
      assert {:ok, state} = Web.render(iur, window_title: "Original")

      assert {:ok, updated_state} = Web.update(iur, state, window_title: "Updated")

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

      assert {:ok, state} = Web.render(iur)

      updated_iur = %Layouts.VBox{
        spacing: 1,
        children: [
          %Widgets.Text{id: :headline, content: "Updated"},
          %Widgets.Button{id: :save, label: "Save", on_click: :save}
        ]
      }

      assert {:ok, updated_state} = Web.update(updated_iur, state)
      assert {:ok, updated_root} = State.get_root(updated_state)

      assert %{
               applied: true,
               strategy: :root_layout_children,
               reused_children: 1,
               re_rendered_children: 1
             } = State.get_metadata(updated_state, :incremental_patch)

      assert updated_root =~ "Updated"
      assert updated_root =~ "Save"
      refute updated_root =~ "Original"
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

      assert {:ok, state} = Web.render(iur)

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

      assert {:ok, updated_state} = Web.update(updated_iur, state)
      assert {:ok, updated_root} = State.get_root(updated_state)

      assert %{
               applied: true,
               strategy: :root_layout_children,
               reused_children: 2,
               re_rendered_children: 1
             } = State.get_metadata(updated_state, :incremental_patch)

      assert updated_root =~ "<span>Left</span>"
      assert updated_root =~ "<span>Right Updated</span>"
      assert updated_root =~ "Save"
      refute updated_root =~ "<span>Right</span>"
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

      assert {:ok, state} = Web.render(iur)

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

      assert {:ok, updated_state} = Web.update(updated_iur, state)
      assert {:ok, updated_root} = State.get_root(updated_state)

      assert %{
               applied: true,
               strategy: :root_layout_children,
               reused_children: 1,
               re_rendered_children: 1
             } = State.get_metadata(updated_state, :incremental_patch)

      assert updated_root =~ "<span>Left</span>"
      assert updated_root =~ "<span>Right</span>"
      assert updated_root =~ "<span>Added</span>"
      assert updated_root =~ "Save"
    end

    test "falls back to full render when root child shape changes" do
      iur = %Layouts.VBox{
        children: [
          %Widgets.Text{id: :headline, content: "Original"}
        ]
      }

      assert {:ok, state} = Web.render(iur)

      updated_iur = %Layouts.VBox{
        children: [
          %Widgets.Text{id: :headline, content: "Original"},
          %Widgets.Text{id: :new_item, content: "Added"}
        ]
      }

      assert {:ok, updated_state} = Web.update(updated_iur, state)

      assert %{
               applied: false,
               reason: :full_render_fallback
             } = State.get_metadata(updated_state, :incremental_patch)
    end

    test "updates and tracks HEEx output format" do
      initial = %Widgets.Text{content: "Before"}
      updated = %Widgets.Text{content: "After"}

      assert {:ok, state} = Web.render(initial, format: :heex)
      assert State.get_metadata(state, :output_format) == :heex

      assert {:ok, updated_state} = Web.update(updated, state)
      assert {:ok, updated_root} = State.get_root(updated_state)

      assert State.get_metadata(updated_state, :output_format) == :heex
      assert updated_root =~ "After"
    end
  end

  describe "destroy/1" do
    test "cleans up renderer state" do
      iur = %Widgets.Text{content: "Test"}

      assert {:ok, state} = Web.render(iur)
      assert :ok = Web.destroy(state)
    end
  end

  describe "convert_iur/2 - Text widget" do
    test "converts text widget to HTML span" do
      text = %Widgets.Text{content: "Hello"}

      result = Web.convert_iur(text)

      assert result =~ ~r/<span[^>]*>Hello<\/span>/
    end

    test "converts text with style" do
      text = %Widgets.Text{
        content: "Styled",
        style: %Style{fg: :cyan, attrs: [:bold]}
      }

      result = Web.convert_iur(text)

      assert result =~ "color: cyan"
      assert result =~ "font-weight: bold"
      assert result =~ "<span"
    end

    test "converts text with nil content" do
      text = %Widgets.Text{content: nil}

      result = Web.convert_iur(text)

      assert result =~ ~r/<span[^>]*><\/span>/
    end

    test "skips invisible text" do
      text = %Widgets.Text{content: "Hidden", visible: false}

      result = Web.convert_iur(text)

      assert result == ""
    end

    test "escapes HTML in text content" do
      text = %Widgets.Text{content: "<script>alert('xss')</script>"}

      result = Web.convert_iur(text)

      assert result =~ "&lt;script&gt;"
      refute result =~ "<script>"
    end
  end

  describe "convert_iur/2 - Button widget" do
    test "converts button widget to HTML button" do
      button = %Widgets.Button{label: "Submit", on_click: :submit}

      result = Web.convert_iur(button)

      assert result =~ ~r/<button[^>]*>Submit<\/button>/
      assert result =~ "phx-click=\"submit\""
    end

    test "converts button with underscore event to kebab-case" do
      button = %Widgets.Button{label: "Save", on_click: :save_form}

      result = Web.convert_iur(button)

      assert result =~ "phx-click=\"save-form\""
    end

    test "converts disabled button" do
      button = %Widgets.Button{
        label: "Disabled",
        on_click: :noop,
        disabled: true
      }

      result = Web.convert_iur(button)

      assert result =~ "disabled=\"true\""
    end

    test "converts button with style" do
      button = %Widgets.Button{
        label: "Styled",
        on_click: :click,
        style: %Style{fg: :green}
      }

      result = Web.convert_iur(button)

      assert result =~ "color: green"
    end

    test "converts button with nil label" do
      button = %Widgets.Button{label: nil, on_click: :noop}

      result = Web.convert_iur(button)

      assert result =~ ~r/<button[^>]*><\/button>/
    end

    test "converts button with id" do
      button = %Widgets.Button{
        label: "Click",
        on_click: :click,
        id: :my_button
      }

      result = Web.convert_iur(button)

      assert result =~ "id=\"my_button\""
    end
  end

  describe "convert_iur/2 - Label widget" do
    test "converts label widget to HTML label" do
      label = %Widgets.Label{text: "Email:", for: :email_input}

      result = Web.convert_iur(label)

      assert result =~ ~r/<label[^>]*for="email_input"[^>]*>Email:<\/label>/
    end

    test "converts label without for reference" do
      label = %Widgets.Label{text: "Just text"}

      result = Web.convert_iur(label)

      assert result =~ ~r/<label[^>]*>Just text<\/label>/
      refute result =~ "for="
    end

    test "converts label with style" do
      label = %Widgets.Label{
        text: "Styled Label",
        for: :input,
        style: %Style{fg: :yellow}
      }

      result = Web.convert_iur(label)

      assert result =~ "color: yellow"
    end
  end

  describe "convert_iur/2 - TextInput widget" do
    test "converts text input with value" do
      input = %Widgets.TextInput{id: :email, value: "test@example.com"}

      result = Web.convert_iur(input)

      assert result =~ ~r/<input[^>]*\/>/
      assert result =~ "id=\"email\""
      assert result =~ "value=\"test@example.com\""
    end

    test "converts text input with placeholder" do
      input = %Widgets.TextInput{
        id: :email,
        placeholder: "user@example.com"
      }

      result = Web.convert_iur(input)

      assert result =~ "placeholder=\"user@example.com\""
    end

    test "converts password input" do
      input = %Widgets.TextInput{id: :password, type: :password}

      result = Web.convert_iur(input)

      assert result =~ "type=\"password\""
    end

    test "converts email input" do
      input = %Widgets.TextInput{id: :email, type: :email}

      result = Web.convert_iur(input)

      assert result =~ "type=\"email\""
    end

    test "converts disabled input" do
      input = %Widgets.TextInput{id: :name, disabled: true}

      result = Web.convert_iur(input)

      assert result =~ "disabled=\"true\""
    end

    test "converts input with phx-change binding" do
      input = %Widgets.TextInput{
        id: :query,
        on_change: :update_query
      }

      result = Web.convert_iur(input)

      assert result =~ "phx-change=\"update-query\""
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

      result = Web.convert_iur(vbox)

      assert result =~ "display: flex"
      assert result =~ "flex-direction: column"
      assert result =~ "First"
      assert result =~ "Second"
    end

    test "converts vbox with spacing" do
      vbox = %Layouts.VBox{
        spacing: 10,
        children: [%Widgets.Text{content: "A"}]
      }

      result = Web.convert_iur(vbox)

      assert result =~ "gap: 10px"
    end

    test "converts vbox with padding" do
      vbox = %Layouts.VBox{
        padding: 16,
        children: [%Widgets.Text{content: "Padded"}]
      }

      result = Web.convert_iur(vbox)

      assert result =~ "padding: 16px"
    end

    test "converts vbox with alignment" do
      vbox = %Layouts.VBox{
        align_items: :center,
        children: [%Widgets.Text{content: "Centered"}]
      }

      result = Web.convert_iur(vbox)

      assert result =~ "align-items: center"
    end

    test "converts vbox with style" do
      vbox = %Layouts.VBox{
        style: %Style{bg: :lightgray},
        children: [%Widgets.Text{content: "Styled"}]
      }

      result = Web.convert_iur(vbox)

      assert result =~ "background-color: lightgray"
    end

    test "converts empty vbox" do
      vbox = %Layouts.VBox{children: []}

      result = Web.convert_iur(vbox)

      assert result =~ ~r/<div[^>]*><\/div>/
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

      result = Web.convert_iur(hbox)

      assert result =~ "display: flex"
      assert result =~ "flex-direction: row"
      assert result =~ "Left"
      assert result =~ "Right"
    end

    test "converts hbox with spacing" do
      hbox = %Layouts.HBox{
        spacing: 20,
        children: [%Widgets.Text{content: "A"}]
      }

      result = Web.convert_iur(hbox)

      assert result =~ "gap: 20px"
    end

    test "converts hbox with style" do
      hbox = %Layouts.HBox{
        style: %Style{fg: :white, bg: :blue},
        children: [%Widgets.Text{content: "Styled"}]
      }

      result = Web.convert_iur(hbox)

      assert result =~ "background-color: blue"
    end
  end

  describe "convert_iur/2 - advanced layouts" do
    test "converts grid with CSS track definitions" do
      grid = %Grid{
        id: :grid_main,
        columns: [1, "2fr", "auto"],
        rows: [1, 1],
        gap: 12,
        children: [
          %Widgets.Text{content: "A"},
          %Widgets.Text{content: "B"}
        ]
      }

      html = Web.convert_iur(grid)

      assert html =~ ~s(id="grid_main")
      assert html =~ "display: grid"
      assert html =~ "grid-template-columns: 1fr 2fr auto"
      assert html =~ "grid-template-rows: 1fr 1fr"
      assert html =~ "gap: 12px"
      assert html =~ "A"
      assert html =~ "B"
    end

    test "converts stack with active index and single active child" do
      stack = %Stack{
        id: :panel_stack,
        active_index: 1,
        transition: :fade,
        children: [
          %Widgets.Text{content: "First"},
          %Widgets.Text{content: "Second"}
        ]
      }

      html = Web.convert_iur(stack)

      assert html =~ ~s(id="panel_stack")
      assert html =~ ~s(data-active-index="1")
      assert html =~ ~s(data-transition="fade")
      refute html =~ "First"
      assert html =~ "Second"
    end

    test "converts zbox with absolute positioned children" do
      zbox = %ZBox{
        id: :overlay,
        positions: %{0 => %{x: 0, y: 0}, panel: %{x: 8, y: 3, z: 4}},
        children: [
          %Widgets.Text{content: "Base"},
          %Widgets.Text{id: :panel, content: "Panel"}
        ]
      }

      html = Web.convert_iur(zbox)

      assert html =~ ~s(id="overlay")
      assert html =~ "position: relative"
      assert html =~ "position: absolute"
      assert html =~ "left: 0px"
      assert html =~ "left: 8px"
      assert html =~ "top: 3px"
      assert html =~ "z-index: 4"
      assert html =~ "Base"
      assert html =~ "Panel"
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

      result = Web.convert_iur(iur)

      assert result =~ "flex-direction: column"
      assert result =~ "flex-direction: row"
      assert result =~ "Title"
      assert result =~ "Left"
      assert result =~ "Right"
      assert result =~ "Submit"
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

      result = Web.convert_iur(iur)

      assert result =~ "Deep"
      # Should have nested divs
      assert result |> String.split("<div") |> length() > 3
    end
  end

  describe "integration tests" do
    test "renders a complete form" do
      iur = %Layouts.VBox{
        spacing: 8,
        children: [
          %Widgets.Label{text: "Email:", for: :email},
          %Widgets.TextInput{id: :email, type: :email, placeholder: "user@example.com"},
          %Widgets.Label{text: "Password:", for: :password},
          %Widgets.TextInput{id: :password, type: :password},
          %Widgets.Button{label: "Submit", on_click: :submit_form}
        ]
      }

      assert {:ok, state} = Web.render(iur)
      assert {:ok, root} = State.get_root(state)
      assert root =~ "Email:"
      assert root =~ "type=\"email\""
      assert root =~ "type=\"password\""
      assert root =~ "phx-click=\"submit-form\""
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

      assert {:ok, state} = Web.render(iur)
      assert {:ok, root} = State.get_root(state)
      assert root =~ "Welcome"
      assert root =~ "font-weight: bold"
      assert root =~ "color: cyan"
      assert root =~ "phx-click=\"ok\""
      assert root =~ "phx-click=\"cancel\""
    end
  end

  describe "convert_iur/2 - data visualization widgets" do
    test "converts gauge with svg output and label" do
      gauge = %Widgets.Gauge{id: :cpu, label: "CPU", value: 75, min: 0, max: 100}
      result = Web.convert_iur(gauge)

      assert result =~ "<svg"
      assert result =~ "CPU"
      assert result =~ "75/100"
    end

    test "converts sparkline with area and no-data fallback" do
      with_data = %Widgets.Sparkline{id: :trend, data: [1, 3, 2], show_area: true, color: :blue}
      with_single_point = %Widgets.Sparkline{id: :trend_empty, data: [1]}

      assert Web.convert_iur(with_data) =~ "<polyline"
      assert Web.convert_iur(with_data) =~ "<polygon"
      assert Web.convert_iur(with_single_point) =~ "No data"
    end

    test "converts bar chart and line chart variants" do
      bar_chart = %Widgets.BarChart{
        id: :sales,
        data: [{"Mon", 3}, {"Tue", 5}],
        orientation: :horizontal
      }

      line_chart = %Widgets.LineChart{
        id: :visits,
        data: [{"Mon", 1}, {"Tue", 3}, {"Wed", 2}],
        show_dots: true,
        show_area: true
      }

      bar_html = Web.convert_iur(bar_chart)
      line_html = Web.convert_iur(line_chart)

      assert bar_html =~ "<svg"
      assert bar_html =~ "<rect"
      assert line_html =~ "<polyline"
      assert line_html =~ "<circle"
      assert line_html =~ "<polygon"
    end

    test "converts table with sortable headers and row-select bindings" do
      table = %Widgets.Table{
        id: :users,
        data: [%{name: "Alice", score: 2}, %{name: "Bob", score: 5}],
        on_row_select: :select_row,
        on_sort: :sort_by,
        sort_column: :score,
        sort_direction: :desc
      }

      result = Web.convert_iur(table)

      assert result =~ "<table"
      assert result =~ "phx-click=\"sort-by\""
      assert result =~ "data-row-index=\"0\""
      assert result =~ "&#9660;"
    end
  end

  describe "convert_iur/2 - navigation widgets" do
    test "converts menu item and menu wrappers with metadata attributes" do
      menu = %Widgets.Menu{
        id: :file_menu,
        title: "File",
        position: :top,
        items: [
          %Widgets.MenuItem{
            id: :save_item,
            label: "Save",
            action: :save_file,
            shortcut: "Ctrl+S",
            icon: :save,
            submenu: [%Widgets.MenuItem{label: "Recent"}]
          }
        ]
      }

      result = Web.convert_iur(menu)

      assert result =~ "<nav"
      assert result =~ "menu-top"
      assert result =~ "data-shortcut=\"Ctrl+S\""
      assert result =~ "data-has-submenu=\"true\""
      assert result =~ "phx-click=\"save-file\""
    end

    test "converts context menu, tabs, and tree view with event bindings" do
      context_menu = %Widgets.ContextMenu{
        id: :ctx,
        trigger_on: :right_click,
        items: [%Widgets.MenuItem{label: "Copy", action: :copy}]
      }

      tabs = %Widgets.Tabs{
        id: :main_tabs,
        active_tab: :home,
        position: :top,
        on_change: :tab_changed,
        tabs: [
          %Widgets.Tab{id: :home, label: "Home", content: %Widgets.Text{content: "Home panel"}},
          %Widgets.Tab{id: :about, label: "About", disabled: true, closable: true}
        ]
      }

      tree = %Widgets.TreeView{
        id: :tree,
        on_select: :select_node,
        on_toggle: :toggle_node,
        root_nodes: [
          %Widgets.TreeNode{
            id: :root,
            label: "root",
            expanded: true,
            children: [%Widgets.TreeNode{id: :child, label: "child"}]
          }
        ]
      }

      context_html = Web.convert_iur(context_menu)
      tabs_html = Web.convert_iur(tabs)
      tree_html = Web.convert_iur(tree)

      assert context_html =~ "data-trigger-on=\"right_click\""
      assert tabs_html =~ "phx-change=\"tab-changed\""
      assert tabs_html =~ "Home panel"
      assert tabs_html =~ "data-closable=\"true\""
      assert tree_html =~ "data-toggle-event=\"toggle-node\""
      assert tree_html =~ "tree-label"
    end
  end

  describe "convert_iur/2 - container widgets" do
    test "converts viewport container with dimensions and scroll metadata" do
      viewport = %Viewport{
        id: :main_viewport,
        width: 640,
        height: 360,
        scroll_x: 8,
        scroll_y: 14,
        on_scroll: :viewport_scrolled,
        border: :dashed,
        content: %Widgets.Text{content: "Viewport content"}
      }

      html = Web.convert_iur(viewport)

      assert html =~ ~s(id="main_viewport")
      assert html =~ ~s(data-scroll-x="8")
      assert html =~ ~s(data-scroll-y="14")
      assert html =~ ~s(data-scroll-event="viewport-scrolled")
      assert html =~ "width: 640px"
      assert html =~ "height: 360px"
      assert html =~ "Viewport content"
    end

    test "converts split pane with orientation and resize metadata" do
      split_pane = %SplitPane{
        id: :main_split,
        orientation: :vertical,
        initial_split: 62,
        min_size: 18,
        on_resize_change: :split_resized,
        panes: [%Widgets.Text{content: "Top"}, %Widgets.Text{content: "Bottom"}]
      }

      html = Web.convert_iur(split_pane)

      assert html =~ ~s(id="main_split")
      assert html =~ ~s(data-initial-split="62")
      assert html =~ ~s(data-min-size="18")
      assert html =~ ~s(data-resize-event="split-resized")
      assert html =~ "flex-direction: column"
      assert html =~ "Top"
      assert html =~ "Bottom"
    end

    test "converts canvas with dimensions and pointer event metadata" do
      canvas = %Canvas{
        id: :chart_canvas,
        width: 800,
        height: 300,
        on_click: :canvas_clicked,
        on_hover: :canvas_hovered
      }

      html = Web.convert_iur(canvas)

      assert html =~ ~s(<canvas)
      assert html =~ ~s(id="chart_canvas")
      assert html =~ ~s(width="800")
      assert html =~ ~s(height="300")
      assert html =~ ~s(data-click-event="canvas-clicked")
      assert html =~ ~s(data-hover-event="canvas-hovered")
    end

    test "converts command_palette with searchable command list" do
      command_palette = %CommandPalette{
        id: :main_commands,
        placeholder: "Search commands",
        trigger_shortcut: "ctrl+k",
        on_select: :command_selected,
        commands: [
          %Command{id: :open, label: "Open File", description: "Open project file"},
          %Command{id: :save, label: "Save File", description: "Save current file"}
        ]
      }

      html = Web.convert_iur(command_palette)

      assert html =~ ~s(id="main_commands")
      assert html =~ ~s(data-trigger-shortcut="ctrl+k")
      assert html =~ ~s(data-select-event="command-selected")
      assert html =~ ~s(placeholder="Search commands")
      assert html =~ ~s(data-command-id="open")
      assert html =~ "Open File"
      assert html =~ "Save File"
    end

    test "converts log_viewer with auto-refresh and filter attributes" do
      log_viewer = %LogViewer{
        id: :logs,
        source: "/tmp/app.log",
        lines: 180,
        auto_scroll: true,
        filter: "error",
        refresh_interval: 500
      }

      html = Web.convert_iur(log_viewer)

      assert html =~ ~s(id="logs")
      assert html =~ ~s(data-source="/tmp/app.log")
      assert html =~ ~s(data-lines="180")
      assert html =~ ~s(data-auto-scroll="true")
      assert html =~ ~s(data-filter="error")
      assert html =~ ~s(data-refresh-interval="500")
      assert html =~ ~s(data-auto-refresh="true")
    end

    test "converts stream_widget with producer and refresh attributes" do
      stream_widget = %StreamWidget{
        id: :events,
        producer: :event_source,
        buffer_size: 40,
        refresh_interval: 250,
        on_item: :stream_item
      }

      html = Web.convert_iur(stream_widget)

      assert html =~ ~s(id="events")
      assert html =~ ~s(data-producer="event_source")
      assert html =~ ~s(data-buffer-size="40")
      assert html =~ ~s(data-refresh-interval="250")
      assert html =~ ~s(data-auto-refresh="true")
      assert html =~ ~s(data-on-item="stream-item")
    end

    test "converts process_monitor with node and polling attributes" do
      process_monitor = %ProcessMonitor{
        id: :processes,
        node: :nonode@nohost,
        sort_by: :reductions,
        refresh_interval: 1_200,
        on_process_select: :process_selected
      }

      html = Web.convert_iur(process_monitor)

      assert html =~ ~s(id="processes")
      assert html =~ ~s(data-node="nonode@nohost")
      assert html =~ ~s(data-sort-by="reductions")
      assert html =~ ~s(data-refresh-interval="1200")
      assert html =~ ~s(data-auto-refresh="true")
      assert html =~ ~s(data-select-event="process-selected")
    end
  end
end
