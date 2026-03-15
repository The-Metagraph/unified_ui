defmodule UnifiedExamples.SharedTest do
  use ExUnit.Case, async: true

  alias UnifiedExamples.Shared

  test "exposes the shared dependency contract for standalone example apps" do
    assert Shared.dependency_apps() == [:unified_ui, :unified_iur, :live_ui]

    assert Shared.local_package_paths() == %{
             unified_ui: Path.expand("../../packages/unified-ui", Shared.shared_root()),
             unified_iur: Path.expand("../../packages/unified_iur", Shared.shared_root()),
             live_ui: Path.expand("../../packages/live_ui", Shared.shared_root())
           }
  end

  test "compiles independently against the local package dependencies" do
    assert Code.ensure_loaded?(UnifiedUi)
    assert Code.ensure_loaded?(UnifiedIUR)
    assert Code.ensure_loaded?(LiveUi)
  end

  test "can enumerate the current standalone app directories without runtime services" do
    shared_root = Path.expand("../..", __DIR__)

    assert Shared.shared_root() == shared_root
    assert Shared.suite_root() == Path.expand("..", shared_root)
    assert Shared.app_directories() == ["button", "text", "text_input"]
  end
end
