defmodule UnifiedExamples.AppReadmeTest do
  use ExUnit.Case, async: false

  alias UnifiedExamples.Shared.AppReadme

  test "generated app readmes explain the interaction to try and expected outcome" do
    button = AppReadme.expected_contents("button")
    overlay = AppReadme.expected_contents("overlay")

    assert button =~ "# Unified Examples Button"
    assert button =~ "## Try It"
    assert button =~ "Click Save profile to emit the authored canonical button signal."
    assert button =~ "## Expect"
    assert button =~ "The button example should make the primary action feel live"

    assert overlay =~ "# Unified Examples Overlay"
    assert overlay =~ "target-driven interaction storytelling"

    assert overlay =~
             "Use the shared trigger to see how the overlay example explains open changes"

    assert overlay =~
             "If the example uses the shared trigger, click `Inspect the overlay layered story`."
  end
end
