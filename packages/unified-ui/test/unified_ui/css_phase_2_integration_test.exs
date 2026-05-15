defmodule UnifiedUi.CssPhase2IntegrationTest do
  use ExUnit.Case, async: true

  alias UnifiedUi.Css

  defmodule PhaseTwoWorkspace do
    use UnifiedUi.Dsl

    identity do
      id(:css_phase_two_workspace)
      title("CSS Phase Two Workspace")
    end

    themes do
      css :selectors do
        source("""
        button { color: gray; }
        .primary { color: blue; }
        #save { color: green; }
        #panel > button:disabled { opacity: 0.5; }
        #panel .primary { background-color: navy; }
        [role=button] { color: red; }
        .missing { color: orange; }
        """)
      end
    end

    composition do
      root(:css_phase_two_root)

      box :panel do
        button :save do
          label("Save")
          class("primary")
          disabled?(true)
        end
      end
    end
  end

  test "matches supported selectors and reports unsupported or unmatched selectors" do
    result = Css.match_module(PhaseTwoWorkspace, no_match_diagnostics?: true)

    assert Enum.map(result.matches, &{&1.selector_text, &1.node_id, &1.state}) == [
             {"button", :save, nil},
             {".primary", :save, nil},
             {"#save", :save, nil},
             {"#panel > button:disabled", :save, :disabled},
             {"#panel .primary", :save, nil}
           ]

    assert Enum.map(result.diagnostics, & &1.kind) == [
             :unsupported_selector,
             :selector_no_match
           ]
  end

  test "resolves cascade specificity, source order, state scopes, and source precedence" do
    cascade = Css.cascade_module(PhaseTwoWorkspace, no_match_diagnostics?: true)
    save_styles = cascade.styles_by_node.save

    assert save_styles.default["color"].value == "green"
    assert save_styles.default["color"].selector_text == "#save"
    assert save_styles.default["background-color"].selector_text == "#panel .primary"
    assert save_styles.states.disabled["opacity"].selector_text == "#panel > button:disabled"

    assert cascade.source_precedence == [:theme_defaults, :style_refs, :css, :local_style]
    assert Enum.any?(cascade.conflicts, &(&1.property == "color"))
    assert Enum.map(cascade.diagnostics, & &1.kind) == [:unsupported_selector, :selector_no_match]
  end
end
