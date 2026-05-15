defmodule UnifiedUi.CssSelectorTest do
  use ExUnit.Case, async: true

  alias UnifiedUi.Css.Selector

  test "parses id, class, kind, and supported state selectors" do
    {:ok, selector} = Selector.parse("button#save.primary:focus")

    assert selector.raw == "button#save.primary:focus"
    assert selector.specificity == {1, 2, 1}

    assert [
             %{
               combinator: nil,
               simple: %{kind: :button, id: :save, classes: ["primary"], states: [:focused]}
             }
           ] = selector.parts
  end

  test "parses supported descendant, child, and selector list forms" do
    {selectors, diagnostics} =
      Selector.parse_selector_list("#shell .cta, box > button.primary:disabled", %{
        block_id: :styles
      })

    assert diagnostics == []
    assert Enum.map(selectors, & &1.raw) == ["#shell .cta", "box > button.primary:disabled"]
    assert Enum.map(selectors, & &1.specificity) == [{1, 1, 0}, {0, 2, 2}]

    assert [
             %{combinator: nil, simple: %{id: :shell}},
             %{combinator: :descendant, simple: %{classes: ["cta"]}}
           ] = hd(selectors).parts

    assert [
             %{combinator: nil, simple: %{kind: :box}},
             %{combinator: :child, simple: %{kind: :button, classes: ["primary"]}}
           ] = List.last(selectors).parts
  end

  test "ignores unsupported browser-only selectors with diagnostics" do
    {selectors, diagnostics} =
      Selector.parse_selector_list("button:hover, [role=button], .item::before", %{
        block_id: :styles,
        source_order: 1
      })

    assert selectors == []

    assert Enum.map(diagnostics, & &1.kind) == [
             :unsupported_selector,
             :unsupported_selector,
             :unsupported_selector
           ]

    assert Enum.all?(diagnostics, &(&1.source.block_id == :styles))
  end
end
