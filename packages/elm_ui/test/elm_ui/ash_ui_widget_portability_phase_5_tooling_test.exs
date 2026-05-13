defmodule ElmUi.AshUiWidgetPortabilityPhase5ToolingTest do
  use ExUnit.Case, async: true

  test "tooling and validation report promoted widget support" do
    report = ElmUi.Tooling.portable_widget_report()

    assert report.complete?
    assert :host_form_shell in report.expected_kinds
    assert Enum.all?(report.widgets, &(&1.native_support == :direct))
    assert Enum.all?(report.widgets, &(&1.iur_support == :direct))

    validation = ElmUi.Validate.example_coverage()

    assert Enum.any?(
             validation.checks,
             &(&1.name == :promoted_portable_widget_support and &1.ok?)
           )
  end
end
