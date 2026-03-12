defmodule UnifiedUi.VersionTest do
  use ExUnit.Case, async: true

  test "version/0 returns a semver string" do
    version = UnifiedUi.version()

    assert is_binary(version)
    assert version =~ ~r/^\d+\.\d+\.\d+$/
  end
end
