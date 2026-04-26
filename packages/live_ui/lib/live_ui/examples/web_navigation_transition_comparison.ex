defmodule LiveUi.Examples.WebNavigationTransitionComparison do
  @moduledoc """
  Maintained mixed-flow example comparing server-authoritative web navigation
  transitions across direct-native and canonical `live_ui` runtime paths.
  """

  alias UnifiedIUR.Element
  alias UnifiedIUR.Interactions.Transport, as: BoundaryTransport

  defmodule HomeScreen do
    use LiveUi.Screen, id: :home, title: "Home"

    @impl true
    def mount_defaults do
      %{shared: "preserved", section: "Home"}
    end

    @impl true
    def render(assigns) do
      ~H"""
      <LiveUi.Widgets.ScreenShell.render id="navigation-home" title={title()}>
        <div data-navigation-section="home"><%= @section %></div>
      </LiveUi.Widgets.ScreenShell.render>
      """
    end
  end

  defmodule SettingsScreen do
    use LiveUi.Screen, id: :settings, title: "Settings"

    @impl true
    def mount_defaults do
      %{section: "Settings"}
    end

    @impl true
    def render(assigns) do
      ~H"""
      <LiveUi.Widgets.ScreenShell.render id="navigation-settings" title={title()}>
        <div data-navigation-section="settings"><%= @section %></div>
      </LiveUi.Widgets.ScreenShell.render>
      """
    end
  end

  def compare do
    with {:ok, native} <- native_flow(),
         {:ok, canonical} <- canonical_flow() do
      {:ok,
       %{
         native: native,
         canonical: canonical,
         host_route_fixture: host_route_fixture(),
         continuity: continuity(native, canonical)
       }}
    end
  end

  def metadata do
    %{
      id: :web_navigation_transition_compare,
      title: "Web Navigation Transition Comparison",
      families: [:navigation, :comparison, :transport],
      comparable_to: [:native_navigation, :canonical_navigation],
      summary:
        "Mixed example comparing server-authoritative screen, replacement, modal, and host-route seams."
    }
  end

  defp native_flow do
    with {:ok, runtime_state} <-
           LiveUi.Runtime.mount(HomeScreen,
             screen_registry: screen_registry(:native),
             host_route_resolver: &resolve_host_route/2
           ),
         {:ok, after_navigate, navigate_translation} <-
           LiveUi.Runtime.dispatch_native_event(
             runtime_state,
             "navigation:open_settings_screen",
             %{},
             family: :navigation,
             intent: :open_settings_screen,
             target: navigation_target(:navigate_to, screen: :settings, params: %{tab: :profile})
           ),
         {:ok, with_modal, modal_translation} <-
           LiveUi.Runtime.dispatch_native_event(
             after_navigate,
             "navigation:open_settings_dialog",
             %{},
             family: :navigation,
             intent: :open_settings_modal,
             target:
               navigation_target(:open_modal,
                 modal: :settings_dialog,
                 params: %{mode: :advanced},
                 metadata: %{surface: :workspace}
               )
           ),
         {:ok, after_replace, replace_translation} <-
           LiveUi.Runtime.dispatch_native_event(
             with_modal,
             "navigation:replace_home_screen",
             %{},
             family: :navigation,
             intent: :replace_home_screen,
             target:
               navigation_target(:replace_with,
                 screen: :home,
                 params: %{source: :command_palette}
               )
           ) do
      {:ok,
       %{
         after_navigate: runtime_snapshot(after_navigate),
         after_modal: runtime_snapshot(with_modal),
         after_replace: runtime_snapshot(after_replace),
         runtime_events: [
           navigate_translation.runtime_event,
           modal_translation.runtime_event,
           replace_translation.runtime_event
         ],
         transition_targets: %{
           navigate: navigate_translation.target.navigation,
           modal: modal_translation.target.navigation,
           replace: replace_translation.target.navigation
         }
       }}
    end
  end

  defp canonical_flow do
    home_element = home_element()

    screen_transition = BoundaryTransport.boundary_fixture!("screen_transition--settings_profile")
    modal_transition = BoundaryTransport.boundary_fixture!("modal_transition--settings_dialog")
    replace_transition = BoundaryTransport.boundary_fixture!("replace_transition--home")

    with {:ok, runtime_state} <-
           LiveUi.Runtime.mount_iur(home_element,
             screen_id: :home,
             screen_registry: screen_registry(:canonical),
             host_route_resolver: &resolve_host_route/2
           ),
         {:ok, navigate_signal} <- boundary_signal(screen_transition, :home),
         {:ok, after_navigate, navigate_runtime_action} <-
           LiveUi.Runtime.handle_boundary_signal(runtime_state, navigate_signal),
         {:ok, modal_signal} <- boundary_signal(modal_transition, :settings),
         {:ok, with_modal, modal_runtime_action} <-
           LiveUi.Runtime.handle_boundary_signal(after_navigate, modal_signal),
         {:ok, replace_signal} <- boundary_signal(replace_transition, :settings),
         {:ok, after_replace, replace_runtime_action} <-
           LiveUi.Runtime.handle_boundary_signal(with_modal, replace_signal) do
      {:ok,
       %{
         after_navigate: runtime_snapshot(after_navigate),
         after_modal: runtime_snapshot(with_modal),
         after_replace: runtime_snapshot(after_replace),
         runtime_events: [
           navigate_runtime_action.runtime_event,
           modal_runtime_action.runtime_event,
           replace_runtime_action.runtime_event
         ],
         transition_targets: %{
           navigate: navigate_runtime_action.target.navigation,
           modal: modal_runtime_action.target.navigation,
           replace: replace_runtime_action.target.navigation
         }
       }}
    end
  end

  defp host_route_fixture do
    %{
      canonical_target: %{action: :navigate_to, screen: :settings, params: %{tab: :profile}},
      host_application: %{
        live_view_route: %{path: "/workspace/settings", params: %{tab: :profile}},
        note:
          "Host route lookup stays in the application resolver; the canonical target remains screen-based."
      }
    }
  end

  defp continuity(native, canonical) do
    %{
      same_navigation_target?:
        native.after_navigate.screen_id == :settings and
          canonical.after_navigate.screen_id == :settings,
      same_modal_identifier?:
        get_in(native, [:after_modal, :current_modal, :modal]) ==
          get_in(canonical, [:after_modal, :current_modal, :modal]),
      same_replacement_target?:
        native.after_replace.screen_id == :home and canonical.after_replace.screen_id == :home,
      replacement_clears_modal?:
        is_nil(native.after_replace.current_modal) and
          is_nil(canonical.after_replace.current_modal),
      history_meaning_preserved?:
        Enum.map(native.after_replace.history, & &1.screen_id) ==
          Enum.map(canonical.after_replace.history, & &1.screen_id),
      host_route_externalized?:
        is_nil(get_in(host_route_fixture(), [:canonical_target, :route])) and
          native.after_navigate.host_route == canonical.after_navigate.host_route,
      server_authoritative?:
        Enum.all?(
          [
            native.after_navigate.server_authoritative?,
            native.after_modal.server_authoritative?,
            native.after_replace.server_authoritative?,
            canonical.after_navigate.server_authoritative?,
            canonical.after_modal.server_authoritative?,
            canonical.after_replace.server_authoritative?
          ],
          & &1
        )
    }
  end

  defp boundary_signal(fixture, screen) do
    with {:ok, translation} <-
           LiveUi.Signals.from_interaction(
             fixture.interaction,
             screen: screen,
             mode: :screen,
             boundary: :boundary,
             payload: fixture.signal_data
           ) do
      {:ok, translation.signal}
    end
  end

  defp home_element do
    Element.new(:widget, :text, id: :home, attributes: %{content: "Home"})
  end

  defp screen_registry(:native) do
    %{home: HomeScreen, settings: SettingsScreen}
  end

  defp screen_registry(:canonical) do
    %{home: home_element(), settings: SettingsScreen}
  end

  defp resolve_host_route(descriptor, _state) do
    screen = Map.get(descriptor, :screen)

    case screen do
      screen when screen in [:home, :settings] ->
        {:ok,
         %{
           path: "/workspace/#{screen}",
           params: normalize_map(Map.get(descriptor, :params, %{}))
         }}

      _other ->
        {:ok, nil}
    end
  end

  defp navigation_target(action, attrs) do
    %{navigation: attrs |> Enum.into(%{}) |> Map.put(:action, action)}
  end

  defp runtime_snapshot(state) do
    %{
      screen_id: state.assigns.current_screen_id,
      title: state.assigns.current_screen_title,
      mode: state.mode,
      shared_assign: Map.get(state.assigns, :shared),
      navigation_action: state.assigns.navigation_action,
      params: state.assigns.navigation_params,
      history: state.assigns.navigation_history,
      forward: state.assigns.navigation_forward,
      current_modal: state.assigns.current_modal,
      host_route: state.assigns.navigation_host_route,
      server_authoritative?: LiveUi.Runtime.assumptions().server_authoritative?
    }
  end

  defp normalize_map(map) when is_map(map), do: Map.new(map)
  defp normalize_map(_other), do: %{}
end
