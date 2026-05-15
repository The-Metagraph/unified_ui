defmodule UnifiedUi.CssPhase1IntegrationTest do
  use ExUnit.Case, async: true

  alias UnifiedUi.{Compiler, Css, Info}

  defmodule PhaseOneWorkspace do
    use UnifiedUi.Dsl

    identity do
      id(:css_phase_one_workspace)
      title("CSS Phase One Workspace")
    end

    themes do
      default_theme(:workspace)

      theme do
        id(:workspace)

        component_style do
          id(:panel_shell)
          component(:box)
          style(style_value(spacing: %{padding: 2}))
        end
      end

      css :base_css do
        source("""
        /* ignored comment */
        #shell { color: white; }
        .workspace-panel { background-color: black; }
        """)
      end

      css :diagnostic_css do
        source("""
        @import url("remote.css");
        .cta { font-weight: bold !important; }
        """)
      end
    end

    composition do
      root(:css_phase_one_root)
      mode(:screen)

      box :shell do
        class("workspace-panel")
        style_refs([:panel_shell])
        style(style_value(visibility: %{hidden?: false}))

        button :cta do
          label("Continue")
          class("cta")
        end
      end
    end
  end

  test "parses ordered CSS blocks and preserves existing authored style sources" do
    parsed = Css.parse_module(PhaseOneWorkspace)
    listing = Compiler.listing(PhaseOneWorkspace)

    assert Enum.map(parsed, & &1.block_id) == [:base_css, :diagnostic_css]
    assert Enum.map(parsed, & &1.source_order) == [0, 1]

    assert listing.authored.style_ref_ids == [:panel_shell]
    assert listing.themes.theme_ids == [:workspace]
    assert listing.css.summary.rule_count == 3
    assert listing.css.summary.declaration_count == 3
    assert listing.css.summary.ignored_count == 1
  end

  test "normalizes comments, whitespace, important flags, and ignored at-rules deterministically" do
    [base, diagnostic] = Css.parse_module(PhaseOneWorkspace)

    assert Enum.map(base.rules, & &1.selector_text) == ["#shell", ".workspace-panel"]

    assert [
             %{
               property: "font-weight",
               value: "bold",
               important?: true,
               source_order: 0
             }
           ] = hd(diagnostic.rules).declarations

    assert [%{kind: :ignored_at_rule, source: %{block_id: :diagnostic_css}}] =
             diagnostic.diagnostics
  end

  test "exposes CSS metadata through module and compiler inspection" do
    module_summary = Info.inspect_module(PhaseOneWorkspace)
    rendered = Compiler.render_inspection(PhaseOneWorkspace)

    assert module_summary.css.count == 2
    assert module_summary.css.rule_count == 3
    assert module_summary.css.diagnostic_count == 1

    assert rendered =~ "css blocks: 2"
    assert rendered =~ "css rules: 3"
    assert rendered =~ "css diagnostics: 1"
  end

  test "rejects CSS blocks outside the theme authoring section" do
    assert_compile_dsl_error(
      """
      identity do
        id(:invalid_css_placement)
      end

      composition do
        root(:invalid_css_placement_root)

        css :bad_css do
          source(".x { color: white; }")
        end
      end
      """,
      "cannot compile module"
    )
  end

  defp compile_module(body) do
    module_name = "Generated#{System.unique_integer([:positive])}"

    Code.compile_string("""
    defmodule UnifiedUi.CssPhase1IntegrationTest.#{module_name} do
      use UnifiedUi.Dsl

      #{body}
    end
    """)
  end

  defp assert_compile_dsl_error(body, expected_message) do
    error = assert_raise CompileError, fn -> compile_module(body) end

    assert Exception.message(error) =~ expected_message
  end
end
