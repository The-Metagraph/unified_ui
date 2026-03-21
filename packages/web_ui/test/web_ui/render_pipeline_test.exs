defmodule WebUi.RenderPipelineTest do
  use ExUnit.Case, async: true

  test "server view state produces a deterministic foundational render tree" do
    screen =
      WebUi.Widgets.screen("native-workspace", "Native Workspace", [
        WebUi.Widgets.content("workspace-header", [
          WebUi.Widgets.text("workspace-title", "Workspace"),
          WebUi.Widgets.tabs(
            "workspace-tabs",
            [
              [id: :overview, label: "Overview", active: true],
              [id: :activity, label: "Activity"]
            ],
            active_item: :overview,
            on_navigate: %{intent: :switch_tab}
          )
        ]),
        WebUi.Widgets.form("workspace-form", [
          WebUi.Widgets.field_group("query-group", [
            WebUi.Widgets.field(
              "query-field",
              WebUi.Widgets.text_input("query-input",
                name: :query,
                value: "Pascal",
                on_focus: %{intent: :focus_query},
                on_change: %{intent: :rename_query}
              ),
              name: :query,
              label: "Search Query",
              help: "Used for preview filtering"
            )
          ])
        ])
      ])

    assert {:ok, state} = WebUi.Runtime.mount_native_screen(screen)

    payload = WebUi.ServerRuntime.frontend_payload(state)
    input_node = find_node(payload.tree, "query-input")

    assert payload.tree.dom.tag == "div"
    assert input_node.dom.tag == "input"
    assert input_node.interactions.focusable?
    assert input_node.interactions.editable?
    assert input_node.diagnostics.event_names == [:change, :focus]
  end

  test "frontend realization layers bounded browser state onto the server render tree" do
    screen =
      WebUi.Widgets.screen("native-dashboard", "Native Dashboard", [
        WebUi.Widgets.text_input("query-input",
          name: :query,
          value: "",
          on_focus: %{intent: :focus_query}
        )
      ])

    assert {:ok, state} = WebUi.Runtime.mount_native_screen(screen)
    assert {:ok, model} = WebUi.Runtime.hydrate_frontend(state)

    assert find_node(model.tree, "query-input").browser.focused? == false

    assert {:ok, focused_model} =
             WebUi.FrontendRuntime.put_local_state(model, :focused_id, "query-input")

    assert {:ok, editing_model} =
             WebUi.FrontendRuntime.put_local_state(focused_model, :editing_ids, ["query-input"])

    query_node = find_node(editing_model.tree, "query-input")

    assert query_node.tag == "input"
    assert query_node.browser.focused?
    assert query_node.browser.editing?
    assert editing_model.render_tree == model.render_tree
  end

  test "advanced widgets reuse the same server and frontend render pipeline" do
    screen =
      WebUi.Widgets.screen("ops-dashboard", "Ops Dashboard", [
        WebUi.Widgets.table(
          "cluster-table",
          [[id: :name, label: "Name"], [id: :status, label: "Status"]],
          [[id: "node-a", cells: ["Node A", "healthy"]]],
          on_sort: %{intent: :sort_cluster}
        ),
        WebUi.Widgets.progress("deploy-progress", current: 3, total: 5, label: "Deploy"),
        WebUi.Widgets.command_palette(
          "ops-command-palette",
          [[id: :restart, label: "Restart Node"]],
          placeholder: "Run command",
          on_command: %{intent: :run_command}
        )
      ])

    assert {:ok, state} = WebUi.Runtime.mount_native_screen(screen)

    payload = WebUi.ServerRuntime.frontend_payload(state)
    table_node = find_node(payload.tree, "cluster-table")
    progress_node = find_node(payload.tree, "deploy-progress")
    palette_node = find_node(payload.tree, "ops-command-palette")

    assert table_node.dom.tag == "table"
    assert table_node.dom.role == "grid"
    assert progress_node.dom.tag == "progress"
    assert progress_node.dom.attributes.value == 3
    assert progress_node.dom.attributes.max == 5
    assert palette_node.dom.role == "combobox"
    assert palette_node.interactions.focusable?
    assert palette_node.interactions.editable?

    assert {:ok, model} = WebUi.Runtime.hydrate_frontend(state)

    assert find_node(model.tree, "ops-command-palette").browser.focusable?
    assert find_node(model.tree, "cluster-table").tag == "table"
  end

  test "display systems and layered widgets reuse the same render and realization flow" do
    overlay =
      WebUi.Layer.overlay(
        "ops-overlay",
        WebUi.Layout.split_pane(
          "ops-split",
          WebUi.Layout.viewport(
            "log-viewport",
            WebUi.Widgets.log_viewer(
              "ops-log-viewer",
              [[id: "entry-1", message: "Connected", severity: :info]],
              follow: true
            ),
            offset: {0, 120},
            on_scroll: %{intent: :scroll_logs}
          ),
          WebUi.Widgets.content("details-panel", [
            WebUi.Widgets.text("details-title", "Details")
          ]),
          ratio: 0.6,
          on_resize: %{intent: :resize_split}
        ),
        [
          WebUi.Layer.dialog(
            "inspect-dialog",
            WebUi.Widgets.content("dialog-content", [
              WebUi.Widgets.text("dialog-copy", "Inspect node")
            ]),
            title: "Inspect Node",
            modal: true
          )
        ],
        on_dismiss: %{intent: :dismiss_overlay}
      )

    screen = WebUi.Widgets.screen("ops-surface", "Ops Surface", [overlay])

    assert {:ok, state} = WebUi.Runtime.mount_native_screen(screen)

    payload = WebUi.ServerRuntime.frontend_payload(state)
    overlay_node = find_node(payload.tree, "ops-overlay")
    viewport_node = find_node(payload.tree, "log-viewport")
    dialog_node = find_node(payload.tree, "inspect-dialog")

    assert overlay_node.dom.role == "presentation"
    assert overlay_node.interactions.interactive?
    assert viewport_node.dom.role == "region"
    assert viewport_node.attributes.offset == %{x: 0, y: 120}
    assert dialog_node.dom.tag == "dialog"
    assert dialog_node.dom.attributes.modal

    assert {:ok, model} = WebUi.Runtime.hydrate_frontend(state)

    assert find_node(model.tree, "inspect-dialog").browser.focusable?
    assert find_node(model.tree, "log-viewport").tag == "div"
  end

  defp find_node(node, id) when is_map(node) do
    if node.id == id do
      node
    else
      node.slots
      |> Enum.flat_map(& &1.children)
      |> Enum.find_value(&find_node(&1, id))
    end
  end

  defp find_node(nil, _id), do: nil
end
