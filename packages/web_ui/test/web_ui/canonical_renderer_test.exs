defmodule WebUi.CanonicalRendererTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.{Canvas, Forms, Layer, Layout, Viewport}
  alias UnifiedIUR.Widgets.{Advanced, Data, Feedback, Foundational, Input}

  test "canonical foundational structures map into the native web_ui widget model" do
    canonical =
      Layout.column(
        [
          Foundational.text("Workspace", id: "workspace-title"),
          Forms.form_builder(
            [
              Forms.field_group(
                [
                  Forms.field(
                    Input.text_input(
                      id: "query-input",
                      name: :query,
                      value: "Pascal",
                      placeholder: "Search"
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
            id: "workspace-form"
          )
        ],
        id: "workspace-layout",
        gap: :lg
      )

    assert {:ok, [%WebUi.Widget{kind: :column} = root]} = WebUi.Renderer.render(canonical)

    assert Enum.map(root.slots.default, & &1.id) == ["workspace-title", "workspace-form"]

    input_widget = find_widget([root], "query-input")

    assert input_widget.kind == :text_input
    assert input_widget.props.name == :query
    assert input_widget.props.value == "Pascal"
  end

  test "canonical view state reuses the same split runtime path as native screens" do
    canonical =
      Layout.column(
        [
          Foundational.text("Workspace", id: "workspace-title"),
          Input.checkbox(id: "alerts-checkbox", name: :alerts, value: true, label_text: "Alerts")
        ],
        id: "workspace-layout"
      )

    assert {:ok, view_state} =
             WebUi.Renderer.render_view_state(canonical,
               screen_id: :canonical_workspace,
               title: "Canonical Workspace"
             )

    assert view_state.screen.mode == :canonical
    assert view_state.screen.id == :canonical_workspace

    assert {:ok, envelope} = WebUi.Server.Sync.outbound(view_state, kind: :hydrate)
    assert {:ok, model} = WebUi.Frontend.ingest_sync(envelope)

    assert model.screen_id == :canonical_workspace
    assert find_node(model.frontend_tree, "alerts-checkbox").tag == "input"
  end

  test "advanced canonical widgets, display systems, and layers reuse the native web_ui model" do
    canonical =
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
                ]
              ],
              id: "ops-log-viewer"
            ),
            id: "log-viewport",
            offset: {0, 240},
            sync_group: :logs
          ),
          Layout.grid(
            [
              Data.table(
                [
                  [id: :name, label: "Name"],
                  [id: :status, label: "Status"]
                ],
                [
                  [id: "node-a", cells: ["Node A", "healthy"]]
                ],
                id: "cluster-table"
              ),
              Canvas.bar_chart(
                [
                  [id: :requests, label: "Requests", values: [12, 18, 16]]
                ],
                id: "requests-chart"
              ),
              Feedback.progress(id: "deploy-progress", current: 3, total: 5, label: "Deploy")
            ],
            id: "details-grid",
            columns: 2,
            gap: 2
          ),
          id: "operations-split",
          ratio: 0.65,
          sync_scroll: :logs
        ),
        [
          Layer.dialog(
            Foundational.content([Foundational.text("Inspect node", id: "dialog-copy")],
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
      )

    assert {:ok, [%WebUi.Widget{kind: :overlay} = root]} = WebUi.Renderer.render(canonical)

    assert find_widget([root], "log-viewport").kind == :viewport
    assert find_widget([root], "cluster-table").kind == :table
    assert find_widget([root], "requests-chart").kind == :bar_chart
    assert find_widget([root], "inspect-dialog").kind == :dialog
  end

  test "advanced canonical view state preserves display and layer semantics through the split runtime" do
    canonical =
      Layer.overlay(
        Layout.split_pane(
          Viewport.region(
            Advanced.log_viewer(
              [
                [id: "log-1", message: "Accepted connection", severity: :info]
              ],
              id: "ops-log-viewer"
            ),
            id: "log-viewport",
            offset: {0, 240},
            sync_group: :logs
          ),
          Foundational.content([Foundational.text("Node details", id: "details-copy")],
            id: "details-panel"
          ),
          id: "operations-split",
          ratio: 0.65
        ),
        [
          Layer.dialog(
            Foundational.content([Foundational.text("Inspect node", id: "dialog-copy")],
              id: "dialog-content"
            ),
            id: "inspect-dialog",
            title: "Inspect Node"
          )
        ],
        id: "operations-overlay",
        focus_scope: :workspace_modal
      )

    assert {:ok, view_state} =
             WebUi.Renderer.render_view_state(canonical,
               screen_id: :canonical_operations,
               title: "Canonical Operations"
             )

    assert view_state.screen.mode == :canonical

    assert find_node(view_state.render_tree, "log-viewport").semantics.display.offset == %{
             x: 0,
             y: 240
           }

    assert {:ok, envelope} = WebUi.Server.Sync.outbound(view_state, kind: :hydrate)
    assert {:ok, model} = WebUi.Frontend.ingest_sync(envelope)

    assert {:ok, model} =
             WebUi.Frontend.put_local(model, :viewport_offsets, %{
               "log-viewport" => %{x: 0, y: 320}
             })

    assert {:ok, model} =
             WebUi.Frontend.put_local(model, :split_ratios, %{"operations-split" => 0.72})

    viewport_browser = find_node(model.frontend_tree, "log-viewport").browser
    split_browser = find_node(model.frontend_tree, "operations-split").browser
    overlay_browser = find_node(model.frontend_tree, "operations-overlay").browser

    assert viewport_browser.viewport.offset == %{x: 0, y: 320}
    assert split_browser.split.ratio == 0.72
    assert overlay_browser.layer.focus_scope == :workspace_modal
  end

  test "unsupported canonical kinds fail with structured coverage diagnostics" do
    unsupported = Input.numeric_input(id: "age-input", name: :age, value: 42)

    assert {:error, %WebUi.Renderer.Error{code: :unsupported_kind, details: details}} =
             WebUi.Renderer.render(unsupported)

    assert details.kind == :numeric_input
    assert :text_input in details.supported_kinds
  end

  defp find_widget(widgets, id) when is_list(widgets) do
    Enum.find_value(widgets, fn widget ->
      if widget.id == id do
        widget
      else
        widget.slots
        |> Map.values()
        |> List.flatten()
        |> find_widget(id)
      end
    end)
  end

  defp find_widget(nil, _id), do: nil

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
