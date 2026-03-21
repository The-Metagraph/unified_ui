defmodule WebUi.TransportTest do
  use ExUnit.Case, async: true

  alias Jido.Signal
  alias WebUi.FrontendRuntime.Model

  test "transport keeps direct native events local when the boundary is not crossed" do
    assert {:ok, translation} =
             WebUi.Transport.from_native_event(
               family: :click,
               intent: :open,
               widget_id: :dialog_trigger,
               boundary: :local
             )

    assert translation.boundary == :local
    assert translation.family == :click

    assert {:ok, %{native_event: %{widget_id: :dialog_trigger}}} =
             WebUi.Transport.to_server_message(translation)
  end

  test "transport emits canonical boundary events as jido signals" do
    assert {:ok, translation} =
             WebUi.Transport.from_native_event(
               family: :submit,
               intent: :save,
               widget_id: :save_button,
               screen: "settings",
               payload: %{valid: true},
               boundary: :boundary
             )

    assert translation.boundary == :boundary
    assert %Signal{} = translation.signal

    assert {:ok, message} = WebUi.Transport.to_server_message(translation.signal)
    assert message.type == "web_ui.submit.save"
    assert message.family == :submit
    refute Map.has_key?(message, :native_event)
  end

  test "frontend bridge builds outgoing envelopes through the shared transport" do
    model = %Model{
      runtime_id: "bridge-runtime",
      title: "Bridge Screen",
      source_kind: :native,
      boundary_mode: :canonical_boundary,
      tree: %{},
      local_state: %{focused_id: nil, flash: nil},
      diagnostics: [],
      metadata: %{}
    }

    assert {:ok, envelope} =
             WebUi.FrontendRuntime.Bridge.outgoing_interaction(model,
               family: :navigation,
               intent: :open_settings,
               boundary: :boundary,
               widget_id: :settings_link
             )

    assert envelope.kind == :event
    assert envelope.runtime_id == "bridge-runtime"
    assert envelope.payload.family == :navigation
    assert envelope.payload.runtime_event == "navigation:open_settings"
  end
end
