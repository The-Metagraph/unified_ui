defmodule UnifiedUi.CssCompilerIntegrationTest do
  use ExUnit.Case, async: true

  alias UnifiedUi.Compiler

  defmodule CssCompiledWorkspace do
    use UnifiedUi.Dsl

    identity do
      id(:css_compiled_workspace)
      title("CSS Compiled Workspace")
    end

    themes do
      default_theme(:workspace)

      theme do
        id(:workspace)

        component_style do
          id(:panel_style)
          component(:box)
          style(style_value(foreground: named_color(:gray), background: named_color(:surface)))
        end
      end

      css :styles do
        source("""
        #panel { color: blue; background-color: white; }
        button:disabled { opacity: 0.4; }
        """)
      end
    end

    composition do
      root(:css_compiled_root)

      box :panel do
        style_refs([:panel_style])

        button :save do
          label("Save")
          disabled?(true)
          style(style_value(foreground: named_color(:red)))
        end
      end
    end
  end

  test "compiler merges CSS-derived styles between style refs and local styles" do
    iur = Compiler.iur!(CssCompiledWorkspace)
    [panel_child] = iur.children
    panel = panel_child.element
    [button_child] = panel.children
    button = button_child.element

    assert panel.attributes.style.foreground == %{mode: :named, name: :blue}
    assert panel.attributes.style.background == %{mode: :named, name: :white}
    assert panel.attributes.style.extra.css.properties == ["background-color", "color"]
    refute Map.has_key?(panel.attributes.style.extra.css, :source)

    assert button.attributes.style.foreground == %{mode: :named, name: :red}
    assert button.attributes.style.state_variants.disabled.visibility == %{opacity: 0.4}
    assert button.attributes.style.state_variants.disabled.extra.css.properties == ["opacity"]
  end

  test "compiler trace carries CSS diagnostics for inspection follow-up" do
    result = Compiler.compile!(CssCompiledWorkspace)

    assert result.trace.css_diagnostics == []
  end
end
