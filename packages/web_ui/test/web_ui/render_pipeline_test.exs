defmodule WebUi.RenderPipelineTest do
  use ExUnit.Case, async: true

  alias WebUi.Widgets.{Forms, Foundational, Input, Layout, Navigation}

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
