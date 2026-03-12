defmodule LiveUi.RuntimeTest do
  use ExUnit.Case, async: true

  alias Jido.Signal
  alias LiveUi.ConfigurationError
  alias LiveUi.Runtime
  alias LiveUi.Runtime.Model
  alias LiveUi.Descriptor
  alias LiveUi.TestSupport.CounterScreen
  alias LiveUi.TestSupport.InvalidScreen
  alias LiveUi.TestSupport.InvalidIurScreen
  alias LiveUi.TestSupport.RawIur

  test "initializes the runtime model from a valid source module" do
    assert {:ok, %Model{} = model} =
             Runtime.init(
               source: CounterScreen,
               source_opts: [count: 2, mount_token: "boot-1"],
               runtime_context: %{request_id: "req-1"}
             )

    assert model.status == :ready
    assert model.source.module == CounterScreen
    assert model.screen_state == %{count: 2, initialized?: true, mount_token: "boot-1"}

    assert model.iur_tree == %{
             id: "counter-root",
             kind: "vbox",
             spacing: 2,
             meta: %{initialized?: true, mount_token: "boot-1"},
             children: [
               %{
                 id: "counter-label",
                 kind: "text",
                 content: "Count: 2",
                 style: %{class: "counter-value"}
               },
               %{
                 id: "increment-button",
                 kind: "button",
                 label: "Increment",
                 on_click: %{intent: "activate", payload: %{delta: 1}}
               }
             ]
           }

    assert model.descriptor_tree.kind == "vbox"
    assert Enum.map(model.descriptor_tree.children, & &1.kind) == ["text", "button"]

    assert model.signal_bindings == [
             %{
               event: "on_click",
               widget_id: "increment-button",
               widget_kind: "button",
               payload: %{"intent" => "activate", "payload" => %{"delta" => 1}}
             }
           ]

    assert model.render_metadata == %{node_count: 3, root_id: "counter-root", root_kind: "vbox"}
    assert model.widget_state == %{}
    assert model.runtime_context == %{request_id: "req-1"}
  end

  test "encodes liveview event payloads as concrete jido signals" do
    {:ok, model} =
      Runtime.init(
        source: CounterScreen,
        source_opts: [count: 1],
        runtime_context: %{signal_source: "/host/live_ui", request_id: "req-2"}
      )

    assert {:ok, %Model{} = updated_model} =
             Runtime.handle_event(model, "click", %{
               "delta" => "3",
               "intent" => "activate",
               "widget_id" => "increment-button",
               "widget_kind" => "button"
             })

    assert updated_model.event_count == 1
    assert updated_model.screen_state.count == 4
    assert %Signal{} = updated_model.last_signal
    assert updated_model.last_signal.type == "live_ui.button.activate"
    assert updated_model.last_signal.source == "/host/live_ui"
    assert updated_model.last_signal.subject == "increment-button"

    assert updated_model.last_signal.data == %{
             intent: "activate",
             payload: %{"delta" => "3"},
             runtime_context: %{signal_source: "/host/live_ui", request_id: "req-2"},
             widget_id: "increment-button",
             widget_kind: "button"
           }

    assert hd(updated_model.descriptor_tree.children).props["content"] == "Count: 4"
  end

  test "initializes the runtime model from a canonical raw iur tree" do
    assert {:ok, %Model{} = model} =
             Runtime.init(
               iur: RawIur.counter_tree(8),
               runtime_context: %{request_id: "req-iur-1"}
             )

    assert model.status == :ready
    assert model.source.kind == :iur
    assert model.source.iur == RawIur.counter_tree(8)
    assert model.screen_state == %{}
    assert model.iur_tree == RawIur.counter_tree(8)
    assert model.descriptor_tree.id == "counter-root"
    assert model.descriptor_tree.kind == "vbox"
    assert Enum.map(model.descriptor_tree.children, & &1.kind) == ["text", "button"]

    assert model.render_metadata == %{
             node_count: 3,
             root_id: "counter-root",
             root_kind: "vbox"
           }
  end

  test "raw iur sources keep the canonical tree stable while recording accepted events" do
    {:ok, model} =
      Runtime.init(
        iur: RawIur.counter_tree(2),
        runtime_context: %{signal_source: "/dynamic/live_ui"}
      )

    assert {:ok, %Model{} = updated_model} =
             Runtime.handle_event(model, "click", %{
               "intent" => "activate",
               "widget_id" => "increment-button",
               "widget_kind" => "button"
             })

    assert updated_model.event_count == 1
    assert updated_model.screen_state == %{}
    assert updated_model.iur_tree == RawIur.counter_tree(2)
    assert updated_model.descriptor_tree.id == "counter-root"
    assert updated_model.last_signal.type == "live_ui.button.activate"
    assert hd(updated_model.descriptor_tree.children).props["content"] == "Count: 2"
  end

  test "advanced widget interactions update server-authoritative widget state overlays" do
    {:ok, model} = Runtime.init(iur: RawIur.stateful_tree(), runtime_context: %{})

    {:ok, tabs_model} =
      Runtime.handle_event(model, "click", %{
        "widget_id" => "tabs-1",
        "widget_kind" => "tabs",
        "event_click_intent" => "switch_tab",
        "event_click_tab_id" => "details",
        "event_click_tab_index" => "1"
      })

    assert tabs_model.widget_state["tabs-1"] == %{
             "active_tab" => "details",
             "active_tab_index" => 1
           }

    assert find_descriptor!(tabs_model.descriptor_tree, "tabs-1").props["active_tab"] == "details"

    {:ok, viewport_model} =
      Runtime.handle_event(tabs_model, "scroll", %{
        "widget_id" => "viewport-1",
        "widget_kind" => "viewport",
        "event_scroll_intent" => "sync_scroll",
        "event_scroll_axis" => "both",
        "event_scroll_json_position" => Jason.encode!(%{"top" => 25, "left" => 4})
      })

    assert viewport_model.widget_state["viewport-1"] == %{
             "axis" => "both",
             "scroll_left" => 4,
             "scroll_top" => 25
           }

    assert find_descriptor!(viewport_model.descriptor_tree, "viewport-1").props["scroll_top"] ==
             25

    {:ok, split_model} =
      Runtime.handle_event(viewport_model, "resize", %{
        "widget_id" => "split-1",
        "widget_kind" => "split_pane",
        "event_resize_intent" => "resize",
        "event_resize_json_sizes" => Jason.encode!([40, 60]),
        "event_resize_orientation" => "vertical"
      })

    assert split_model.widget_state["split-1"] == %{
             "orientation" => "vertical",
             "sizes" => [40, 60]
           }

    assert find_descriptor!(split_model.descriptor_tree, "split-1").props["sizes"] == [40, 60]

    {:ok, table_model} =
      Runtime.handle_event(split_model, "click", %{
        "widget_id" => "users-table",
        "widget_kind" => "table",
        "event_click_intent" => "select_row",
        "event_click_row_id" => "user-1",
        "event_click_row_index" => "0",
        "event_click_sort_column" => "name",
        "event_click_direction" => "asc"
      })

    assert table_model.widget_state["users-table"] == %{
             "selected_row_id" => "user-1",
             "selected_row_index" => 0,
             "sort_column" => "name",
             "sort_direction" => "asc"
           }

    assert find_descriptor!(table_model.descriptor_tree, "users-table").props["selected_row_id"] ==
             "user-1"

    {:ok, tree_model} =
      Runtime.handle_event(table_model, "click", %{
        "widget_id" => "tree-node-1",
        "widget_kind" => "tree_node",
        "event_click_intent" => "toggle_node",
        "event_click_node_id" => "tree-node-1",
        "event_click_expanded" => "true"
      })

    assert tree_model.widget_state["tree-node-1"] == %{
             "expanded" => false,
             "node_id" => "tree-node-1",
             "selected" => true
           }

    assert find_descriptor!(tree_model.descriptor_tree, "tree-node-1").props["expanded"] == false

    {:ok, palette_model} =
      Runtime.handle_event(tree_model, "change", %{
        "widget_id" => "palette-1",
        "widget_kind" => "command_palette",
        "event_change_intent" => "update_query",
        "query" => "dep",
        "active_command_id" => "deploy",
        "open" => "true"
      })

    assert palette_model.widget_state["palette-1"] == %{
             "active_command_id" => "deploy",
             "open" => true,
             "query" => "dep"
           }

    assert find_descriptor!(palette_model.descriptor_tree, "palette-1").props["query"] == "dep"

    {:ok, logs_model} =
      Runtime.handle_event(palette_model, "change", %{
        "widget_id" => "logs",
        "widget_kind" => "log_viewer",
        "event_change_intent" => "filter_logs",
        "filter" => "error"
      })

    assert logs_model.widget_state["logs"] == %{"filter" => "error"}
    assert find_descriptor!(logs_model.descriptor_tree, "logs").props["filter"] == "error"

    {:ok, processes_model} =
      Runtime.handle_event(logs_model, "click", %{
        "widget_id" => "processes",
        "widget_kind" => "process_monitor",
        "event_click_intent" => "select_process",
        "event_click_name" => "worker",
        "event_click_pid" => "#PID<0.10.0>"
      })

    assert processes_model.widget_state["processes"] == %{
             "selected_pid" => "#PID<0.10.0>",
             "selected_process_name" => "worker"
           }

    assert find_descriptor!(processes_model.descriptor_tree, "processes").props["selected_pid"] ==
             "#PID<0.10.0>"
  end

  test "accepts passthrough jido signals without rebuilding metadata from the payload" do
    {:ok, model} =
      Runtime.init(source: CounterScreen, source_opts: [count: 5], runtime_context: %{})

    {:ok, signal} =
      Signal.new(%{
        type: "live_ui.button.increment",
        data: %{payload: %{"delta" => 2}, widget_id: "increment-button", widget_kind: "button"},
        source: "/host/live_ui",
        subject: "increment-button"
      })

    assert {:ok, %Model{} = updated_model} =
             Runtime.handle_event(model, "ignored", %{"signal" => signal})

    assert updated_model.screen_state.count == 7
    assert updated_model.last_signal == signal
    assert updated_model.screen_state.last_signal_type == "live_ui.button.increment"
    assert hd(updated_model.descriptor_tree.children).props["content"] == "Count: 7"
  end

  test "rejects event payloads missing required widget metadata" do
    {:ok, model} = Runtime.init(source: CounterScreen, source_opts: [], runtime_context: %{})

    assert {:error, %ConfigurationError{} = error} =
             Runtime.handle_event(model, "click", %{"delta" => 1, "widget_kind" => "button"})

    assert error.message =~ "missing required metadata"
    assert error.details.field == "widget_id"
  end

  test "returns configuration errors for invalid source modules" do
    assert {:error, %ConfigurationError{} = error} =
             Runtime.init(source: InvalidScreen, source_opts: [], runtime_context: %{})

    assert error.message =~ "missing required callbacks"
  end

  test "returns interpreter failures when the source emits an unsupported node kind" do
    assert {:error, %ConfigurationError{} = error} =
             Runtime.init(source: InvalidIurScreen, source_opts: [], runtime_context: %{})

    assert error.message =~ "unsupported"
  end

  test "rejects runtime initialization when both source and iur are provided" do
    assert {:error, %ConfigurationError{} = error} =
             Runtime.init(source: CounterScreen, iur: RawIur.counter_tree(), runtime_context: %{})

    assert error.message =~ "either :source or :iur, not both"
  end

  defp find_descriptor!(%Descriptor{id: id} = descriptor, id), do: descriptor

  defp find_descriptor!(%Descriptor{} = descriptor, id) do
    Enum.find_value(descriptor.children, &find_descriptor(&1, id)) ||
      raise "descriptor #{id} not found"
  end

  defp find_descriptor(%Descriptor{id: id} = descriptor, id), do: descriptor

  defp find_descriptor(%Descriptor{} = descriptor, id) do
    Enum.find_value(descriptor.children, &find_descriptor(&1, id))
  end
end
