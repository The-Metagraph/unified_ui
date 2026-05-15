defmodule UnifiedUi.CssPhase3IntegrationTest do
  use ExUnit.Case, async: true

  alias UnifiedUi.Css

  defmodule PhaseThreeWorkspace do
    use UnifiedUi.Dsl

    identity do
      id(:css_phase_three_workspace)
      title("CSS Phase Three Workspace")
    end

    themes do
      css :styles do
        source("""
        #panel {
          color: #123456;
          background-color: white;
          padding: 4px 8px;
          border-radius: 2px;
          border-style: solid;
          font: italic bold 14px system-ui;
          animation: fade-in 200ms;
          background-image: url("remote.png");
        }

        button:disabled {
          opacity: 0.45;
          color: rgb(200, 201, 202);
        }
        """)
      end
    end

    composition do
      root(:css_phase_three_root)

      box :panel do
        button :save do
          label("Save")
          disabled?(true)
        end
      end
    end
  end

  test "lowers supported CSS declarations into normalized canonical style data" do
    translated = Css.translate_module(PhaseThreeWorkspace)
    panel = translated.styles_by_node.panel.default

    assert panel.foreground == %{mode: :rgb, red: 18, green: 52, blue: 86}
    assert panel.background == %{mode: :named, name: :white}
    assert panel.typography.font_weight == :bold
    assert panel.typography.font_size == %{value: 14, unit: :px}
    assert panel.typography.italic? == true
    assert panel.spacing.padding_left == %{value: 8, unit: :px}
    assert panel.border.radius == %{value: 2, unit: :px}
    assert panel.border.style == :solid
  end

  test "lowers state-scoped declarations and reports ignored unsupported CSS" do
    translated = Css.translate_module(PhaseThreeWorkspace)
    disabled = translated.styles_by_node.save.states.disabled

    assert disabled.visibility.opacity == 0.45
    assert disabled.foreground == %{mode: :rgb, red: 200, green: 201, blue: 202}

    diagnostic_kinds = Enum.map(translated.diagnostics, & &1.kind)
    assert :unsupported_property in diagnostic_kinds
    assert :unsafe_external_resource in diagnostic_kinds
  end
end
