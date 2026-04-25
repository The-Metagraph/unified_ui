defmodule LiveUi.CanonicalNavigationTransportIntegrationTest do
  use ExUnit.Case, async: true

  alias Jido.Signal
  alias UnifiedIUR.Interactions.Transport, as: BoundaryTransport

  test "consumes shared screen-transition fixtures without browser-only route fields" do
    fixture = BoundaryTransport.boundary_fixture!("screen_transition--settings_profile")

    assert {:ok, translation} =
             LiveUi.Signals.from_interaction(
               fixture.interaction,
               screen: :workspace,
               mode: :screen,
               boundary: :boundary,
               payload: fixture.signal_data
             )

    assert :ok = BoundaryTransport.validate_boundary_fixture(fixture)
    assert translation.target == fixture.descriptor.target
    assert %Signal{} = translation.signal
    assert translation.signal.data == fixture.signal_data
    assert translation.signal.extensions.live_ui_target == fixture.descriptor.target
    refute translation.signal.extensions.live_ui_target.navigation[:route]
  end
end
