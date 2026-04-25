defmodule UnifiedIUR.InteractionsTransportTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Interactions.Transport

  test "exposes maintained shared boundary fixtures and review summaries" do
    assert Transport.boundary_fixture_ids() == [
             "screen_transition--settings_profile",
             "replace_transition--home",
             "history_transition--back",
             "modal_transition--settings_dialog"
           ]

    assert {:ok, fixture} = Transport.boundary_fixture("screen_transition--settings_profile")

    assert fixture.signal_data == %{mapping: %{origin: :workspace}}

    assert fixture.summary == %{
             family: :navigation,
             intent: :open_settings_screen,
             action: :navigate_to,
             screen: :settings,
             modal: nil,
             params?: true,
             targetless?: false
           }

    assert fixture.extensions == %{
             unified_iur_boundary: fixture.descriptor,
             unified_iur_boundary_summary: fixture.summary
           }

    assert :ok = Transport.validate_boundary_fixture(fixture)
  end

  test "keeps targetless history transitions portable without fake screen ids" do
    fixture = Transport.boundary_fixture!("history_transition--back")

    assert fixture.summary.targetless?

    assert fixture.descriptor.target == %{
             navigation: %{
               action: :go_back,
               kind: :history_transition,
               metadata: %{source: :header}
             }
           }

    assert :ok = Transport.validate_boundary_extensions(fixture.extensions)
  end

  test "rejects leaked router syntax and missing required canonical fields" do
    assert {:error, {:forbidden_navigation_keys, [:route]}} =
             Transport.validate_boundary_extensions(%{
               unified_iur_boundary: %{
                 family: :navigation,
                 intent: :open_settings_screen,
                 source_context: %{element_id: "settings-link"},
                 target: %{navigation: %{action: :navigate_to, route: "/settings"}},
                 metadata: %{}
               },
               unified_iur_boundary_summary: %{}
             })

    assert {:error, {:missing_field, :screen}} =
             Transport.validate_boundary_extensions(%{
               unified_iur_boundary: %{
                 family: :navigation,
                 intent: :open_settings_screen,
                 source_context: %{element_id: "settings-link"},
                 target: %{navigation: %{action: :navigate_to}},
                 metadata: %{}
               },
               unified_iur_boundary_summary: %{
                 family: :navigation,
                 intent: :open_settings_screen,
                 action: :navigate_to,
                 screen: nil,
                 modal: nil,
                 params?: false,
                 targetless?: true
               }
             })
  end
end
