# Boundaries: Core vs Host vs External

## Purpose

This document defines practical ownership boundaries for `web_ui` to prevent split runtime authority.

Primary recommendation:

- keep `web_ui` as a transport/UI integration framework
- keep domain/runtime authority in host-app runtime services
- externalize heavy integrations behind explicit contracts

## Boundary Principles

1. `web_ui` owns transport and UI integration seams, not product domain logic.
2. Domain state mutation MUST happen in host runtime services.
3. CloudEvents-shaped envelopes are the only client/server payload boundary.
4. Browser JS interop is optional and MUST stay behind explicit ports.
5. Persistence and external integrations stay behind host adapters.
6. Product UX definitions stay in host app code, not in `web_ui` core.

## Split Gates (Must All Pass)

A concern can move out of core only if all gates pass:

1. It has a stable contract boundary.
2. It does not create a second runtime authority.
3. It preserves observability/correlation requirements.
4. It does not break bootstrap usability for single-node development.
5. It keeps governance and conformance checks coherent.

Default decision: if unclear, keep concern in host-app integrations and revisit with ADR evidence.

## V0 Ownership Matrix

| Concern | V0 Ownership | Why |
|---|---|---|
| Elm runtime bootstrap | Core (`web_ui`) | Shared framework capability |
| Channel/transport handling | Core (`web_ui`) | Shared protocol boundary |
| Domain event handlers | Host app | Product-specific behavior |
| Jido agent runtime | Host app | Authoritative mutable state |
| Persistence adapters | Host app/external libs | Data-plane concern |
| Tailwind/theme composition | Host app | Product UX concern |
| JS interop extensions | Mixed (core seam, host implementations) | Keep core minimal while allowing flexibility |

## Decision Workflow

For each boundary decision:

1. Record ownership and contract in a short note.
2. Evaluate against split gates.
3. If behavior-shape changes, update contracts + conformance mappings.
4. Capture final decision in ADR when ownership changes.
