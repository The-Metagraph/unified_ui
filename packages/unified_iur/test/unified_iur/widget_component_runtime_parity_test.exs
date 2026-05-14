defmodule UnifiedIUR.WidgetComponentRuntimeParityTest do
  use ExUnit.Case, async: false

  @moduletag timeout: 300_000

  @suites [
    {"ElmUi", "packages/elm_ui", "test/elm_ui/widget_components_test.exs"},
    {"DesktopUi", "packages/desktop_ui", "test/desktop_ui/widget_components_test.exs"},
    {"TerminalUi", "packages/terminal_ui", "test/terminal_ui/widget_components_test.exs"}
  ]

  test "phase 4 runtime parity suites pass for every renderer package" do
    workspace_root = Path.expand("../../../..", __DIR__)

    for {runtime, package_path, test_path} <- @suites do
      package_root = Path.join(workspace_root, package_path)

      {output, status} =
        System.cmd("mix", ["test", test_path],
          cd: package_root,
          env: [{"MIX_ENV", "test"}],
          stderr_to_stdout: true
        )

      assert status == 0, """
      #{runtime} runtime parity suite failed.

      #{output}
      """
    end
  end
end
