defmodule TerminalUi.RuntimeTest do
  use ExUnit.Case, async: true

  alias TerminalUi.Runtime
  alias UnifiedIUR.Element

  test "runtime exposes the phase one backbone modules and capabilities" do
    assert TerminalUi.Runtime.Boot in Runtime.modules()
    assert TerminalUi.Runtime.EventLoop in Runtime.modules()
    assert TerminalUi.Runtime.Screen in Runtime.modules()
    assert TerminalUi.Runtime.Realization in Runtime.modules()
    assert TerminalUi.Runtime.State in Runtime.modules()
    assert TerminalUi.Layout in Runtime.modules()
    assert TerminalUi.Layer in Runtime.modules()
    assert Runtime.validation_state() == :advanced_runtime_ready
    assert :shared_realization_model in Runtime.capabilities()
    assert :advanced_display_systems in Runtime.capabilities()
    assert :layered_runtime_behavior in Runtime.capabilities()
    assert :canonical_foundational_rendering in Runtime.capabilities()
  end

  test "runtime mounts a native screen through the shared term_ui-backed backbone" do
    screen = %{
      id: :welcome,
      title: "Welcome",
      root: TerminalUi.Widgets.text("welcome_text", "Hello")
    }

    assert {:ok, runtime_state} =
             Runtime.mount_native_screen(screen, runtime_id: "terminal-ui:welcome")

    assert runtime_state.runtime_id == "terminal-ui:welcome"
    assert runtime_state.screen_id == "welcome"
    assert runtime_state.source_kind == :native
    assert runtime_state.backend_mode == :raw
    assert runtime_state.capabilities.backend_mode == :raw
    assert runtime_state.backend_adapter.runtime_module == TermUI.Runtime
    assert runtime_state.event_loop.input_dispatch == :scaffold_ready
    assert runtime_state.screen.layout.composition == :foundational_shared_runtime
    assert runtime_state.realization.validation_state == :foundational_ready
    assert runtime_state.validation_state == :foundational_realization_ready

    assert runtime_state.realization.cell_surface == [
             %{widget_id: "welcome_text", content: "Hello", kind: :text, family: :content}
           ]

    assert runtime_state.lifecycle.boot == :initialized
  end

  test "runtime returns deterministic diagnostics for malformed screens and unsupported canonical constructs" do
    assert {:error, %TerminalUi.Runtime.Error{reason: :invalid_screen}} =
             Runtime.mount_native_screen(%{id: :broken, title: "Broken"})

    element = Element.new(:widget, :table, id: :hello, attributes: %{})

    assert {:error, %TerminalUi.Runtime.Error{reason: :unsupported_canonical_construct}} =
             Runtime.mount_iur_screen(element)
  end
end
