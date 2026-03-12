defmodule UnifiedUi.Dsl.ExtensionTest do
  use ExUnit.Case

  alias UnifiedUi.Dsl.Sections

  describe "Extension compilation" do
    test "extension module compiles without errors" do
      assert Code.ensure_loaded?(UnifiedUi.Dsl.Extension)
    end
  end

  describe "DSL module" do
    test "Dsl module compiles without errors" do
      assert Code.ensure_loaded?(UnifiedUi.Dsl)
    end

    test "can create a module using UnifiedUi.Dsl" do
      defmodule TestUiModule do
        use UnifiedUi.Dsl
      end

      assert Code.ensure_loaded?(TestUiModule)
    end
  end

  describe "Section definitions via extension" do
    test "extension uses canonical section module definitions" do
      expected_sections = [
        Sections.Ui.section(),
        Sections.Widgets.section(),
        Sections.Layouts.section(),
        Sections.Styles.section(),
        Sections.Signals.section()
      ]

      assert Enum.map(UnifiedUi.Dsl.Extension.sections(), &section_signature/1) ==
               Enum.map(expected_sections, &section_signature/1)
    end
  end

  describe "Extension pipeline configuration" do
    test "exposes expected transformers and verifiers" do
      assert UnifiedUi.Dsl.Extension.transformers() == [
               UnifiedUi.Dsl.Transformers.PrecomputeTransformer,
               UnifiedUi.Dsl.Transformers.InitTransformer,
               UnifiedUi.Dsl.Transformers.UpdateTransformer,
               UnifiedUi.Dsl.Transformers.JidoAgentTransformer,
               UnifiedUi.Dsl.Transformers.ViewTransformer
             ]

      assert UnifiedUi.Dsl.Extension.verifiers() == [
               UnifiedUi.Dsl.Verifiers.EntityUniquenessVerifier,
               UnifiedUi.Dsl.Verifiers.UniqueIdVerifier,
               UnifiedUi.Dsl.Verifiers.LayoutStructureVerifier,
               UnifiedUi.Dsl.Verifiers.SignalHandlerVerifier,
               UnifiedUi.Dsl.Verifiers.RequiredAttributeVerifier,
               UnifiedUi.Dsl.Verifiers.StyleReferenceVerifier,
               UnifiedUi.Dsl.Verifiers.StateReferenceVerifier
             ]
    end

    test "exposes info module configuration" do
      assert UnifiedUi.Dsl.Extension.info_sections() == [:signals]
      assert UnifiedUi.Dsl.Extension.info_module() == UnifiedUi.Info
    end
  end

  describe "Standard signals" do
    test "returns list of standard signal types" do
      signals = UnifiedUi.Dsl.standard_signals()
      assert :click in signals
      assert :change in signals
      assert :submit in signals
      assert :focus in signals
      assert :blur in signals
      assert :select in signals
    end
  end

  describe "Style attributes" do
    test "standard_signals returns correct count" do
      signals = UnifiedUi.Dsl.standard_signals()
      assert length(signals) == 6
    end
  end

  defp section_signature(section) do
    {section.name, section.top_level?, Enum.map(section.entities, & &1.name)}
  end
end
