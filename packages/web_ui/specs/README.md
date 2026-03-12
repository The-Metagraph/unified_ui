# Specs Index

This directory is the architecture and governance source of truth for `web_ui`.

Normative language in this directory uses RFC-2119 terms: **MUST**, **MUST NOT**, **SHOULD**, **SHOULD NOT**, and **MAY**.

## How The Specs System Works

The specs system is layered:

1. Baseline architecture docs define system shape and authority boundaries.
2. Contracts define enforceable requirement families (`REQ-*`).
3. ADRs define architectural authority and decision history.
4. Conformance docs define scenario families (`SCN-*`) and requirement-to-scenario mappings.
5. Operations/planning docs define rollout and execution governance.

`AC-*` acceptance criteria are introduced in component specs as implementation starts and MUST map to both `REQ-*` and `SCN-*`.

## Governance Model

The governance gate enforces change policy:

1. Contract changes require conformance matrix updates in the same change set.
2. Contract or architecture baseline changes require an ADR update in the same change set.
3. AC-bearing component spec changes require contract and conformance mapping alignment.

This keeps architecture authority, contract requirements, and conformance coverage synchronized.

## Start Here

- [getting-started.md](/Users/Pascal/code/unified/web_ui/specs/getting-started.md)

## Canonical Baselines

- [design.md](/Users/Pascal/code/unified/web_ui/specs/design.md)
- [topology.md](/Users/Pascal/code/unified/web_ui/specs/topology.md)
- [boundaries.md](/Users/Pascal/code/unified/web_ui/specs/boundaries.md)
- [control_planes.md](/Users/Pascal/code/unified/web_ui/specs/control_planes.md)
- [targets.md](/Users/Pascal/code/unified/web_ui/specs/targets.md)
- [services-and-libraries.md](/Users/Pascal/code/unified/web_ui/specs/services-and-libraries.md)

## Contract Layer

- [contracts/control_plane_ownership_matrix.md](/Users/Pascal/code/unified/web_ui/specs/contracts/control_plane_ownership_matrix.md)
- [contracts/service_contract.md](/Users/Pascal/code/unified/web_ui/specs/contracts/service_contract.md)
- [contracts/supervision_restart_contract.md](/Users/Pascal/code/unified/web_ui/specs/contracts/supervision_restart_contract.md)
- [contracts/turn_execution_contract.md](/Users/Pascal/code/unified/web_ui/specs/contracts/turn_execution_contract.md)
- [contracts/policy_authorization_contract.md](/Users/Pascal/code/unified/web_ui/specs/contracts/policy_authorization_contract.md)
- [contracts/scope_resolution_contract.md](/Users/Pascal/code/unified/web_ui/specs/contracts/scope_resolution_contract.md)
- [contracts/prompt_asset_contract.md](/Users/Pascal/code/unified/web_ui/specs/contracts/prompt_asset_contract.md)
- [contracts/persistence_replay_contract.md](/Users/Pascal/code/unified/web_ui/specs/contracts/persistence_replay_contract.md)
- [contracts/observability_contract.md](/Users/Pascal/code/unified/web_ui/specs/contracts/observability_contract.md)
- [contracts/eval_contract.md](/Users/Pascal/code/unified/web_ui/specs/contracts/eval_contract.md)
- [contracts/widget_system_contract.md](/Users/Pascal/code/unified/web_ui/specs/contracts/widget_system_contract.md)

## Events

- [events/README.md](/Users/Pascal/code/unified/web_ui/specs/events/README.md)
- [events/event_type_catalog.md](/Users/Pascal/code/unified/web_ui/specs/events/event_type_catalog.md)
- [events/widget_event_matrix.md](/Users/Pascal/code/unified/web_ui/specs/events/widget_event_matrix.md)
- [events/elm_binding_examples.md](/Users/Pascal/code/unified/web_ui/specs/events/elm_binding_examples.md)

## ADRs

- [adr/ADR-0001-control-plane-authority.md](/Users/Pascal/code/unified/web_ui/specs/adr/ADR-0001-control-plane-authority.md)

## Conformance

- [conformance/spec_conformance_matrix.md](/Users/Pascal/code/unified/web_ui/specs/conformance/spec_conformance_matrix.md)
- [conformance/scenario_catalog.md](/Users/Pascal/code/unified/web_ui/specs/conformance/scenario_catalog.md)
- [conformance/fault_recovery_and_determinism_hardening.md](/Users/Pascal/code/unified/web_ui/specs/conformance/fault_recovery_and_determinism_hardening.md)

## Planning

- [planning/README.md](/Users/Pascal/code/unified/web_ui/specs/planning/README.md)

## Operations

- [operations/README.md](/Users/Pascal/code/unified/web_ui/specs/operations/README.md)

## Governance Validation

Run the docs governance gate locally:

```bash
./scripts/validate_specs_governance.sh
```

Run the conformance harness locally:

```bash
./scripts/run_conformance.sh
```

or:

```bash
mix conformance
```

CI runs the same checks in:

- `.github/workflows/specs-governance.yml`
- `.github/workflows/conformance.yml`
