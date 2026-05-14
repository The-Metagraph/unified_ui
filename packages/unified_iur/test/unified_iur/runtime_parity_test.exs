defmodule UnifiedIUR.RuntimeParityTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.{Interoperability, RuntimeParity}

  test "exposes shared component runtime parity fixture groups" do
    assert RuntimeParity.groups() == [
             :content,
             :identity,
             :form,
             :control,
             :row,
             :progress,
             :layer,
             :callout,
             :redline,
             :code,
             :composer,
             :repeated_rows
           ]

    fixtures = RuntimeParity.fixtures()

    assert Enum.map(fixtures, & &1.group) == RuntimeParity.groups()
    assert Enum.all?(fixtures, &String.starts_with?(&1.id, "components-runtime-parity--"))
    assert Enum.all?(fixtures, &(&1.minimum_behavior == RuntimeParity.minimum_behavior().full))
  end

  test "fixtures preserve semantic expectations, interactions, and text safety" do
    form = RuntimeParity.fixture!(:form)
    redline = RuntimeParity.fixture!(:redline)
    code = RuntimeParity.fixture!("components-runtime-parity--code")
    repeated = RuntimeParity.fixture!(:repeated_rows)

    assert form.expected.interactions == [:submit, :change]
    assert form.expected.labels == ["Title", "Save"]

    assert redline.expected.safety == %{
             plain_text: true,
             malicious_text: "<script>safe redline</script>"
           }

    assert code.expected.safety == %{plain_text: true, malicious_text: "<defmodule>"}

    repeated_kinds = repeated.element |> Interoperability.walk() |> Enum.map(& &1.kind)
    assert repeated.expected.state == %{hydrated?: true, row_count: 2}
    assert Enum.count(repeated_kinds, &(&1 == :artifact_row)) == 2
  end

  test "coverage report classifies full, degraded, and unsupported runtime support" do
    report =
      RuntimeParity.coverage_report(:terminal_ui, [:inline_rich_text_heading, :redline_inline],
        degraded_kinds: [:avatar]
      )

    assert report.runtime == :terminal_ui
    refute report.complete?
    assert report.degraded?
    assert report.kinds.inline_rich_text_heading.status == :full
    assert report.kinds.redline_inline.status == :full
    assert report.kinds.avatar.status == :degraded
    assert report.kinds.chat_composer.status == :unsupported
    assert :chat_composer in report.unsupported_kinds
    assert :avatar in report.degraded_kinds

    assert report.kinds.avatar.minimum_behavior == [
             :explicit_degradation,
             :structure_preservation,
             :state_preservation,
             :accessibility_metadata,
             :interaction_translation,
             :safe_text_output
           ]
  end

  test "acceptance criteria enumerate required kinds and fixture groups" do
    criteria = RuntimeParity.acceptance_criteria()

    assert criteria.statuses == [:full, :degraded, :unsupported]
    assert criteria.required_fixture_groups == RuntimeParity.groups()
    assert :redline in criteria.text_safety_groups
    assert :composer in criteria.interaction_groups
    assert :code_block_syntax_highlighted in criteria.required_widget_kinds
  end
end
