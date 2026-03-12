defmodule WebUi.Persistence.ReplayBaselineRegistryTest do
  use ExUnit.Case, async: true

  alias WebUi.Persistence.ReplayBaselineRegistry
  alias WebUi.Persistence.ReplayLog
  alias WebUi.TypedError

  defp baseline_with_cursor(cursor) when is_integer(cursor) and cursor >= 0 do
    log =
      1..cursor
      |> Enum.reduce(ReplayLog.new(), fn seq, replay_log ->
        {:ok, updated_log} =
          ReplayLog.append(replay_log, %{
            direction: if(rem(seq, 2) == 0, do: :inbound, else: :outbound),
            event: if(rem(seq, 2) == 0, do: "result", else: "dispatch"),
            metadata: %{seq: seq}
          })

        updated_log
      end)

    {:ok, baseline} = ReplayLog.capture_baseline(log, %{label: "baseline-#{cursor}"})
    baseline
  end

  test "new returns deterministic empty registry state" do
    assert ReplayBaselineRegistry.new() == %{
             baselines: %{},
             order: [],
             active_baseline_id: nil,
             retention_limit: nil
           }
  end

  test "upsert stores baselines with deterministic ordering and active selection" do
    baseline_a = baseline_with_cursor(1)
    baseline_b = baseline_with_cursor(3)

    {:ok, registry} = ReplayBaselineRegistry.new() |> ReplayBaselineRegistry.upsert(baseline_a)
    {:ok, registry} = ReplayBaselineRegistry.upsert(registry, baseline_b)
    {:ok, ordered_baselines} = ReplayBaselineRegistry.list(registry)
    {:ok, active_baseline} = ReplayBaselineRegistry.active(registry)

    assert registry.order == [baseline_b.baseline_id, baseline_a.baseline_id]
    assert Enum.map(ordered_baselines, & &1.baseline_id) == registry.order
    assert registry.active_baseline_id == baseline_b.baseline_id
    assert active_baseline.baseline_id == baseline_b.baseline_id
  end

  test "upsert enforces retention limits and preserves deterministic active fallback" do
    baseline_a = baseline_with_cursor(1)
    baseline_b = baseline_with_cursor(2)
    baseline_c = baseline_with_cursor(3)

    {:ok, registry} = ReplayBaselineRegistry.new() |> ReplayBaselineRegistry.upsert(baseline_a)
    {:ok, registry} = ReplayBaselineRegistry.upsert(registry, baseline_b, %{activate: false})

    {:ok, registry} =
      ReplayBaselineRegistry.upsert(registry, baseline_c, %{retention_limit: 2, activate: false})

    {:ok, ordered_baselines} = ReplayBaselineRegistry.list(registry)

    assert registry.retention_limit == 2
    assert registry.order == [baseline_c.baseline_id, baseline_b.baseline_id]
    assert Enum.map(ordered_baselines, & &1.baseline_id) == registry.order
    assert registry.active_baseline_id == baseline_c.baseline_id

    assert {:error, %TypedError{} = missing_baseline_error} =
             ReplayBaselineRegistry.fetch(registry, baseline_a.baseline_id)

    assert missing_baseline_error.error_code == "replay_baseline_registry.baseline_not_found"
  end

  test "activate selects requested baseline deterministically" do
    baseline_a = baseline_with_cursor(1)
    baseline_b = baseline_with_cursor(2)

    {:ok, registry} = ReplayBaselineRegistry.new() |> ReplayBaselineRegistry.upsert(baseline_a)
    {:ok, registry} = ReplayBaselineRegistry.upsert(registry, baseline_b)
    {:ok, registry} = ReplayBaselineRegistry.activate(registry, baseline_a.baseline_id)
    {:ok, active_baseline} = ReplayBaselineRegistry.active(registry)

    assert registry.active_baseline_id == baseline_a.baseline_id
    assert active_baseline.baseline_id == baseline_a.baseline_id
  end

  test "fails closed for invalid baselines, options, and unknown activation IDs" do
    registry = ReplayBaselineRegistry.new()

    assert {:error, %TypedError{} = invalid_baseline_error} =
             ReplayBaselineRegistry.upsert(registry, %{cursor: 1})

    assert invalid_baseline_error.error_code == "replay_baseline_registry.invalid_baseline"

    baseline = baseline_with_cursor(1)

    assert {:error, %TypedError{} = invalid_options_error} =
             ReplayBaselineRegistry.upsert(registry, baseline, %{retention_limit: 0})

    assert invalid_options_error.error_code == "replay_baseline_registry.invalid_options"

    {:ok, registry} = ReplayBaselineRegistry.upsert(registry, baseline)

    assert {:error, %TypedError{} = missing_baseline_error} =
             ReplayBaselineRegistry.activate(registry, "baseline-000999-0000000000")

    assert missing_baseline_error.error_code == "replay_baseline_registry.baseline_not_found"
  end
end
