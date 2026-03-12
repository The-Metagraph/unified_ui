# Troubleshooting

## Compile-Time Verifier Errors

### Symptom

Compilation fails with DSL verification errors.

### Checks

- Ensure all `id` values are unique in a UI tree.
- Ensure layout nesting is valid.
- Ensure named style references used in `style` exist.
- Ensure state references match declared `state` keys.

## Signals Not Updating State

### Symptom

Events fire but `update/2` does not change state.

### Checks

- Confirm adapter events are mapped via `*.Events.to_signal/2`.
- Match on the actual signal shape in `update/2` (`type` + `data.action`).
- Keep a fallback clause: `def update(state, _), do: state`.

## Style Not Applied

### Symptom

Rendered output ignores expected style.

### Checks

- Verify style keys are valid (`fg`, `bg`, `attrs`, spacing, dimensions).
- If using named styles, verify the referenced style name exists.
- Validate adapter style conversion modules for target-specific behavior.

## Test Failures In Planning Phases

### Symptom

Phase integration tests fail after DSL or adapter changes.

### Checks

- Re-run targeted tests first (`mix test test/unified_ui/integration/phase_*.exs`).
- Confirm changed entities still map to correct `UnifiedIUR` structs.
- Confirm adapter render output keeps expected shape and metadata.

## Doc Build Issues

### Symptom

`mix docs` fails or guide is missing.

### Checks

- Ensure guide file is listed in `mix.exs` `docs.extras`.
- Check markdown links are valid.
- Re-run `mix docs` and inspect `doc/index.html`.

## Guide Clarity Feedback

### Symptom

A guide works eventually, but one or more sections are hard to follow.

### Checks

- Open a `Guide feedback` issue using `.github/ISSUE_TEMPLATE/guide_feedback.yml`.
- Include the exact guide path and section heading.
- Include what you expected to happen and what blocked you.
