defmodule WebUi.Examples.CanonicalAdvancedOperationsScreen do
  @moduledoc """
  Canonical advanced operations example rendered through the `web_ui` advanced
  renderer and runtime.
  """

  alias UnifiedIUR.{Canvas, Layer, Layout, Viewport}
  alias UnifiedIUR.Widgets.{Advanced, Data, Feedback, Foundational}

  @spec element() :: UnifiedIUR.Element.t()
  def element do
    Layout.stack(
      [
        Layer.overlay(
          Layout.split_pane(
            Viewport.region(
              Advanced.log_viewer(
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
            ),
            Layout.grid(
              [
                Data.table(
                  [
                    [id: :name, label: "Name"],
                    [id: :status, label: "Status"],
                    [id: :latency, label: "Latency"]
                  ],
                  [
                    [id: "node-a", cells: ["Node A", "healthy", "82ms"]],
                    [id: "node-b", cells: ["Node B", "degraded", "141ms"]]
                  ],
                  id: "cluster-table"
                ),
                Canvas.bar_chart(
                  [
                    [id: :requests, label: "Requests", values: [12, 18, 16]],
                    [id: :errors, label: "Errors", values: [1, 0, 2]]
                  ],
                  id: "requests-chart"
                ),
                Feedback.progress(id: "deploy-progress", current: 3, total: 5, label: "Deploy"),
                Advanced.cluster_dashboard(
                  [
                    [id: "node-a", status: :healthy],
                    [id: "node-b", status: :degraded]
                  ],
                  id: "cluster-dashboard",
                  summary: %{healthy: 1, degraded: 1}
                ),
                Advanced.command_palette(
                  [
                    [id: :deploy, label: "Deploy", value: :deploy],
                    [id: :rollback, label: "Rollback", value: :rollback]
                  ],
                  id: "ops-command-palette",
                  query: "deploy"
                ),
                Canvas.surface(
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
              gap: 2
            ),
            id: "operations-split",
            ratio: 0.65,
            sync_scroll: :logs
          ),
          [
            Layer.dialog(
              Foundational.content(
                [
                  Foundational.text("Inspect node", id: "dialog-title"),
                  Feedback.status("Node A is healthy", id: "dialog-status", severity: :info)
                ],
                id: "dialog-content"
              ),
              id: "inspect-dialog",
              title: "Inspect Node"
            ),
            Layer.toast(Foundational.text("Deploy complete", id: "toast-copy"),
              id: "deploy-toast",
              severity: :info
            )
          ],
          id: "operations-overlay",
          focus_scope: :workspace_modal
        ),
        Viewport.scroll_bar(
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
  end

  @spec render_view_state(keyword()) ::
          {:ok, WebUi.Server.ViewState.t()}
          | {:error, WebUi.Renderer.Error.t() | WebUi.Server.Error.t()}
  def render_view_state(opts \\ []) do
    WebUi.Renderer.render_view_state(
      element(),
      Keyword.merge(
        [screen_id: :canonical_advanced_operations, title: "Canonical Advanced Operations"],
        opts
      )
    )
  end

  def metadata do
    %{
      id: :canonical_advanced_operations,
      title: "Canonical Advanced Operations",
      families: [:data, :document, :feedback, :visualization, :operational, :layout, :layer],
      comparable_to: :native_advanced_operations,
      summary: "Canonical advanced operations workspace rendered through web_ui."
    }
  end
end
