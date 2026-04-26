defmodule LiveUi.RuntimeNavigationTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Element
  alias UnifiedIUR.Interactions.Transport, as: BoundaryTransport

  defmodule HomeScreen do
    use LiveUi.Screen, id: :home, title: "Home"

    @impl true
    def mount_defaults do
      %{shared: "preserved", welcome: "Home"}
    end

    @impl true
    def render(assigns) do
      ~H"""
      <div><%= @welcome %></div>
      """
    end
  end

  defmodule SettingsScreen do
    use LiveUi.Screen, id: :settings, title: "Settings"

    @impl true
    def mount_defaults do
      %{welcome: "Settings"}
    end

    @impl true
    def render(assigns) do
      ~H"""
      <div><%= @welcome %></div>
      """
    end
  end

  test "native runtime dispatch resolves canonical screen transitions on the server" do
    assert {:ok, runtime_state} =
             LiveUi.Runtime.mount(HomeScreen,
               screen_registry: %{settings: SettingsScreen},
               host_route_resolver: fn descriptor, _state ->
                 if descriptor.screen == :settings, do: %{path: "/settings"}, else: nil
               end
             )

    assert {:ok, updated_state, translation} =
             LiveUi.Runtime.dispatch_native_event(
               runtime_state,
               "navigation:open_settings_screen",
               %{},
               family: :navigation,
               intent: :open_settings_screen,
               target: %{
                 navigation: %{
                   action: :navigate_to,
                   screen: :settings,
                   params: %{tab: :profile}
                 }
               }
             )

    assert translation.family == :navigation
    assert updated_state.screen == SettingsScreen
    assert updated_state.mode == :native
    assert updated_state.assigns.shared == "preserved"
    assert updated_state.assigns.current_screen_id == :settings
    assert updated_state.assigns.navigation_params == %{tab: :profile}
    assert updated_state.assigns.navigation_host_route == %{path: "/settings"}
    assert Enum.map(updated_state.navigation.history, & &1.screen_id) == [:home]
  end

  test "canonical boundary fixtures share the same transition resolver, history, and modal state" do
    home_element =
      Element.new(:widget, :text, id: :workspace_home, attributes: %{content: "Workspace Home"})

    screen_transition = BoundaryTransport.boundary_fixture!("screen_transition--settings_profile")
    history_transition = BoundaryTransport.boundary_fixture!("history_transition--back")
    modal_transition = BoundaryTransport.boundary_fixture!("modal_transition--settings_dialog")

    assert {:ok, runtime_state} =
             LiveUi.Runtime.mount_iur(home_element,
               screen_registry: %{settings: SettingsScreen},
               screen_id: :workspace_home
             )

    assert {:ok, screen_translation} =
             LiveUi.Signals.from_interaction(
               screen_transition.interaction,
               screen: :workspace_home,
               mode: :screen,
               boundary: :boundary,
               payload: screen_transition.signal_data
             )

    assert {:ok, after_navigation, _runtime_action} =
             LiveUi.Runtime.handle_boundary_signal(runtime_state, screen_translation.signal)

    assert after_navigation.screen == SettingsScreen
    assert after_navigation.assigns.current_screen_id == :settings

    assert after_navigation.assigns.navigation_history == [
             %{screen_id: :workspace_home, title: "Workspace Home", mode: :canonical, params: %{}}
           ]

    assert {:ok, modal_translation} =
             LiveUi.Signals.from_interaction(
               modal_transition.interaction,
               screen: :settings,
               mode: :screen,
               boundary: :boundary,
               payload: modal_transition.signal_data
             )

    assert {:ok, with_modal, _runtime_action} =
             LiveUi.Runtime.handle_boundary_signal(after_navigation, modal_translation.signal)

    assert with_modal.assigns.current_modal == %{
             modal: modal_transition.summary.modal,
             params: modal_transition.descriptor.target.navigation.params,
             metadata: modal_transition.descriptor.target.navigation.metadata
           }

    assert {:ok, history_translation} =
             LiveUi.Signals.from_interaction(
               history_transition.interaction,
               screen: :settings,
               mode: :screen,
               boundary: :boundary,
               payload: history_transition.signal_data
             )

    assert {:ok, back_home, _runtime_action} =
             LiveUi.Runtime.handle_boundary_signal(with_modal, history_translation.signal)

    assert back_home.mode == :canonical
    assert back_home.screen == LiveUi.Runtime.CanonicalScreen
    assert back_home.assigns.current_screen_id == :workspace_home

    assert back_home.assigns.navigation_forward == [
             %{screen_id: :settings, title: "Settings", mode: :native, params: %{tab: :profile}}
           ]
  end

  test "navigation failures surface deterministic diagnostics" do
    assert {:ok, runtime_state} = LiveUi.Runtime.mount(HomeScreen)

    assert {:error, %LiveUi.Runtime.Error{reason: :unresolved_navigation_target}} =
             LiveUi.Runtime.dispatch_native_event(
               runtime_state,
               "navigation:open_missing",
               %{},
               family: :navigation,
               intent: :open_missing_screen,
               target: %{navigation: %{action: :navigate_to, screen: :missing}}
             )

    assert {:error, %LiveUi.Runtime.Error{reason: :host_route_navigation_syntax}} =
             LiveUi.Runtime.dispatch_native_event(
               runtime_state,
               "navigation:open_route",
               %{},
               family: :navigation,
               intent: :open_settings_screen,
               target: %{
                 navigation: %{action: :navigate_to, screen: :settings, route: "/settings"}
               }
             )
  end
end
