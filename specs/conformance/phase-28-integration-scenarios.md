# Phase 28 Integration Scenarios

## Purpose

Define conformance scenarios for deterministic canonical Unified-IUR container traversal and extended signal/event mapping behavior.

## Canonical Extended Unified-IUR Scenarios

1. `SCN-033`: equivalent canonical extended Unified-IUR inputs produce deterministic event traces and widget inventories.
2. `SCN-033`: malformed extended signal payloads fail closed with typed validation errors.
3. `SCN-033`: repeated equivalent extended interpretation flows produce equivalent traces.

## Validation Commands

```bash
mix test test/web_ui/integration/phase_28_canonical_unified_iur_extended_mapping_test.exs
./scripts/run_conformance.sh --report-only
```
