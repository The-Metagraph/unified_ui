defmodule WebUi.RenderPipelineTest do
  use ExUnit.Case, async: true

  alias WebUi.Widgets.{Data, Feedback, Forms, Foundational, Input, Layout, Navigation}
  alias WebUi.Widgets.{Operational, Visualization}

  defmodule NativeWorkspaceScreen do
    use WebUi.Server.Screen, id: :native_workspace, title: "Native Workspace"

    @impl true
    def mount_defaults do
      %{query: "Pascal", active_tab: :overview}
    end

    @impl true
    def event_routes do
      %{"focus" => :focus_query}
    end

    @impl true
    def view(assigns) do
      header =
        Foundational.content(
          [
            Foundational.text("Workspace", id: "workspace-title"),
            Navigation.tabs(
              [
                [id: :overview, label: "Overview", active?: true],
                [id: :activity, label: "Activity"]
              ],
              id: "workspace-tabs",
              active_item: assigns.active_tab,
              navigation: "switch_tab"
            )
          ],
          id: "workspace-header",
          presentation: :banner
        )

      form =
        Forms.form_builder(
          [
            Forms.field_group(
              [
                Forms.field(
                  Input.text_input(
                    id: "query-input",
                    name: :query,
                    value: assigns.query,
                    focus: "focus",
                    change: "rename_query"
                  ),
                  id: "query-field",
                  name: :query,
                  label: "Search Query",
                  help: "Used for preview filtering"
                )
              ],
              id: "query-group",
              legend: "Search"
            )
          ],
          id: "workspace-form",
          submit: "save_workspace"
        )

      [
        Layout.column([header, form],
          id: "workspace-layout",
          gap: :lg,
          align: :stretch
        )
      ]
    end

    @impl true
    def handle_event(:focus_query, _payload, assigns) do
      {:ok, assigns}
    end
  end

  defmodule NativeOperationsScreen do
    use WebUi.Server.Screen, id: :native_operations, title: "Native Operations"

    @impl true
    def mount_defaults do
      %{filter: :healthy, command_query: "deploy"}
    end

    @impl true
    def event_routes do
      %{"sort_cluster" => :sort_cluster}
    end

    @impl true
    def view(assigns) do
      table =
        Data.table(
          [
            [id: :name, label: "Name", sortable?: true],
            [id: :status, label: "Status"]
          ],
          [
            [id: "node-a", cells: ["Node A", "healthy"], selected?: true],
            [id: "node-b", cells: ["Node B", "degraded"]]
          ],
          id: "cluster-table",
          sort_key: :name,
          sort_direction: :asc,
          filters: [[field: :status, operator: :eq, value: assigns.filter]],
          page: 1,
          page_size: 20,
          total_entries: 42,
          sort: "sort_cluster"
        )

      log_viewer =
        Data.log_viewer(
          [
            [id: "log-1", message: "Accepted connection", severity: :info]
          ],
          id: "ops-log"
        )

      command_palette =
        Operational.command_palette(
          [
            [id: :deploy, label: "Deploy", value: :deploy],
            [id: :rollback, label: "Rollback", value: :rollback]
          ],
          id: "ops-command-palette",
          query: assigns.command_query
        )

      [
        Layout.column(
          [
            Feedback.status("Cluster healthy", id: "cluster-status", severity: :info),
            table,
            log_viewer,
            Visualization.sparkline([4, 5, 7, 6], id: "cpu-sparkline"),
            command_palette
          ],
          id: "operations-layout",
          gap: :lg
        )
      ]
    end

    @impl true
    def handle_event(:sort_cluster, _payload, assigns) do
      {:ok, assigns}
    end
  end

  defmodule NativeDisplayScreen do
    use WebUi.Server.Screen, id: :native_display, title: "Native Display"

    @impl true
    def mount_defaults do
      %{dialog_open?: true}
    end

    @impl true
    def event_routes do
      %{"dismiss_overlay" => :dismiss_overlay}
    end

    @impl true
    def view(assigns) do
      viewport =
        WebUi.Layout.viewport(
          Data.log_viewer(
            [
              [id: "log-1", message: "Accepted connection", severity: :info]
            ],
            id: "ops-log-viewer"
          ),
          id: "log-viewport",
          offset: {0, 240},
          height: 24,
          width: 80,
          sync_group: :logs,
          scroll: "scroll_logs"
        )

      split =
        WebUi.Layout.split_pane(
          viewport,
          Foundational.content([Foundational.text("Node details", id: "node-details")],
            id: "details-panel"
          ),
          id: "operations-split",
          ratio: 0.65,
          sync_scroll: :logs
        )

      dialog =
        WebUi.Layer.dialog(
          Foundational.content([Foundational.text("Inspect node", id: "dialog-copy")],
            id: "dialog-content"
          ),
          id: "inspect-dialog",
          title: "Inspect Node",
          modal?: true,
          open?: assigns.dialog_open?
        )

      toast =
        WebUi.Layer.toast(
          Foundational.text("Deploy complete", id: "toast-copy"),
          id: "deploy-toast",
          severity: :info,
          open?: true
        )

      overlay =
        WebUi.Layer.overlay(split, [dialog, toast],
          id: "operations-overlay",
          focus_scope: :workspace_modal,
          open?: true,
          dismiss: "dismiss_overlay"
        )

      [
        overlay,
        WebUi.Layout.scroll_bar(
          id: "log-scrollbar",
          viewport_ref: "log-viewport",
          viewport_size: 24,
          content_size: 120,
          sync_group: :logs
        )
      ]
    end

    @impl true
    def handle_event(:dismiss_overlay, _payload, assigns) do
      {:ok, %{assigns | dialog_open?: false}}
    end
  end

  test "server view state produces a deterministic foundational render tree" do
    assert {:ok, state} = WebUi.Server.mount(NativeWorkspaceScreen)

    assert [%{id: "workspace-layout", dom: %{tag: "div"}, slots: slots}] =
             state.view_state.render_tree

    assert [%{name: :default, children: children}] = slots
    assert Enum.map(children, & &1.id) == ["workspace-header", "workspace-form"]

    input_node = find_node(state.view_state.render_tree, "query-input")

    assert input_node.dom.tag == "input"
    assert input_node.interactions.focusable?
    assert input_node.interactions.editable?
    assert input_node.diagnostics.event_names == [:change, :focus]
  end

  test "frontend realization layers bounded browser state onto the server render tree" do
    {:ok, state} = WebUi.Server.mount(NativeWorkspaceScreen)
    {:ok, envelope} = WebUi.Server.sync_envelope(state)
    {:ok, model} = WebUi.Frontend.ingest_sync(envelope)

    assert find_node(model.frontend_tree, "query-input").browser.focused? == false

    {:ok, focused_model} = WebUi.Frontend.put_local(model, :focused_widget, "query-input")

    {:ok, editing_model} =
      WebUi.Frontend.put_local(focused_model, :editing_widgets, ["query-input"])

    query_node = find_node(editing_model.frontend_tree, "query-input")

    assert query_node.tag == "input"
    assert query_node.browser.focused?
    assert query_node.browser.editing?
    assert editing_model.render_tree == model.render_tree
  end

  test "advanced widgets render deterministic semantics through the server and frontend runtime" do
    assert {:ok, state} = WebUi.Server.mount(NativeOperationsScreen)

    table_node = find_node(state.view_state.render_tree, "cluster-table")
    log_node = find_node(state.view_state.render_tree, "ops-log")
    command_palette_node = find_node(state.view_state.render_tree, "ops-command-palette")

    assert table_node.dom.tag == "table"
    assert table_node.dom.role == "table"
    assert table_node.semantics.selection_mode == :single
    assert table_node.diagnostics.content_metrics == %{columns: 2, rows: 2}
    assert log_node.dom.tag == "pre"
    assert log_node.semantics.capabilities.document?
    assert command_palette_node.interactions.editable?

    {:ok, envelope} = WebUi.Server.sync_envelope(state)
    {:ok, model} = WebUi.Frontend.ingest_sync(envelope)

    table_browser = find_node(model.frontend_tree, "cluster-table").browser

    assert table_browser.selection.selected_ids == ["node-a"]
    assert table_browser.sorting == %{key: :name, direction: :asc}
    assert table_browser.pagination == %{page: 1, page_size: 20, total_entries: 42}
  end

  test "display systems and layered widgets stay coherent across server and frontend state" do
    assert {:ok, state} = WebUi.Server.mount(NativeDisplayScreen)

    overlay_node = find_node(state.view_state.render_tree, "operations-overlay")
    viewport_node = find_node(state.view_state.render_tree, "log-viewport")
    scroll_bar_node = find_node(state.view_state.render_tree, "log-scrollbar")
    split_node = find_node(state.view_state.render_tree, "operations-split")

    assert viewport_node.dom.role == "region"
    assert viewport_node.semantics.display.offset == %{x: 0, y: 240}
    assert split_node.semantics.display.ratio == 0.65
    assert overlay_node.semantics.layer.focus_scope == :workspace_modal
    assert scroll_bar_node.dom.role == "scrollbar"

    {:ok, envelope} = WebUi.Server.sync_envelope(state)
    {:ok, model} = WebUi.Frontend.ingest_sync(envelope)

    {:ok, model} =
      WebUi.Frontend.put_local(model, :viewport_offsets, %{"log-viewport" => %{x: 0, y: 320}})

    {:ok, model} =
      WebUi.Frontend.put_local(model, :split_ratios, %{"operations-split" => 0.72})

    {:ok, model} =
      WebUi.Frontend.put_local(model, :open_layers, %{
        "operations-overlay" => true,
        "inspect-dialog" => false,
        "deploy-toast" => true
      })

    {:ok, model} = WebUi.Frontend.put_local(model, :dismissed_layers, ["deploy-toast"])

    viewport_browser = find_node(model.frontend_tree, "log-viewport").browser
    split_browser = find_node(model.frontend_tree, "operations-split").browser
    dialog_browser = find_node(model.frontend_tree, "inspect-dialog").browser
    toast_browser = find_node(model.frontend_tree, "deploy-toast").browser

    assert viewport_browser.viewport.offset == %{x: 0, y: 320}
    assert split_browser.split.ratio == 0.72
    assert dialog_browser.layer.open? == false
    assert toast_browser.layer.dismissed?
  end

  test "invalid display configuration fails with actionable diagnostics" do
    assert {:error, %WebUi.Server.Error{code: :invalid_display_configuration, details: details}} =
             WebUi.Server.ViewState.from_widgets(
               %{id: :broken_display, title: "Broken Display"},
               %{},
               [
                 %{
                   id: "broken-scroll",
                   kind: :scroll_bar,
                   props: %{sync_group: :logs}
                 }
               ],
               %{}
             )

    assert details.reason == :scroll_bar_requires_viewport_ref
    assert details.id == "broken-scroll"
  end

  defp find_node(nodes, id) when is_list(nodes) do
    Enum.find_value(nodes, fn node ->
      if node.id == id do
        node
      else
        node.slots
        |> Enum.flat_map(& &1.children)
        |> find_node(id)
      end
    end)
  end

  defp find_node(nil, _id), do: nil
end
