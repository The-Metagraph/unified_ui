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
          color: white;
          background-color: black;
          border-color: gray;
          font-weight: 700;
          font-style: italic;
          text-decoration: underline line-through;
          opacity: 0.8;
          padding: 12px;
          width: 20rem;
          text-align: center;
          border-width: 1px;
          border-radius: 4px;
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
             foreground: %{mode: :named, name: "white"},
             background: %{mode: :named, name: "black"},
             border_color: %{mode: :named, name: "gray"},
             typography: %{
               font_weight: 700,
               italic?: true,
               underline?: true,
               strikethrough?: true
             },
             visibility: %{opacity: "0.8"},
             spacing: %{padding: "12px"},
             sizing: %{width: "20rem"},
             alignment: %{text_align: "center"},
             border: %{width: "1px", radius: "4px", style: "solid"}
           } = panel_style
  end

  test "translates state-scoped declarations and reports unsupported properties" do
    translated = Css.translate_module(TranslationWorkspace)

    assert translated.styles_by_node.save.states.disabled.visibility == %{opacity: "0.4"}

    assert Enum.any?(translated.diagnostics, fn diagnostic ->
             diagnostic.kind == :unsupported_property and
               diagnostic.source.property == "transform"
           end)
  end
end
