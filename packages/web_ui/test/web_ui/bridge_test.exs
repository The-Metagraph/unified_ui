defmodule WebUi.BridgeTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Element
  alias WebUi.FrontendRuntime.{Boot, Message, Model}
  alias WebUi.ServerRuntime

  test "server runtime exposes deterministic hydration envelopes" do
    assert {:ok, state} =
             WebUi.Runtime.mount_native_screen(WebUi.Examples.native_counter_screen())

    envelope = ServerRuntime.frontend_envelope(state)

    assert envelope.kind == :hydrate
    assert envelope.payload.runtime_id == state.runtime_id
    assert envelope.payload.boundary_mode == :native_local
  end

  test "server runtime rejects unsupported frontend messages with deterministic diagnostics" do
    assert {:ok, state} =
             WebUi.Runtime.mount_native_screen(WebUi.Examples.native_counter_screen())

    assert {:error, %ServerRuntime.Error{reason: :unsupported_frontend_message}} =
             ServerRuntime.receive_frontend_message(
               state,
               Message.new(:hydrate, %{runtime_id: state.runtime_id})
             )
  end

  test "frontend runtime rejects non-hydrate boot messages before hydration" do
    message = Message.new(:event, %{family: :click, runtime_event: "click:open"})

    assert {:error, %WebUi.FrontendRuntime.Error{reason: :invalid_boot_order}} =
             Boot.hydrate_message(message)
  end

  test "server runtime rejects malformed boundary routing" do
    assert {:ok, state} =
             WebUi.Runtime.mount_native_screen(WebUi.Examples.native_counter_screen())

    assert {:error, %ServerRuntime.Error{reason: :missing_boundary_signal}} =
             ServerRuntime.handle_event(state, %{
               boundary: :boundary,
               family: :click,
               runtime_event: "click:submit",
               signal: nil
             })
  end

  test "frontend bridge decodes incoming envelopes through the shared message contract" do
    model = %Model{
      runtime_id: "incoming-runtime",
      title: "Incoming Screen",
      source_kind: :native,
      boundary_mode: :native_local,
      tree: %{},
      local_state: %{focused_id: nil, flash: nil},
      diagnostics: [],
      metadata: %{}
    }

    {:ok, event_message} =
      WebUi.FrontendRuntime.Bridge.outgoing_interaction(model,
        family: :click,
        intent: :open,
        boundary: :local,
        widget_id: :open_button
      )

    assert {:ok, %{kind: :event, payload: %{family: :click}}} =
             WebUi.FrontendRuntime.Bridge.incoming_message(event_message)
  end

  test "frontend bridge infers canonical boundary translation for canonical models" do
    model = %Model{
      runtime_id: "canonical-runtime",
      title: "Canonical Screen",
      source_kind: :canonical,
      boundary_mode: :canonical_boundary,
      tree: %{},
      local_state: %{focused_id: nil, flash: nil},
      diagnostics: [],
      metadata: %{}
    }

    {:ok, event_message} =
      WebUi.FrontendRuntime.Bridge.outgoing_interaction(model,
        family: :command,
        intent: :run,
        widget_id: :ops_command_palette
      )

    assert event_message.metadata.boundary == :boundary
    assert event_message.payload.family == :command
    assert event_message.payload.type == "web_ui.command.run"
  end

  test "frontend runtime accepts canonical hydration envelopes" do
    element = Element.new(:widget, :text, id: :canonical_message, attributes: %{content: "Hi"})
    assert {:ok, state} = WebUi.Runtime.mount_iur_screen(element)

    envelope = ServerRuntime.frontend_envelope(state)

    assert {:ok, model} = Boot.hydrate_message(envelope)
    assert model.source_kind == :canonical
    assert model.tree.kind == :text
  end
end
