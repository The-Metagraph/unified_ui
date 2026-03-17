defmodule WebUi.PhaseTwoIntegrationTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Widgets.Input

  alias WebUi.Examples.{
    CanonicalFoundationalScreen,
    FoundationalContinuity,
    NativeFoundationalScreen
  }

  defmodule InvalidFoundationalScreen do
    use WebUi.Server.Screen, id: :invalid_foundational, title: "Invalid Foundational"

    @impl true
    def mount_defaults, do: %{}

    @impl true
    def event_routes, do: %{}

    @impl true
    def view(_assigns) do
      [%{kind: :text}]
    end

    @impl true
    def handle_event(_route, _payload, assigns), do: {:ok, assigns}
  end

  test "native foundational examples render coherently through the server and frontend split" do
    assert {:ok, state} = WebUi.Server.mount(NativeFoundationalScreen)
    assert find_render_node(state.view_state.render_tree, "workspace-layout").dom.tag == "div"

    assert {:ok, envelope} = WebUi.Server.sync_envelope(state)
    assert {:ok, model} = WebUi.Frontend.ingest_sync(envelope)

    assert model.screen_id == :native_foundational
    assert find_frontend_node(model.frontend_tree, "workspace-tabs").role == "tablist"
    assert find_frontend_node(model.frontend_tree, "query-input").tag == "input"
  end

  test "native form editing and navigation keep server authority while rerendering the frontend view" do
    {:ok, state} = WebUi.Server.mount(NativeFoundationalScreen)

    assert {:ok, renamed_state} =
             WebUi.Server.handle_event(state, "rename_query", %{"query" => "Ari"})

    assert find_widget(renamed_state.view_state.widgets, "query-input").props.value == "Ari"

    assert {:ok, switched_state} =
             WebUi.Server.handle_event(renamed_state, "switch_tab", %{"tab" => "activity"})

    assert find_widget(switched_state.view_state.widgets, "workspace-tabs").props.active_item ==
             :activity

    {:ok, update_envelope} = WebUi.Server.sync_envelope(switched_state, kind: :update)
    {:ok, model} = WebUi.Frontend.ingest_sync(update_envelope)

    assert model.server_revision == 2

    assert find_frontend_node(model.frontend_tree, "workspace-tabs").attrs.active_item ==
             :activity
  end

  test "invalid foundational declarations fail with deterministic diagnostics" do
    assert {:error, %WebUi.Server.Error{code: :invalid_widget}} =
             WebUi.Server.mount(InvalidFoundationalScreen)
  end

  test "canonical foundational rendering reuses the native widget model and split runtime path" do
    element = CanonicalFoundationalScreen.element()

    assert {:ok, widgets} = WebUi.Renderer.render(element)

    assert {:ok, view_state} =
             WebUi.Renderer.render_view_state(element, screen_id: :phase_two_canonical)

    assert view_state.widgets == widgets
    assert find_render_node(view_state.render_tree, "workspace-form").dom.tag == "form"

    assert {:ok, envelope} = WebUi.Server.Sync.outbound(view_state, kind: :hydrate)
    assert {:ok, model} = WebUi.Frontend.ingest_sync(envelope)

    assert model.screen_id == :phase_two_canonical
    assert find_frontend_node(model.frontend_tree, "save-button").tag == "button"
  end

  test "native and canonical foundational examples preserve continuity" do
    comparison = FoundationalContinuity.compare()

    assert comparison.continuity.widget_kinds_match?
    assert comparison.continuity.render_tags_match?
    assert "workspace-layout" in comparison.continuity.shared_ids
    assert "save-button" in comparison.continuity.shared_ids
  end

  test "unsupported canonical inputs fail deterministically with coverage diagnostics" do
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
