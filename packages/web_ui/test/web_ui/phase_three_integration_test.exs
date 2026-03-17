defmodule WebUi.PhaseThreeIntegrationTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Widgets.Data, as: CanonicalData

  alias WebUi.Examples.{
    AdvancedContinuity,
    CanonicalAdvancedOperationsScreen,
    NativeAdvancedOperationsScreen
  }

  defmodule InvalidAdvancedScreen do
    use WebUi.Server.Screen, id: :invalid_advanced, title: "Invalid Advanced"

    @impl true
    def mount_defaults, do: %{}

    @impl true
    def event_routes, do: %{}

    @impl true
    def view(_assigns) do
      [
        %{
          id: "broken-scroll",
          kind: :scroll_bar,
          props: %{sync_group: :logs}
        }
      ]
    end

    @impl true
    def handle_event(_route, _payload, assigns), do: {:ok, assigns}
  end

  test "native advanced examples render coherently through the server and frontend split" do
    assert {:ok, state} = WebUi.Server.mount(NativeAdvancedOperationsScreen)

    assert find_render_node(state.view_state.render_tree, "operations-root").kind == :stack

    assert find_render_node(state.view_state.render_tree, "operations-overlay").dom.tag ==
             "section"

    assert find_render_node(state.view_state.render_tree, "log-viewport").semantics.display.offset ==
             %{
               x: 0,
               y: 240
             }

    assert {:ok, envelope} = WebUi.Server.sync_envelope(state)
    assert {:ok, model} = WebUi.Frontend.ingest_sync(envelope)

    assert model.screen_id == :native_advanced_operations
    assert find_frontend_node(model.frontend_tree, "requests-chart").tag == "canvas"
    assert find_frontend_node(model.frontend_tree, "inspect-dialog").browser.layer.open?
  end

  test "advanced native runtime keeps server authority while browser-local display state stays bounded" do
    {:ok, state} = WebUi.Server.mount(NativeAdvancedOperationsScreen)

    assert {:ok, dismissed_state} = WebUi.Server.handle_event(state, "dismiss_overlay", %{})

    refute find_widget(dismissed_state.view_state.widgets, "inspect-dialog").state.open?

    {:ok, envelope} = WebUi.Server.sync_envelope(state, kind: :update)
    {:ok, model} = WebUi.Frontend.ingest_sync(envelope)

    {:ok, model} =
      WebUi.Frontend.put_local(model, :viewport_offsets, %{"log-viewport" => %{x: 0, y: 320}})

    {:ok, model} = WebUi.Frontend.put_local(model, :split_ratios, %{"operations-split" => 0.72})

    {:ok, model} =
      WebUi.Frontend.put_local(model, :open_layers, %{
        "operations-overlay" => true,
        "inspect-dialog" => false,
        "deploy-toast" => true
      })

    {:ok, model} = WebUi.Frontend.put_local(model, :dismissed_layers, ["deploy-toast"])

    assert find_frontend_node(model.frontend_tree, "log-viewport").browser.viewport.offset == %{
             x: 0,
             y: 320
           }

    assert find_frontend_node(model.frontend_tree, "operations-split").browser.split.ratio == 0.72
    refute find_frontend_node(model.frontend_tree, "inspect-dialog").browser.layer.open?
    assert find_frontend_node(model.frontend_tree, "deploy-toast").browser.layer.dismissed?
    assert model.render_tree == state.view_state.render_tree
  end

  test "invalid advanced widget wiring fails with deterministic display diagnostics" do
    assert {:error, %WebUi.Server.Error{code: :invalid_display_configuration, details: details}} =
             WebUi.Server.mount(InvalidAdvancedScreen)

    assert details.reason == :scroll_bar_requires_viewport_ref
    assert details.id == "broken-scroll"
  end

  test "canonical advanced rendering reuses the native widget model and split runtime path" do
    element = CanonicalAdvancedOperationsScreen.element()

    assert {:ok, widgets} = WebUi.Renderer.render(element)

    assert {:ok, view_state} =
             WebUi.Renderer.render_view_state(element, screen_id: :phase_three_canonical)

    assert view_state.widgets == widgets
    assert find_render_node(view_state.render_tree, "operations-root").kind == :stack
    assert find_render_node(view_state.render_tree, "cluster-table").dom.tag == "table"

    assert {:ok, envelope} = WebUi.Server.Sync.outbound(view_state, kind: :hydrate)
    assert {:ok, model} = WebUi.Frontend.ingest_sync(envelope)

    assert model.screen_id == :phase_three_canonical
    assert find_frontend_node(model.frontend_tree, "log-scrollbar").role == "scrollbar"
  end

  test "native and canonical advanced examples preserve continuity" do
    comparison = AdvancedContinuity.compare()

    assert comparison.continuity.widget_kinds_match?
    assert comparison.continuity.render_tags_match?
    assert comparison.continuity.display_kinds_match?
    assert comparison.continuity.layer_kinds_match?
    assert "operations-overlay" in comparison.continuity.shared_ids
    assert "log-scrollbar" in comparison.continuity.shared_ids
  end

  test "unsupported advanced canonical inputs fail deterministically with coverage diagnostics" do
    unsupported =
      CanonicalData.list(
        [
          [id: :node_a, label: "Node A", value: :node_a]
        ],
        id: "cluster-list"
      )

    assert {:error, %WebUi.Renderer.Error{code: :unsupported_kind, details: details}} =
             WebUi.Renderer.render(unsupported)

    assert details.kind == :list
    assert :table in details.supported_kinds
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

  defp find_render_node(nodes, id) when is_list(nodes) do
    Enum.find_value(nodes, fn node ->
      if node.id == id do
        node
      else
        node.slots
        |> Enum.flat_map(& &1.children)
        |> find_render_node(id)
      end
    end)
  end

  defp find_render_node(nil, _id), do: nil

  defp find_frontend_node(nodes, id) when is_list(nodes) do
    Enum.find_value(nodes, fn node ->
      if node.id == id do
        node
      else
        node.slots
        |> Enum.flat_map(& &1.children)
        |> find_frontend_node(id)
      end
    end)
  end

  defp find_frontend_node(nil, _id), do: nil
end
