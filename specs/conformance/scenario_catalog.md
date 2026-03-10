# Scenario Catalog

Canonical validation scenarios for the current baseline contract layer.

| Scenario ID | Name | Summary |
|---|---|---|
| `SCN-001` | Control-plane ownership consistency | Runtime modules map to one canonical plane assignment without conflicts. |
| `SCN-002` | Transport boundary authority | Endpoint/router/channel orchestration does not mutate domain state. |
| `SCN-003` | CloudEvent envelope validation | Ingress rejects malformed envelopes with typed protocol errors. |
| `SCN-004` | Correlation continuity | Correlation and request IDs are preserved ingress -> runtime -> egress. |
| `SCN-005` | Typed service outcome normalization | Runtime operations return typed success/error envelopes only. |
| `SCN-006` | Observability minimum baseline | Required event envelopes and metric families are emitted and joinable. |
| `SCN-007` | Built-in widget catalog parity | Built-in widget catalog exactly matches the public `term_ui` widget baseline list. |
| `SCN-008` | Widget descriptor completeness | Built-in widget descriptors include required schema metadata and stable IDs. |
| `SCN-009` | Custom widget registration validation | Invalid or duplicate custom widget registrations fail closed with typed errors. |
| `SCN-010` | Built-in override protection | Custom registrations cannot replace reserved built-in widget IDs by default. |
| `SCN-011` | Widget event correlation continuity | Widget render and lifecycle events preserve `correlation_id` and `request_id`. |
| `SCN-012` | Deterministic widget render behavior | Equivalent widget descriptor + props + state inputs produce equivalent render outputs. |
| `SCN-013` | Session-resume replay idempotency | Repeated disconnect loops preserve one pending resume join command per topic. |
| `SCN-014` | Retry storm containment | Retry paths apply deterministic backoff and fail closed when retry budget is exhausted. |
| `SCN-015` | Metric rejection joinability resilience | Observability metric rejections preserve correlation context and runtime event integrity. |
| `SCN-016` | Timeout/retry/cancel terminal determinism | Timeout and recovery chains converge to deterministic terminal UI state and retry reset. |
| `SCN-017` | Burst dispatch ordering determinism | Burst widget interactions preserve monotonic dispatch sequence through runtime, transport, and replay. |
| `SCN-018` | Outcome hint reconciliation continuity | Success outcomes preserve normalized `ui_hints` and UI reconciliation applies/clears hints deterministically. |
| `SCN-019` | Release gate regression fail-closed behavior | Release gate regression probes validate deterministic pass markers and fail on injected governance defects. |
| `SCN-020` | Session resume cursor continuity | Reconnect and join-ack flows preserve deterministic resume cursor continuity and replay diagnostics. |
| `SCN-021` | Unified-IUR interpretation continuity | Unified-IUR layout trees and signal hooks normalize into deterministic runtime/event descriptors with fail-closed validation. |
| `SCN-022` | Runtime policy authorization continuity | Policy authorization checks gate dispatch deterministically with typed deny/allow outcomes and fail-closed malformed policy handling. |
| `SCN-023` | Turn execution determinism continuity | Runtime dispatch/reconciliation preserves deterministic `turn_id` progression and active/completed turn state tracking. |
| `SCN-024` | Scope resolution continuity | Runtime dispatch resolves and propagates scope metadata deterministically while enforcing fail-closed scope-policy checks. |
| `SCN-025` | Persistence replay checkpoint continuity | Runtime dispatch/result reconciliation preserve deterministic replay cursor progression and checkpoint continuity for equivalent event flows. |
| `SCN-026` | Replay retention/export control continuity | Replay snapshot/export and compaction control paths preserve deterministic diagnostics and cursor continuity under equivalent flows. |
| `SCN-027` | Replay restore/apply continuity | Replay restore operations rehydrate deterministic replay state and preserve cursor continuity for post-restore dispatch/result appends. |
| `SCN-028` | Replay verification continuity | Replay verification operations detect deterministic match/drift outcomes and stable first-drift diagnostics for equivalent replay traces. |
| `SCN-029` | Replay verification gate continuity | Replay verification gate policies classify deterministic pass/fail outcomes with stable reason sets for equivalent verification inputs. |
| `SCN-030` | Replay baseline capture and gate continuity | Replay baseline capture and baseline gate operations preserve deterministic baseline envelopes and stable gate diagnostics for equivalent replay traces. |
| `SCN-031` | Replay baseline registry continuity | Replay baseline registry upsert/retention/activation flows preserve deterministic active baseline selection and gate resolution under equivalent capture traces. |
| `SCN-032` | Canonical Unified-IUR dependency continuity | Canonical `unified_iur` schema/source markers and `UnifiedIUR.*` struct interpretation remain deterministic with fail-closed drift handling. |
| `SCN-033` | Canonical Unified-IUR extended mapping continuity | Canonical menu/table/tabs/tree descriptors preserve deterministic container traversal and extended `unified.*` event mapping with fail-closed malformed signal handling. |
| `SCN-034` | Canonical Unified-IUR signal coercion and descriptor hygiene continuity | Canonical atom/string signal primitives normalize deterministically and mapped signal fields stay isolated from interpreted widget props. |
| `SCN-035` | Canonical Unified-IUR descriptor parity continuity | Equivalent canonical struct/map extended descriptors normalize to identical interpreted descriptor trees after default-prop canonicalization. |
| `SCN-036` | Canonical Unified-IUR deep value/style parity continuity | Equivalent canonical nested struct/map prop values (including style payloads) normalize to identical deep descriptor value shapes. |
| `SCN-037` | Canonical Unified-IUR nested default profile parity continuity | Equivalent canonical nested descriptors with default-profile differences (for example table columns) normalize to identical interpreted deep snapshots. |
| `SCN-038` | Canonical Unified-IUR collection normalization parity continuity | Equivalent canonical set-like collection values (for example `MapSet` vs list) normalize to deterministic portable shapes with parity-equivalent interpreted snapshots. |
| `SCN-039` | Frontend toolchain enforcement continuity | Elm/Tailwind/DaisyUI toolchain validation remains wired across local hooks and CI so frontend assets build deterministically before merge. |
| `SCN-040` | Elm runtime transport bridge continuity | Elm runtime commands and JS bridge loopback events preserve deterministic bootstrap and typed runtime-event handling in local dev harness flows. |
| `SCN-041` | Frontend transport contract parity continuity | Frontend Elm/JS runtime harness references only canonical transport topic and event names from `WebUi.Transport.Naming`, with deterministic validation gates in local and CI workflows. |
| `SCN-042` | Frontend CloudEvent contract parity continuity | Frontend Elm/JS runtime harness emits and validates CloudEvent envelopes using required fields/extensions from `WebUi.CloudEvent`, with deterministic local and CI contract validation gates. |
| `SCN-043` | Frontend runtime-context continuity and parity | Frontend Elm/JS runtime harness propagates required/optional runtime-context fields (`correlation_id`, `request_id`, `session_id`, `client_id`, `user_id`, `trace_id`) through local transport loops with deterministic local and CI parity validation gates. |
| `SCN-044` | Frontend event catalog parity continuity | Frontend Elm/JS runtime harness emits and validates CloudEvent widget event `type` values against canonical `WebUi.Events.EventCatalog` entries, with deterministic typed invalid-event guardrails and local/CI validation gates. |
| `SCN-045` | Frontend event payload contract parity continuity | Frontend Elm/JS runtime harness emits and validates CloudEvent widget event `data` payload keys against canonical `WebUi.Events.EventCatalog` required key specs, with deterministic typed invalid-payload guardrails and local/CI validation gates. |
| `SCN-046` | Frontend event route contract parity continuity | Frontend Elm/JS runtime harness emits and validates CloudEvent widget event route-family mappings and dispatch-key conventions against canonical `WebUi.Events.EventCatalog` and `WebUi.WidgetRegistry` route contracts, with deterministic typed invalid-route guardrails and local/CI validation gates. |
| `SCN-047` | Frontend route-family continuity and parity | Frontend Elm/JS runtime harness emits and validates CloudEvent widget payload `route_family` continuity against canonical `WebUi.Events.EventCatalog` route-family mappings, with deterministic typed route-family mismatch guardrails and local/CI validation gates. |
| `SCN-048` | Frontend route-keys continuity and parity | Frontend Elm/JS runtime harness emits and validates CloudEvent widget payload `route_keys` continuity against canonical `WebUi.WidgetRegistry` route-key requirements, with deterministic typed route-keys mismatch guardrails and local/CI validation gates. |
| `SCN-049` | Frontend route-key ordering continuity and parity | Frontend Elm/JS runtime harness emits and validates CloudEvent widget payload `route_keys` ordering continuity against canonical `WebUi.WidgetRegistry` route-key ordering requirements, with deterministic typed duplicate/order mismatch guardrails and local/CI validation gates. |
| `SCN-050` | Frontend route-key completeness and parity | Frontend Elm/JS runtime harness emits and validates CloudEvent widget payload `route_keys` required-key completeness against canonical `WebUi.WidgetRegistry` route-key requirements, with deterministic typed missing-key guardrails and local/CI validation gates. |
| `SCN-051` | Frontend route-key allowlist and parity | Frontend Elm/JS runtime harness emits and validates CloudEvent widget payload `route_keys` allowlist continuity against canonical `WebUi.WidgetRegistry` route-key requirements, with deterministic typed unexpected-key guardrails and local/CI validation gates. |
| `SCN-052` | Frontend route-key payload-shape and parity | Frontend Elm/JS runtime harness emits and validates CloudEvent widget payload `route_keys` payload-shape continuity against canonical `WebUi.WidgetRegistry` route-key requirements, with deterministic typed invalid-value guardrails and local/CI validation gates. |
| `SCN-053` | Frontend route-key value-shape and parity | Frontend Elm/JS runtime harness emits and validates CloudEvent widget required route-key field value-shape continuity against canonical `WebUi.WidgetRegistry` route-key requirements, with deterministic typed invalid-value guardrails and local/CI validation gates. |
| `SCN-054` | Frontend route-key value-source and parity | Frontend Elm/JS runtime harness emits and validates CloudEvent widget required route-key source continuity against canonical route-key source conventions, with deterministic typed invalid-source guardrails and local/CI validation gates. |
| `SCN-055` | Frontend route-key source-requirements and parity | Frontend Elm/JS runtime harness emits and validates CloudEvent widget required route-key source-requirement continuity against canonical route-key source conventions, with deterministic typed source-requirement drift guardrails and local/CI validation gates. |
