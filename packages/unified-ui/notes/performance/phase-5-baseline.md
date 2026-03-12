# Phase 5 Baseline Profiling

This document captures the baseline benchmark suite introduced for Phase 5 performance optimization.

## Scope

The benchmark script profiles:

- DSL compilation time for a generated screen with 100 widgets
- IUR generation for a large UI tree
- Concurrent rendering across terminal, desktop, and web adapters
- Terminal-only frame rendering latency
- Signal dispatch roundtrip latency (dispatch + state readback)
- Style resolution performance with deep inheritance

## How To Run

- Full run: `mix unified_ui.bench`
- CI quick run: `mix unified_ui.bench --quick`
- CI budget check: `mix unified_ui.perf.check --quick`

The CI workflow executes the quick run in the `benchmark` job.

## Baseline Notes

Use this file to track how benchmark throughput changes over time and to spot regressions before optimization work is merged.

Sample quick-run baseline (Apple M4, Elixir 1.19.5, Erlang 28.3.1):

- DSL compile profile (100 widgets): `1569.42 ms`
- `iur.build.large_ui`: `~0.75 K ips` (`~1340.64 us`)
- `render.concurrent.all_platforms`: `~1.71 K ips` (`~583.09 us`)
- `render.terminal.frame`: `~24.06 K ips` (`~41.57 us`)
- `signals.dispatch.roundtrip`: `~709.93 K ips` (`~1.41 us`)
- `style.resolve.deep_inheritance`: `~71.22 K ips` (`~14.04 us`)
