defmodule WebUi.Iur.ValueNormalizerTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Style
  alias WebUi.Iur.ValueNormalizer

  test "canonicalizes nested structs and maps recursively" do
    value = %{
      "style" => %Style{fg: :blue, attrs: [:bold]},
      "meta" => %{"depth" => 2, "tags" => ["alpha", "beta"]}
    }

    normalized = ValueNormalizer.canonicalize(value)

    assert normalized == %{
             style: %{
               fg: :blue,
               bg: nil,
               attrs: [:bold],
               padding: nil,
               margin: nil,
               width: nil,
               height: nil,
               align: nil
             },
             meta: %{depth: 2, tags: ["alpha", "beta"]}
           }
  end

  test "preserves tuple shape while normalizing tuple entries" do
    value = %{rgb: {255, 128, 0}, nested: {%Style{fg: :red}, %{"k" => "v"}}}
    normalized = ValueNormalizer.canonicalize(value)

    assert normalized.rgb == {255, 128, 0}

    assert normalized.nested ==
             {
               %{
                 fg: :red,
                 bg: nil,
                 attrs: [],
                 padding: nil,
                 margin: nil,
                 width: nil,
                 height: nil,
                 align: nil
               },
               %{k: "v"}
             }
  end

  test "unknown string keys remain strings while known keys are atomized" do
    value = %{"label" => "Save", "custom_key_xyz" => 1}
    normalized = ValueNormalizer.canonicalize(value)

    assert normalized[:label] == "Save"
    assert normalized["custom_key_xyz"] == 1
  end
end
