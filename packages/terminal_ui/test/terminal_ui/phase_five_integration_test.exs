defmodule TerminalUi.PhaseFiveIntegrationTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Element

  test "native and canonical styling resolve through the same shared theme and style model" do
    native_screen = TerminalUi.Examples.native_styled_screen()
    canonical_screen = TerminalUi.Examples.canonical_styled_screen()

    assert {:ok, native_state} =
             TerminalUi.Runtime.mount_native_screen(native_screen, backend_mode: :raw)

    assert {:ok, canonical_state} =
             TerminalUi.Runtime.mount_iur_screen(canonical_screen,
               backend_mode: :raw,
               theme: :high_contrast
             )

    native_snapshot = TerminalUi.Inspection.runtime_snapshot(native_state)
    canonical_snapshot = TerminalUi.Inspection.runtime_snapshot(canonical_state)
    continuity = TerminalUi.Continuity.compare(native_state, canonical_state)

    native_save = Enum.find(native_snapshot.style.style_nodes, &(&1.id == "styled-save"))
    canonical_save = Enum.find(canonical_snapshot.style.style_nodes, &(&1.id == "styled-save"))

    assert native_snapshot.runtime.theme == :high_contrast
    assert canonical_snapshot.runtime.theme == :high_contrast
    assert native_save.resolved_styles.variant == :accented
    assert canonical_save.resolved_styles.variant == :accented
    assert continuity.continuity.widget_identity_match?
    assert continuity.continuity.theme_resolution_match?
    assert continuity.continuity.style_resolution_match?
    assert continuity.continuity.validation.status == :pass
  end

  test "unicode and color degradation remain explicit without changing shared semantics" do
    native_screen = TerminalUi.Examples.native_styled_screen()
    canonical_screen = TerminalUi.Examples.canonical_styled_screen()

    assert {:ok, native_raw} =
             TerminalUi.Runtime.mount_native_screen(native_screen, backend_mode: :raw)

    assert {:ok, native_tty} =
             TerminalUi.Runtime.mount_native_screen(native_screen, backend_mode: :tty)

    assert {:ok, canonical_raw} =
             TerminalUi.Runtime.mount_iur_screen(canonical_screen,
               backend_mode: :raw,
               theme: :high_contrast
             )

    assert {:ok, canonical_tty} =
             TerminalUi.Runtime.mount_iur_screen(canonical_screen,
               backend_mode: :tty,
               theme: :high_contrast
             )

    native_capability = TerminalUi.Continuity.compare_capabilities(native_raw, native_tty)

    canonical_capability =
      TerminalUi.Continuity.compare_capabilities(canonical_raw, canonical_tty)

    native_tty_snapshot = TerminalUi.Inspection.runtime_snapshot(native_tty)
    canonical_tty_snapshot = TerminalUi.Inspection.runtime_snapshot(canonical_tty)

    assert native_tty_snapshot.capabilities.snapshot.glyph_set == :ascii
    assert native_tty_snapshot.capabilities.snapshot.color_mode == :limited_color
    assert native_tty_snapshot.degradation.plan.canvas_mode == :ascii_canvas
    assert canonical_tty_snapshot.degradation.plan.canvas_mode == :ascii_canvas

    assert native_raw.realization.cell_surface |> Enum.map(& &1.kind) |> Enum.sort() ==
             native_tty.realization.cell_surface |> Enum.map(& &1.kind) |> Enum.sort()

    assert canonical_raw.realization.cell_surface |> Enum.map(& &1.kind) |> Enum.sort() ==
             canonical_tty.realization.cell_surface |> Enum.map(& &1.kind) |> Enum.sort()

    assert native_capability.continuity.validation.status == :pass
    assert canonical_capability.continuity.validation.status == :pass
  end

  test "inspection and continuity helpers surface semantic drift deterministically" do
    native_screen = TerminalUi.Examples.native_styled_screen()

    drifted_canonical =
      Element.new(:layout, :column,
        id: "styled-root",
        children: [
          Element.new(:widget, :text,
            id: "styled-title",
            attributes: %{text: "Styled Workspace"}
          ),
          Element.new(:widget, :button, id: "styled-save", attributes: %{text: "Deploy"})
        ]
      )

    assert {:ok, native_state} =
             TerminalUi.Runtime.mount_native_screen(native_screen, backend_mode: :raw)

    assert {:ok, drifted_state} =
             TerminalUi.Runtime.mount_iur_screen(drifted_canonical,
               backend_mode: :raw,
               theme: :high_contrast
             )

    report = TerminalUi.Continuity.compare(native_state, drifted_state)

    assert report.continuity.validation.status == :fail
    refute report.continuity.style_resolution_match?
    assert Enum.any?(report.diagnostics, &(&1.reason == :resolved_style_mismatch))
  end
end
