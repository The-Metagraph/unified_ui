defmodule UnifiedUi.IUR.BuilderTrackBTest do
  use ExUnit.Case, async: true

  alias UnifiedUi.Dsl.Style, as: DslStyle
  alias UnifiedUi.Dsl.Theme, as: DslTheme
  alias UnifiedUi.IUR.Builder

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

  alias UnifiedIUR.Widgets

  describe "Track B builder coverage" do
    test "build/1 skips non-render entities and selects first buildable entity" do
      dsl_state = %{
        [:ui] => %{
          entities: [
            %{name: :state, attrs: %{attrs: [count: 0]}},
            %{name: :gauge, attrs: %{id: :cpu, value: 72, min: 0, max: 100}}
          ]
        }
      }

      assert %Widgets.Gauge{id: :cpu, value: 72} = Builder.build(dsl_state)
    end

    test "build/2 resolves theme token styles from runtime theme state" do
      light_text = %DslStyle{name: :light_text, attributes: [fg: :black]}
      dark_text = %DslStyle{name: :dark_text, attributes: [fg: :white]}
      light_theme = %DslTheme{name: :light, styles: [text: :light_text]}
      dark_theme = %DslTheme{name: :dark, styles: [text: :dark_text]}

      dsl_state = %{
        [:ui] => %{entities: [%{name: :text, attrs: %{content: "Theme Aware", style: :text}}]},
        :styles => %{entities: [light_text, dark_text, light_theme, dark_theme]},
        persist: %{module: __MODULE__}
      }

      assert %Widgets.Text{style: %UnifiedIUR.Style{fg: :black}} =
               Builder.build(dsl_state, %{theme: :light})

      assert %Widgets.Text{style: %UnifiedIUR.Style{fg: :white}} =
               Builder.build(dsl_state, %{theme: "dark"})
    end

    test "build/2 interpolates state references in widget and layout attributes" do
      dsl_state = %{
        [:ui] => %{
          entities: [
            %{
              name: :vbox,
              attrs: %{id: :root, visible: {:state, :show_root}},
              entities: [
                %{
                  name: :text,
                  attrs: %{
                    id: :status_text,
                    content: {:state, :message},
                    visible: {:state, :show_status}
                  }
                },
                %{
                  name: :text_input,
                  attrs: %{
                    id: :email,
                    value: {:state, :email},
                    disabled: {:state, :submitting}
                  }
                },
                %{
                  name: :button,
                  attrs: %{
                    id: :save_btn,
                    label: "Save",
                    disabled: {:state, :submitting}
                  }
                }
              ]
            }
          ]
        }
      }

      runtime_state = %{
        show_root: true,
        show_status: false,
        message: "Pending",
        email: "user@example.com",
        submitting: true
      }

      assert %UnifiedIUR.Layouts.VBox{visible: true, children: [text, input, button]} =
               Builder.build(dsl_state, runtime_state)

      assert %Widgets.Text{id: :status_text, content: "Pending", visible: false} = text
      assert %Widgets.TextInput{id: :email, value: "user@example.com", disabled: true} = input
      assert %Widgets.Button{id: :save_btn, disabled: true} = button
    end

    test "builds data visualization entities" do
      gauge =
        Builder.build_entity(
          %{name: :gauge, attrs: %{id: :cpu, value: 72, min: 0, max: 100}},
          %{}
        )

      sparkline =
        Builder.build_entity(
          %{name: :sparkline, attrs: %{id: :mem, data: [1, 2, 3], show_dots: true}},
          %{}
        )

      bar_chart =
        Builder.build_entity(
          %{name: :bar_chart, attrs: %{id: :sales, data: [{"Mon", 1}], orientation: :vertical}},
          %{}
        )

      line_chart =
        Builder.build_entity(
          %{name: :line_chart, attrs: %{id: :latency, data: [{"P99", 30}], show_dots: true}},
          %{}
        )

      assert %Widgets.Gauge{id: :cpu, value: 72, min: 0, max: 100} = gauge
      assert %Widgets.Sparkline{id: :mem, data: [1, 2, 3], show_dots: true} = sparkline
      assert %Widgets.BarChart{id: :sales, orientation: :vertical} = bar_chart
      assert %Widgets.LineChart{id: :latency, show_dots: true} = line_chart
    end

    test "builds table with nested column entities" do
      table_entity = %{
        name: :table,
        attrs: %{id: :users, data: [%{id: 1, name: "Alice"}], sort_direction: :desc},
        entities: [
          %{
            name: :columns,
            entities: [
              %{name: :column, attrs: %{key: :id, header: "ID", align: :right, width: 4}},
              %{name: :column, attrs: %{key: :name, header: "Name", sortable: true}}
            ]
          }
        ]
      }

      table = Builder.build_entity(table_entity, %{})

      assert %Widgets.Table{id: :users, sort_direction: :desc} = table
      assert [%Widgets.Column{key: :id}, %Widgets.Column{key: :name}] = table.columns

      [id_col, name_col] = table.columns
      assert id_col.header == "ID"
      assert id_col.align == :right
      assert id_col.width == 4
      assert name_col.header == "Name"
      assert name_col.sortable == true
    end

    test "builds navigation entities and nested collections" do
      menu =
        Builder.build_entity(
          %{
            name: :menu,
            attrs: %{id: :main_menu, title: "Main", position: :top},
            entities: [
              %{
                name: :menu_items,
                entities: [
                  %{name: :menu_item, attrs: %{label: "Open", action: :open}},
                  %{name: :menu_item, attrs: %{label: "Save", action: :save}}
                ]
              }
            ]
          },
          %{}
        )

      context_menu =
        Builder.build_entity(
          %{
            name: :context_menu,
            attrs: %{id: :editor_context, trigger_on: :right_click},
            entities: [
              %{
                name: :items,
                entities: [
                  %{name: :menu_item, attrs: %{label: "Copy", action: :copy}},
                  %{name: :menu_item, attrs: %{label: "Paste", action: :paste}}
                ]
              }
            ]
          },
          %{}
        )

      tabs =
        Builder.build_entity(
          %{
            name: :tabs,
            attrs: %{id: :workspace_tabs, active_tab: :home, on_change: :tab_changed},
            entities: [
              %{
                name: :tabs,
                entities: [
                  %{name: :tab, attrs: %{id: :home, label: "Home"}},
                  %{name: :tab, attrs: %{id: :files, label: "Files"}}
                ]
              }
            ]
          },
          %{}
        )

      tree_view =
        Builder.build_entity(
          %{
            name: :tree_view,
            attrs: %{id: :project_tree, selected_node: :readme, on_select: :node_selected},
            entities: [
              %{
                name: :root_nodes,
                entities: [
                  %{name: :tree_node, attrs: %{id: :readme, label: "README.md"}},
                  %{name: :tree_node, attrs: %{id: :mix, label: "mix.exs"}}
                ]
              }
            ]
          },
          %{}
        )

      assert %Widgets.Menu{id: :main_menu, title: "Main", position: :top} = menu
      assert [%Widgets.MenuItem{label: "Open"}, %Widgets.MenuItem{label: "Save"}] = menu.items

      assert %Widgets.ContextMenu{id: :editor_context, trigger_on: :right_click} = context_menu

      assert [%Widgets.MenuItem{label: "Copy"}, %Widgets.MenuItem{label: "Paste"}] =
               context_menu.items

      assert %Widgets.Tabs{id: :workspace_tabs, active_tab: :home, on_change: :tab_changed} = tabs

      assert [%Widgets.Tab{id: :home, label: "Home"}, %Widgets.Tab{id: :files, label: "Files"}] =
               tabs.tabs

      assert %Widgets.TreeView{
               id: :project_tree,
               selected_node: :readme,
               on_select: :node_selected
             } = tree_view

      assert [%Widgets.TreeNode{id: :readme, label: "README.md"}, %Widgets.TreeNode{id: :mix}] =
               tree_view.root_nodes
    end

    test "builds dialog and feedback entities" do
      dialog =
        Builder.build_entity(
          %{
            name: :dialog,
            attrs: %{
              id: :confirm_delete,
              title: "Delete file",
              content: "Are you sure?",
              on_close: :close_dialog,
              width: 40,
              closable: true
            },
            entities: [
              %{
                name: :buttons,
                entities: [
                  %{
                    name: :dialog_button,
                    attrs: %{label: "Cancel", action: :cancel, role: :cancel}
                  },
                  %{
                    name: :dialog_button,
                    attrs: %{label: "Delete", action: :confirm_delete, role: :destructive}
                  }
                ]
              }
            ]
          },
          %{}
        )

      alert_dialog =
        Builder.build_entity(
          %{
            name: :alert_dialog,
            attrs: %{
              id: :disk_alert,
              title: "Disk Space",
              message: "Low disk space remaining",
              severity: :warning,
              on_confirm: :open_cleanup,
              on_cancel: :dismiss_alert
            }
          },
          %{}
        )

      toast =
        Builder.build_entity(
          %{
            name: :toast,
            attrs: %{
              id: :saved_toast,
              message: "Saved successfully",
              severity: :success,
              duration: 1500,
              on_dismiss: :toast_closed
            }
          },
          %{}
        )

      assert %Widgets.Dialog{id: :confirm_delete, title: "Delete file", on_close: :close_dialog} =
               dialog

      assert [%Widgets.DialogButton{label: "Cancel"}, %Widgets.DialogButton{label: "Delete"}] =
               dialog.buttons

      assert %Widgets.AlertDialog{id: :disk_alert, severity: :warning} = alert_dialog
      assert alert_dialog.on_confirm == :open_cleanup
      assert alert_dialog.on_cancel == :dismiss_alert

      assert %Widgets.Toast{id: :saved_toast, severity: :success, duration: 1500} = toast
      assert toast.on_dismiss == :toast_closed
    end

    test "builds advanced input entities" do
      pick_list =
        Builder.build_entity(
          %{
            name: :pick_list,
            attrs: %{
              id: :country,
              options: [{"us", "United States"}, {"ca", "Canada"}],
              selected: "ca",
              searchable: true,
              on_select: :country_selected
            }
          },
          %{}
        )

      form_builder =
        Builder.build_entity(
          %{
            name: :form_builder,
            attrs: %{
              id: :profile_form,
              fields: [%{name: :email, type: :email, required: true}],
              on_submit: :save_profile,
              submit_label: "Save"
            }
          },
          %{}
        )

      assert %Widgets.PickList{
               id: :country,
               selected: "ca",
               searchable: true,
               on_select: :country_selected
             } = pick_list

      assert [%Widgets.PickListOption{value: "us"}, %Widgets.PickListOption{value: "ca"}] =
               pick_list.options

      assert %Widgets.FormBuilder{
               id: :profile_form,
               on_submit: :save_profile,
               submit_label: "Save"
             } = form_builder

      assert [%Widgets.FormField{name: :email, type: :email, required: true}] =
               form_builder.fields
    end

    test "builds container widgets with nested content and panes" do
      viewport =
        Builder.build_entity(
          %{
            name: :viewport,
            attrs: %{
              id: :main_viewport,
              width: 80,
              height: 20,
              scroll_x: 3,
              scroll_y: 7,
              on_scroll: :viewport_scrolled
            },
            entities: [
              %{
                name: :content,
                entities: [
                  %{name: :text, attrs: %{content: "Scrollable content"}}
                ]
              }
            ]
          },
          %{}
        )

      split_pane =
        Builder.build_entity(
          %{
            name: :split_pane,
            attrs: %{
              id: :main_split,
              orientation: :vertical,
              initial_split: 60,
              min_size: 15,
              on_resize_change: :split_resized
            },
            entities: [
              %{
                name: :panes,
                entities: [
                  %{name: :text, attrs: %{content: "Left pane"}},
                  %{name: :text, attrs: %{content: "Right pane"}}
                ]
              }
            ]
          },
          %{}
        )

      assert %Viewport{
               id: :main_viewport,
               width: 80,
               height: 20,
               scroll_x: 3,
               scroll_y: 7,
               on_scroll: :viewport_scrolled
             } = viewport

      assert %Widgets.Text{content: "Scrollable content"} = viewport.content

      assert %SplitPane{
               id: :main_split,
               orientation: :vertical,
               initial_split: 60,
               min_size: 15,
               on_resize_change: :split_resized
             } = split_pane

      assert [%Widgets.Text{content: "Left pane"}, %Widgets.Text{content: "Right pane"}] =
               split_pane.panes
    end

    test "builds specialized widgets with command filtering metadata" do
      canvas =
        Builder.build_entity(
          %{
            name: :canvas,
            attrs: %{
              id: :chart_canvas,
              width: 120,
              height: 40,
              on_click: :canvas_clicked,
              on_hover: :canvas_hovered
            }
          },
          %{}
        )

      command_palette =
        Builder.build_entity(
          %{
            name: :command_palette,
            attrs: %{
              id: :main_commands,
              placeholder: "Search commands",
              trigger_shortcut: "ctrl+k",
              on_select: :command_selected
            },
            entities: [
              %{
                name: :cmds,
                entities: [
                  %{name: :command, attrs: %{id: :open, label: "Open File", keywords: ["open"]}},
                  %{name: :command, attrs: %{id: :save, label: "Save File", keywords: ["save"]}}
                ]
              }
            ]
          },
          %{}
        )

      assert %Canvas{
               id: :chart_canvas,
               width: 120,
               height: 40,
               on_click: :canvas_clicked,
               on_hover: :canvas_hovered
             } = canvas

      assert %CommandPalette{
               id: :main_commands,
               placeholder: "Search commands",
               trigger_shortcut: "ctrl+k",
               on_select: :command_selected
             } = command_palette

      assert [%Command{id: :open, label: "Open File"}, %Command{id: :save, label: "Save File"}] =
               command_palette.commands
    end

    test "builds monitoring widgets with refresh metadata" do
      log_viewer =
        Builder.build_entity(
          %{
            name: :log_viewer,
            attrs: %{
              id: :logs,
              source: "/tmp/app.log",
              lines: 250,
              auto_scroll: true,
              refresh_interval: 750
            }
          },
          %{}
        )

      stream_widget =
        Builder.build_entity(
          %{
            name: :stream_widget,
            attrs: %{
              id: :events,
              producer: :event_stream,
              buffer_size: 50,
              refresh_interval: 500,
              on_item: :stream_item
            }
          },
          %{}
        )

      process_monitor =
        Builder.build_entity(
          %{
            name: :process_monitor,
            attrs: %{
              id: :procs,
              node: :nonode@nohost,
              refresh_interval: 1_500,
              sort_by: :reductions,
              on_process_select: :process_selected
            }
          },
          %{}
        )

      assert %LogViewer{id: :logs, source: "/tmp/app.log", lines: 250, refresh_interval: 750} =
               log_viewer

      assert %StreamWidget{
               id: :events,
               producer: :event_stream,
               buffer_size: 50,
               refresh_interval: 500,
               on_item: :stream_item
             } = stream_widget

      assert %ProcessMonitor{
               id: :procs,
               node: :nonode@nohost,
               refresh_interval: 1_500,
               sort_by: :reductions,
               on_process_select: :process_selected
             } = process_monitor
    end

    test "builds advanced layouts with normalized children and positioning" do
      grid =
        Builder.build_entity(
          %{
            name: :grid,
            attrs: %{
              id: :dashboard_grid,
              columns: [1, "2fr", "auto"],
              rows: [1, 2],
              gap: 3,
              children: [
                %{name: :text, attrs: %{content: "Cell A"}},
                %{name: :button, attrs: %{label: "Cell B", on_click: :noop}}
              ]
            }
          },
          %{}
        )

      stack =
        Builder.build_entity(
          %{
            name: :stack,
            attrs: %{id: :panel_stack, active_index: 1, transition: :fade},
            entities: [
              %{
                name: :children,
                entities: [
                  %{name: :text, attrs: %{content: "First"}},
                  %{name: :text, attrs: %{content: "Second"}}
                ]
              }
            ]
          },
          %{}
        )

      zbox =
        Builder.build_entity(
          %{
            name: :zbox,
            attrs: %{
              id: :overlay,
              positions: %{0 => %{x: 2, y: 1, z: 1}, panel: %{x: 10, y: 4, z_index: 5}},
              children: [
                %{name: :text, attrs: %{content: "Base"}},
                %{name: :text, attrs: %{id: :panel, content: "Panel"}}
              ]
            }
          },
          %{}
        )

      assert %Grid{id: :dashboard_grid, columns: [1, "2fr", "auto"], rows: [1, 2], gap: 3} = grid
      assert [%Widgets.Text{content: "Cell A"}, %Widgets.Button{label: "Cell B"}] = grid.children

      assert %Stack{id: :panel_stack, active_index: 1, transition: :fade} = stack
      assert [%Widgets.Text{content: "First"}, %Widgets.Text{content: "Second"}] = stack.children

      assert %ZBox{id: :overlay} = zbox
      assert zbox.positions[0] == %{x: 2, y: 1, z: 1}
      assert zbox.positions[:panel] == %{x: 10, y: 4, z_index: 5}

      assert [%Widgets.Text{content: "Base"}, %Widgets.Text{id: :panel, content: "Panel"}] =
               zbox.children
    end
  end
end
