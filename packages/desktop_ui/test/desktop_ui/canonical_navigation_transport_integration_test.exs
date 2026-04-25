defmodule DesktopUi.CanonicalNavigationTransportIntegrationTest do
  use ExUnit.Case, async: true

  alias Jido.Signal
  alias DesktopUi.Transport
  alias UnifiedIUR.Interactions.Transport, as: BoundaryTransport

  test "consumes shared modal-transition fixtures without runtime-module identifiers" do
    fixture = BoundaryTransport.boundary_fixture!("modal_transition--settings_dialog")

    assert {:ok, translation} =
             Transport.from_interaction(
               fixture.interaction,
               platform_target: :linux,
               widget_id: "settings-trigger",
               runtime_id: "desktop-ui:workspace",
               screen: "workspace",
               payload: fixture.signal_data
             )

    assert :ok = BoundaryTransport.validate_boundary_fixture(fixture)
    assert translation.target == fixture.descriptor.target
    assert %Signal{} = translation.signal
    assert translation.signal.data == fixture.signal_data
    assert translation.signal.extensions.desktop_ui_target == fixture.descriptor.target
    refute translation.signal.extensions.desktop_ui_target.navigation[:module]
  end
end
