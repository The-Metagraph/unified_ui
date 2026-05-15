defmodule UnifiedUi.CssAuthoringTest do
  use ExUnit.Case, async: true

  alias UnifiedUi.{Css, Info}

  defmodule CssAuthoredWorkspace do
    use UnifiedUi.Dsl

    identity do
      id(:css_authored_workspace)
      title("CSS Authored Workspace")
    end

    themes do
      css :workspace_styles do
        source("""
        #shell { color: white; }
        .hero-card { background-color: black; }
        """)

        authored_ref([:tests, :css_authoring])
        summary("Workspace-local CSS authoring block")
      end

      css :overrides do
        source(".cta.primary { font-weight: bold; }")
      end
    end

    composition do
      root(:css_authored_workspace_root)
      mode(:screen)

      box :shell do
        class("hero-card")
        classes(["workspace-panel"])

        button :cta do
          label("Continue")
          class("cta primary")
          classes(["portable-action"])
        end
      end
    end
  end

  test "registers authored CSS stylesheet blocks in deterministic source order" do
    assert [
             %{id: :workspace_styles, order: 0, source_bytes: first_bytes},
             %{id: :overrides, order: 1, source_bytes: second_bytes}
           ] = Css.module_summary(CssAuthoredWorkspace).blocks

    assert first_bytes > 0
    assert second_bytes > 0

    assert Enum.map(Css.stylesheets(CssAuthoredWorkspace), & &1.id) == [
             :workspace_styles,
             :overrides
           ]
  end

  test "normalizes portable class metadata on authored nodes" do
    [shell] = Info.composition_summary(CssAuthoredWorkspace)
    [cta] = shell.children

    assert shell.class == "hero-card workspace-panel"
    assert shell.classes == ["hero-card", "workspace-panel"]

    assert cta.class == "cta primary portable-action"
    assert cta.classes == ["cta", "primary", "portable-action"]
  end
end
