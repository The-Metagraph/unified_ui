# WebUi Observability

This subject backfills the current observability contract implemented by
`packages/web_ui`.

```spec-meta
id: web_ui.observability
kind: subsystem
status: active
summary: Current observability contract for `packages/web_ui`, including runtime-event conformance, bounded metrics, correlation joinability, and integration with transport, widget, agent, and service-result flows.
surface:
  - packages/web_ui/lib/web_ui/observability/runtime_event.ex
  - packages/web_ui/lib/web_ui/observability/metrics.ex
  - packages/web_ui/lib/web_ui/observability/diagnostics.ex
  - packages/web_ui/lib/web_ui/channel.ex
  - packages/web_ui/lib/web_ui/agent.ex
  - packages/web_ui/lib/web_ui/widget.ex
  - packages/web_ui/lib/web_ui/service_result_envelope.ex
  - packages/web_ui/test/web_ui/observability
  - packages/web_ui/test/web_ui
decisions:
  - repo.governance.contract_policy
```

## Requirements

```spec-requirements
- id: web_ui.observability.runtime_event_conformance
  statement: 'The package shall enforce the current runtime-event envelope contract for required fields, versioned event names, timestamp validity, allowed outcomes, context continuity, and conformance-failure fallback events.'
  priority: must
  stability: stable

- id: web_ui.observability.metrics_and_joinability
  statement: 'The package shall maintain the current bounded metric family registry, label policy, record aggregation behavior, and event-to-metric joinability diagnostics based on correlation and request identifiers.'
  priority: must
  stability: stable

- id: web_ui.observability.integration_emission
  statement: 'The current channel, widget, agent, and service-result paths shall emit runtime observability events and metric records for success, failure, timeout, encode or decode failure, denied paths, and service lifecycle outcomes.'
  priority: must
  stability: stable
```

## Verification

```spec-verification
- kind: source_file
  target: packages/web_ui/lib/web_ui/observability/runtime_event.ex
  covers:
    - web_ui.observability.runtime_event_conformance

- kind: source_file
  target: packages/web_ui/lib/web_ui/observability/metrics.ex
  covers:
    - web_ui.observability.metrics_and_joinability

- kind: source_file
  target: packages/web_ui/lib/web_ui/observability/diagnostics.ex
  covers:
    - web_ui.observability.metrics_and_joinability
    - web_ui.observability.integration_emission

- kind: source_file
  target: packages/web_ui/lib/web_ui/channel.ex
  covers:
    - web_ui.observability.integration_emission

- kind: source_file
  target: packages/web_ui/lib/web_ui/agent.ex
  covers:
    - web_ui.observability.integration_emission

- kind: source_file
  target: packages/web_ui/lib/web_ui/widget.ex
  covers:
    - web_ui.observability.integration_emission

- kind: source_file
  target: packages/web_ui/lib/web_ui/service_result_envelope.ex
  covers:
    - web_ui.observability.integration_emission

- kind: source_file
  target: packages/web_ui/test/web_ui/observability/runtime_event_test.exs
  covers:
    - web_ui.observability.runtime_event_conformance

- kind: source_file
  target: packages/web_ui/test/web_ui/observability/metrics_test.exs
  covers:
    - web_ui.observability.metrics_and_joinability

- kind: source_file
  target: packages/web_ui/test/web_ui/observability/diagnostics_test.exs
  covers:
    - web_ui.observability.metrics_and_joinability

- kind: source_file
  target: packages/web_ui/test/web_ui/channel_observability_test.exs
  covers:
    - web_ui.observability.integration_emission

- kind: source_file
  target: packages/web_ui/test/web_ui/channel_metrics_test.exs
  covers:
    - web_ui.observability.integration_emission

- kind: source_file
  target: packages/web_ui/test/web_ui/agent_metrics_test.exs
  covers:
    - web_ui.observability.integration_emission

- kind: source_file
  target: packages/web_ui/test/web_ui/integration/phase_07_observability_baseline_test.exs
  covers:
    - web_ui.observability.runtime_event_conformance
    - web_ui.observability.metrics_and_joinability
    - web_ui.observability.integration_emission
```
