defmodule WebUi.PhaseOneIntegrationTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Element
  alias WebUi.FrontendRuntime.{Boot, Message}
  alias WebUi.ServerRuntime

  test "package and split runtime entrypoints stay available without owning application startup" do
    assert WebUi.server() == WebUi.Server
    assert WebUi.frontend() == WebUi.Frontend
    assert WebUi.runtime() == WebUi.Runtime
    assert WebUi.renderer() == WebUi.Renderer
    assert WebUi.transport() == WebUi.Transport
  end

  test "minimal native screen mounts, hydrates, and renders through the backbone" do
    assert {:ok, runtime_state} =
             WebUi.Runtime.mount_native_screen(WebUi.Examples.native_counter_screen())

    envelope = ServerRuntime.frontend_envelope(runtime_state)
    assert {:ok, frontend_model} = Boot.hydrate_message(envelope)

    assert runtime_state.rendered_tree.kind == :stack
    assert frontend_model.tree.kind == :stack
    assert frontend_model.boundary_mode == :native_local
  end

  test "canonical screens reuse the same runtime and frontend flow" do
    element =
      Element.new(:widget, :button,
        id: :phase_one_button,
        attributes: %{label: "Continue"}
      )

    assert {:ok, runtime_state} = WebUi.Runtime.mount_iur_screen(element, runtime_id: "phase-one")
    assert {:ok, frontend_model} = WebUi.Runtime.hydrate_frontend(runtime_state)

    assert runtime_state.boundary_mode == :canonical_boundary
    assert frontend_model.tree.kind == :button
  end

  test "malformed widget declarations, hydration payloads, and wiring fail with deterministic diagnostics" do
    assert {:error, %ServerRuntime.Error{reason: :invalid_screen}} =
             WebUi.Runtime.mount_native_screen(%{id: :broken, title: "Broken"})

    assert {:error, %WebUi.FrontendRuntime.Error{reason: :invalid_hydration_payload}} =
             Boot.hydrate(%{runtime_id: "missing"})

    assert {:error, %ServerRuntime.Error{reason: :unsupported_frontend_message}} =
             ServerRuntime.receive_frontend_message(
               %WebUi.ServerRuntime.State{
                 runtime_id: "phase-one",
                 rendered_tree: WebUi.Widgets.text(:id, "ok")
               },
               Message.new(:hydrate, %{runtime_id: "phase-one"})
             )
  end

  test "reference helpers and inspection surfaces expose phase one boundaries without renderer coupling" do
    reference = WebUi.reference()
    info = WebUi.info()

    widget =
      WebUi.Widgets.button(:save, "Save",
        on_click: %{family: :click, intent: :save, boundary: :local}
      )

    assert :hydration_envelope in reference.runtime.bridge_boundaries
    assert reference.widgets.contract.metadata == [:label, :description, :role, :variant]
    assert info.bridge.boundaries == [:hydration_envelope, :event_envelope, :acknowledgement]
    assert WebUi.Info.widget_summary(widget).event_keys == [:click]
  end
end
