defmodule TerminalUi.AshUiWidgetPortabilityPhase5ToolingTest do
  use ExUnit.Case, async: true

  test "tooling and validation report degraded promoted widget support" do
    report = TerminalUi.Tooling.portable_widget_report()

    assert report.complete?
    assert report.support_mode == :degraded

    code_block = Enum.find(report.widgets, &(&1.kind == :code_block_syntax_highlighted))
    collection = Enum.find(report.widgets, &(&1.kind == :repeated_collection))

    assert code_block.iur_support == :degraded
    assert code_block.fallback == :plain_code_block
    assert collection.fallback == :linearized_collection

    validation = TerminalUi.Validate.example_coverage()

    assert Enum.any?(
             validation.checks,
             &(&1.name == :promoted_portable_widget_support and &1.ok?)
           )
  end
end
