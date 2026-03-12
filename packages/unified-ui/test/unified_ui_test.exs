defmodule UnifiedUiTest do
  use ExUnit.Case

  describe "application initialization" do
    test "application compiles successfully" do
      # Basic compilation test - if this compiles, the project structure is valid
      assert true
    end
  end

  describe "directory structure" do
    test "lib/unified_ui/dsl directory exists" do
      assert File.dir?("lib/unified_ui/dsl")
    end

    test "lib/unified_ui/widgets directory exists" do
      assert File.dir?("lib/unified_ui/widgets")
    end

    test "lib/unified_ui/layouts directory exists" do
      assert File.dir?("lib/unified_ui/layouts")
    end

    test "lib/unified_ui/styles directory exists" do
      assert File.dir?("lib/unified_ui/styles")
    end

    test "lib/unified_ui/iur directory exists" do
      assert File.dir?("lib/unified_ui/iur")
    end

    test "lib/unified_ui/adapters directory exists" do
      assert File.dir?("lib/unified_ui/adapters")
    end
  end

  describe "test directory structure" do
    test "test/unified_ui/dsl directory exists" do
      assert File.dir?("test/unified_ui/dsl")
    end

    test "test/unified_ui/widgets directory exists" do
      assert File.dir?("test/unified_ui/widgets")
    end

    test "test/unified_ui/layouts directory exists" do
      assert File.dir?("test/unified_ui/layouts")
    end

    test "test/unified_ui/styles directory exists" do
      assert File.dir?("test/unified_ui/styles")
    end

    # Note: test/unified_ui/iur directory was removed when IUR was extracted to unified_iur package

    test "test/unified_ui/adapters directory exists" do
      assert File.dir?("test/unified_ui/adapters")
    end

    test "test/unified_ui/integration directory exists" do
      assert File.dir?("test/unified_ui/integration")
    end
  end

  describe "configuration" do
    test ".formatter.exs exists" do
      assert File.exists?(".formatter.exs")
    end

    test "config/config.exs exists" do
      assert File.exists?("config/config.exs")
    end

    test "config/dev.exs exists" do
      assert File.exists?("config/dev.exs")
    end

    test "config/test.exs exists" do
      assert File.exists?("config/test.exs")
    end

    test "config/prod.exs exists" do
      assert File.exists?("config/prod.exs")
    end
  end
end
