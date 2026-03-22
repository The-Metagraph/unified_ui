defmodule TerminalUi.PhaseThreeIntegrationTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Element

  test "advanced native and canonical terminal flows share the layered runtime model" do
    native_screen = TerminalUi.Examples.native_advanced_operations_screen()
    canonical_screen = TerminalUi.Examples.canonical_advanced_operations_screen()

    assert {:ok, native_raw} =
             TerminalUi.Runtime.mount_native_screen(native_screen, backend_mode: :raw)

    assert {:ok, native_tty} =
             TerminalUi.Runtime.mount_native_screen(native_screen, backend_mode: :tty)

    assert {:ok, canonical_raw} =
             TerminalUi.Runtime.mount_iur_screen(canonical_screen, backend_mode: :raw)

    assert {:ok, canonical_tty} =
             TerminalUi.Runtime.mount_iur_screen(canonical_screen, backend_mode: :tty)

    assert native_raw.validation_state == :advanced_runtime_ready
    assert canonical_raw.validation_state == :advanced_runtime_ready
    assert native_raw.realization.validation_state == :advanced_ready
    assert canonical_raw.realization.validation_state == :advanced_ready

    assert Enum.any?(native_raw.realization.layers, fn layer ->
             layer.role == :overlay
           end)

    assert Enum.any?(canonical_raw.realization.layers, fn layer ->
             layer.role == :overlay
           end)

    assert Enum.any?(native_raw.realization.viewport_regions, fn region ->
             region.kind == :viewport
           end)

    assert Enum.any?(canonical_raw.realization.viewport_regions, fn region ->
             region.kind == :viewport
           end)

    assert native_tty.realization.diagnostics.capability_profile == :fallback_terminal
    assert canonical_tty.realization.diagnostics.capability_profile == :fallback_terminal

    assert Enum.any?(native_tty.realization.fallbacks, fn fallback ->
             fallback.fallback == :inline_overlay
           end)

    assert Enum.any?(canonical_tty.realization.fallbacks, fn fallback ->
             fallback.fallback == :ascii_canvas
           end)
  end

  test "unsupported advanced constructs and invalid layered state fail deterministically" do
    broken_overlay = Element.new(:layer, :overlay, id: "broken-overlay")

    assert {:error, %TerminalUi.Runtime.Error{} = error} =
             TerminalUi.Runtime.mount_iur_screen(broken_overlay, backend_mode: :raw)

    assert error.reason == :unsupported_canonical_construct
    assert error.details.id == "broken-overlay"
    assert error.details.missing_slots == [:base]
  end

  test "advanced examples and capability comparison helpers keep bounded variation visible" do
    comparison = TerminalUi.Examples.advanced_comparison()
    capability = TerminalUi.Examples.advanced_capability_comparison()
    reference = TerminalUi.reference()
    summary = TerminalUi.info()

    assert comparison.id == :advanced_continuity
    assert comparison.parity.shared_runtime_backbone?
    assert comparison.parity.advanced_state_match?
    assert comparison.parity.layered_roles_match?
    assert comparison.parity.display_kinds_match?

    assert capability.id == :advanced_capability_continuity
    assert capability.parity.native_semantics_stable?
    assert capability.parity.canonical_semantics_stable?
    assert capability.parity.tty_fallbacks_explicit?
    assert capability.parity.allowed_variation_bounded?
    assert capability.native_tty.allowed_variation == capability.canonical_tty.allowed_variation

    assert :native_advanced_operations in reference.examples.native_ids
    assert :canonical_advanced_operations in reference.examples.canonical_ids
    assert :advanced_continuity in reference.examples.comparison_ids
    assert :advanced_capability_continuity in reference.examples.comparison_ids
    assert Map.has_key?(reference.examples.coverage_matrix.workflows, :advanced_review)
    assert :advanced_review in summary.examples.workflows
    assert :layering in summary.examples.categories
    assert :advanced_display_systems in reference.runtime.capabilities
    assert summary.layout.kinds == TerminalUi.Layout.kinds()
    assert summary.layer.kinds == TerminalUi.Layer.kinds()
  end
end
