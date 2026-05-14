# Phase 5 - Suite Catalog, Tooling, and Validation Workflow

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `examples/README`
- `examples/catalog.tsv`
- `LiveUi.Tooling`
- `Mix.Tasks.LiveUi.*`
- `UnifiedUi.Compiler`
- `LiveUi.Renderer`

## Relevant Assumptions / Defaults
- The full example-app catalog exists or is nearly complete before this phase begins.
- Tooling should help maintainers discover apps, run them, preview them, and validate suite-wide contract continuity.
- Validation should focus on catalog completeness, shared-template reuse, and shared-theme/style continuity across the suite.

[x] 5 Phase 5 - Suite Catalog, Tooling, and Validation Workflow
  Implement the suite index, app discovery tooling, preview surfaces, and validation workflows that turn the example apps into a maintainable review surface rather than just a directory of standalone projects.

[x] 5.1 Section - Root Suite Index and Catalog Discovery
    Implement the root suite index and discovery surfaces that let maintainers map widgets to example apps quickly.

    [x] 5.1.1 Task - Implement the root example-suite index
      Provide one authoritative root index that explains the common DSL template contract and full per-widget app catalog.

      [x] 5.1.1.1 Subtask - Implement the root `examples/README` as the suite landing page.
      [x] 5.1.1.2 Subtask - Add machine-readable or easily parseable catalog metadata for example app discovery.
      [x] 5.1.1.3 Subtask - Add tests that prove the root index stays synchronized with the example catalog.

  [x] 5.2 Section - Independent App Run and Preview Tooling
    Implement the tooling that lets maintainers run and preview one example app at a time.

    [x] 5.2.1 Task - Implement per-app run and preview workflows
      Provide one repeatable path for starting or previewing an individual example app without hand-crafted one-off commands.

      [x] 5.2.1.1 Subtask - Implement helper scripts, Mix tasks, or documented commands that run one example app independently.
      [x] 5.2.1.2 Subtask - Implement preview workflows that surface the shared template and primary widget focus clearly.
      [x] 5.2.1.3 Subtask - Add tests that prove example-app discovery and preview routing work for representative apps from multiple families.

[x] 5.3 Section - Shared Template and Theme Validation
    Implement the validation workflows that reject catalog drift and shared-template divergence across the suite.

    [x] 5.3.1 Task - Implement suite validation checks
      Provide validation that the example suite remains complete and consistent with the self-contained app contract.

      [x] 5.3.1.1 Subtask - Implement validation that every catalog entry has a corresponding example-app directory.
      [x] 5.3.1.2 Subtask - Implement validation that every example app uses the shared DSL template and shared default theme/style profile.
      [x] 5.3.1.3 Subtask - Add tests that fail when an app diverges from the shared template or shared theme contract.

  [x] 5.4 Section - Cross-Family Review Metadata
    Implement the metadata surfaces that help reviewers map any app back to its widget family, theme baseline, and shared template contract.

    [x] 5.4.1 Task - Implement review metadata and reporting
      Provide review metadata that makes the suite usable as a coverage and comparison surface during package review.

      [x] 5.4.1.1 Subtask - Implement per-app metadata for widget family, primary subject, and shared-template usage.
      [x] 5.4.1.2 Subtask - Implement suite-level reporting for catalog completeness and shared-theme continuity.
      [x] 5.4.1.3 Subtask - Add tests that prove review metadata stays traceable to the example catalog and suite index.

  [x] 5.5 Section - Phase 5 Integration Tests
    Validate the suite index, per-app preview tooling, and suite-wide validation workflows through one maintainer path.

    [x] 5.5.1 Task - Suite tooling and validation integration scenarios
      Verify the example suite behaves like one coherent product-level review surface rather than a disconnected set of standalone apps.

      [x] 5.5.1.1 Subtask - Verify maintainers can discover, run, and preview representative apps from multiple families through one workflow.
      [x] 5.5.1.2 Subtask - Verify validation catches catalog drift and shared-template divergence reliably.
      [x] 5.5.1.3 Subtask - Verify suite metadata remains aligned with the example catalog and root index.
