defmodule LiveUi.Components.WidgetRenderingTest do
  use ExUnit.Case, async: true

  import Phoenix.Component, only: [sigil_H: 2]
  import Phoenix.LiveViewTest, only: [render_component: 2, rendered_to_string: 1]

  alias LiveUi.Widgets
  alias LiveUi.WidgetRegistry

  test "renders stateless widgets with stable css tokens" do
    rendered =
      render_component(&WidgetRegistry.render/1,
        descriptor: %{
          id: "headline",
          kind: "text",
          props: %{"text" => "Hello", "style" => %{"class" => "hero", "tone" => "accent"}}
        }
      )
      |> rendered_to_string()

    assert rendered =~ "Hello"
    assert rendered =~ "live-ui-text"
    assert rendered =~ "hero"
    assert rendered =~ "tone-accent"
  end

  test "renders descriptor-defined click payload attrs for buttons" do
    rendered =
      render_component(&WidgetRegistry.render/1,
        descriptor: %{
          id: "increment-button",
          kind: "button",
          props: %{"label" => "Increment"},
          signal_bindings: [
            %{
              event: "on_click",
              widget_id: "increment-button",
              widget_kind: "button",
              payload: %{
                "intent" => "activate",
                "payload" => %{"delta" => 2, "source" => "counter"}
              }
            }
          ]
        }
      )
      |> rendered_to_string()

    assert rendered =~ "phx-click=&quot;click&quot;"
    assert rendered =~ "phx-value-event_click_intent=&quot;activate&quot;"
    assert rendered =~ "phx-value-event_click_delta=&quot;2&quot;"
    assert rendered =~ "phx-value-event_click_source=&quot;counter&quot;"
  end

  test "renders scoped attrs for multi-event text inputs" do
    rendered =
      render_component(&WidgetRegistry.render/1,
        descriptor: %{
          id: "name-input",
          kind: "text_input",
          props: %{"value" => "Pascal"},
          signal_bindings: [
            %{
              event: "on_change",
              widget_id: "name-input",
              widget_kind: "text_input",
              payload: %{"intent" => "update_name"}
            },
            %{
              event: "on_submit",
              widget_id: "name-input",
              widget_kind: "text_input",
              payload: %{"intent" => "commit_name", "payload" => %{"source" => "blur"}}
            }
          ]
        }
      )
      |> rendered_to_string()

    assert rendered =~ "phx-change=&quot;change&quot;"
    assert rendered =~ "phx-blur=&quot;submit&quot;"
    assert rendered =~ "phx-value-event_change_intent=&quot;update_name&quot;"
    assert rendered =~ "phx-value-event_submit_intent=&quot;commit_name&quot;"
    assert rendered =~ "phx-value-event_submit_source=&quot;blur&quot;"
  end

  test "renders stateful composites with hook metadata" do
    rendered =
      render_component(&WidgetRegistry.render/1,
        descriptor: %{
          id: "main-split",
          kind: "split_pane",
          props: %{"sizes" => [30, 70], "style" => %{"gap" => 2}}
        }
      )
      |> rendered_to_string()

    assert rendered =~ "live-ui-layout--split_pane"
    assert rendered =~ "LiveUi.SplitPane"
    assert rendered =~ "gap-2"
    refute rendered =~ "align-items: nil"
  end

  test "renders table interactions with stable scoped payload attrs" do
    rendered =
      render_component(&WidgetRegistry.render/1,
        descriptor: %{
          id: "users-table",
          kind: "table",
          props: %{
            "columns" => [%{"key" => "name", "header" => "Name"}],
            "data" => [%{"name" => "Pascal"}]
          },
          signal_bindings: [
            %{
              event: "on_row_select",
              widget_id: "users-table",
              widget_kind: "table",
              payload: %{"intent" => "select_row"}
            },
            %{
              event: "on_sort",
              widget_id: "users-table",
              widget_kind: "table",
              payload: %{"intent" => "sort_rows", "payload" => %{"direction" => "asc"}}
            }
          ]
        }
      )
      |> rendered_to_string()

    assert rendered =~ "phx-value-event_click_sort_column=&quot;name&quot;"
    assert rendered =~ "phx-value-event_click_direction=&quot;asc&quot;"
    assert rendered =~ "phx-value-event_click_row_id=&quot;0&quot;"
    assert rendered =~ "phx-value-event_click_row_index=&quot;0&quot;"
  end

  test "renders form builders with change and submit bindings" do
    rendered =
      render_component(&WidgetRegistry.render/1,
        descriptor: %{
          id: "profile-form",
          kind: "form_builder",
          props: %{"submit_label" => "Save"},
          children: [
            %{
              id: "display-name",
              kind: "form_field",
              props: %{"label" => "Name", "name" => "name", "default" => "Pascal"}
            }
          ],
          signal_bindings: [
            %{
              event: "on_change",
              widget_id: "profile-form",
              widget_kind: "form_builder",
              payload: %{"intent" => "update_profile"}
            },
            %{
              event: "on_submit",
              widget_id: "profile-form",
              widget_kind: "form_builder",
              payload: %{"intent" => "save_profile"}
            }
          ]
        }
      )
      |> rendered_to_string()

    assert rendered =~ "phx-change=&quot;change&quot;"
    assert rendered =~ "phx-submit=&quot;submit&quot;"
    assert rendered =~ "phx-value-event_change_intent=&quot;update_profile&quot;"
    assert rendered =~ "phx-value-event_submit_intent=&quot;save_profile&quot;"
  end

  test "renders tree, viewport, split pane, and command palette interaction metadata" do
    rendered =
      render_component(&WidgetRegistry.render/1,
        descriptor: %{
          id: "workspace-root",
          kind: "vbox",
          props: %{},
          children: [
            %{
              id: "tree-node-1",
              kind: "tree_node",
              props: %{"label" => "Node 1", "expanded" => true},
              signal_bindings: [
                %{
                  event: "on_toggle",
                  widget_id: "tree-node-1",
                  widget_kind: "tree_node",
                  payload: %{"intent" => "toggle_node"}
                }
              ],
              children: [%{id: "leaf", kind: "label", props: %{"text" => "Leaf"}}]
            },
            %{
              id: "viewport-1",
              kind: "viewport",
              props: %{"scroll_top" => 12, "scroll_left" => 4},
              signal_bindings: [
                %{
                  event: "on_scroll",
                  widget_id: "viewport-1",
                  widget_kind: "viewport",
                  payload: %{"intent" => "sync_scroll"}
                }
              ],
              children: [%{id: "copy", kind: "text", props: %{"content" => "Scrollable"}}]
            },
            %{
              id: "main-split",
              kind: "split_pane",
              props: %{"sizes" => [30, 70], "orientation" => "vertical"},
              signal_bindings: [
                %{
                  event: "on_resize_change",
                  widget_id: "main-split",
                  widget_kind: "split_pane",
                  payload: %{"intent" => "resize"}
                }
              ],
              children: [
                %{id: "left-pane", kind: "label", props: %{"text" => "Left"}},
                %{id: "right-pane", kind: "label", props: %{"text" => "Right"}}
              ]
            },
            %{
              id: "palette-1",
              kind: "command_palette",
              props: %{"query" => "dep", "active_command_id" => "deploy"},
              signal_bindings: [
                %{
                  event: "on_change",
                  widget_id: "palette-1",
                  widget_kind: "command_palette",
                  payload: %{"intent" => "update_query"}
                },
                %{
                  event: "on_submit",
                  widget_id: "palette-1",
                  widget_kind: "command_palette",
                  payload: %{"intent" => "submit_query"}
                }
              ],
              children: [
                %{
                  id: "deploy",
                  kind: "command",
                  props: %{"label" => "Deploy"},
                  signal_bindings: [
                    %{
                      event: "action",
                      widget_id: "deploy",
                      widget_kind: "command",
                      payload: %{
                        "intent" => "run_command",
                        "payload" => %{"command_id" => "deploy"}
                      }
                    }
                  ]
                }
              ]
            }
          ]
        }
      )
      |> rendered_to_string()

    assert rendered =~ "phx-value-event_click_node_id=&quot;tree-node-1&quot;"
    assert rendered =~ "phx-value-event_click_expanded=&quot;true&quot;"
    assert rendered =~ "data-scroll-top=&quot;12&quot;"
    assert rendered =~ "data-live-ui-event=&quot;scroll&quot;"
    assert rendered =~ "LiveUi.Viewport"
    assert rendered =~ "data-pane-index=&quot;0&quot;"
    assert rendered =~ "flex: 0 0 30%"
    assert rendered =~ "data-live-ui-event=&quot;resize&quot;"
    assert rendered =~ "LiveUi.SplitPane"
    assert rendered =~ "phx-change=&quot;change&quot;"
    assert rendered =~ "phx-submit=&quot;submit&quot;"
    assert rendered =~ "data-active-command-id=&quot;deploy&quot;"
    assert rendered =~ "phx-value-event_click_command_id=&quot;deploy&quot;"
  end

  test "renders monitoring widgets with structured filter and process-select actions" do
    rendered =
      render_component(&WidgetRegistry.render/1,
        descriptor: %{
          id: "monitor-root",
          kind: "vbox",
          props: %{},
          children: [
            %{
              id: "logs",
              kind: "log_viewer",
              props: %{"filter" => "error", "lines" => ["error one"], "source" => "app.log"},
              signal_bindings: [
                %{
                  event: "on_change",
                  widget_id: "logs",
                  widget_kind: "log_viewer",
                  payload: %{"intent" => "filter_logs"}
                },
                %{
                  event: "action",
                  widget_id: "logs",
                  widget_kind: "log_viewer",
                  payload: %{"intent" => "refresh_logs"}
                }
              ]
            },
            %{
              id: "processes",
              kind: "process_monitor",
              props: %{
                "node" => "demo@127.0.0.1",
                "processes" => [%{"pid" => "#PID<0.10.0>", "name" => "worker"}]
              },
              signal_bindings: [
                %{
                  event: "on_process_select",
                  widget_id: "processes",
                  widget_kind: "process_monitor",
                  payload: %{"intent" => "select_process"}
                }
              ]
            }
          ]
        }
      )
      |> rendered_to_string()

    assert rendered =~ "Filter logs"
    assert rendered =~ "phx-value-event_change_intent=&quot;filter_logs&quot;"
    assert rendered =~ "phx-value-event_click_intent=&quot;refresh_logs&quot;"
    assert rendered =~ "data-live-ui-source=&quot;app.log&quot;"
    assert rendered =~ "demo@127.0.0.1"
    assert rendered =~ "phx-value-event_click_pid=&quot;#PID&amp;lt;0.10.0&amp;gt;&quot;"
    assert rendered =~ "phx-value-event_click_name=&quot;worker&quot;"
  end

  test "renders server-authoritative overlay state for composite widgets" do
    rendered =
      render_component(&WidgetRegistry.render/1,
        descriptor: %{
          id: "state-root",
          kind: "vbox",
          props: %{},
          children: [
            %{
              id: "tabs-1",
              kind: "tabs",
              props: %{"active_tab" => "details", "open" => true},
              children: [
                %{id: "summary", kind: "tab", props: %{"label" => "Summary"}},
                %{id: "details", kind: "tab", props: %{"label" => "Details"}}
              ]
            },
            %{
              id: "tree-node-1",
              kind: "tree_node",
              props: %{"label" => "Node 1", "expanded" => false, "selected" => true},
              children: []
            },
            %{
              id: "users-table",
              kind: "table",
              props: %{
                "columns" => [%{"key" => "name", "header" => "Name"}],
                "data" => [%{"id" => "user-1", "name" => "Pascal"}],
                "selected_row_id" => "user-1",
                "sort_column" => "name",
                "sort_direction" => "asc"
              },
              signal_bindings: [
                %{
                  event: "on_sort",
                  widget_id: "users-table",
                  widget_kind: "table",
                  payload: %{"intent" => "sort_rows"}
                },
                %{
                  event: "on_row_select",
                  widget_id: "users-table",
                  widget_kind: "table",
                  payload: %{"intent" => "select_row"}
                }
              ]
            },
            %{
              id: "palette-1",
              kind: "command_palette",
              props: %{"query" => "dep", "active_command_id" => "deploy", "open" => false},
              children: [%{id: "deploy", kind: "command", props: %{"label" => "Deploy"}}]
            },
            %{
              id: "processes",
              kind: "process_monitor",
              props: %{
                "selected_pid" => "#PID<0.10.0>",
                "processes" => [%{"pid" => "#PID<0.10.0>", "name" => "worker"}]
              },
              signal_bindings: [
                %{
                  event: "on_process_select",
                  widget_id: "processes",
                  widget_kind: "process_monitor",
                  payload: %{"intent" => "select_process"}
                }
              ]
            }
          ]
        }
      )
      |> rendered_to_string()

    assert rendered =~ "live-ui-tabs__tab is-active"
    assert rendered =~ "live-ui-tree__node is-selected"
    assert rendered =~ "aria-expanded=&quot;false&quot;"
    assert rendered =~ "data-selected-row-id=&quot;user-1&quot;"
    assert rendered =~ "live-ui-table__sort is-sorted"
    assert rendered =~ "live-ui-table__row is-selected"
    assert rendered =~ "is-closed"
    assert rendered =~ "data-open=&quot;false&quot;"
    assert rendered =~ "live-ui-process-monitor__process is-selected"
  end

  test "renders layouts by recursively dispatching child descriptors" do
    rendered =
      render_component(&WidgetRegistry.render/1,
        descriptor: %{
          id: "stack",
          kind: "vbox",
          props: %{},
          children: [
            %{id: "label-1", kind: "label", props: %{"text" => "Name"}},
            %{id: "input-1", kind: "text_input", props: %{"value" => "Pascal"}}
          ]
        }
      )
      |> rendered_to_string()

    assert rendered =~ "live-ui-layout--vbox"
    assert rendered =~ "Name"
    assert rendered =~ "value=&quot;Pascal&quot;"
  end

  test "renders public live_ui widgets directly without descriptor input" do
    rendered =
      render_component(&direct_widget_screen/1, %{})
      |> rendered_to_string()

    assert rendered =~ "live-ui-layout--vbox"
    assert rendered =~ "live-ui-layout--hbox"
    assert rendered =~ "Hello"
    assert rendered =~ "Save"
    assert rendered =~ "value=&quot;Pascal&quot;"
    assert rendered =~ "hero"
    assert rendered =~ "phx-click=&quot;click&quot;"
    assert rendered =~ "phx-value-event_click_intent=&quot;save&quot;"
  end

  test "renders public layout widgets with the same hook metadata as the IUR path" do
    rendered =
      render_component(&direct_interactive_layout_screen/1, %{})
      |> rendered_to_string()

    assert rendered =~ "LiveUi.Viewport"
    assert rendered =~ "data-live-ui-event=&quot;scroll&quot;"
    assert rendered =~ "data-scroll-top=&quot;12&quot;"
    assert rendered =~ "LiveUi.SplitPane"
    assert rendered =~ "data-live-ui-event=&quot;resize&quot;"
    assert rendered =~ "flex: 0 0 30%"
  end

  test "renders public composite widgets directly with shared interaction contracts" do
    rendered =
      render_component(&direct_composite_widget_screen/1, %{})
      |> rendered_to_string()

    assert rendered =~ "live-ui-tabs__tab is-active"
    assert rendered =~ "Name"
    assert rendered =~ "Pascal"
    assert rendered =~ "phx-value-event_click_tab_id=&quot;details&quot;"
    assert rendered =~ "phx-change=&quot;change&quot;"
    assert rendered =~ "phx-submit=&quot;submit&quot;"
    assert rendered =~ "role=&quot;dialog&quot;"
    assert rendered =~ "Archive"
    assert rendered =~ "phx-value-event_click_intent=&quot;archive_dialog&quot;"
    assert rendered =~ "data-active-command-id=&quot;deploy&quot;"
    assert rendered =~ "phx-value-event_click_command_id=&quot;deploy&quot;"
    assert rendered =~ "phx-value-event_change_intent=&quot;pick_region&quot;"
  end

  test "renders public data and extension widgets directly" do
    rendered =
      render_component(&direct_data_widget_screen/1, %{})
      |> rendered_to_string()

    assert rendered =~ "System Load"
    assert rendered =~ "value=&quot;62&quot;"
    assert rendered =~ "Deploys"
    assert rendered =~ "meter"
    assert rendered =~ "data-live-ui-hook=&quot;LiveUi.Canvas&quot;"
    assert rendered =~ "Filter logs"
    assert rendered =~ "phx-value-event_change_intent=&quot;filter_logs&quot;"
    assert rendered =~ "phx-value-event_click_intent=&quot;refresh_logs&quot;"
    assert rendered =~ "phx-value-event_click_pid=&quot;#PID&amp;lt;0.10.0&amp;gt;&quot;"
    assert rendered =~ "Saved"
  end

  defp direct_widget_screen(assigns) do
    ~H"""
    <Widgets.vbox id="direct-root" spacing={2}>
      <Widgets.text id="headline" content="Hello" style={%{"class" => "hero"}} />
      <Widgets.hbox id="actions" gap={1}>
        <Widgets.button
          id="save-button"
          label="Save"
          signal_bindings={[
            %{
              event: "on_click",
              payload: %{"intent" => "save"}
            }
          ]}
        />
        <Widgets.text_input id="name-input" value="Pascal" />
      </Widgets.hbox>
    </Widgets.vbox>
    """
  end

  defp direct_interactive_layout_screen(assigns) do
    ~H"""
    <Widgets.vbox id="interactive-root">
      <Widgets.viewport
        id="viewport-1"
        scroll_top={12}
        scroll_left={4}
        signal_bindings={[
          %{
            event: "on_scroll",
            payload: %{"intent" => "sync_scroll"}
          }
        ]}
      >
        <Widgets.text id="copy" content="Scrollable" />
      </Widgets.viewport>
      <Widgets.split_pane
        id="split-1"
        sizes={[30, 70]}
        orientation="vertical"
        signal_bindings={[
          %{
            event: "on_resize_change",
            payload: %{"intent" => "resize"}
          }
        ]}
      >
        <:pane>
          <Widgets.label id="left-pane" text="Left" />
        </:pane>
        <:pane>
          <Widgets.label id="right-pane" text="Right" />
        </:pane>
      </Widgets.split_pane>
    </Widgets.vbox>
    """
  end

  defp direct_composite_widget_screen(assigns) do
    ~H"""
    <Widgets.vbox id="composite-root" gap={2}>
      <Widgets.tabs
        id="tabs-1"
        active_tab="details"
        signal_bindings={[
          %{event: "on_change", payload: %{"intent" => "switch_tab"}}
        ]}
      >
        <:tab id="summary" label="Summary">
          <Widgets.text id="summary-copy" content="Summary" />
        </:tab>
        <:tab id="details" label="Details">
          <Widgets.table
            id="users-table"
            columns={[%{"key" => "name", "header" => "Name"}]}
            data={[%{"id" => "user-1", "name" => "Pascal"}]}
            selected_row_id="user-1"
            signal_bindings={[
              %{event: "on_row_select", payload: %{"intent" => "select_user"}}
            ]}
          />
        </:tab>
      </Widgets.tabs>

      <Widgets.command_palette
        id="palette-1"
        query="dep"
        active_command_id="deploy"
        signal_bindings={[
          %{event: "on_change", payload: %{"intent" => "update_query"}},
          %{event: "on_submit", payload: %{"intent" => "submit_query"}}
        ]}
      >
        <Widgets.command
          id="deploy"
          label="Deploy"
          signal_bindings={[
            %{event: "action", payload: %{"intent" => "run_command", "payload" => %{"command_id" => "deploy"}}}
          ]}
        />
      </Widgets.command_palette>

      <Widgets.form_builder
        id="profile-form"
        submit_label="Save"
        signal_bindings={[
          %{event: "on_change", payload: %{"intent" => "update_profile"}},
          %{event: "on_submit", payload: %{"intent" => "save_profile"}}
        ]}
      >
        <Widgets.form_field id="display-name" label="Name" name="name" default="Pascal" />
        <Widgets.pick_list
          id="region"
          placeholder="Select region"
          signal_bindings={[
            %{event: "on_select", payload: %{"intent" => "pick_region"}}
          ]}
        >
          <Widgets.pick_list_option value="us-west" label="US West" />
        </Widgets.pick_list>
      </Widgets.form_builder>

      <Widgets.dialog id="archive-dialog" title="Archive item">
        <Widgets.text id="dialog-copy" content="Archive now?" />
        <:action>
          <Widgets.dialog_button
            id="archive-action"
            label="Archive"
            signal_bindings={[
              %{event: "action", payload: %{"intent" => "archive_dialog"}}
            ]}
          />
        </:action>
      </Widgets.dialog>
    </Widgets.vbox>
    """
  end

  defp direct_data_widget_screen(assigns) do
    ~H"""
    <Widgets.vbox id="data-root" gap={2}>
      <Widgets.gauge id="system-load" label="System Load" value={62} />
      <Widgets.bar_chart
        id="deploy-chart"
        title="Deploys"
        data={[
          %{"label" => "Mon", "value" => 3},
          %{"label" => "Tue", "value" => 5}
        ]}
      />
      <Widgets.canvas
        id="job-canvas"
        title="Topology"
        operations={[
          %{"op" => "rect", "x" => 10, "y" => 12, "width" => 40, "height" => 20}
        ]}
      />
      <Widgets.log_viewer
        id="logs"
        filter="error"
        lines={["error one"]}
        source="app.log"
        signal_bindings={[
          %{event: "on_change", payload: %{"intent" => "filter_logs"}},
          %{event: "action", payload: %{"intent" => "refresh_logs"}}
        ]}
      />
      <Widgets.process_monitor
        id="processes"
        node="demo@127.0.0.1"
        processes={[%{"pid" => "#PID<0.10.0>", "name" => "worker"}]}
        selected_pid="#PID<0.10.0>"
        signal_bindings={[
          %{event: "on_process_select", payload: %{"intent" => "select_process"}}
        ]}
      />
      <Widgets.toast id="saved-toast" message="Saved" />
    </Widgets.vbox>
    """
  end
end
