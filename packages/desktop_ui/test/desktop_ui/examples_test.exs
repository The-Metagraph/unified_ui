defmodule DesktopUi.ExamplesTest do
  use ExUnit.Case, async: true

  test "foundational examples expose native, canonical, and comparison coverage" do
    native = DesktopUi.Examples.native_foundational_screen()
    canonical = DesktopUi.Examples.canonical_foundational_screen()
    comparison = DesktopUi.Examples.foundational_comparison()

    assert native.metadata.example_id == :native_foundational
    assert native.metadata.source == :native
    assert :content_widgets in native.metadata.coverage

    assert canonical.kind == :column
    assert canonical.type == :layout

    assert comparison.id == :foundational_continuity
    assert comparison.parity.shared_runtime_backbone?
    assert comparison.parity.focus_order_match?
    assert comparison.parity.body_kind_sequence_match?
    assert comparison.parity.binding_names_match?
  end

  test "reference and info surfaces expose foundational example identifiers" do
    reference = DesktopUi.reference()
    summary = DesktopUi.info()

    assert reference.examples.native_ids == [:native_foundational]
    assert reference.examples.canonical_ids == [:canonical_foundational]
    assert reference.examples.comparison_ids == [:foundational_continuity]

    assert summary.examples.native_ids == [:native_foundational]
    assert summary.examples.comparison_ids == [:foundational_continuity]
    assert DesktopUi.examples() == DesktopUi.Examples
  end
end
