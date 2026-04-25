defmodule TerminalUi.CanonicalNavigationTransportIntegrationTest do
  use ExUnit.Case, async: true

  alias Jido.Signal
  alias TerminalUi.Transport
  alias UnifiedIUR.Interactions.Transport, as: BoundaryTransport

  test "consumes shared history-transition fixtures without fake screen identifiers" do
    fixture = BoundaryTransport.boundary_fixture!("history_transition--back")

    assert {:ok, translation} =
             Transport.from_interaction(
               fixture.interaction,
               backend_mode: :raw,
               input_family: :key,
               widget_id: "history-button",
               runtime_id: "terminal-ui:workspace",
               screen: "workspace",
               payload: fixture.signal_data
             )

    assert :ok = BoundaryTransport.validate_boundary_fixture(fixture)
    assert translation.target == fixture.descriptor.target
    assert %Signal{} = translation.signal
    assert translation.signal.data == fixture.signal_data
    assert translation.signal.extensions.terminal_ui_target == fixture.descriptor.target
    refute Map.has_key?(translation.target.navigation, :screen)
    refute Map.has_key?(translation.target.navigation, :modal)
  end
end
