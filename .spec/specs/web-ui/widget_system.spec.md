# WebUi Widget System

This subject backfills the current widget-catalog, registration, and render
boundary contract for `packages/web_ui`.

```spec-meta
id: web_ui.widget_system
kind: subsystem
status: active
summary: Current widget system contract for `packages/web_ui`, including descriptor validation, built-in catalog parity, governed custom registration, and normalized render request or result flows.
surface:
  - packages/web_ui/lib/web_ui/widget_descriptor.ex
  - packages/web_ui/lib/web_ui/widget_registration_request.ex
  - packages/web_ui/lib/web_ui/widget_registry.ex
  - packages/web_ui/lib/web_ui/widget_render_request.ex
  - packages/web_ui/lib/web_ui/widget_render_result.ex
  - packages/web_ui/lib/web_ui/widget.ex
  - packages/web_ui/test/web_ui
decisions:
  - repo.governance.contract_policy
```

## Requirements

```spec-requirements
- id: web_ui.widget_system.catalog_baseline
  statement: 'The package shall maintain the current built-in widget catalog, descriptor completeness rules, category and event-type validation, and catalog fingerprint or term_ui parity checks implemented by `WebUi.WidgetRegistry`.'
  priority: must
  stability: stable

- id: web_ui.widget_system.custom_registration
  statement: 'The widget registry shall support the current governed custom-widget registration flow, including descriptor validation, reserved-id protection, implementation references, capabilities, and lifecycle registration events.'
  priority: must
  stability: stable

- id: web_ui.widget_system.render_boundary
  statement: 'The widget render boundary shall normalize current render requests and results, render built-in widgets deterministically, require explicit extension dispatch for custom widgets, deny blocked extension actions, and emit the current lifecycle or diagnostic events.'
  priority: must
  stability: stable
```

## Verification

```spec-verification
- kind: source_file
  target: packages/web_ui/lib/web_ui/widget_descriptor.ex
  covers:
    - web_ui.widget_system.catalog_baseline
    - web_ui.widget_system.custom_registration

- kind: source_file
  target: packages/web_ui/lib/web_ui/widget_registration_request.ex
  covers:
    - web_ui.widget_system.custom_registration

- kind: source_file
  target: packages/web_ui/lib/web_ui/widget_registry.ex
  covers:
    - web_ui.widget_system.catalog_baseline
    - web_ui.widget_system.custom_registration

- kind: source_file
  target: packages/web_ui/lib/web_ui/widget_render_request.ex
  covers:
    - web_ui.widget_system.render_boundary

- kind: source_file
  target: packages/web_ui/lib/web_ui/widget_render_result.ex
  covers:
    - web_ui.widget_system.render_boundary

- kind: source_file
  target: packages/web_ui/lib/web_ui/widget.ex
  covers:
    - web_ui.widget_system.render_boundary

- kind: source_file
  target: packages/web_ui/test/web_ui/widget_descriptor_test.exs
  covers:
    - web_ui.widget_system.catalog_baseline

- kind: source_file
  target: packages/web_ui/test/web_ui/widget_registration_request_test.exs
  covers:
    - web_ui.widget_system.custom_registration

- kind: source_file
  target: packages/web_ui/test/web_ui/widget_registry_catalog_test.exs
  covers:
    - web_ui.widget_system.catalog_baseline

- kind: source_file
  target: packages/web_ui/test/web_ui/widget_registry_descriptor_test.exs
  covers:
    - web_ui.widget_system.catalog_baseline

- kind: source_file
  target: packages/web_ui/test/web_ui/widget_registry_custom_test.exs
  covers:
    - web_ui.widget_system.custom_registration

- kind: source_file
  target: packages/web_ui/test/web_ui/widget_render_request_test.exs
  covers:
    - web_ui.widget_system.render_boundary

- kind: source_file
  target: packages/web_ui/test/web_ui/widget_render_test.exs
  covers:
    - web_ui.widget_system.render_boundary

- kind: source_file
  target: packages/web_ui/test/web_ui/widget_custom_render_test.exs
  covers:
    - web_ui.widget_system.render_boundary

- kind: source_file
  target: packages/web_ui/test/web_ui/integration/phase_04_widget_registry_test.exs
  covers:
    - web_ui.widget_system.catalog_baseline
    - web_ui.widget_system.render_boundary

- kind: source_file
  target: packages/web_ui/test/web_ui/integration/phase_06_custom_widget_governance_test.exs
  covers:
    - web_ui.widget_system.custom_registration
    - web_ui.widget_system.render_boundary
```
