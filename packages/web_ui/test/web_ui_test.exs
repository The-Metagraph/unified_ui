defmodule WebUiTest do
  use ExUnit.Case
  doctest WebUi

  test "greets the world" do
    assert WebUi.hello() == :world
  end
end
