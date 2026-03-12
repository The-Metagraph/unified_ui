# Targets

## Purpose

This document defines release targets for architecture, governance, and initial runtime readiness.

## V0 Targets

| Target Area | Goal | Validation Signal |
|---|---|---|
| Architecture baseline | Canonical design/topology/boundary docs authored | Baseline docs approved in PR review |
| Contract baseline | Transport/service contract families defined | Contract docs include REQ identifiers |
| Governance | Specs validation passes in CI | `Specs Governance / validate` green |
| Conformance | Scenario catalog and matrix exist and are internally consistent | `Conformance / Conformance` green |
| Runtime bootstrap | Elm app + channel roundtrip operational in dev | End-to-end handshake scenario passes |
| Observability baseline | Correlation fields present in emitted runtime events | Event assertions pass in integration tests |

## Exit Criteria for First Implemented Slice

1. At least one end-to-end user interaction path is event-driven through Elm -> channel -> runtime -> Elm.
2. Event envelope validation and typed error handling are implemented on transport boundaries.
3. Conformance-tagged tests exist for the first implemented scenarios.
4. Governance and conformance scripts pass locally and in CI.
