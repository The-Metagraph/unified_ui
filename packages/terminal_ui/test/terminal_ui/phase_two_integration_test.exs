defmodule TerminalUi.PhaseTwoIntegrationTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Element

  test "native and canonical foundational screens converge on the same shared runtime backbone" do
    native_screen = TerminalUi.Examples.native_foundational_screen()
    canonical_screen = TerminalUi.Examples.canonical_foundational_screen()

    assert {:ok, native_state} =
             TerminalUi.Runtime.mount_native_screen(native_screen, backend_mode: :raw)

    assert {:ok, canonical_state} =
             TerminalUi.Runtime.mount_iur_screen(canonical_screen, backend_mode: :raw)

    assert native_state.validation_state == :foundational_realization_ready
    assert canonical_state.validation_state == :foundational_realization_ready
    assert native_state.realization.validation_state == :foundational_ready
    assert canonical_state.realization.validation_state == :foundational_ready
    assert native_state.realization.focus_order == canonical_state.realization.focus_order

    assert Enum.map(native_state.realization.cell_surface, & &1.kind) ==
             Enum.map(canonical_state.realization.cell_surface, & &1.kind)

    assert native_state.screen.bindings.names == [:alerts, :query, :section, :selected_result]
    assert canonical_state.screen.bindings.names == [:alerts, :query, :section, :selected_result]
  end

  test "unsupported foundational widgets and invalid canonical bindings fail with deterministic diagnostics" do
    unsupported = Element.new(:widget, :calendar, id: "unsupported-calendar")

    assert {:error, %TerminalUi.Runtime.Error{} = unsupported_error} =
             TerminalUi.Runtime.mount_iur_screen(unsupported, backend_mode: :raw)

    assert unsupported_error.reason == :unsupported_canonical_construct
    assert unsupported_error.details.kind == :calendar

    invalid_bindings =
      Element.new(:widget, :text_input,
        id: "query",
        attributes: %{bindings: [%{invalid: true}]}
      )

    assert {:error, %TerminalUi.Runtime.Error{} = invalid_binding_error} =
             TerminalUi.Runtime.mount_iur_screen(invalid_bindings, backend_mode: :raw)

    assert invalid_binding_error.reason == :invalid_canonical_bindings
  end

  test "maintained examples and comparison helpers stay aligned with reference and info surfaces" do
    comparison = TerminalUi.Examples.foundational_comparison()
    reference = TerminalUi.reference()
    summary = TerminalUi.info()

    assert comparison.parity.focus_order_match?
    assert comparison.parity.cell_surface_kinds_match?
    assert comparison.parity.shared_runtime_backbone?
    assert :native_foundational in reference.examples.native_ids
    assert :canonical_foundational in reference.examples.canonical_ids
    assert :foundational_continuity in reference.examples.comparison_ids
    assert :foundational_continuity in summary.examples.comparison_ids
  end
end
