# Control Planes

| Plane | Responsibilities | Main Ownership |
|---|---|---|
| **Product Plane** | Product routes, user workflows, auth context, release policy | Host application |
| **UI Runtime Plane** | Elm model/update/view behavior, local rendering state, user interaction events | Browser Elm runtime |
| **Transport Plane** | WebSocket channel lifecycle, envelope validation, message routing ingress/egress | `web_ui` endpoint/channel |
| **Runtime Authority Plane** | Domain logic and mutable runtime state transitions | Jido runtime services |
| **Data Plane** | Persistence, replay data, external integration state | Host app adapters/integrations |
| **Extension Plane** | Optional JS interop and future protocol adapters | `web_ui` extension seams |

## Plane Rules

- Runtime authority MUST remain server-side.
- UI runtime MUST NOT bypass transport contracts.
- Transport handlers MUST be stateless orchestration boundaries.
- Extension code MUST NOT introduce alternate domain-state ownership.

## Control Plane Authority

Control-plane ownership for this document and its references MUST follow:

- [control_plane_ownership_matrix.md](/Users/Pascal/code/unified/web_ui/specs/contracts/control_plane_ownership_matrix.md)
