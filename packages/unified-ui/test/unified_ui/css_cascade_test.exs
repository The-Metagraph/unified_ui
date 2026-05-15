defmodule UnifiedUi.CssCascadeTest do
  use ExUnit.Case, async: true

  alias UnifiedUi.Css
  alias UnifiedUi.Css.Cascade

  defmodule CascadeWorkspace do
    use UnifiedUi.Dsl

    identity do
      id(:css_cascade_workspace)
      title("CSS Cascade Workspace")
    end

    themes do
      css :base do
        source("""
        button { color: gray; }
        .primary { color: blue; }
        #save { color: green; }
        button:disabled { opacity: 0.6; }
        """)
      end

      css :overrides do
        source("""
        .primary { color: red; }
        button { color: black !important; }
        """)
      end
    end

    composition do
      root(:css_cascade_root)

      button :save do
        label("Save")
        class("primary")
        disabled?(true)
      end
    end
  end

  test "resolves CSS-derived declarations by importance, specificity, and source order" do
    cascade = Css.cascade_module(CascadeWorkspace)
    style = cascade.styles_by_node.save

    assert style.default["color"].value == "black"
    assert style.default["color"].important? == true
    assert style.default["color"].selector_text == "button"

    assert style.states.disabled["opacity"].value == "0.6"
    assert style.states.disabled["opacity"].selector_text == "button:disabled"

    assert Enum.count(cascade.conflicts, &(&1.property == "color")) == 4
  end

  test "documents canonical style source precedence for later compiler merging" do
    assert Cascade.source_precedence() == [:theme_defaults, :style_refs, :css, :local_style]
    assert Css.cascade_module(CascadeWorkspace).source_precedence == Cascade.source_precedence()
  end
end
