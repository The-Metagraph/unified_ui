# Guide Clarity Feedback Review (March 7, 2026)

## Scope

Internal maintainer walkthrough of:

- `guides/getting-started.md`
- `guides/troubleshooting.md`

## Feedback Collected

1. **Event conversion example ambiguity**
   The Getting Started event example used `to_signal/3` as if it returned a signal directly, but adapters return `{:ok, signal}` or `{:error, reason}`.

2. **Button identity mismatch**
   The Getting Started UI example omitted explicit button `id`s while the event example referenced `:increment_button`.

3. **No dedicated docs-clarity intake path**
   Existing issue templates covered bugs/features but not guide clarity feedback.

## Actions Taken

1. Updated `guides/getting-started.md` to:
   - add explicit button IDs used by the event example
   - use the correct `{:ok, signal}` return shape from `to_signal/3`
   - use `:click` with `widget_id` payload matching adapter expectations

2. Added `.github/ISSUE_TEMPLATE/guide_feedback.yml` with required fields for:
   - guide path
   - section heading
   - confusion details
   - impact severity

3. Added a "Guide Clarity Feedback" section in `guides/troubleshooting.md` pointing contributors to the guide feedback template.
