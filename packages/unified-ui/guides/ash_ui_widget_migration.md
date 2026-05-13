# AshUi Widget Migration

AshUi-originated widget proposals are canonical in `UnifiedUi` only after they
are stripped of Ash, Phoenix, and renderer-local ownership.

## Canonical Mapping

| AshUi proposal shape | Canonical `UnifiedUi` construct | Boundary rule |
| --- | --- | --- |
| Disclosure, kicker, avatar, presence, segmented controls, multi-column rows, artifact rows, sticky headers | Promoted semantic and micro-interaction widgets | Author the portable widget name and canonical fields; keep Ash resource metadata in bindings or host data |
| Pipeline steppers, segmented progress, workflow stage lists, thin meters, slide-over panels, event callouts, redlines, syntax-highlighted code, chat composers | Promoted workflow, document, and composer widgets | Author canonical widget fields and canonical interaction intent |
| `phoenix_form` | `host_form_shell` | The host owns Phoenix form structs, Ash changesets, validation lifecycle, and submit execution |
| Relationship-driven row rendering | `repeated_collection` | Bind a portable collection source and use `row_value`, `row_index`, `row_key`, and `row_payload` descriptors inside one row template |

## What Stays AshUi-Owned

AshUi or the host application owns:

- Ash resources, relationships, calculations, aggregates, and action metadata
- Ash changesets and validation result formatting
- Phoenix or AshPhoenix form structs and lifecycle callbacks
- data loading, authorization, pagination, and persistence
- adapter code that maps host data into canonical binding and row-scope values

## Authoring Notes

Prefer canonical field names even when the original AshUi proposal used a more
specific option. For example, an Ash artifact relationship should become a
`repeated_collection` with `collection_source`, `item_alias`, `index_alias`,
`key_path`, and an `artifact_row` child template. Row actions should emit
canonical interaction intent and `row_payload` descriptors rather than renderer
callbacks or Ash relationship callbacks.

Use `mix unified_ui.inspect --format portable_widgets`,
`mix unified_ui.export --format portable_widgets`, and `mix unified_ui.validate`
to check authoring support, canonical IUR representation, runtime parity, and
row-scope preservation.
