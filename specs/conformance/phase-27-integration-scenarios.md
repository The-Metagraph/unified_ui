# Phase 27 Integration Scenarios

## Purpose

Define conformance scenarios for deterministic interpretation of canonical `unified_iur` structures and fail-closed schema/source drift handling.

## Canonical Unified-IUR Dependency Scenarios

1. `SCN-032`: equivalent canonical `UnifiedIUR.*` inputs normalize to deterministic runtime descriptor trees.
2. `SCN-032`: unsupported Unified-IUR schema/source markers fail closed with typed validation errors.
3. `SCN-032`: repeated equivalent canonical interpretation flows produce equivalent trace outputs.

## Validation Commands

```bash
mix test test/web_ui/integration/phase_27_canonical_unified_iur_dependency_test.exs
./scripts/run_conformance.sh --report-only
```
