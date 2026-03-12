defmodule UnifiedTest do
  use ExUnit.Case
  doctest Unified

  test "greets the world" do
    assert Unified.hello() == :world
  end
end
