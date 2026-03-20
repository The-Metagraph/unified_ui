defmodule Unified.SpecCompliance.EvidenceTest do
  use ExUnit.Case, async: true

  alias Unified.SpecCompliance.Evidence

  import SpecComplianceTestSupport

  test "evaluates every v1 evidence kind" do
    root = tmp_root!("evidence")
    write_file!(root, "present.txt", "present")
    write_file!(root, "nested/file.txt", "nested")

    assert [] ==
             Evidence.run(
               [
                 %{"kind" => "path_exists", "path" => "present.txt"},
                 %{"kind" => "path_absent", "path" => "missing.txt"},
                 %{"kind" => "path_glob_nonempty", "glob" => "nested/*.txt"},
                 %{
                   "kind" => "command",
                   "run" => "printf 'ok'",
                   "expect_stdout_contains" => "ok"
                 }
               ],
               root,
               [run_commands: true],
               "demo.package.ready"
             )
  end

  test "reports failing command evidence" do
    root = tmp_root!("command_failure")

    findings =
      Evidence.run(
        [%{"kind" => "command", "run" => "printf 'nope'", "expect_stdout_contains" => "ok"}],
        root,
        [run_commands: true],
        "demo.package.ready"
      )

    assert Enum.any?(findings, &(&1.code == "command_stdout_mismatch"))
  end
end
