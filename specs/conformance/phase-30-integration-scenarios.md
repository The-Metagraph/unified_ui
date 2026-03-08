# Phase 30 Integration Scenarios

## Purpose

Define conformance scenarios for deterministic canonical Unified-IUR descriptor parity between equivalent struct and map interpretations.

## Canonical Descriptor Parity Scenarios

1. `SCN-035`: equivalent canonical extended struct/map inputs produce identical normalized descriptor trees and event traces.
2. `SCN-035`: canonical default-prop normalization removes default-only widget fields while preserving non-default render props.
3. `SCN-035`: malformed extended payloads fail closed with typed validation errors under parity-enabled interpreter flow.

## Validation Command

```bash
mix test test/web_ui/integration/phase_30_canonical_unified_iur_descriptor_parity_test.exs
```
