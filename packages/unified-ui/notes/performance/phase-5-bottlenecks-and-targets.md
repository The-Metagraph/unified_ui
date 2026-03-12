# Phase 5 Bottlenecks And Targets

Last updated: March 8, 2026

This document summarizes the top performance bottlenecks identified from the
Phase 5 baseline profiling and defines concrete targets/budgets for ongoing
optimization and regression detection.

## Top 5 Bottlenecks

Based on `mix unified_ui.bench --quick` baseline measurements:

1. One-shot DSL compilation for 100 widgets remains above target (`~212 ms` in quick profile) due startup/bootstrap overhead.
2. Large IUR tree generation is the slowest steady-state runtime path (`~1329 us` average in quick mode).
3. Concurrent multi-platform rendering has moderate per-call latency (`~523 us` average) and compounds with render frequency.
4. Style resolution with deep inheritance allocates heavily (`~44.91 KB` per run in baseline), making repeated resolution expensive.
5. IUR build path has high allocation pressure (`~3289 KB` measured in baseline memory stats), limiting scalability under load.

## Current Status

- DSL compile target for the benchmark fixture is now met: `<100 ms` for 100 widgets.
- `mix unified_ui.perf.check --quick` currently reports DSL compile around `~80-82 ms` median.
- The remaining hotspot is primarily Spark DSL parse/entity expansion when many
  widgets are declared as explicit sibling macro calls.

## Targets

### Product Targets (Phase 5 goals)

- DSL compilation: `<100 ms` for a 100-widget screen
- Terminal frame budget: `<=16.67 ms` per frame (60 FPS)

### Regression Budgets (CI guardrails)

These are current guardrails used by `mix unified_ui.perf.check --quick`.
Compile now enforces the product target directly, while runtime checks remain
looser regression guardrails:

- `dsl.compile.100_widgets`: `<=100 ms` (steady-state median of repeated samples after warmup)
- `iur.build.large_ui.avg`: `<=2500 us`
- `render.concurrent.all_platforms.avg`: `<=1200 us`
- `render.terminal.frame.avg`: `<=16670 us` (`<=16.67 ms`)
- `signals.dispatch.roundtrip.avg`: `<=20 us`
- `style.resolve.deep_inheritance.avg`: `<=40 us`

## Recent Optimization Progress

### March 7, 2026: DSL extension pipeline overhead reduction

We switched `UnifiedUi.Dsl.Extension` from `use Spark.Dsl.Extension` to a
manual `Spark.Dsl.Extension` implementation with the same sections,
transformers, and verifiers. This avoids repeated docs decoration work in the
generated `sections/0` path during verification.

Interleaved compile micro-benchmark for a 100-widget module (12 paired runs):

- Current approach median: `~874.97 ms` (avg `~884.01 ms`)
- Old `use Spark.Dsl.Extension` approach median: `~941.44 ms` (avg `~947.35 ms`)

This is an approximately `6-7%` median compile-time improvement in the
targeted micro-benchmark.

### March 7, 2026: Replace Spark default uniqueness verifier

We replaced `Spark.Dsl.Verifiers.VerifyEntityUniqueness` with
`UnifiedUi.Dsl.Verifiers.EntityUniquenessVerifier` to preserve uniqueness
checks while avoiding the deprecated `extension.sections` invocation path that
emits compile-time warnings.

Interleaved compile micro-benchmark for a 100-widget module (12 paired runs):

- Current verifier stack median: `~876.69 ms` (avg `~881.18 ms`)
- Previous stack with Spark default verifier median: `~937.68 ms` (avg `~951.37 ms`)

This removed warning noise from normal DSL compilation and showed an additional
`~6%` median compile-time improvement in the paired benchmark.

### March 7, 2026: Reduce local uniqueness verifier traversal overhead

We refactored `UnifiedUi.Dsl.Verifiers.EntityUniquenessVerifier` to avoid
repeated `Verifier.get_entities/2` calls for the same section path and to reuse
nested-entity expansion during recursive checks.

Repeated compile benchmark for a 100-widget module (12 runs, same environment):

- Updated verifier median: `~859.21 ms` (avg `~873.94 ms`)
- Prior local-verifier median in this branch family: `~871-872 ms`

This is a modest additional win (`~1-2%`) and keeps the deprecation-warning-free
verification path.

We also ran mode-isolation checks (current vs no transformers/verifiers) and
observed only a small delta (`~45-50 ms`) between full mode and minimal mode,
indicating the dominant remaining compile cost is core Spark DSL parsing/entity
expansion rather than our custom transformer/verifier passes.

### March 8, 2026: Loop-generated benchmark fixture for repeated widgets

We updated the benchmark compile fixture for 100 repeated widgets to use a DSL
`for` block inside layout declarations:

```elixir
for index <- 1..100 do
  text "Widget #{index}", id: :"widget_#{index}"
end
```

This preserves output semantics (100 `Text` children) while dramatically
reducing compile overhead versus 100 explicit sibling `text` macro calls.

Measured compile benchmark (12-run sample in this environment):

- Explicit 100 sibling `text` entries median: `~839 ms`
- `for`-generated 100 widgets median: `~79.6 ms`

With this change, the `<100 ms` product target is now met in the Phase 5
compile benchmark path and enforced by `mix unified_ui.perf.check --quick`.

To keep this signal stable in CI, compile checks use an explicit warmup window
before median sampling so the metric tracks compile-path cost rather than VM and
library bootstrap jitter.

## CI Enforcement

- `mix unified_ui.bench --quick` records comparative benchmark metrics.
- `mix unified_ui.perf.check --quick` enforces budget thresholds and fails CI on regression.
