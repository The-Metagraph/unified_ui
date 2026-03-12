defmodule WebUi.Integration.Phase08ConformanceAutomationTest do
  use ExUnit.Case, async: false

  alias WebUi.TestSupport.Conformance.Assertions
  alias WebUi.TestSupport.Conformance.Fixtures

  @root Path.expand("../../..", __DIR__)
  @scenario_catalog Path.join(@root, "specs/conformance/scenario_catalog.md")
  @conformance_matrix Path.join(@root, "specs/conformance/spec_conformance_matrix.md")
  @scenario_test Path.join(@root, "test/web_ui/integration/scenario_catalog_conformance_test.exs")

  @catalog_row_012_name "Deterministic widget render behavior"

  test "report-only conformance output remains deterministic across repeated runs" do
    {output_a, status_a} = run_report_only()
    {output_b, status_b} = run_report_only()

    assert status_a == 0
    assert status_b == 0
    assert normalize_output(output_a) == normalize_output(output_b)
  end

  test "conformance fixtures remain explicit and isolated from ambient runtime state" do
    context_a = Fixtures.runtime_context(prefix: "phase8-a")
    context_b = Fixtures.runtime_context(prefix: "phase8-b")

    assert context_a.correlation_id == "phase8-a-corr"
    assert context_a.request_id == "phase8-a-req"
    assert context_b.correlation_id == "phase8-b-corr"
    refute context_a == context_b

    envelope = Fixtures.event_envelope(prefix: "phase8-event", context: context_a)

    assert envelope.correlation_id == context_a.correlation_id
    assert envelope.request_id == context_a.request_id
    assert envelope.id == "evt-phase8-event"
  end

  test "conformance assertions fail closed on continuity and schema defects" do
    assert_raise ExUnit.AssertionError, fn ->
      Assertions.assert_correlation_continuity(
        %{correlation_id: "corr-8", request_id: "req-8"},
        "corr-8",
        "req-mismatch"
      )
    end

    assert_raise ExUnit.AssertionError, fn ->
      Assertions.assert_event_payload_keys(
        %{event_name: "runtime.widget.rendered.v1"},
        [:event_name, :outcome]
      )
    end

    assert_raise ExUnit.AssertionError, fn ->
      Assertions.assert_typed_error(
        %{error_code: "agent.runtime_timeout", category: "timeout"},
        "agent.runtime_timeout",
        "validation"
      )
    end
  end

  test "missing matrix-to-test scenario coverage fails conformance gate" do
    missing_id = scenario_id(98)

    with_multi_file_patch(
      [
        {@scenario_catalog,
         fn original ->
           String.replace(
             original,
             scenario_catalog_row(12, @catalog_row_012_name),
             scenario_catalog_row(12, @catalog_row_012_name) <>
               "\n" <> scenario_catalog_row(missing_id, "Temporary missing coverage probe"),
             global: false
           )
         end},
        {@conformance_matrix,
         fn original ->
           String.replace(
             original,
             component_coverage_row([1, 6]),
             component_coverage_row([1, 6, missing_id]),
             global: false
           )
         end}
      ],
      fn ->
        {output, status} = run_report_only()

        assert status == 1
        assert output =~ "FAIL: matrix scenarios missing conformance tests:"
        assert output =~ missing_id
      end
    )
  end

  test "aligned catalog, matrix, and tests pass conformance gate" do
    aligned_id = scenario_id(99)

    with_multi_file_patch(
      [
        {@scenario_catalog,
         fn original ->
           String.replace(
             original,
             scenario_catalog_row(12, @catalog_row_012_name),
             scenario_catalog_row(12, @catalog_row_012_name) <>
               "\n" <> scenario_catalog_row(aligned_id, "Temporary alignment probe"),
             global: false
           )
         end},
        {@conformance_matrix,
         fn original ->
           String.replace(
             original,
             component_coverage_row([1, 6]),
             component_coverage_row([1, 6, aligned_id]),
             global: false
           )
         end},
        {@scenario_test,
         fn original ->
           String.replace(
             original,
             "use ExUnit.Case, async: true",
             "use ExUnit.Case, async: true\n\n  # " <>
               aligned_id <> " integration alignment marker",
             global: false
           )
         end}
      ],
      fn ->
        {output, status} = run_report_only()

        assert status == 0
        assert output =~ "Scenario alignment checks passed."
        assert output =~ aligned_id
      end
    )
  end

  test "diagnostics report broken scenario families with explicit identifiers" do
    unknown_id = scenario_id(999)

    with_file_patch(
      @conformance_matrix,
      fn original ->
        String.replace(
          original,
          observability_coverage_row([4, 6, 15]),
          observability_coverage_row([4, 6, 15, unknown_id]),
          global: false
        )
      end,
      fn ->
        {output, status} = run_report_only()

        assert status == 1
        assert output =~ "FAIL: matrix scenarios missing from scenario catalog:"
        assert output =~ unknown_id
        assert output =~ "-- matrix references for #{unknown_id} --"
      end
    )
  end

  defp run_report_only do
    System.cmd(
      "bash",
      ["./scripts/run_conformance.sh", "--report-only", "--skip-governance"],
      cd: @root,
      env: [{"MIX_ENV", "test"}],
      stderr_to_stdout: true
    )
  end

  defp with_file_patch(path, patch_fun, test_fun) do
    with_multi_file_patch([{path, patch_fun}], test_fun)
  end

  defp with_multi_file_patch(patches, test_fun) do
    originals =
      for {path, _patch_fun} <- patches, into: %{} do
        {path, File.read!(path)}
      end

    on_exit(fn ->
      Enum.each(originals, fn {path, original} ->
        File.write!(path, original)
      end)
    end)

    Enum.each(patches, fn {path, patch_fun} ->
      originals
      |> Map.fetch!(path)
      |> patch_fun.()
      |> then(&File.write!(path, &1))
    end)

    test_fun.()
  end

  defp scenario_catalog_row(id_or_number, name) do
    id = to_id(id_or_number)

    summary =
      if id == scenario_id(12) do
        "Equivalent widget descriptor + props + state inputs produce equivalent render outputs."
      else
        "Temporary aligned scenario used for integration-gate validation."
      end

    "| `#{id}` | #{name} | #{summary} |"
  end

  defp component_coverage_row(ids) do
    "| `specs/operations/rfc_intake_governance.md` | `AC-*` | `REQ-CP-*`, `REQ-OBS-*` | #{coverage_list(ids)} |"
  end

  defp observability_coverage_row(ids) do
    "| `REQ-OBS-001`..`REQ-OBS-010` | [observability_contract.md](/Users/Pascal/code/unified/web_ui/specs/contracts/observability_contract.md) | `WebUi.Channel`, `WebUi.CloudEvent`, `WebUi.Agent` | #{coverage_list(ids)} |"
  end

  defp coverage_list(ids) do
    ids
    |> List.wrap()
    |> Enum.map(&to_id/1)
    |> Enum.map_join(", ", fn id -> "`#{id}`" end)
  end

  defp to_id(value) when is_integer(value), do: scenario_id(value)
  defp to_id(value) when is_binary(value), do: value

  defp scenario_id(number) when is_integer(number) and number > 0 do
    "SCN-" <> (number |> Integer.to_string() |> String.pad_leading(3, "0"))
  end

  defp normalize_output(output) do
    output
    |> String.replace(~r/\r\n?/, "\n")
    |> String.trim()
  end
end
