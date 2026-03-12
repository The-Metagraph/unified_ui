defmodule DesktopUiTest do
  use ExUnit.Case
  doctest DesktopUi

  test "greets the world" do
    assert DesktopUi.hello() == :world
  end
end
