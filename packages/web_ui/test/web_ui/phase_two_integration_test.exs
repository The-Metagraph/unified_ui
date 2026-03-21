defmodule WebUi.PhaseTwoIntegrationTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Element

  test "foundational native screens hydrate and preserve bounded frontend behavior" do
    assert {:ok, runtime_state} =
             WebUi.Runtime.mount_native_screen(WebUi.Examples.native_foundational_screen())

    assert {:ok, frontend_model} = WebUi.Runtime.hydrate_frontend(runtime_state)

    tabs = find_node(frontend_model.tree, "workspace-tabs")
    input = find_node(frontend_model.tree, "query-input")

    assert runtime_state.source_kind == :native
    assert tabs.browser.navigable?
    assert input.browser.editable?

    assert {:ok, focused_model} =
             WebUi.FrontendRuntime.put_local_state(frontend_model, :focused_id, "query-input")

    assert find_node(focused_model.tree, "query-input").browser.focused?
    assert focused_model.render_tree == frontend_model.render_tree
  end

  test "canonical foundational screens reuse the same runtime and preserve continuity" do
    assert {:ok, runtime_state} =
             WebUi.Runtime.mount_iur_screen(WebUi.Examples.canonical_foundational_screen())

    assert {:ok, frontend_model} = WebUi.Runtime.hydrate_frontend(runtime_state)

    comparison = WebUi.Examples.foundational_comparison()

    assert runtime_state.boundary_mode == :canonical_boundary
    assert find_node(frontend_model.tree, "workspace-actions").tag == "div"
    assert comparison.continuity.widget_kinds_match?
    assert comparison.continuity.render_tags_match?
    assert "query-input" in comparison.continuity.shared_ids
    assert "save-button" in comparison.continuity.shared_ids
  end

  test "unsupported canonical inputs fail with coverage-oriented diagnostics" do
    unsupported =
      Element.new(:widget, :dialog,
        id: "dialog-root",
        attributes: %{title: "Unsupported"}
      )

    assert {:error,
            %WebUi.ServerRuntime.Error{reason: :invalid_canonical_screen, details: details}} =
             WebUi.Runtime.mount_iur_screen(unsupported)

    assert details.renderer_code == :unsupported_kind
    assert details.renderer_details.kind == :dialog
    assert :text_input in details.renderer_details.supported_kinds
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
