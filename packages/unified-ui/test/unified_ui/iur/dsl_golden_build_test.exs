defmodule UnifiedUi.IUR.DslGoldenBuildTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.{Layouts, Widgets}
  alias UnifiedUi.IUR.Builder

  describe "basic widgets and layouts DSL state to IUR build" do
    test "build/1 skips non-render entities and builds a nested widget tree" do
      dsl_state = %{
        [:ui] => %{
          entities: [
            %{name: :state, attrs: %{attrs: [count: 0]}},
            %{
              name: :vbox,
              attrs: %{id: :basic_root, spacing: 2},
              entities: [
                %{name: :text, attrs: %{id: :title, content: "Welcome"}},
                %{
                  name: :hbox,
                  attrs: %{id: :form_row, spacing: 1},
                  entities: [
                    %{
                      name: :label,
                      attrs: %{id: :username_label, for: :username, text: "Username"}
                    },
                    %{
                      name: :text_input,
                      attrs: %{
                        id: :username,
                        placeholder: "Enter username",
                        on_change: :username_changed,
                        on_submit: :login_submit
                      }
                    },
                    %{
                      name: :button,
                      attrs: %{
                        id: :submit_btn,
                        label: "Submit",
                        on_click: {:submit_login, %{source: :golden}}
                      }
                    }
                  ]
                }
              ]
            }
          ]
        }
      }

      iur = Builder.build(dsl_state)

      assert %Layouts.VBox{id: :basic_root, spacing: 2, children: [title, row]} = iur
      assert %Widgets.Text{id: :title, content: "Welcome"} = title
      assert %Layouts.HBox{id: :form_row, spacing: 1, children: [label, input, button]} = row

      assert %Widgets.Label{id: :username_label, for: :username, text: "Username"} = label

      assert %Widgets.TextInput{
               id: :username,
               placeholder: "Enter username",
               type: :text,
               on_change: :username_changed,
               on_submit: :login_submit
             } = input

      assert %Widgets.Button{
               id: :submit_btn,
               label: "Submit",
               on_click: {:submit_login, %{source: :golden}}
             } = button
    end
  end

  describe "data visualization DSL state to IUR build" do
    test "build/1 converts all data visualization entities under a complex root layout" do
      dsl_state = %{
        [:ui] => %{
          entities: [
            %{
              name: :vbox,
              attrs: %{id: :metrics_root},
              entities: [
                %{name: :gauge, attrs: %{id: :cpu, value: 72, min: 0, max: 100, label: "CPU"}},
                %{
                  name: :sparkline,
                  attrs: %{id: :memory_trend, data: [10, 20, 15, 30], show_dots: true}
                },
                %{
                  name: :bar_chart,
                  attrs: %{
                    id: :sales_chart,
                    data: [{"Mon", 10}, {"Tue", 12}],
                    orientation: :vertical
                  }
                },
                %{
                  name: :line_chart,
                  attrs: %{id: :latency_chart, data: [{"P95", 40}, {"P99", 55}], show_dots: true}
                }
              ]
            }
          ]
        }
      }

      iur = Builder.build(dsl_state)

      assert %Layouts.VBox{
               id: :metrics_root,
               children: [gauge, sparkline, bar_chart, line_chart]
             } = iur

      assert %Widgets.Gauge{id: :cpu, value: 72, min: 0, max: 100, label: "CPU"} = gauge

      assert %Widgets.Sparkline{id: :memory_trend, data: [10, 20, 15, 30], show_dots: true} =
               sparkline

      assert %Widgets.BarChart{id: :sales_chart, orientation: :vertical} = bar_chart
      assert %Widgets.LineChart{id: :latency_chart, show_dots: true} = line_chart
    end
  end

  describe "table DSL state to IUR build" do
    test "build/1 converts table with nested column definitions" do
      dsl_state = %{
        [:ui] => %{
          entities: [
            %{
              name: :vbox,
              attrs: %{id: :table_root},
              entities: [
                %{
                  name: :table,
                  attrs: %{
                    id: :users_table,
                    data: [%{id: 1, name: "Alice"}, %{id: 2, name: "Bob"}],
                    sort_column: :id,
                    sort_direction: :desc,
                    on_sort: :users_sorted,
                    on_row_select: :user_selected
                  },
                  entities: [
                    %{
                      name: :columns,
                      entities: [
                        %{
                          name: :column,
                          attrs: %{key: :id, header: "ID", align: :right, width: 4}
                        },
                        %{name: :column, attrs: %{key: :name, header: "Name", sortable: true}}
                      ]
                    }
                  ]
                }
              ]
            }
          ]
        }
      }

      iur = Builder.build(dsl_state)

      assert %Layouts.VBox{id: :table_root, children: [table]} = iur

      assert %Widgets.Table{
               id: :users_table,
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
  end

  describe "navigation DSL state to IUR build" do
    test "build/1 converts menu/context/tabs/tree structures with nested entities" do
      dsl_state = %{
        [:ui] => %{
          entities: [
            %{
              name: :vbox,
              attrs: %{id: :navigation_root},
              entities: [
                %{
                  name: :menu,
                  attrs: %{id: :main_menu, title: "Main", position: :top},
                  entities: [
                    %{
                      name: :menu_items,
                      entities: [
                        %{
                          name: :menu_item,
                          attrs: %{id: :open_item, label: "Open", action: :open_file}
                        },
                        %{
                          name: :menu_item,
                          attrs: %{label: "Save", action: {:save_file, %{source: :menu}}}
                        }
                      ]
                    }
                  ]
                },
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
                %{
                  name: :tabs,
                  attrs: %{id: :workspace_tabs, active_tab: :home, on_change: :tab_changed},
                  entities: [
                    %{
                      name: :tabs,
                      entities: [
                        %{
                          name: :tab,
                          attrs: %{id: :home, label: "Home"},
                          entities: [
                            %{name: :text, attrs: %{id: :home_content, content: "Home content"}}
                          ]
                        },
                        %{
                          name: :tab,
                          attrs: %{id: :files, label: "Files", icon: :folder},
                          entities: [
                            %{
                              name: :vbox,
                              attrs: %{id: :files_panel},
                              entities: [
                                %{
                                  name: :text,
                                  attrs: %{id: :files_content, content: "Files content"}
                                }
                              ]
                            }
                          ]
                        }
                      ]
                    }
                  ]
                },
                %{
                  name: :tree_view,
                  attrs: %{id: :project_tree, selected_node: :readme, on_select: :node_selected},
                  entities: [
                    %{
                      name: :root_nodes,
                      entities: [
                        %{name: :tree_node, attrs: %{id: :readme, label: "README.md"}},
                        %{
                          name: :tree_node,
                          attrs: %{id: :lib, label: "lib", expanded: true},
                          entities: [
                            %{
                              name: :children,
                              entities: [
                                %{name: :tree_node, attrs: %{id: :main, label: "main.ex"}}
                              ]
                            }
                          ]
                        }
                      ]
                    }
                  ]
                }
              ]
            }
          ]
        }
      }

      iur = Builder.build(dsl_state)

      assert %Layouts.VBox{
               id: :navigation_root,
               children: [menu, context_menu, tabs, tree_view]
             } = iur

      assert %Widgets.Menu{id: :main_menu, title: "Main", position: :top, items: menu_items} =
               menu

      assert [%Widgets.MenuItem{id: :open_item, label: "Open"}, %Widgets.MenuItem{label: "Save"}] =
               menu_items

      assert %Widgets.ContextMenu{
               id: :editor_context,
               trigger_on: :right_click,
               items: context_items
             } =
               context_menu

      assert [%Widgets.MenuItem{label: "Copy"}, %Widgets.MenuItem{label: "Paste"}] = context_items

      assert %Widgets.Tabs{
               id: :workspace_tabs,
               active_tab: :home,
               on_change: :tab_changed,
               tabs: [home, files]
             } =
               tabs

      assert %Widgets.Tab{id: :home, label: "Home", content: %Widgets.Text{id: :home_content}} =
               home

      assert %Widgets.Tab{
               id: :files,
               label: "Files",
               icon: :folder,
               content: %Layouts.VBox{id: :files_panel}
             } =
               files

      assert %Widgets.TreeView{
               id: :project_tree,
               selected_node: :readme,
               on_select: :node_selected,
               root_nodes: [readme, lib]
             } = tree_view

      assert %Widgets.TreeNode{id: :readme, label: "README.md"} = readme
      assert %Widgets.TreeNode{id: :lib, label: "lib", expanded: true, children: [main]} = lib
      assert %Widgets.TreeNode{id: :main, label: "main.ex"} = main
    end
  end

  describe "dialog and feedback DSL state to IUR build" do
    test "build/1 converts dialog, alert_dialog, and toast entities" do
      dsl_state = %{
        [:ui] => %{
          entities: [
            %{
              name: :vbox,
              attrs: %{id: :dialog_root},
              entities: [
                %{
                  name: :dialog,
                  attrs: %{
                    id: :delete_dialog,
                    title: "Delete item",
                    content: "Delete the selected item?",
                    on_close: :close_delete_dialog
                  },
                  entities: [
                    %{
                      name: :buttons,
                      entities: [
                        %{
                          name: :dialog_button,
                          attrs: %{label: "Cancel", action: :cancel_delete}
                        },
                        %{
                          name: :dialog_button,
                          attrs: %{label: "Delete", action: :confirm_delete, role: :destructive}
                        }
                      ]
                    }
                  ]
                },
                %{
                  name: :alert_dialog,
                  attrs: %{
                    id: :warning_alert,
                    title: "Warning",
                    message: "Operation cannot be undone",
                    severity: :warning,
                    on_confirm: :confirm_warning,
                    on_cancel: :dismiss_warning
                  }
                },
                %{
                  name: :toast,
                  attrs: %{
                    id: :save_toast,
                    message: "Saved",
                    severity: :success,
                    duration: 1200,
                    on_dismiss: :toast_dismissed
                  }
                }
              ]
            }
          ]
        }
      }

      iur = Builder.build(dsl_state)

      assert %Layouts.VBox{id: :dialog_root, children: [dialog, alert, toast]} = iur
      assert %Widgets.Dialog{id: :delete_dialog, title: "Delete item"} = dialog

      assert %Widgets.DialogButton{label: "Cancel", action: :cancel_delete} =
               Enum.at(dialog.buttons, 0)

      assert %Widgets.DialogButton{role: :destructive, action: :confirm_delete} =
               Enum.at(dialog.buttons, 1)

      assert %Widgets.AlertDialog{
               id: :warning_alert,
               severity: :warning,
               on_confirm: :confirm_warning,
               on_cancel: :dismiss_warning
             } = alert

      assert %Widgets.Toast{
               id: :save_toast,
               severity: :success,
               duration: 1200,
               on_dismiss: :toast_dismissed
             } = toast
    end
  end

  describe "advanced input DSL state to IUR build" do
    test "build/1 converts pick_list and form_builder entities" do
      dsl_state = %{
        [:ui] => %{
          entities: [
            %{
              name: :vbox,
              attrs: %{id: :input_root},
              entities: [
                %{
                  name: :pick_list,
                  attrs: %{
                    id: :country_select,
                    options: [{"us", "United States"}, {"ca", "Canada"}],
                    selected: "ca",
                    searchable: true,
                    on_select: :country_selected
                  }
                },
                %{
                  name: :form_builder,
                  attrs: %{
                    id: :profile_form,
                    fields: [
                      %{name: :email, type: :email, required: true, placeholder: "user@site.com"},
                      %{name: :newsletter, type: :checkbox, default: true}
                    ],
                    on_submit: :save_profile,
                    submit_label: "Save Profile"
                  }
                }
              ]
            }
          ]
        }
      }

      iur = Builder.build(dsl_state)

      assert %Layouts.VBox{id: :input_root, children: [pick_list, form_builder]} = iur

      assert %Widgets.PickList{
               id: :country_select,
               selected: "ca",
               searchable: true,
               on_select: :country_selected,
               options: [us, ca]
             } = pick_list

      assert %Widgets.PickListOption{value: "us", label: "United States"} = us
      assert %Widgets.PickListOption{value: "ca", label: "Canada"} = ca

      assert %Widgets.FormBuilder{
               id: :profile_form,
               on_submit: :save_profile,
               submit_label: "Save Profile",
               fields: [email_field, newsletter_field]
             } = form_builder

      assert %Widgets.FormField{
               name: :email,
               type: :email,
               required: true,
               placeholder: "user@site.com"
             } = email_field

      assert %Widgets.FormField{name: :newsletter, type: :checkbox, default: true} =
               newsletter_field
    end
  end
end
