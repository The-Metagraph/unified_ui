# Reference Blueprint Proof

This guide records the three examples that Phase 1 uses as the first proof set
for the self-contained refactor. The goal is to make the first migrations
repeatable instead of picking examples ad hoc in later phases.

## Shared-to-Local Replacement Map

Every first-pass migration should use the same replacement model:

- `UnifiedExamples.Shared.App` becomes explicit local `:application`,
  `:endpoint`, `:router`, `:layouts`, and `:live` modules
- `UnifiedExamples.Shared.Template` becomes explicit local `:screen`,
  `:theme`, `:style_profile`, and `:helpers` modules
- `UnifiedExamples.Shared.Fixtures` becomes a local `:fixtures` module only
  when the example actually needs fixture data

## Reference Examples

### `button`

- proof kind: `:low_complexity_content`
- family: `:content`
- reason: it uses the shared app and template macros without pulling in shared
  fixtures
- proof target: preserve the suite shell, accent action styling, and authored
  click interaction while moving to explicit local runtime and authored modules

### `text_input`

- proof kind: `:input_oriented`
- family: `:input`
- reason: it is the clearest input-focused proof that still exercises form
  shell behavior, primary input styling, and reviewer-visible interaction notes
- proof target: replace shared panel helpers locally while preserving the same
  input styling and interaction storytelling

### `cluster_dashboard`

- proof kind: `:high_complexity_runtime`
- family: `:operational`
- reason: it combines shared fixtures with a more involved operational surface
  while still needing the same browser shell and theme baseline
- proof target: move fixture-heavy operational behavior local without losing the
  preserved shell, theme, and style continuity

## Phase 1 Outcome

Section `1.3` is complete when maintainers can point to one low-complexity
content example, one input-oriented example, and one higher-complexity example
as the first migration proofs. The structured implementation surface for this
guide lives in `UnifiedExamples.Shared.SelfContainedBlueprint.reference_blueprint_proof/0`.
