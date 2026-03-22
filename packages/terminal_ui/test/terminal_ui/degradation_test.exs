defmodule TerminalUi.DegradationTest do
  use ExUnit.Case, async: true

  test "capability diagnostics expose explicit degradation planning" do
    raw = TerminalUi.Capabilities.snapshot(backend_mode: :raw)
    tty = TerminalUi.Capabilities.snapshot(backend_mode: :tty)
    tty_diagnostics = TerminalUi.Capabilities.diagnostics(backend_mode: :tty)
    tty_plan = TerminalUi.Degradation.plan(tty)

    assert TerminalUi.Capabilities.modules() == [TerminalUi.Capabilities, TerminalUi.Degradation]
    assert raw.color_mode == :rich_color
    assert raw.glyph_set == :unicode
    assert tty.color_mode == :limited_color
    assert tty.glyph_set == :ascii
    assert TerminalUi.Capabilities.color_modes() == [:rich_color, :limited_color]
    assert TerminalUi.Capabilities.glyph_modes() == [:unicode, :ascii]

    assert tty_plan.profile == :fallback_terminal
    assert tty_plan.glyph_set == :ascii
    assert tty_plan.overlay_mode == :inline_overlay
    assert tty_plan.canvas_mode == :ascii_canvas
    assert :glyph_fallback in tty_plan.allowed_variation

    assert tty_diagnostics.degradation_plan == tty_plan
    assert tty_diagnostics.module_boundaries.shared_runtime == [:runtime, :renderer, :transport]
    assert TerminalUi.Degradation in tty_diagnostics.module_boundaries.capability_modules
  end

  test "widget degradation decisions stay explicit and bounded by capability profile" do
    dialog = TerminalUi.Widgets.dialog("confirm", [TerminalUi.Widgets.text("body", "Confirm?")])

    canvas =
      TerminalUi.Widgets.canvas("topology", [%{kind: :cell, position: %{x: 0, y: 0}, text: "A"}])

    input = TerminalUi.Widgets.text_input("query", value: "status:ok")

    assert TerminalUi.Degradation.resolve(dialog, backend_mode: :raw) == nil
    assert TerminalUi.Degradation.resolve(dialog, backend_mode: :tty) == :inline_overlay
    assert TerminalUi.Degradation.resolve(canvas, backend_mode: :tty) == :ascii_canvas
    assert TerminalUi.Degradation.resolve(input, backend_mode: :tty) == nil

    diagnostics = TerminalUi.Degradation.diagnostics(backend_mode: :tty)

    assert diagnostics.profile == :fallback_terminal
    assert diagnostics.bounded_semantics.shared_runtime
    assert diagnostics.plan.pointer_mode == :keyboard_fallback
  end
end
