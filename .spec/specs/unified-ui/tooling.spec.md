# UnifiedUi Tooling

This subject backfills the current package-specific Mix tooling shipped by
`packages/unified-ui`.

```spec-meta
id: unified_ui.tooling
kind: tooling
status: active
summary: Current Mix-task tooling contract for `packages/unified-ui`, derived from the implemented project scaffolding, generators, preview utilities, and developer workflow wrappers.
surface:
  - packages/unified-ui/lib/mix/tasks
  - packages/unified-ui/lib/unified_ui/mix_tasks
  - packages/unified-ui/test/mix/tasks
decisions:
  - repo.governance.contract_policy
```

## Requirements

```spec-requirements
- id: unified_ui.tooling.project_generator
  statement: The package shall provide `mix unified_ui.new` to scaffold a new UnifiedUi project with a starter screen, application, tests, and baseline project files.
  priority: must
  stability: stable

- id: unified_ui.tooling.component_generators
  statement: The package shall provide generator tasks for current extension points, including `mix unified_ui.gen.widget`, `mix unified_ui.gen.screen`, and `mix unified_ui.gen.extension`.
  priority: must
  stability: stable

- id: unified_ui.tooling.preview_and_stats
  statement: The package shall provide project inspection and preview tasks that can render screen modules across supported platforms and report codebase statistics.
  priority: must
  stability: stable

- id: unified_ui.tooling.dev_wrappers
  statement: The package shall provide current workflow wrapper tasks for formatting, testing, benchmarking, and performance checks.
  priority: must
  stability: stable
```

## Verification

```spec-verification
- kind: source_file
  target: packages/unified-ui/lib/mix/tasks/unified_ui.new.ex
  covers:
    - unified_ui.tooling.project_generator

- kind: source_file
  target: packages/unified-ui/lib/mix/tasks/unified_ui.gen.widget.ex
  covers:
    - unified_ui.tooling.component_generators

- kind: source_file
  target: packages/unified-ui/lib/mix/tasks/unified_ui.gen.screen.ex
  covers:
    - unified_ui.tooling.component_generators

- kind: source_file
  target: packages/unified-ui/lib/mix/tasks/unified_ui.gen.extension.ex
  covers:
    - unified_ui.tooling.component_generators

- kind: source_file
  target: packages/unified-ui/lib/mix/tasks/unified_ui.preview.ex
  covers:
    - unified_ui.tooling.preview_and_stats

- kind: source_file
  target: packages/unified-ui/lib/mix/tasks/unified_ui.stats.ex
  covers:
    - unified_ui.tooling.preview_and_stats

- kind: source_file
  target: packages/unified-ui/lib/mix/tasks/unified_ui.format.ex
  covers:
    - unified_ui.tooling.dev_wrappers

- kind: source_file
  target: packages/unified-ui/lib/mix/tasks/unified_ui.test.ex
  covers:
    - unified_ui.tooling.dev_wrappers

- kind: source_file
  target: packages/unified-ui/lib/mix/tasks/unified_ui.bench.ex
  covers:
    - unified_ui.tooling.dev_wrappers

- kind: source_file
  target: packages/unified-ui/lib/mix/tasks/unified_ui.perf.check.ex
  covers:
    - unified_ui.tooling.dev_wrappers

- kind: source_file
  target: packages/unified-ui/test/mix/tasks/unified_ui_new_task_test.exs
  covers:
    - unified_ui.tooling.project_generator

- kind: source_file
  target: packages/unified-ui/test/mix/tasks/unified_ui_gen_widget_task_test.exs
  covers:
    - unified_ui.tooling.component_generators

- kind: source_file
  target: packages/unified-ui/test/mix/tasks/unified_ui_gen_screen_task_test.exs
  covers:
    - unified_ui.tooling.component_generators

- kind: source_file
  target: packages/unified-ui/test/mix/tasks/unified_ui_gen_extension_task_test.exs
  covers:
    - unified_ui.tooling.component_generators

- kind: source_file
  target: packages/unified-ui/test/mix/tasks/unified_ui_preview_task_test.exs
  covers:
    - unified_ui.tooling.preview_and_stats

- kind: source_file
  target: packages/unified-ui/test/mix/tasks/unified_ui_stats_task_test.exs
  covers:
    - unified_ui.tooling.preview_and_stats

- kind: source_file
  target: packages/unified-ui/test/mix/tasks/unified_ui_format_task_test.exs
  covers:
    - unified_ui.tooling.dev_wrappers

- kind: source_file
  target: packages/unified-ui/test/mix/tasks/unified_ui_test_task_test.exs
  covers:
    - unified_ui.tooling.dev_wrappers

- kind: source_file
  target: packages/unified-ui/test/mix/tasks/unified_ui_bench_task_test.exs
  covers:
    - unified_ui.tooling.dev_wrappers

- kind: source_file
  target: packages/unified-ui/test/mix/tasks/unified_ui_perf_check_task_test.exs
  covers:
    - unified_ui.tooling.dev_wrappers
```
