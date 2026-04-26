defmodule DesktopUi.CanonicalNavigationDesktopRuntimeIntegrationTest do
  use ExUnit.Case, async: true

  alias DesktopUi.Runtime
  alias UnifiedIUR.Interactions.Transport, as: BoundaryTransport

  defmodule HomeScreen do
    def render(_assigns), do: %{}
  end

  defmodule SettingsScreen do
    def render(_assigns), do: %{}
  end

  defmodule SettingsDialogScreen do
    def render(_assigns), do: %{}
  end

  defmodule ScreenRegistry do
    def register do
      %{
        home: {HomeScreen, title: "Home"},
        settings: {SettingsScreen, title: "Settings"},
        settings_dialog: {SettingsDialogScreen, title: "Settings Dialog", modal_only?: true}
      }
    end

    def get_screen(:home), do: HomeScreen
    def get_screen(:settings), do: SettingsScreen
    def get_screen(:settings_dialog), do: SettingsDialogScreen
    def get_screen(_), do: nil

    def screen_metadata(:home), do: %{title: "Home"}
    def screen_metadata(:settings), do: %{title: "Settings"}
    def screen_metadata(:settings_dialog), do: %{title: "Settings Dialog", modal_only?: true}
    def screen_metadata(_), do: %{}
  end

  test "desktop runtime maps canonical navigation fixtures through the controller while preserving window state" do
    navigate_fixture = BoundaryTransport.boundary_fixture!("screen_transition--settings_profile")
    replace_fixture = BoundaryTransport.boundary_fixture!("replace_transition--home")

    assert {:ok, runtime_state} =
             Runtime.mount_native_screen(base_screen(),
               platform_target: :linux,
               screen_registry: ScreenRegistry,
               navigation_screen_id: :home
             )

    primary_window = runtime_state.windows.primary
    initial_runtime_id = runtime_state.runtime_id

    assert {:ok, after_navigate, navigate_route} =
             Runtime.dispatch_native_event(
               runtime_state,
               family: :navigation,
               intent: navigate_fixture.interaction.intent,
               widget_id: "settings-link",
               target: navigate_fixture.descriptor.target,
               payload: navigate_fixture.signal_data
             )

    assert navigate_route.route == :canonical_boundary
    assert navigate_route.translation.target == navigate_fixture.descriptor.target
    assert after_navigate.screen_id == "settings"
    assert after_navigate.current_screen_module == SettingsScreen
    assert after_navigate.screen_params == %{tab: :profile}
    assert after_navigate.title == "Settings"
    assert after_navigate.runtime_id == initial_runtime_id
    assert after_navigate.windows.primary == primary_window
    assert after_navigate.navigation_state.history == [{:home, HomeScreen, %{}}]

    assert {:ok, replace_translation} =
             DesktopUi.Transport.from_interaction(
               replace_fixture.interaction,
               platform_target: :linux,
               widget_id: "home-link",
               runtime_id: after_navigate.runtime_id,
               screen: after_navigate.screen_id,
               payload: replace_fixture.signal_data
             )

    assert {:ok, after_replace, replace_route} =
             Runtime.handle_boundary_signal(after_navigate, replace_translation.signal)

    assert replace_route.route == :canonical_boundary
    assert after_replace.screen_id == "home"
    assert after_replace.current_screen_module == HomeScreen
    assert after_replace.screen_params == %{source: :command_palette}
    assert after_replace.windows.primary == primary_window
    assert after_replace.navigation_state.history == [{:home, HomeScreen, %{}}]
    assert after_replace.screen.metadata.navigation_action == :replace_with
  end

  test "desktop runtime preserves history and modal semantics across canonical actions" do
    navigate_fixture = BoundaryTransport.boundary_fixture!("screen_transition--settings_profile")
    modal_fixture = BoundaryTransport.boundary_fixture!("modal_transition--settings_dialog")
    history_fixture = BoundaryTransport.boundary_fixture!("history_transition--back")

    assert {:ok, runtime_state} =
             Runtime.mount_native_screen(base_screen(),
               platform_target: :linux,
               screen_registry: ScreenRegistry,
               navigation_screen_id: :home
             )

    assert {:ok, after_navigate, _route} =
             Runtime.dispatch_native_event(
               runtime_state,
               family: :navigation,
               intent: navigate_fixture.interaction.intent,
               widget_id: "settings-link",
               target: navigate_fixture.descriptor.target,
               payload: navigate_fixture.signal_data
             )

    assert {:ok, with_modal, modal_route} =
             Runtime.dispatch_native_event(
               after_navigate,
               family: :navigation,
               intent: modal_fixture.interaction.intent,
               widget_id: "settings-dialog-button",
               target: modal_fixture.descriptor.target,
               payload: modal_fixture.signal_data
             )

    assert modal_route.translation.target == modal_fixture.descriptor.target
    assert with_modal.screen_id == "settings"
    assert with_modal.navigation_state.modal_open?
    assert with_modal.navigation_state.modals == [
             {:settings_dialog, SettingsDialogScreen, %{mode: :advanced}}
           ]

    assert {:ok, after_close, _close_route} =
             Runtime.dispatch_native_event(
               with_modal,
               family: :navigation,
               intent: :close_settings_modal,
               widget_id: "close-settings-dialog",
               target: %{navigation: %{action: :close_modal, modal: :settings_dialog}}
             )

    refute after_close.navigation_state.modal_open?
    assert after_close.navigation_state.modals == []
    assert after_close.screen_id == "settings"

    assert {:ok, after_back, back_route} =
             Runtime.dispatch_native_event(
               after_close,
               family: :navigation,
               intent: history_fixture.interaction.intent,
               widget_id: "back-button",
               target: history_fixture.descriptor.target,
               payload: history_fixture.signal_data
             )

    assert back_route.translation.target == history_fixture.descriptor.target
    assert after_back.screen_id == "home"
    assert after_back.current_screen_module == HomeScreen
    assert after_back.navigation_state.forward == [{:settings, SettingsScreen, %{tab: :profile}}]
  end

  test "desktop runtime reports invalid screen targets, leaked route syntax, and modal mismatches deterministically" do
    assert {:ok, runtime_state} =
             Runtime.mount_native_screen(base_screen(),
               platform_target: :linux,
               screen_registry: ScreenRegistry,
               navigation_screen_id: :home
             )

    assert {:error, %Runtime.Error{reason: :unresolved_navigation_target}} =
             Runtime.dispatch_native_event(
               runtime_state,
               family: :navigation,
               intent: :open_missing_screen,
               widget_id: "missing-link",
               target: %{navigation: %{action: :navigate_to, screen: :missing}}
             )

    assert {:error, %Runtime.Error{reason: :host_route_navigation_syntax}} =
             Runtime.dispatch_native_event(
               runtime_state,
               family: :navigation,
               intent: :open_settings_screen,
               widget_id: "settings-link",
               target: %{
                 navigation: %{action: :navigate_to, screen: :settings, route: "/settings"}
               }
             )

    assert {:error, %Runtime.Error{reason: :invalid_modal_transition}} =
             Runtime.dispatch_native_event(
               runtime_state,
               family: :navigation,
               intent: :close_settings_modal,
               widget_id: "close-settings-dialog",
               target: %{navigation: %{action: :close_modal, modal: :settings_dialog}}
             )
  end

  defp base_screen do
    %{
      id: "workspace",
      title: "Workspace",
      root:
        DesktopUi.Widgets.window("workspace-window", "Workspace", [
          DesktopUi.Widgets.column("workspace-layout", [
            DesktopUi.Widgets.text("workspace-title", "Workspace"),
            DesktopUi.Widgets.button("settings-link", "Settings", navigate_to: :settings)
          ])
        ])
    }
  end
end
