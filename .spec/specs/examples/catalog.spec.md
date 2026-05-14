# Example Apps Catalog

This subject defines the complete widget and construct catalog that the example
application suite shall cover.

## Related General Specs

- [Example Apps Suite](./package.spec.md)
- [Example Apps Structure](./structure.spec.md)
- [Example Apps DSL Template](./dsl_template.spec.md)
- [Platform Runtimes](../platform_runtimes.spec.md)

```spec-meta
id: repo.examples.catalog
kind: subsystem
status: active
summary: Complete per-widget and per-construct example-application catalog for the standalone `examples/` suite.
surface:
  - examples/**
  - .spec/specs/examples/catalog.spec.md
decisions:
  - repo.ecosystem.contract_model
```

## Requirements

```spec-requirements
- id: repo.examples.catalog.complete_catalog_subject_coverage
  statement: The example-app suite shall include one primary example application for every widget or construct named in the family-specific catalog sections of this subject.
  priority: must
  stability: stable

- id: repo.examples.catalog.one_primary_subject_per_app
  statement: Each focused widget or construct catalog entry shall map to one dedicated example application directory whose primary subject matches the catalog entry name.
  priority: must
  stability: stable

- id: repo.examples.catalog.common_template_continuity
  statement: Every catalog entry shall be demonstrated through the common example-shell authoring contract, the suite default theme, and the suite default style profile so reviewers can compare widgets across a consistent shell.
  priority: must
  stability: stable

- id: repo.examples.catalog.family_traceability
  statement: The catalog shall group example applications by widget family or construct family so maintainers can review coverage by feature area rather than only by directory listing.
  priority: must
  stability: stable
```

## Catalog

### Foundational Content

| Directory | Primary Subject | Family |
| --- | --- | --- |
| `examples/text/` | `text` | content |
| `examples/label/` | `label` | content |
| `examples/icon/` | `icon` | content |
| `examples/image/` | `image` | content |
| `examples/button/` | `button` | content |
| `examples/link/` | `link` | content |
| `examples/separator/` | `separator` | content |
| `examples/spacer/` | `spacer` | content |
| `examples/content/` | `content` | layout/content |

### Forms and Input

| Directory | Primary Subject | Family |
| --- | --- | --- |
| `examples/form_builder/` | `form_builder` | forms |
| `examples/field_group/` | `field_group` | forms |
| `examples/field/` | `field` | forms |
| `examples/text_input/` | `text_input` | input |
| `examples/numeric_input/` | `numeric_input` | input |
| `examples/checkbox/` | `checkbox` | input |
| `examples/radio_group/` | `radio_group` | input |
| `examples/select/` | `select` | input |
| `examples/pick_list/` | `pick_list` | input |
| `examples/date_input/` | `date_input` | input |
| `examples/time_input/` | `time_input` | input |
| `examples/file_input/` | `file_input` | input |
| `examples/toggle/` | `toggle` | input |

### Layout and Display Primitives

| Directory | Primary Subject | Family |
| --- | --- | --- |
| `examples/box/` | `box` | layout |
| `examples/row/` | `row` | layout |
| `examples/column/` | `column` | layout |
| `examples/grid/` | `grid` | layout |
| `examples/viewport/` | `viewport` | display |
| `examples/scroll_bar/` | `scroll_bar` | display |
| `examples/split_pane/` | `split_pane` | display |
| `examples/canvas/` | `canvas` | display |

### Navigation and Selection

| Directory | Primary Subject | Family |
| --- | --- | --- |
| `examples/menu/` | `menu` | navigation |
| `examples/tabs/` | `tabs` | navigation |
| `examples/list/` | `list` | navigation/data |
| `examples/command_palette/` | `command_palette` | navigation |

### Data and Feedback

| Directory | Primary Subject | Family |
| --- | --- | --- |
| `examples/table/` | `table` | data |
| `examples/tree_view/` | `tree_view` | data |
| `examples/markdown_viewer/` | `markdown_viewer` | data |
| `examples/log_viewer/` | `log_viewer` | data |
| `examples/status/` | `status` | feedback |
| `examples/progress/` | `progress` | feedback |
| `examples/gauge/` | `gauge` | feedback/data |
| `examples/inline_feedback/` | `inline_feedback` | feedback |
| `examples/sparkline/` | `sparkline` | data/display |
| `examples/bar_chart/` | `bar_chart` | data/display |
| `examples/line_chart/` | `line_chart` | data/display |

### Operational and Monitoring

| Directory | Primary Subject | Family |
| --- | --- | --- |
| `examples/stream_widget/` | `stream_widget` | operational |
| `examples/process_monitor/` | `process_monitor` | operational |
| `examples/supervision_tree_viewer/` | `supervision_tree_viewer` | operational |
| `examples/cluster_dashboard/` | `cluster_dashboard` | operational |

### Overlays and Layered Constructs

| Directory | Primary Subject | Family |
| --- | --- | --- |
| `examples/overlay/` | `overlay` | overlay |
| `examples/dialog/` | `dialog` | overlay |
| `examples/alert_dialog/` | `alert_dialog` | overlay |
| `examples/context_menu/` | `context_menu` | overlay |
| `examples/toast/` | `toast` | overlay |

## Scenarios

```spec-scenarios
- id: repo.examples.catalog.review_family_coverage
  covers:
    - repo.examples.catalog.complete_catalog_subject_coverage
    - repo.examples.catalog.family_traceability
  given:
    - A reviewer wants to confirm that the example suite covers every current widget family and display construct named in the catalog
  when:
    - The reviewer reads the catalog
  then:
    - The reviewer can see one example application directory for every current subject, grouped by feature family and named after the primary widget or construct
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/examples/catalog.spec.md
  covers:
    - repo.examples.catalog.complete_catalog_subject_coverage
    - repo.examples.catalog.one_primary_subject_per_app
    - repo.examples.catalog.common_template_continuity
    - repo.examples.catalog.family_traceability
    - repo.examples.catalog.review_family_coverage
```
