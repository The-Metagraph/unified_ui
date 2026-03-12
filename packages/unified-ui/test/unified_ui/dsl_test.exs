defmodule UnifiedUi.DslTest do
  @moduledoc """
  Tests for the UnifiedUi.Dsl module.
  """

  use ExUnit.Case, async: false

  alias UnifiedIUR.{Layouts, Widgets}
  alias UnifiedUi.Dsl

  describe "DSL module compilation" do
    test "DSL module exists and is loadable" do
      assert Code.ensure_loaded?(Dsl)
    end

    test "DSL module has correct metadata" do
      {:module, _} = Code.ensure_loaded(Dsl)
      # __using__ is a macro, not a function, so it won't be in function_exported?
      # Just check that standard_signals delegate exists
      assert function_exported?(Dsl, :standard_signals, 0)
    end
  end

  describe "module fixtures using UnifiedUi.Dsl" do
    test "supports nested layout and widget DSL macros in a compiled module" do
      module = unique_fixture_module(:basic_layout)

      compile_fixture(
        module,
        """
        vbox do
          id :root
          spacing 1
          text "Hello", id: :hello

          hbox do
            id :row
            button "Go", id: :go_btn, on_click: :go
          end
        end
        """
      )

      assert function_exported?(module, :view, 1)

      assert %Layouts.VBox{id: :root, spacing: 1, children: [title, row]} = module.view(%{})
      assert %Widgets.Text{id: :hello, content: "Hello"} = title
      assert %Layouts.HBox{id: :row, children: [button]} = row
      assert %Widgets.Button{id: :go_btn, label: "Go", on_click: :go} = button
    end

    test "supports tab content and recursive tree nodes in compiled modules" do
      module = unique_fixture_module(:navigation)

      compile_fixture(
        module,
        """
        vbox do
          id :nav_root

          menu :main_menu do
            title "Main"
            position :top
            menu_item "Open", id: :open_item, action: :open_file
            menu_item "Save", action: {:save_file, %{source: :menu}}
          end

          context_menu :editor_context do
            trigger_on :right_click
            menu_item "Copy", action: :copy
            menu_item "Paste", action: :paste
          end

          tabs :workspace_tabs do
            active_tab :home

            tab :home, "Home" do
              text "Home content", id: :home_text
            end
          end

          tree_view :project_tree do
            selected_node :root

            tree_node :root, "root"
          end
        end
        """
      )

      assert function_exported?(module, :view, 1)

      assert %Layouts.VBox{id: :nav_root, children: [menu, context_menu, tabs, tree]} =
               module.view(%{})

      assert %Widgets.Menu{id: :main_menu, title: "Main", position: :top, items: menu_items} =
               menu

      assert [%Widgets.MenuItem{id: :open_item, label: "Open"}, %Widgets.MenuItem{label: "Save"}] =
               menu_items

      assert %Widgets.ContextMenu{
               id: :editor_context,
               trigger_on: :right_click
             } = context_menu

      assert %Widgets.Tabs{id: :workspace_tabs, active_tab: :home, tabs: [home_tab]} = tabs

      assert %Widgets.Tab{id: :home, label: "Home", content: [home_text]} = home_tab
      assert %Widgets.Text{id: :home_text} = home_text

      assert %Widgets.TreeView{id: :project_tree, selected_node: :root, root_nodes: [root_node]} =
               tree

      assert %Widgets.TreeNode{id: :root, label: "root", children: nil} = root_node
    end

    test "supports data visualization widgets in a compiled module" do
      module = unique_fixture_module(:data_viz)

      compile_fixture(
        module,
        """
        vbox do
          id :metrics_root
          gauge :cpu, 72, min: 0, max: 100, label: "CPU"
          sparkline :memory_trend, [10, 20, 15, 30], show_dots: true
          bar_chart :sales_chart, [{"Mon", 10}, {"Tue", 12}], orientation: :vertical
          line_chart :latency_chart, [{"P95", 40}, {"P99", 55}], show_dots: true
        end
        """
      )

      assert function_exported?(module, :view, 1)

      assert %Layouts.VBox{id: :metrics_root, children: [gauge, sparkline, bar_chart, line_chart]} =
               module.view(%{})

      assert %Widgets.Gauge{id: :cpu, value: 72, min: 0, max: 100, label: "CPU"} = gauge

      assert %Widgets.Sparkline{id: :memory_trend, data: [10, 20, 15, 30], show_dots: true} =
               sparkline

      assert %Widgets.BarChart{id: :sales_chart, orientation: :vertical} = bar_chart
      assert %Widgets.LineChart{id: :latency_chart, show_dots: true} = line_chart
    end

    test "supports tables and nested columns in a compiled module" do
      module = unique_fixture_module(:table)

      compile_fixture(
        module,
        """
        vbox do
          id :table_root

          table :users, [%{id: 1, name: "Alice"}, %{id: 2, name: "Bob"}] do
            sort_column :id
            sort_direction :desc
            on_sort :users_sorted
            on_row_select :user_selected

            column :id, "ID", align: :right, width: 4
            column :name, "Name", sortable: true
          end
        end
        """
      )

      assert function_exported?(module, :view, 1)

      assert %Layouts.VBox{id: :table_root, children: [table]} = module.view(%{})

      assert %Widgets.Table{
               id: :users,
               sort_column: :id,
               sort_direction: :desc,
               on_sort: :users_sorted,
               on_row_select: :user_selected,
               columns: [id_col, name_col]
             } = table

      assert [%{id: 1, name: "Alice"}, %{id: 2, name: "Bob"}] = table.data
      assert %Widgets.Column{key: :id, header: "ID", align: :right, width: 4} = id_col
      assert %Widgets.Column{key: :name, header: "Name", sortable: true} = name_col
    end

    test "supports for-comprehension generated widgets inside layout blocks" do
      module = unique_fixture_module(:for_generated_widgets)

      compile_fixture(
        module,
        """
        vbox do
          id :loop_root

          for i <- 1..100 do
            text "Widget \#{i}", id: :"widget_\#{i}"
          end
        end
        """
      )

      assert function_exported?(module, :view, 1)

      assert %Layouts.VBox{id: :loop_root, children: children} = module.view(%{})
      assert length(children) == 100
      assert Enum.all?(children, &match?(%Widgets.Text{}, &1))
      assert %Widgets.Text{id: :widget_1, content: "Widget 1"} = List.first(children)
      assert %Widgets.Text{id: :widget_100, content: "Widget 100"} = List.last(children)
    end

    test "interpolates {:state, :key} references in generated view output" do
      module = unique_fixture_module(:state_interpolation)

      compile_fixture(
        module,
        """
        state(Enum.into(%{
          email: "guest@example.com",
          submitting: false,
          show_status: true,
          status_message: "Idle",
          show_root: true
        }, []))

        vbox do
          id :root
          visible {:state, :show_root}

          text {:state, :status_message}, id: :status, visible: {:state, :show_status}
          text_input :email_input, value: {:state, :email}, disabled: {:state, :submitting}
          button "Submit", id: :submit_btn, disabled: {:state, :submitting}
        end
        """
      )

      assert module.init([]) == %{
               email: "guest@example.com",
               submitting: false,
               show_status: true,
               status_message: "Idle",
               show_root: true
             }

      assert %Layouts.VBox{visible: true, children: [status, input, button]} =
               module.view(%{
                 email: "admin@example.com",
                 submitting: true,
                 show_status: false,
                 status_message: "Saving...",
                 show_root: true
               })

      assert %Widgets.Text{id: :status, content: "Saving...", visible: false} = status

      assert %Widgets.TextInput{id: :email_input, value: "admin@example.com", disabled: true} =
               input

      assert %Widgets.Button{id: :submit_btn, disabled: true} = button
    end
  end

  describe "standard_signals" do
    test "standard_signals returns expected list" do
      signals = Dsl.standard_signals()
      assert is_list(signals)
      assert :click in signals
      assert :change in signals
      assert :submit in signals
    end
  end

  defp unique_fixture_module(tag) do
    Module.concat([UnifiedUi, DslFixture, tag, :"M#{System.unique_integer([:positive])}"])
  end

  defp compile_fixture(module, body) do
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
end
