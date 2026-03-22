defmodule TerminalUi.InspectionContinuityTest do
  use ExUnit.Case, async: true

  test "inspection surfaces summarize styles, themes, and degradation state" do
    native_screen = %{
      id: "styled-inspection",
      title: "Styled Inspection",
      theme: :high_contrast,
      root:
        TerminalUi.Widgets.column("styled-root", [
          TerminalUi.Widgets.text("title", "Styled",
            theme: :high_contrast,
            semantic_role: :title
          ),
          TerminalUi.Widgets.button("save", "Save", theme: :high_contrast, variant: :accented)
        ])
    }

    assert {:ok, state} =
             TerminalUi.Runtime.mount_native_screen(native_screen, backend_mode: :tty)

    snapshot = TerminalUi.Inspection.runtime_snapshot(state)

    assert snapshot.runtime.theme == :high_contrast
    assert snapshot.capabilities.snapshot.degradation_profile == :fallback_terminal
    assert :high_contrast in snapshot.style.themes
    assert Enum.any?(snapshot.style.style_nodes, &(&1.id == "save"))
    assert snapshot.degradation.plan.overlay_mode == :inline_overlay
  end

  test "continuity surfaces compare native-canonical and cross-capability execution deterministically" do
    native_screen = %{
      id: "styled-parity",
      title: "Styled Parity",
      theme: :high_contrast,
      root:
        TerminalUi.Widgets.column("styled-root", [
          TerminalUi.Widgets.text("title", "Styled", theme: :high_contrast),
          TerminalUi.Widgets.button("save", "Save", theme: :high_contrast)
        ])
    }

    canonical_screen =
      UnifiedIUR.Layout.column(
        [
          UnifiedIUR.Widgets.Foundational.text("Styled", id: "title"),
          UnifiedIUR.Widgets.Foundational.button("Save", id: "save")
        ],
        id: "styled-root"
      )

    assert {:ok, native_raw} =
             TerminalUi.Runtime.mount_native_screen(native_screen, backend_mode: :raw)

    assert {:ok, canonical_raw} =
             TerminalUi.Runtime.mount_iur_screen(canonical_screen,
               backend_mode: :raw,
               theme: :high_contrast
             )

    assert {:ok, native_tty} =
             TerminalUi.Runtime.mount_native_screen(native_screen, backend_mode: :tty)

    continuity = TerminalUi.Continuity.compare(native_raw, canonical_raw)
    capability_continuity = TerminalUi.Continuity.compare_capabilities(native_raw, native_tty)

    assert continuity.continuity.widget_identity_match?
    assert continuity.continuity.theme_resolution_match?
    assert continuity.continuity.style_resolution_match?
    assert capability_continuity.continuity.widget_identity_match?
    assert capability_continuity.continuity.theme_resolution_match?
    assert capability_continuity.continuity.style_resolution_match?
    assert capability_continuity.continuity.validation.status == :pass
  end
end
