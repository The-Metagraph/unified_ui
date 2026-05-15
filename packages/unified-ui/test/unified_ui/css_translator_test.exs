defmodule UnifiedUi.CssTranslatorTest do
  use ExUnit.Case, async: true

  alias UnifiedUi.Css
  alias UnifiedUi.Style

  defmodule TranslationWorkspace do
    use UnifiedUi.Dsl

    identity do
      id(:css_translation_workspace)
      title("CSS Translation Workspace")
    end

    themes do
      css :visuals do
        source("""
        #panel {
          color: #fff;
          background-color: rgb(0, 0, 0);
          border-color: #808080;
          font: italic bold 16px system-ui;
          font-weight: 700;
          font-style: italic;
          text-decoration: underline line-through;
          opacity: 0.8;
          padding: 12px 16px;
          width: 20rem;
          text-align: center;
          border-width: 1px;
          border-radius: 4px 8px;
          border-style: solid;
          transform: rotate(10deg);
        }

        button:disabled { opacity: 0.4; }
        """)
      end
    end

    composition do
      root(:css_translation_root)

      box :panel do
        button :save do
          label("Save")
          disabled?(true)
        end
      end
    end
  end

  test "translates supported CSS visual declarations into canonical style fields" do
    translated = Css.translate_module(TranslationWorkspace)
    panel_style = translated.styles_by_node.panel.default

    assert %Style{
             foreground: %{mode: :rgb, red: 255, green: 255, blue: 255},
             background: %{mode: :rgb, red: 0, green: 0, blue: 0},
             border_color: %{mode: :rgb, red: 128, green: 128, blue: 128},
             typography: %{
               font_weight: 700,
               font_size: %{value: 16, unit: :px},
               italic?: true,
               underline?: true,
               strikethrough?: true
             },
             visibility: %{opacity: 0.8},
             spacing: %{
               padding_top: %{value: 12, unit: :px},
               padding_right: %{value: 16, unit: :px},
               padding_bottom: %{value: 12, unit: :px},
               padding_left: %{value: 16, unit: :px}
             },
             sizing: %{width: %{value: 20, unit: :rem}},
             alignment: %{text_align: :center},
             border: %{
               width: %{value: 1, unit: :px},
               radius: %{
                 top: %{value: 4, unit: :px},
                 right: %{value: 8, unit: :px},
                 bottom: %{value: 4, unit: :px},
                 left: %{value: 8, unit: :px}
               },
               style: :solid
             }
           } = panel_style
  end

  test "translates state-scoped declarations and reports unsupported properties" do
    translated = Css.translate_module(TranslationWorkspace)

    assert translated.styles_by_node.save.states.disabled.visibility == %{opacity: 0.4}

    assert Enum.any?(translated.diagnostics, fn diagnostic ->
             diagnostic.kind == :unsupported_property and
               diagnostic.source.property == "transform"
           end)
  end
end
