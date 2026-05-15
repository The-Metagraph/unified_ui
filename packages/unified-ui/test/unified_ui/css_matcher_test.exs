defmodule UnifiedUi.CssMatcherTest do
  use ExUnit.Case, async: true

  alias UnifiedUi.Css
  alias UnifiedUi.Css.Matcher

  defmodule MatchWorkspace do
    use UnifiedUi.Dsl

    identity do
      id(:css_match_workspace)
      title("CSS Match Workspace")
    end

    themes do
      css :selectors do
        source("""
        #shell { color: white; }
        .primary.cta { font-weight: bold; }
        box > button:disabled { opacity: 0.5; }
        #shell .nested-action { color: blue; }
        .missing { color: red; }
        button:hover { color: pink; }
        """)
      end
    end

    composition do
      root(:css_match_root)
      mode(:screen)

      box :shell do
        class("panel")

        button :primary_action do
          label("Save")
          class("primary cta nested-action")
          disabled?(true)
        end
      end
    end
  end

  test "builds deterministic selector match inputs from authored nodes" do
    [shell, button] =
      MatchWorkspace
      |> UnifiedUi.Info.composition_nodes()
      |> Matcher.build_index()

    assert shell.id == :shell
    assert shell.kind == :box
    assert shell.classes == ["panel"]
    assert shell.parent_id == nil

    assert button.id == :primary_action
    assert button.kind == :button
    assert button.classes == ["primary", "cta", "nested-action"]
    assert button.states == [:disabled]
    assert button.parent_id == :shell
  end

  test "matches supported selectors against authored nodes" do
    result = Css.match_module(MatchWorkspace, no_match_diagnostics?: true)

    assert Enum.map(result.matches, &{&1.selector_text, &1.node_id, &1.state}) == [
             {"#shell", :shell, nil},
             {".primary.cta", :primary_action, nil},
             {"box > button:disabled", :primary_action, :disabled},
             {"#shell .nested-action", :primary_action, nil}
           ]

    assert Enum.map(result.diagnostics, & &1.kind) == [
             :selector_no_match,
             :unsupported_selector
           ]
  end
end
