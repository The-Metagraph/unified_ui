defmodule UnifiedUi.CssPhase4IntegrationTest do
  use ExUnit.Case, async: true

  alias UnifiedUi.{Compiler, Export}

  defmodule PhaseFourWorkspace do
    use UnifiedUi.Dsl

    identity do
      id(:css_phase_four_workspace)
      title("CSS Phase Four Workspace")
    end

    themes do
      css :styles do
        source("""
        #panel { color: #2563eb; padding: 8px; }
        button:disabled { opacity: 0.35; }
        @import url("remote.css");
        .unsupported:hover { color: red; }
        """)
      end
    end

    composition do
      root(:css_phase_four_root)

      box :panel do
        button :save do
          label("Save")
          disabled?(true)
        end
      end
    end
  end

  test "compiles CSS-authored modules into canonical IUR style attachments without raw CSS" do
    iur = Compiler.iur!(PhaseFourWorkspace)
    panel = iur.children |> hd() |> Map.fetch!(:element)
    button = panel.children |> hd() |> Map.fetch!(:element)

    assert UnifiedIUR.Validate.element(iur) == :ok
    assert panel.attributes.style.foreground == %{mode: :rgb, red: 37, green: 99, blue: 235}
    assert panel.attributes.style.spacing.padding_top == %{value: 8, unit: :px}
    assert panel.attributes.style.extra.css.properties == ["color", "padding"]
    assert button.attributes.style.state_variants.disabled.visibility == %{opacity: 0.35}

    refute Map.has_key?(iur.attributes, :css)
    refute Map.has_key?(panel.attributes, :css)
  end

  test "inspection and export report CSS summaries and diagnostics deterministically" do
    report = Compiler.inspection(PhaseFourWorkspace)
    {:ok, inspection} = Export.module(PhaseFourWorkspace, :inspection)

    assert report.listing.css.summary.rule_count == 3
    assert report.listing.css.summary.diagnostic_count == 1
    assert inspection =~ "css blocks: 1"
    assert inspection =~ "css rules: 3"
    assert inspection =~ "css diagnostics: 1"
  end
end
