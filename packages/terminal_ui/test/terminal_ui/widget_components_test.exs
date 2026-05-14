defmodule TerminalUi.WidgetComponentsTest do
  use ExUnit.Case, async: true

  alias TerminalUi.Renderer
  alias TerminalUi.Widgets.Components
  alias UnifiedIUR.RuntimeParity

  test "native component constructors expose terminal models and fallback metadata" do
    composer =
      TerminalUi.Widgets.chat_composer("composer", [],
        value: "Draft",
        on_send: %{intent: :send_message}
      )

    header =
      TerminalUi.Widgets.sticky_frosted_header(
        "header",
        [TerminalUi.Widgets.text("title", "Operations")],
        title: "Operations"
      )

    redline =
      TerminalUi.Widgets.redline_inline("redline", [
        %{state: :insert, text: "<script>kept as text</script>"}
      ])

    assert composer.kind == :chat_composer
    assert composer.family == :component
    assert composer.metadata.focusable
    assert composer.events.submit == %{intent: :send_message}

    assert header.metadata.degradation_strategy == :plain_header
    assert header.styles.degradation == :plain_header

    assert redline.attributes.text_safety == %{content: :plain_text}
    assert redline.metadata.degradation_strategy == :plain_redline_tokens
    assert TerminalUi.Widgets.validation_state().widget_components == :ready
  end

  test "canonical parity fixtures map into TerminalUi component widgets" do
    coverage =
      RuntimeParity.coverage_report(:terminal_ui, Renderer.supported_kinds(),
        degraded_kinds: Components.degraded_kinds()
      )

    assert coverage.complete?
    assert coverage.degraded?
    assert :sticky_frosted_header in coverage.degraded_kinds

    for fixture <- RuntimeParity.fixtures() do
      assert {:ok, widget} = Renderer.render(fixture.element)

      rendered_kinds =
        widget
        |> flatten_widgets()
        |> Enum.map(& &1.kind)

      for expected_kind <- fixture.expected.kinds do
        assert expected_kind in rendered_kinds
      end
    end
  end

  test "component fixtures mount through the shared terminal runtime with explicit fallbacks" do
    for fixture <- RuntimeParity.fixtures() do
      assert {:ok, runtime_state} =
               TerminalUi.Runtime.mount_iur_screen(fixture.element, backend_mode: :tty)

      assert runtime_state.source_kind == :canonical
      assert runtime_state.realization.diagnostics.capability_profile == :fallback_terminal
      assert runtime_state.realization.cell_surface != []

      fallback_kinds =
        runtime_state.realization.fallbacks
        |> Enum.map(& &1.kind)

      assert Enum.all?(fallback_kinds, &(&1 in Components.degraded_kinds()))
    end
  end

  test "component degradation summaries preserve terminal fallback meaning" do
    tty_summary = TerminalUi.Degradation.component_summary(backend_mode: :tty)
    raw_summary = TerminalUi.Degradation.component_summary(backend_mode: :raw)

    assert tty_summary.avatar == :initials_avatar
    assert tty_summary.segmented_progress_bar == :ascii_progress
    assert tty_summary.code_block_syntax_highlighted == :plain_code_tokens
    assert raw_summary == %{}

    assert :component_visual_fallback in TerminalUi.Capabilities.allowed_variation(
             TerminalUi.Capabilities.snapshot(backend_mode: :tty)
           )
  end

  defp flatten_widgets(widget) do
    [widget | Enum.flat_map(widget.children, &flatten_widgets/1)]
  end
end
