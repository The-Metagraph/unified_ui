defmodule WebUi.PhaseOneIntegrationTest do
  use ExUnit.Case, async: true

  defmodule MinimalNativeScreen do
    use WebUi.Server.Screen, id: :minimal_native, title: "Minimal Native"

    @impl true
    def mount_defaults do
      %{query: "hello", changed?: false}
    end

    @impl true
    def event_routes do
      %{"change" => :change_query}
    end

    @impl true
    def view(assigns) do
      [
        [
          id: "query-input",
          kind: :text_input,
          props: %{value: assigns.query},
          events: %{change: "change"},
          style_hooks: [:tone, :variant]
        ],
        %{
          "id" => "query-summary",
          "kind" => "text",
          "props" => %{"content" => "#{assigns.query}:#{assigns.changed?}"}
        }
      ]
    end

    @impl true
    def handle_event(:change_query, %{"query" => query}, assigns) do
      {:ok, %{assigns | query: query, changed?: true}}
    end

    @impl true
    def frontend_boot do
      %{entry: :minimal_native}
    end
  end

  defmodule InvalidWidgetScreen do
    use WebUi.Server.Screen, id: :invalid_widget, title: "Invalid Widget"

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

  defmodule InvalidFrontendBootScreen do
    use WebUi.Server.Screen, id: :invalid_boot, title: "Invalid Boot"

    @impl true
    def mount_defaults, do: %{}

    @impl true
    def event_routes, do: %{}

    @impl true
    def view(_assigns) do
      [%{id: "ok", kind: :text}]
    end

    @impl true
    def handle_event(_route, _payload, assigns), do: {:ok, assigns}

    @impl true
    def frontend_boot, do: :invalid
  end

  test "package exposes split runtime entrypoints without taking over application startup" do
    assert WebUi.widgets() == WebUi.Widgets
    assert WebUi.server() == WebUi.Server
    assert WebUi.frontend() == WebUi.Frontend
    assert WebUi.runtime() == WebUi.Runtime
    assert :mount in WebUi.Server.capabilities()
    assert :hydrate in WebUi.Frontend.capabilities()
    refute Keyword.has_key?(WebUi.MixProject.application(), :mod)
  end

  test "minimal native screens mount, render, and hydrate through the phase one backbone" do
    assert {:ok, state} = WebUi.Server.mount(MinimalNativeScreen)

    view_state = WebUi.Server.render_view_state(state)

    assert view_state.screen.id == :minimal_native

    assert [
             %WebUi.Widget{
               id: "query-input",
               family: :input,
               kind: :text_input,
               style_hooks: [:tone, :variant]
             },
             %WebUi.Widget{id: "query-summary", family: :foundational, kind: :text}
           ] = view_state.widgets

    assert {:ok, envelope} = WebUi.Server.sync_envelope(state)
    assert {:ok, model} = WebUi.Frontend.ingest_sync(envelope)

    assert model.screen_id == :minimal_native
    assert model.bridge.entry_module == WebUi.Frontend.entry_module()
    assert Enum.map(model.widgets, &WebUi.Widget.summary/1) == model.widget_summaries
  end

  test "malformed declarations and runtime wiring fail with deterministic diagnostics" do
    assert {:error, %WebUi.Server.Error{code: :invalid_widget}} =
             WebUi.Server.mount(InvalidWidgetScreen)

    assert {:error, %WebUi.Server.Error{code: :invalid_frontend_boot}} =
             WebUi.Server.mount(InvalidFrontendBootScreen)

    assert {:error, %WebUi.Server.Error{code: :invalid_sync_envelope}} =
             WebUi.Frontend.ingest_sync(%{kind: :hydrate})

    assert {:error, %WebUi.Frontend.Error{code: :invalid_hydration_payload}} =
             WebUi.Frontend.hydrate(%{screen: %{id: :broken}})
  end

  test "reference helpers report widget families and split-runtime boundaries without renderer modules" do
    reference = WebUi.reference()

    assert :input in reference.widgets.families
    assert reference.widgets.metadata_contract.required_keys == [:id, :kind]
    assert reference.runtime.sides.server == WebUi.Server
    assert reference.runtime.sides.frontend == WebUi.Frontend
    assert reference.runtime.browser_bridge.entry_module == WebUi.Frontend.entry_module()
    assert reference.renderer.responsibilities == WebUi.Renderer.responsibilities()
  end

  test "inspection helpers expose runtime assumptions, bridge entry points, and validation state" do
    info = WebUi.info()
    reference = WebUi.reference()

    assert info.assumptions.authoritative_server?

    assert info.browser_bridge.boot_contract.required_keys ==
             [:screen, :widgets, :widget_summaries, :render_tree, :bridge, :revision]

    assert info.validation_state.widgets.widget_definition == :ready
    assert info.validation_state.server.server_state == :ready
    assert info.validation_state.frontend.browser_bridge == :ready
    assert reference.runtime.assumptions.server.authoritative_server?
    assert reference.runtime.assumptions.frontend.canonical_meaning_owned_by_server?
  end
end
