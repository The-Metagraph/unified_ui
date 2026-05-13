defmodule LiveUi.AshUiWidgetPortabilityPhase5ToolingTest do
  use ExUnit.Case, async: true

  test "tooling reports promoted widget and repeated collection support" do
    report = LiveUi.Tooling.portable_widget_report()

    assert report.complete?
    assert :repeated_collection in report.expected_kinds
    assert Enum.all?(report.widgets, &(&1.native_support == :direct))
    assert Enum.all?(report.widgets, &(&1.iur_support == :direct))

    validation = LiveUi.Tooling.validation_report()

    assert validation.portable_widget_support.complete?

    assert Enum.any?(
             validation.release_readiness.criteria,
             &(&1.id == :portable_widget_support and &1.passed?)
           )
  end
end
