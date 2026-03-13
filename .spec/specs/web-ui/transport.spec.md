# WebUi Transport

This subject defines the intended ecosystem-aligned signal and transport
contract for `packages/web_ui`.

```spec-meta
id: web_ui.transport
kind: integration
status: active
summary: Ecosystem-aligned transport contract for `packages/web_ui`, bridging canonical widget events between Phoenix and Elm through CloudEvents-shaped envelopes and canonical Jido.Signal semantics.
surface:
  - packages/web_ui
  - .spec/specs/web-ui/transport.spec.md
decisions:
  - repo.ecosystem.contract_model
  - repo.web_ui.ecosystem_alignment
```

## Requirements

```spec-requirements
- id: web_ui.transport.phoenix_elm_bridge
  statement: '`web_ui` shall bridge canonical widget events between Phoenix and Elm through CloudEvents-shaped envelopes and canonical Jido.Signal semantics.'
  priority: must
  stability: stable

- id: web_ui.transport.canonical_event_meaning
  statement: 'The transport boundary shall preserve canonical event meaning across the server and frontend runtimes, including stable signal type, source, subject, and payload semantics.'
  priority: must
  stability: stable

- id: web_ui.transport.local_state_not_contract
  statement: 'Renderer-specific local state may vary inside `web_ui`, but local state shall not replace the canonical signal contract at the cross-package boundary.'
  priority: must
  stability: stable
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/web-ui/transport.spec.md
  covers:
    - web_ui.transport.phoenix_elm_bridge
    - web_ui.transport.canonical_event_meaning
    - web_ui.transport.local_state_not_contract
```
