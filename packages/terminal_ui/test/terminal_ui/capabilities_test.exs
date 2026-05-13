defmodule TerminalUi.CapabilitiesTest do
  use ExUnit.Case, async: true

  test "backend selection exposes richer and fallback seams deterministically" do
    assert {:ok, :raw} = TerminalUi.Backend.select()
    assert {:ok, :raw} = TerminalUi.Backend.select(backend_mode: :auto, raw_supported: true)
    assert {:ok, :tty} = TerminalUi.Backend.select(backend_mode: :auto, raw_supported: false)
    assert {:ok, :tty} = TerminalUi.Backend.select(backend_mode: :tty)

    assert {:error, {:unsupported_backend_mode, :bogus}} =
             TerminalUi.Backend.select(backend_mode: :bogus)
  end

  test "backend modules expose bounded callback and capability summaries" do
    assert TerminalUi.Backend.modules() == [TerminalUi.Backend.RawMode, TerminalUi.Backend.Tty]

    assert TerminalUi.Backend.adapter_summary(:raw).mouse
    refute TerminalUi.Backend.adapter_summary(:tty).mouse
    assert :paste in TerminalUi.Backend.adapter_summary(:raw).callbacks

    assert :inline_menu_selection in TerminalUi.Backend.adapter_summary(:tty).keyboard_alternatives

    assert :raw_to_tty == TerminalUi.Backend.selection_contract().fallback_rule
  end

  test "capability snapshots and diagnostics keep degradation explicit" do
    raw = TerminalUi.Capabilities.snapshot(backend_mode: :raw)
    tty = TerminalUi.Capabilities.snapshot(backend_mode: :tty)
    tty_diagnostics = TerminalUi.Capabilities.diagnostics(backend_mode: :tty)

    assert raw.degradation_profile == :rich_terminal
    assert raw.color_mode == :rich_color
    assert raw.glyph_set == :unicode
    assert raw.unicode
    assert raw.mouse
    assert raw.positioning
    assert raw.canvas
    assert tty.degradation_profile == :fallback_terminal
    assert tty.color_mode == :limited_color
    assert tty.glyph_set == :ascii
    refute tty.unicode
    refute tty.mouse
    refute tty.positioning
    refute tty.canvas

    assert tty.keyboard_alternatives == [
             :inline_menu_selection,
             :ctrl_resize,
             :arrow_navigation,
             :inline_overlay,
             :paged_scroll,
             :inline_disclosure,
             :linearized_collection,
             :linearized_form,
             :inline_text_prompt
           ]

    assert :unicode in tty_diagnostics.degraded_capabilities
    assert :mouse in tty_diagnostics.degraded_capabilities
    assert :paste in tty_diagnostics.degraded_capabilities
    assert :color in tty_diagnostics.degraded_capabilities
    assert :positioning in tty_diagnostics.degraded_capabilities
    assert :canvas in tty_diagnostics.degraded_capabilities
    assert tty_diagnostics.profile == :fallback_terminal
    assert tty_diagnostics.fallback_modes.overlay == :inline_overlay
    assert tty_diagnostics.fallback_modes.scroll == :paged_scroll
    assert :overlay_presentation in tty_diagnostics.allowed_variation
    assert tty_diagnostics.degradation_plan.canvas_mode == :ascii_canvas
    assert TerminalUi.Degradation in tty_diagnostics.module_boundaries.capability_modules
  end
end
