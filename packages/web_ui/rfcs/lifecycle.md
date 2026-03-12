# RFC Lifecycle And Status Transition Rules

This guide defines lifecycle hygiene for `rfcs/RFC-XXXX-*.md` documents and their corresponding `rfcs/index.md` rows.

## Allowed Statuses

- `Draft`
- `Proposed`
- `Accepted`
- `Rejected`
- `Implemented`
- `Superseded`

## Transition Rules

Allowed transitions:

- `Draft` -> `Proposed`, `Rejected`
- `Proposed` -> `Accepted`, `Rejected`
- `Accepted` -> `Implemented`, `Superseded`
- `Implemented` -> `Superseded`
- `Rejected` -> `Draft` (only if reopened with explicit note in `Open Questions`)

Disallowed transitions:

- `Rejected` -> `Accepted` without first returning to `Draft`
- `Superseded` -> any non-superseded state

## Status Change PR Checklist

Every PR that changes an RFC status SHOULD include:

1. Updated `Status` metadata in the RFC document.
2. Matching `Status` update in `rfcs/index.md`.
3. Updated `Notes` section in `rfcs/index.md` describing transition context.
4. `Supersedes` and/or `Superseded By` linkage updates when applicable.

Additional mandatory checks:

1. If status becomes `Accepted` or `Implemented`, the same change set MUST include at least one `specs/*.md` update.
2. If status becomes `Superseded`, the RFC metadata MUST include `Superseded By: RFC-YYYY` and the replacing RFC SHOULD include `Supersedes: RFC-XXXX`.

## Supersede And Deprecation Conventions

When RFC `RFC-A` supersedes `RFC-B`:

1. `RFC-B` status MUST be `Superseded`.
2. `RFC-B` metadata SHOULD set `Superseded By: RFC-A`.
3. `RFC-A` metadata SHOULD set `Supersedes: RFC-B`.
4. `rfcs/index.md` rows for both RFCs SHOULD reflect the relationship.

If an RFC leads to deprecating a spec path:

1. The RFC `Spec Creation Plan` row MUST use `deprecate`.
2. The matching spec document SHOULD include an explicit deprecation note with replacement target and timeline.
3. Related contract/matrix/scenario updates SHOULD be included in the same PR when behavior changes.
