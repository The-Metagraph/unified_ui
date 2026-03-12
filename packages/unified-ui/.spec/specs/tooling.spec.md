# Tooling

Current Mix-task and generator workflow contract for UnifiedUi repositories.

```spec-meta
id: unified_ui.tooling
kind: workflow
status: active
summary: Project, screen, widget, extension, preview, formatting, test, benchmark, performance, and statistics tasks shipped by UnifiedUi.
surface:
  - lib/mix/tasks/unified_ui.new.ex
  - lib/mix/tasks/unified_ui.gen.screen.ex
  - lib/mix/tasks/unified_ui.gen.widget.ex
  - lib/mix/tasks/unified_ui.gen.extension.ex
  - lib/mix/tasks/unified_ui.preview.ex
  - lib/mix/tasks/unified_ui.format.ex
  - lib/mix/tasks/unified_ui.test.ex
  - lib/mix/tasks/unified_ui.stats.ex
  - lib/mix/tasks/unified_ui.bench.ex
  - lib/mix/tasks/unified_ui.perf.check.ex
  - benchmarks/phase5_baseline.exs
  - benchmarks/phase5_budget_check.exs
  - guides/extensions.md
```

## Requirements

```spec-requirements
- id: unified_ui.tooling.project_generator
  statement: mix unified_ui.new shall scaffold a new project with application files, configuration, formatter setup, a starter screen, and starter tests.
  priority: must
  stability: stable

- id: unified_ui.tooling.component_generators
  statement: mix unified_ui.gen.screen, mix unified_ui.gen.widget, and mix unified_ui.gen.extension shall generate modules and optional tests, and the screen generator shall update a supervisor file when requested.
  priority: must
  stability: stable

- id: unified_ui.tooling.preview_and_stats
  statement: mix unified_ui.preview shall render module previews for supported platform selections and mix unified_ui.stats shall report project structure statistics.
  priority: must
  stability: evolving

- id: unified_ui.tooling.dev_wrappers
  statement: mix unified_ui.format, mix unified_ui.test, mix unified_ui.bench, and mix unified_ui.perf.check shall delegate to the underlying formatter, test runner, and benchmark scripts while preserving their supported pass-through options.
  priority: must
  stability: stable

- id: unified_ui.tooling.task_docs
  statement: Shipped UnifiedUi Mix tasks shall provide shortdoc and moduledoc entries.
  priority: should
  stability: stable
```

## Scenarios

```spec-scenarios
- id: unified_ui.tooling.bootstrap_project
  given:
    - a destination path for a new UnifiedUi application
  when:
    - mix unified_ui.new runs
  then:
    - the scaffolded project contains application, config, screen, and test files
  covers:
    - unified_ui.tooling.project_generator

- id: unified_ui.tooling.generate_and_preview
  given:
    - an existing project and a screen or extension module name
  when:
    - the generator tasks and preview task run
  then:
    - the generated modules are written to disk and preview renders for the selected platform
  covers:
    - unified_ui.tooling.component_generators
    - unified_ui.tooling.preview_and_stats
```

## Verification

```spec-verification
- kind: source_file
  target: lib/mix/tasks/unified_ui.new.ex
  covers:
    - unified_ui.tooling.project_generator

- kind: source_file
  target: lib/mix/tasks/unified_ui.gen.screen.ex
  covers:
    - unified_ui.tooling.component_generators

- kind: source_file
  target: lib/mix/tasks/unified_ui.gen.widget.ex
  covers:
    - unified_ui.tooling.component_generators

- kind: source_file
  target: lib/mix/tasks/unified_ui.gen.extension.ex
  covers:
    - unified_ui.tooling.component_generators

- kind: source_file
  target: lib/mix/tasks/unified_ui.preview.ex
  covers:
    - unified_ui.tooling.preview_and_stats

- kind: source_file
  target: lib/mix/tasks/unified_ui.stats.ex
  covers:
    - unified_ui.tooling.preview_and_stats

- kind: source_file
  target: lib/mix/tasks/unified_ui.format.ex
  covers:
    - unified_ui.tooling.dev_wrappers

- kind: source_file
  target: lib/mix/tasks/unified_ui.test.ex
  covers:
    - unified_ui.tooling.dev_wrappers

- kind: source_file
  target: lib/mix/tasks/unified_ui.bench.ex
  covers:
    - unified_ui.tooling.dev_wrappers

- kind: source_file
  target: lib/mix/tasks/unified_ui.perf.check.ex
  covers:
    - unified_ui.tooling.dev_wrappers

- kind: guide_file
  target: guides/extensions.md
  covers:
    - unified_ui.tooling.component_generators

- kind: test_file
  target: test/mix/tasks/unified_ui_new_task_test.exs
  covers:
    - unified_ui.tooling.project_generator

- kind: test_file
  target: test/mix/tasks/unified_ui_gen_screen_task_test.exs
  covers:
    - unified_ui.tooling.component_generators

- kind: test_file
  target: test/mix/tasks/unified_ui_gen_widget_task_test.exs
  covers:
    - unified_ui.tooling.component_generators

- kind: test_file
  target: test/mix/tasks/unified_ui_gen_extension_task_test.exs
  covers:
    - unified_ui.tooling.component_generators

- kind: test_file
  target: test/mix/tasks/unified_ui_preview_task_test.exs
  covers:
    - unified_ui.tooling.preview_and_stats

- kind: test_file
  target: test/mix/tasks/unified_ui_stats_task_test.exs
  covers:
    - unified_ui.tooling.preview_and_stats

- kind: test_file
  target: test/mix/tasks/unified_ui_format_task_test.exs
  covers:
    - unified_ui.tooling.dev_wrappers

- kind: test_file
  target: test/mix/tasks/unified_ui_test_task_test.exs
  covers:
    - unified_ui.tooling.dev_wrappers

- kind: test_file
  target: test/mix/tasks/unified_ui_bench_task_test.exs
  covers:
    - unified_ui.tooling.dev_wrappers

- kind: test_file
  target: test/mix/tasks/unified_ui_perf_check_task_test.exs
  covers:
    - unified_ui.tooling.dev_wrappers

- kind: test_file
  target: test/mix/tasks/unified_ui_tasks_help_test.exs
  covers:
    - unified_ui.tooling.task_docs

- kind: command
  target: mix test test/mix/tasks
  execute: true
  covers:
    - unified_ui.tooling.project_generator
    - unified_ui.tooling.component_generators
    - unified_ui.tooling.preview_and_stats
    - unified_ui.tooling.dev_wrappers
    - unified_ui.tooling.task_docs
```
