# Phase 17 Integration Scenarios

## Purpose

Define conformance scenarios for runtime policy authorization and dispatch guard behavior.

## Policy Authorization Scenarios

1. `SCN-022`: denied widget events fail closed before outbound dispatch and surface typed authorization errors.
2. `SCN-022`: allowed widget events dispatch when allowlist and user requirements are satisfied.
3. `SCN-022`: malformed policy documents fail closed deterministically with typed validation errors.

## Validation Commands

```bash
mix test test/web_ui/integration/phase_17_policy_authorization_test.exs
./scripts/run_conformance.sh --report-only
```
