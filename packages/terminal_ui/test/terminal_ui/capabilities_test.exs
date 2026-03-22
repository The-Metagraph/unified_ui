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
    assert raw.unicode
    assert raw.mouse
    assert tty.degradation_profile == :fallback_terminal
    refute tty.unicode
    refute tty.mouse
    assert tty.keyboard_alternatives == [:inline_menu_selection, :ctrl_resize, :arrow_navigation]

    assert :unicode in tty_diagnostics.degraded_capabilities
    assert :mouse in tty_diagnostics.degraded_capabilities
    assert :paste in tty_diagnostics.degraded_capabilities
    assert :color in tty_diagnostics.degraded_capabilities
    assert tty_diagnostics.profile == :fallback_terminal
  end
end
