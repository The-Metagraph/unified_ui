defmodule WebUi.FrontendRuntimeTest do
  use ExUnit.Case, async: true

  defmodule NativeDashboardScreen do
    use WebUi.Server.Screen, id: :native_dashboard, title: "Native Dashboard"

    @impl true
    def mount_defaults do
      %{query: "", focused?: false}
    end

    @impl true
    def event_routes do
      %{"focus" => :focus_query}
    end

    @impl true
    def view(assigns) do
      [
        %{
          id: "query-input",
          kind: :text_input,
          props: %{value: assigns.query},
          events: %{focus: "focus"}
        }
      ]
    end

    @impl true
    def handle_event(:focus_query, _payload, assigns) do
      {:ok, %{assigns | focused?: true}}
    end
  end

  test "frontend hydration ingests authoritative server payloads" do
    {:ok, state} = WebUi.Server.mount(NativeDashboardScreen)
    {:ok, envelope} = WebUi.Server.sync_envelope(state)

    assert {:ok, model} = WebUi.Frontend.ingest_sync(envelope)

    assert model.screen_id == :native_dashboard
    assert model.title == "Native Dashboard"
    assert model.server_revision == 0
    assert model.status == :hydrated
    assert [%{id: "query-input", kind: :text_input}] = model.widgets
  end

  test "frontend local state stays bounded and separate from authoritative server state" do
    {:ok, state} = WebUi.Server.mount(NativeDashboardScreen)
    {:ok, envelope} = WebUi.Server.sync_envelope(state)
    {:ok, model} = WebUi.Frontend.ingest_sync(envelope)

    assert {:ok, updated_model} = WebUi.Frontend.put_local(model, :focused_widget, "query-input")

    assert updated_model.local_state == %{focused_widget: "query-input"}
    assert updated_model.status == :dirty
    assert updated_model.server_revision == model.server_revision
  end

  test "frontend outbound messages retain screen and revision context" do
    {:ok, state} = WebUi.Server.mount(NativeDashboardScreen)
    {:ok, envelope} = WebUi.Server.sync_envelope(state)
    {:ok, model} = WebUi.Frontend.ingest_sync(envelope)

    assert {:ok, message} =
             WebUi.Frontend.outbound_message(model, "focus", %{"focused" => true},
               element_id: "query-input",
               widget: :text_input
             )

    assert message.event == "focus"
    assert message.source.screen_id == :native_dashboard
    assert message.source.revision == 0
    assert message.source.element_id == "query-input"
  end

  test "invalid hydration payloads fail with structured frontend errors" do
    assert {:error, %WebUi.Frontend.Error{code: :invalid_hydration_payload}} =
             WebUi.Frontend.hydrate(%{screen: %{id: :broken}})
  end
end
