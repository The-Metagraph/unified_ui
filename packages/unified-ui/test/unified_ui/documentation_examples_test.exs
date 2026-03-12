defmodule UnifiedUi.DocumentationExamplesTest do
  use ExUnit.Case, async: true

  doctest UnifiedUi.Errors
  doctest UnifiedUi.Signals
  doctest UnifiedUi.Table.Sort
end
