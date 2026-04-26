defmodule ElmUi.CanonicalNavigationWebRuntimeIntegrationTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Element
  alias UnifiedIUR.Interactions.Transport, as: BoundaryTransport

  test "maintained navigation example keeps authoritative server and frontend screens aligned across native and canonical flows" do
    navigate_fixture = BoundaryTransport.boundary_fixture!("screen_transition--settings_profile")
    replace_fixture = BoundaryTransport.boundary_fixture!("replace_transition--home")
    modal_fixture = BoundaryTransport.boundary_fixture!("modal_transition--settings_dialog")

    comparison = ElmUi.Examples.navigation_comparison()

    assert transition_summary(comparison.native.after_navigate.navigation.last_transition) ==
             transition_summary(navigate_fixture.descriptor.target.navigation)

    assert transition_summary(comparison.canonical.after_navigate.navigation.last_transition) ==
             transition_summary(navigate_fixture.descriptor.target.navigation)

    assert transition_summary(comparison.native.after_replace.navigation.last_transition) ==
             transition_summary(replace_fixture.descriptor.target.navigation)

    assert transition_summary(comparison.canonical.after_replace.navigation.last_transition) ==
             transition_summary(replace_fixture.descriptor.target.navigation)

    assert modal_summary(comparison.native.after_modal.navigation.current_modal) ==
             modal_summary(modal_fixture.descriptor.target.navigation)

    assert modal_summary(comparison.canonical.after_modal.navigation.current_modal) ==
             modal_summary(modal_fixture.descriptor.target.navigation)

    assert comparison.continuity.same_navigation_target?
    assert comparison.continuity.frontend_coordination?
    assert comparison.continuity.same_modal_identifier?
    assert comparison.continuity.same_replacement_target?
    assert comparison.continuity.server_authority_preserved?
  end

  test "canonical elm_ui navigation keeps host-route state outside the transition contract" do
    comparison = ElmUi.Examples.navigation_comparison()

    refute Map.has_key?(comparison.host_route_fixture.canonical_target, :route)
    refute Map.has_key?(comparison.host_route_fixture.canonical_target, :path)

    assert comparison.native.after_navigate.authoritative_host_route.path == "/workspace/settings"

    assert comparison.canonical.after_navigate.authoritative_host_route.path ==
             "/workspace/settings"

    assert comparison.continuity.host_route_externalized?

    assert {:ok, translation} =
             ElmUi.Transport.from_native_event(
               family: :navigation,
               intent: :open_settings_screen,
               widget_id: "settings-link",
               screen: "home",
               runtime_id: "contract-check",
               source_kind: :canonical,
               boundary_mode: :canonical_boundary,
               target: %{
                 navigation: %{action: :navigate_to, screen: :settings, params: %{tab: :profile}}
               }
             )

    assert transition_summary(translation.target.navigation) ==
             transition_summary(comparison.host_route_fixture.canonical_target)
  end

  test "frontend route divergence is reported deterministically when browser-local state disagrees" do
    home_element = Element.new(:widget, :text, id: "home", attributes: %{content: "Home"})

    settings_element =
      Element.new(:widget, :text, id: "settings", attributes: %{content: "Settings"})

    assert {:ok, runtime_state} =
             ElmUi.Runtime.mount_iur_screen(home_element,
               runtime_id: "canonical-navigation-divergence",
               screen_registry: %{settings: settings_element}
             )

    assert {:ok, frontend_model} = ElmUi.Runtime.hydrate_frontend(runtime_state)

    assert {:ok, frontend_after_dispatch, event_message} =
             ElmUi.FrontendRuntime.dispatch_interaction(frontend_model,
               family: :navigation,
               intent: :open_settings_screen,
               boundary: :boundary,
               widget_id: "settings-link",
               target: %{
                 navigation: %{action: :navigate_to, screen: :settings, params: %{tab: :profile}}
               },
               route_state: %{screen_id: "wrong-screen", path: "/workspace/wrong-screen"}
             )

    assert frontend_after_dispatch.local_state.pending_boundary_event.runtime_event ==
             "navigation:open_settings_screen"

    assert {:ok, next_state, ack_message} =
             ElmUi.Runtime.handle_frontend_event(runtime_state, event_message)

    assert Enum.any?(next_state.diagnostics, fn diagnostic ->
             diagnostic.reason == :frontend_route_state_divergence and
               to_string(diagnostic.authoritative_screen) == "settings"
           end)

    assert Enum.any?(ack_message.payload.diagnostics, fn diagnostic ->
             diagnostic.reason == :frontend_route_state_divergence and
               to_string(diagnostic.authoritative_screen) == "settings"
           end)
  end

  defp transition_summary(target) do
    %{
      action: get_value(target, :action),
      screen: get_value(target, :screen),
      params: normalize_map(get_value(target, :params, %{}))
    }
  end

  defp modal_summary(target) do
    %{
      modal: get_value(target, :modal),
      params: normalize_map(get_value(target, :params, %{})),
      metadata: normalize_map(get_value(target, :metadata, %{}))
    }
  end

  defp get_value(map, key, default \\ nil) when is_map(map) do
    Map.get(map, key, Map.get(map, Atom.to_string(key), default))
  end

  defp normalize_map(map) when is_map(map), do: Map.new(map)
  defp normalize_map(_other), do: %{}
end
