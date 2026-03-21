defmodule WebUi.PhaseThreeIntegrationTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Element

  test "advanced native screens hydrate and preserve bounded browser-local behavior" do
    assert {:ok, runtime_state} =
             WebUi.Runtime.mount_native_screen(WebUi.Examples.native_advanced_screen())

    assert {:ok, frontend_model} = WebUi.Runtime.hydrate_frontend(runtime_state)

    viewport = find_node(frontend_model.tree, "log-viewport")
    palette = find_node(frontend_model.tree, "ops-command-palette")
    dialog = find_node(frontend_model.tree, "inspect-dialog")
    scroll_bar = find_node(frontend_model.tree, "log-scrollbar")

    assert runtime_state.source_kind == :native
    assert viewport.role == "region"
    assert palette.browser.editable?
    assert dialog.tag == "dialog"
    assert scroll_bar.role == "scrollbar"

    assert {:ok, focused_model} =
             WebUi.FrontendRuntime.put_local_state(
               frontend_model,
               :focused_id,
               "ops-command-palette"
             )

    assert find_node(focused_model.tree, "ops-command-palette").browser.focused?
    assert focused_model.render_tree == frontend_model.render_tree
  end

  test "invalid advanced widget and display wiring fails with actionable diagnostics" do
    viewport =
      WebUi.Layout.viewport(
        "primary-viewport",
        WebUi.Widgets.content("primary-content", [WebUi.Widgets.text("copy", "Primary")])
      )

    content =
      WebUi.Widgets.content("secondary-content", [
        WebUi.Widgets.text("secondary-copy", "Secondary")
      ])

    assert_raise ArgumentError,
                 ~r/split_pane widgets require both panes to be :viewport widgets when :sync_scroll is true/,
                 fn ->
                   WebUi.Layout.split_pane("invalid-sync", viewport, content, sync_scroll: true)
                 end
  end

  test "advanced canonical screens reuse native widget and layer realization" do
    assert {:ok, runtime_state} =
             WebUi.Runtime.mount_iur_screen(WebUi.Examples.canonical_advanced_screen())

    assert {:ok, frontend_model} = WebUi.Runtime.hydrate_frontend(runtime_state)

    assert runtime_state.boundary_mode == :canonical_boundary
    assert find_node(frontend_model.tree, "operations-overlay").role == "presentation"
    assert find_node(frontend_model.tree, "cluster-table").tag == "table"
    assert find_node(frontend_model.tree, "inspect-dialog").tag == "dialog"
    assert find_node(frontend_model.tree, "log-scrollbar").role == "scrollbar"
  end

  test "native and canonical advanced examples preserve continuity" do
    comparison = WebUi.Examples.advanced_comparison()

    assert comparison.continuity.widget_kinds_match?
    assert comparison.continuity.render_tags_match?
    assert comparison.continuity.display_kinds_match?
    assert comparison.continuity.layer_kinds_match?
    assert "operations-overlay" in comparison.continuity.shared_ids
    assert "log-scrollbar" in comparison.continuity.shared_ids
  end

  test "unsupported advanced canonical inputs fail deterministically with coverage diagnostics" do
    unsupported =
      Element.new(:layer, :sheet,
        id: "sheet-root",
        attributes: %{title: "Unsupported"}
      )

    assert {:error,
            %WebUi.ServerRuntime.Error{reason: :invalid_canonical_screen, details: details}} =
             WebUi.Runtime.mount_iur_screen(unsupported)

    assert details.renderer_code == :unsupported_kind
    assert details.renderer_details.kind == :sheet
    assert :overlay in details.renderer_details.supported_kinds
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
