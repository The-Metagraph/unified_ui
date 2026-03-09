# Phase 34 - Frontend Toolchain Enforcement and Merge Gates

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `scripts/validate_frontend_toolchain.sh`
- `.githooks/pre-commit`
- `.githooks/pre-push`
- `.github/workflows/frontend-toolchain.yml`
- `specs/conformance/spec_conformance_matrix.md`

## Relevant Assumptions / Defaults
- Elm, Tailwind CSS, and DaisyUI remain the canonical frontend toolchain for browser assets in this repository.
- Frontend validation must run in both local development gates and CI merge gates.
- Frontend validation must fail closed when required toolchain files or deterministic build outputs are missing.

[x] 34 Phase 34 - Frontend Toolchain Enforcement and Merge Gates
  Enforce deterministic frontend asset validation across local hooks, CI workflows, and conformance mapping.

  [x] 34.1 Section - Frontend Validation Script
    Define a deterministic frontend validation script for toolchain wiring and build output checks.

    [x] 34.1.1 Task - Implement frontend toolchain validator entrypoint
      Add a reusable script that validates required toolchain files and frontend build output determinism.

      [x] 34.1.1.1 Subtask - Implement report-only validation for required frontend toolchain files.
      [x] 34.1.1.2 Subtask - Implement strict build validation flow with optional dependency-install skipping.
      [x] 34.1.1.3 Subtask - Implement Makefile target wiring for local frontend validation.

  [x] 34.2 Section - Git Hook Gate Wiring
    Wire frontend validation into local commit/push gate boundaries.

    [x] 34.2.1 Task - Implement hook-level frontend validation enforcement
      Ensure frontend checks are invoked consistently at pre-commit and pre-push stages.

      [x] 34.2.1.1 Subtask - Implement pre-commit report-only frontend validation invocation.
      [x] 34.2.1.2 Subtask - Implement pre-push frontend build validation invocation.
      [x] 34.2.1.3 Subtask - Implement local documentation updates for hook behavior and frontend validation commands.

  [x] 34.3 Section - CI Merge Gate Coverage
    Add dedicated CI enforcement for frontend toolchain validation.

    [x] 34.3.1 Task - Implement frontend toolchain workflow checks
      Ensure pull requests and pushes run frontend validation with pinned Node runtime setup.

      [x] 34.3.1.1 Subtask - Implement GitHub Actions workflow for frontend toolchain validation.
      [x] 34.3.1.2 Subtask - Implement Node runtime setup with deterministic npm cache behavior.
      [x] 34.3.1.3 Subtask - Implement workflow command wiring to `validate_frontend_toolchain.sh`.

  [x] 34.4 Section - Phase 34 Integration Tests
    Validate frontend enforcement continuity through conformance-tagged integration coverage.

    [x] 34.4.1 Task - Frontend validation conformance scenarios
      Verify deterministic hook/workflow/script wiring and report-only script behavior.

      [x] 34.4.1.1 Subtask - Verify `SCN-039` script report-only mode passes with required frontend files present.
      [x] 34.4.1.2 Subtask - Verify `SCN-039` git hooks reference frontend validation commands at expected gate boundaries.
      [x] 34.4.1.3 Subtask - Verify `SCN-039` CI workflow references pinned Node setup and frontend validation command wiring.
