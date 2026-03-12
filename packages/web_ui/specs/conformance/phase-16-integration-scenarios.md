# Phase 16 Integration Scenarios

## Purpose

Define conformance scenarios for deterministic Unified-IUR interpretation and canonical signal/event mapping.

## Unified-IUR Interpretation Scenarios

1. `SCN-021`: equivalent Unified-IUR layout inputs normalize to deterministic runtime descriptor trees.
2. `SCN-021`: Unified-IUR signal hooks (`on_click`, `on_change`, `on_submit`) map to canonical `unified.*` event templates.
3. `SCN-021`: malformed Unified-IUR descriptors fail closed with typed validation errors.

## Validation Commands

```bash
mix test test/web_ui/integration/phase_16_unified_iur_interpretation_test.exs
./scripts/run_conformance.sh --report-only
```
