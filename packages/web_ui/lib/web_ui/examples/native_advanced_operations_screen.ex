defmodule WebUi.Examples.NativeAdvancedOperationsScreen do
  @moduledoc """
  Review-friendly direct-native advanced operations screen covering display
  systems, layered composition, data views, and visualization widgets.
  """

  use WebUi.Server.Screen, id: :native_advanced_operations, title: "Native Advanced Operations"

  alias WebUi.Widgets.{Data, Feedback, Foundational, Operational, Visualization}

  @impl true
  def mount_defaults do
    %{dialog_open?: true, active_filter: :healthy, command_query: "deploy"}
  end

  @impl true
  def event_routes do
    %{
      "dismiss_overlay" => :dismiss_overlay,
      "sort_cluster" => :sort_cluster,
      "run_command" => :run_command
    }
  end

  @impl true
  def view(assigns) do
    viewport =
      WebUi.Layout.viewport(
        Data.log_viewer(
          [
            [
              id: "log-1",
              message: "Accepted connection",
              severity: :info,
              timestamp: "2026-03-14T10:00:00Z"
            ],
            [
              id: "log-2",
              message: "Replica promoted",
              severity: :warning,
              timestamp: "2026-03-14T10:02:00Z"
            ]
          ],
          id: "ops-log-viewer"
        ),
        id: "log-viewport",
        offset: {0, 240},
        height: 24,
        width: 80,
        sync_group: :logs
      )

    operations_grid =
      WebUi.Layout.grid(
        [
          Data.table(
            [
              [id: :name, label: "Name", sortable?: true],
              [id: :status, label: "Status"],
              [id: :latency, label: "Latency"]
            ],
            [
              [id: "node-a", cells: ["Node A", "healthy", "82ms"], selected?: true],
              [id: "node-b", cells: ["Node B", "degraded", "141ms"]]
            ],
            id: "cluster-table",
            sort_key: :name,
            sort_direction: :asc,
            filters: [[field: :status, operator: :eq, value: assigns.active_filter]],
            sort: "sort_cluster"
          ),
          Visualization.bar_chart(
            [
              [id: :requests, label: "Requests", values: [12, 18, 16]],
              [id: :errors, label: "Errors", values: [1, 0, 2]]
            ],
            id: "requests-chart"
          ),
          Feedback.progress(
            id: "deploy-progress",
            current: 3,
            total: 5,
            label: "Deploy"
          ),
          Operational.cluster_dashboard(
            [
              [id: "node-a", status: :healthy],
              [id: "node-b", status: :degraded]
            ],
            id: "cluster-dashboard",
            summary: %{healthy: 1, degraded: 1}
          ),
          Operational.command_palette(
            [
              [id: :deploy, label: "Deploy", value: :deploy],
              [id: :rollback, label: "Rollback", value: :rollback]
            ],
            id: "ops-command-palette",
            query: assigns.command_query,
            command: "run_command"
          ),
          Visualization.canvas(
            [
              [kind: :cell, position: {0, 0}, text: "A", style_refs: [:accent]],
              [kind: :cell, position: {1, 0}, text: "B"]
            ],
            id: "cluster-canvas",
            width: 20,
            height: 10
          )
        ],
        id: "operations-grid",
        columns: 2,
        gap: :lg
      )

    split =
      WebUi.Layout.split_pane(
        viewport,
        operations_grid,
        id: "operations-split",
        ratio: 0.65,
        sync_scroll: :logs
      )

    dialog =
      WebUi.Layer.dialog(
        Foundational.content(
          [
            Foundational.text("Inspect node", id: "dialog-title"),
            Feedback.status("Node A is healthy", id: "dialog-status", severity: :info)
          ],
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
      WebUi.Layout.stack(
        [
          overlay,
          WebUi.Layout.scroll_bar(
            id: "log-scrollbar",
            viewport_ref: "log-viewport",
            viewport_size: 24,
            content_size: 120,
            sync_group: :logs
          )
        ],
        id: "operations-root",
        stacking: :flow
      )
    ]
  end

  @impl true
  def handle_event(:dismiss_overlay, _payload, assigns) do
    {:ok, %{assigns | dialog_open?: false}}
  end

  def handle_event(:sort_cluster, _payload, assigns), do: {:ok, assigns}
  def handle_event(:run_command, _payload, assigns), do: {:ok, assigns}

  @impl true
  def frontend_boot do
    %{entry: :native_advanced_operations, comparable_to: :canonical_advanced_operations}
  end

  def metadata do
    %{
      id: :native_advanced_operations,
      title: title(),
      families: [:data, :document, :feedback, :visualization, :operational, :layout, :layer],
      comparable_to: :canonical_advanced_operations,
      summary: "Direct-native advanced operations workspace for layered review."
    }
  end
end
