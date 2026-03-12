# Package

Current package and repository contract for UnifiedUi.

```spec-meta
id: unified_ui.package
kind: package
status: active
summary: Published package identity, repository automation, and shipped example surfaces for UnifiedUi.
surface:
  - mix.exs
  - README.md
  - lib/unified_ui.ex
  - examples/custom_widget/README.md
  - .github/workflows/ci.yml
  - .github/workflows/release.yml
  - .github/ISSUE_TEMPLATE/*.yml
  - PULL_REQUEST_TEMPLATE.md
```

## Requirements

```spec-requirements
- id: unified_ui.package.metadata
  statement: The repository shall define UnifiedUi package metadata, documentation extras, and a public version helper.
  priority: must
  stability: stable

- id: unified_ui.package.overview
  statement: The package overview shall describe UnifiedUi as a Spark-based multi-platform UI DSL targeting terminal, desktop, and web renderers.
  priority: must
  stability: evolving

- id: unified_ui.package.repo_automation
  statement: The repository shall include CI, release, issue, and pull request automation files that codify contribution and validation workflow.
  priority: must
  stability: stable

- id: unified_ui.package.extension_example
  statement: The repository shall ship a custom widget example that matches the documented extension path.
  priority: should
  stability: evolving
```

## Verification

```spec-verification
- kind: source_file
  target: mix.exs
  covers:
    - unified_ui.package.metadata

- kind: source_file
  target: lib/unified_ui.ex
  covers:
    - unified_ui.package.metadata

- kind: readme_file
  target: README.md
  covers:
    - unified_ui.package.overview

- kind: workflow_file
  target: .github/workflows/ci.yml
  covers:
    - unified_ui.package.repo_automation

- kind: workflow_file
  target: .github/workflows/release.yml
  covers:
    - unified_ui.package.repo_automation

- kind: file
  target: .github/ISSUE_TEMPLATE/bug_report.yml
  covers:
    - unified_ui.package.repo_automation

- kind: file
  target: .github/ISSUE_TEMPLATE/feature_request.yml
  covers:
    - unified_ui.package.repo_automation

- kind: file
  target: .github/ISSUE_TEMPLATE/guide_feedback.yml
  covers:
    - unified_ui.package.repo_automation

- kind: file
  target: PULL_REQUEST_TEMPLATE.md
  covers:
    - unified_ui.package.repo_automation

- kind: file
  target: examples/custom_widget/README.md
  covers:
    - unified_ui.package.extension_example

- kind: test_file
  target: test/unified_ui/github_automation_config_test.exs
  covers:
    - unified_ui.package.repo_automation

- kind: test_file
  target: test/unified_ui/unified_ui_test.exs
  covers:
    - unified_ui.package.metadata

- kind: command
  target: mix test test/unified_ui/github_automation_config_test.exs test/unified_ui/unified_ui_test.exs
  execute: true
  covers:
    - unified_ui.package.metadata
    - unified_ui.package.repo_automation
```
