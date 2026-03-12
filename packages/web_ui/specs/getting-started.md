# Specs Getting Started

This guide explains how to use the specs system for a new or early-stage project.

## 1) Establish Baseline Architecture

Start with:

- [design.md](/Users/Pascal/code/unified/web_ui/specs/design.md)
- [topology.md](/Users/Pascal/code/unified/web_ui/specs/topology.md)
- [boundaries.md](/Users/Pascal/code/unified/web_ui/specs/boundaries.md)
- [control_planes.md](/Users/Pascal/code/unified/web_ui/specs/control_planes.md)
- [services-and-libraries.md](/Users/Pascal/code/unified/web_ui/specs/services-and-libraries.md)
- [targets.md](/Users/Pascal/code/unified/web_ui/specs/targets.md)

Goal: document system shape and ownership boundaries before writing component specs.

## 2) Lock Authority In ADR-0001

Use [ADR-0001-control-plane-authority.md](/Users/Pascal/code/unified/web_ui/specs/adr/ADR-0001-control-plane-authority.md) as the architecture tie-breaker.

When authority changes, update ADR-0001 in the same change set.

## 3) Define Contract Requirements

Contracts define requirement families (`REQ-*`) that implementation and reviews must satisfy.

Typical baseline families:

- control plane ownership
- service/runtime behavior
- observability
- security/policy
- data/schema boundaries

## 4) Define Conformance Scenarios

Conformance documents define:

- scenario catalog (`SCN-*`)
- requirement-to-scenario matrix mappings

Every requirement family should be represented by one or more scenarios.

## 5) Define Event Handling Surface

If the project includes interactive UI surfaces, define the code-handled event layer under:

- `specs/events/README.md`
- `specs/events/event_type_catalog.md`
- `specs/events/widget_event_matrix.md`

Use Elm handler APIs (`Html.Events`, `Browser.Events`) as the canonical source for event trigger semantics.

## 6) Add Component Specs With AC Mapping

As implementation starts, add component specs with acceptance criteria (`AC-*`).

Each `AC-*` MUST map to:

- at least one `REQ-*` family
- at least one `SCN-*` scenario

## 7) Run Governance Checks

Validate policy and conformance alignment locally:

```bash
./scripts/validate_specs_governance.sh
./scripts/run_conformance.sh
```

## 8) Bootstrap A New Project Scaffold

Use the generator script from this repository:

```bash
./scripts/gen-specs.sh --target /path/to/project --project-name my_project
```

This creates a baseline `specs/` tree with:

- baseline architecture docs
- contract stubs
- ADR-0001
- conformance scenario/matrix stubs
- operations/planning stubs
