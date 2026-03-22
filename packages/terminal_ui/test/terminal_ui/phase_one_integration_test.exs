defmodule TerminalUi.PhaseOneIntegrationTest do
  use ExUnit.Case, async: true

  alias TerminalUi.Runtime.Error
  alias UnifiedIUR.Element

  test "package exposes phase one entrypoints without application takeover" do
    assert TerminalUi.widgets() == TerminalUi.Widgets
    assert TerminalUi.runtime() == TerminalUi.Runtime
    assert TerminalUi.backend() == TerminalUi.Backend
    assert TerminalUi.capabilities() == TerminalUi.Capabilities
    assert TerminalUi.renderer() == TerminalUi.Renderer
    assert TerminalUi.transport() == TerminalUi.Transport
    assert TerminalUi.tooling() == TerminalUi.Tooling
    assert TerminalUi.Renderer.accepts() == Element
    refute Keyword.has_key?(TerminalUi.MixProject.application(), :mod)
  end

  test "minimal native screens boot through the shared runtime backbone" do
    root =
      TerminalUi.Widgets.column("workspace-screen", [
        TerminalUi.Widgets.text("workspace-title", "Workspace", fg: :cyan),
        TerminalUi.Widgets.button("save-workspace", "Save", on_press: %{intent: :save_workspace})
      ])

    screen = %{id: "workspace", title: "Workspace", root: root}

    assert {:ok, state} = TerminalUi.Runtime.mount_native_screen(screen, backend_mode: :raw)
    assert state.runtime_id == "terminal-ui:workspace"
    assert state.screen_id == "workspace"
    assert state.source_kind == :native
    assert state.backend_mode == :raw
    assert state.root == root
    assert state.validation_state == :foundational_realization_ready
    assert state.screen.layout.composition == :foundational_shared_runtime
    assert state.realization.validation_state == :foundational_ready
    assert state.focus.current == "save-workspace"
    assert state.capabilities.degradation_profile == :rich_terminal
    assert state.event_loop.input_dispatch == :scaffold_ready
    assert state.event_loop.screen_id == "workspace"
    assert state.backend_adapter.mode == :raw
  end

  test "invalid boot data and unsupported canonical constructs fail with deterministic diagnostics" do
    invalid_screen = %{id: "broken", title: "Broken", root: %{label: "missing widget contract"}}

    assert {:error, %Error{} = invalid_root_error} =
             TerminalUi.Runtime.mount_native_screen(invalid_screen, backend_mode: :raw)

    assert invalid_root_error.reason == :invalid_screen_root
    assert invalid_root_error.details.root == %{label: "missing widget contract"}

    valid_screen = %{id: "screen", title: "Screen", root: TerminalUi.Widgets.text("title", "Ok")}

    assert {:error, %Error{} = invalid_backend_error} =
             TerminalUi.Runtime.mount_native_screen(valid_screen, backend_mode: :serial)

    assert invalid_backend_error.reason == :unsupported_backend_mode
    assert invalid_backend_error.details.backend_mode == :serial

    element = Element.new(:widget, :table, id: "status")

    assert {:error, %Error{} = canonical_error} =
             TerminalUi.Runtime.mount_iur_screen(element, backend_mode: :raw)

    assert canonical_error.reason == :unsupported_canonical_construct
    assert canonical_error.details.kind == :table
  end

  test "reference and info helpers expose runtime, capability, and backend seams without renderer coverage" do
    reference = TerminalUi.reference()
    summary = TerminalUi.info()

    assert reference.widgets.validation_state.direct_native_scaffold == :ready
    assert reference.runtime.validation_state == :foundational_realization_ready
    assert reference.backend.modes == [:raw, :tty]
    assert reference.transport.modes == [:native_local, :canonical_boundary]
    assert :capability_snapshot in reference.runtime.capabilities
    assert :foundational_canonical_mapping in reference.renderer.responsibilities
    assert :rich_terminal in reference.capabilities.profiles

    assert summary.package == :terminal_ui
    assert summary.runtime.validation_state == :foundational_realization_ready
    assert :layout in summary.widgets.families
    assert :fallback_terminal in summary.capabilities.profiles
    assert :runtime_review in summary.tooling.workflows
  end
end
