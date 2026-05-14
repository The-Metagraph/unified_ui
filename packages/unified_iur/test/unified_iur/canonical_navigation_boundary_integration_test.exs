defmodule UnifiedIUR.CanonicalNavigationBoundaryIntegrationTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Interactions.Transport

  test "shared boundary fixtures preserve canonical transition meaning deterministically" do
    first =
      Transport.boundary_fixtures()
      |> Enum.map(&Map.take(&1, [:id, :signal_data, :extensions, :summary]))

    second =
      Transport.boundary_fixtures()
      |> Enum.map(&Map.take(&1, [:id, :signal_data, :extensions, :summary]))

    assert first == second

    assert Enum.all?(
             Transport.boundary_fixtures(),
             &(Transport.validate_boundary_fixture(&1) == :ok)
           )

    assert Enum.find(first, &(&1.id == "screen_transition--settings_profile")) == %{
             id: "screen_transition--settings_profile",
             signal_data: %{mapping: %{origin: :workspace}},
             extensions: %{
               unified_iur_boundary: %{
                 family: :navigation,
                 intent: :open_settings_screen,
                 source_context: %{element_id: "settings-link", scope: :screen},
                 target: %{
                   navigation: %{
                     action: :navigate_to,
                     kind: :screen_transition,
                     params: %{tab: :profile},
                     screen: :settings
                   }
                 },
                 metadata: %{}
               },
               unified_iur_boundary_summary: %{
                 family: :navigation,
                 intent: :open_settings_screen,
                 action: :navigate_to,
                 screen: :settings,
                 modal: nil,
                 params?: true,
                 targetless?: false,
                 modal_stack?: false,
                 modal_stack_operation: nil,
                 modal_stack_target: nil,
                 modal_stack_effect: nil
               }
             },
             summary: %{
               family: :navigation,
               intent: :open_settings_screen,
               action: :navigate_to,
               screen: :settings,
               modal: nil,
               params?: true,
               targetless?: false,
               modal_stack?: false,
               modal_stack_operation: nil,
               modal_stack_target: nil,
               modal_stack_effect: nil
             }
           }
  end

  test "shared boundary validation rejects malformed payloads and leaked route syntax" do
    assert {:error, {:invalid_boundary_payload, "oops"}} =
             Transport.validate_boundary_payload("oops")

    assert {:error, {:forbidden_navigation_keys, [:route]}} =
             Transport.validate_boundary_extensions(%{
               unified_iur_boundary: %{
                 family: :navigation,
                 intent: :open_settings_screen,
                 source_context: %{element_id: "settings-link"},
                 target: %{
                   navigation: %{action: :navigate_to, screen: :settings, route: "/settings"}
                 },
                 metadata: %{}
               },
               unified_iur_boundary_summary: %{
                 family: :navigation,
                 intent: :open_settings_screen,
                 action: :navigate_to,
                 screen: :settings,
                 modal: nil,
                 params?: false,
                 targetless?: false
               }
             })
  end
end
