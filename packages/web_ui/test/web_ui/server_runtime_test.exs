defmodule WebUi.ServerRuntimeTest do
  use ExUnit.Case, async: true

  defmodule NativeProfileScreen do
    use WebUi.Server.Screen, id: :native_profile, title: "Native Profile"

    @impl true
    def mount_defaults do
      %{name: "Pascal", edits: 0}
    end

    @impl true
    def event_routes do
      %{"rename" => :rename_profile}
    end

    @impl true
    def view(assigns) do
      [
        %{
          id: "profile-name",
          kind: :text_input,
          props: %{value: assigns.name},
          events: %{change: "rename"}
        },
        %{
          id: "profile-summary",
          kind: :text,
          props: %{content: "#{assigns.name} (#{assigns.edits})"}
        }
      ]
    end

    @impl true
    def handle_event(:rename_profile, %{"name" => name}, assigns) do
      {:ok, %{assigns | name: name, edits: assigns.edits + 1}}
    end

    @impl true
    def frontend_boot do
      %{entry: :native_profile}
    end
  end

  test "server mount builds authoritative view state for direct-native screens" do
    assert {:ok, state} = WebUi.Server.mount(NativeProfileScreen)

    assert state.screen == NativeProfileScreen
    assert state.mode == :native
    assert state.assigns == %{name: "Pascal", edits: 0}
    assert state.view_state.screen.id == :native_profile
    assert state.view_state.screen.title == "Native Profile"

    assert [%{id: "profile-name", kind: :text_input}, %{id: "profile-summary", kind: :text}] =
             state.view_state.widgets
  end

  test "server event handling rerenders view state and increments revision" do
    {:ok, state} = WebUi.Server.mount(NativeProfileScreen)

    assert {:ok, updated_state} = WebUi.Server.handle_event(state, "rename", %{"name" => "Ari"})

    assert updated_state.revision == 1
    assert updated_state.assigns == %{name: "Ari", edits: 1}
    assert Enum.at(updated_state.view_state.widgets, 0).props == %{value: "Ari"}
  end

  test "server sync envelopes expose the current authoritative payload" do
    {:ok, state} = WebUi.Server.mount(NativeProfileScreen)

    assert {:ok, %{kind: :hydrate, revision: 0, payload: payload}} =
             WebUi.Server.sync_envelope(state)

    assert payload.screen.id == :native_profile
    assert payload.bridge.entry_module == WebUi.Frontend.entry_module()
  end

  test "invalid event routes fail with structured server errors" do
    {:ok, state} = WebUi.Server.mount(NativeProfileScreen)

    assert {:error, %WebUi.Server.Error{code: :invalid_event_route}} =
             WebUi.Server.handle_event(state, "missing", %{})
  end
end
