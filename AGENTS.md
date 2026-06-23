# unified_ui

> Spec-Led monorepo for the unified UI ecosystem. An authored DSL (`unified_ui`) lowers to a canonical IR (`unified_iur`), rendered by runtime libraries (`live_ui`, `elm_ui`, `desktop_ui`, `terminal_ui`). Plan/contract: `.spec/specs/architecture.spec.md` — do not restate it here.

<!-- Reviewed 2026-06-22. No phase numbers / PR ranges / status - link live sources. -->

## Stack

Elixir 1.19.5-otp-28 / Erlang 28.3.1 (`.tool-versions`; nodejs 22.14.0 for Elm/assets). Spark DSL (vendored `vendor/spark`), `jido_signal ~> 2.0`, Phoenix + LiveView (runtime libs). Spec-led via `spec_led_ex`.

## Setup

Root `mix.exs` is thin (spec tooling + lint only). Code lives in package-local Mix projects under `packages/`. Work per package:

```bash
cd packages/<pkg>      # unified-ui | unified_iur | live_ui | elm_ui | desktop_ui | terminal_ui
mix deps.get
```

## Build / test / lint

```bash
mix compile --warnings-as-errors
mix test                                   # from inside the package dir
mix test test/foo_test.exs                 # single file
mix test test/foo_test.exs:42              # single test by line
mix format
mix credo --strict
```

Done = run this gate from the repo root (mirrors `.githooks/pre-commit`):

```bash
mix format --check-formatted && mix compile --warnings-as-errors && mix credo --strict && mix dialyzer
```

Plus `mix spec.check` and `mix spec.diffcheck` when specs/code/docs/tests changed.

## Layout

- `packages/unified-ui/` (app `:unified_ui`) authored DSL + compiler (hyphen dir, underscore elsewhere); `packages/unified_iur/` (app `:unified_iur`) canonical IR; `packages/{live_ui,elm_ui,desktop_ui,terminal_ui}/` runtime libraries (native + IUR renderer).
- `.spec/` current-truth contract layer (read `.spec/AGENTS.md` before editing); `examples/<widget>/` standalone apps (`examples/catalog.tsv` = catalog); `vendor/spark` vendored DSL toolkit.

## Boundaries (MANDATORY — see CLAUDE.md for rationale)

- `unified_ui` = only authored DSL boundary; `unified_iur` = only cross-package interchange/rendering boundary. Renderers consume `UnifiedIUR`, must NOT require DSL modules; runtime-native structs/responsibilities must not leak into canonical values. `Jido.Signal` (CloudEvents) = cross-package transport contract.
- Deps: nothing from the Metagraph tree upstream; runtimes path-dep `{:unified_iur, path: "../unified_iur"}`, `unified-ui` path-deps `unified_iur` + vendored `spark`. Downstream `ash_ui` vendors these; `ariston-ui` gets them transitively.
- Canonical surface changes: specs move WITH code in the same change set (`.spec/specs/governance/contracts/*_change_contract.spec.md`). No branch-local proposal layer under `.spec/`; don't hand-edit generated `.spec/state.json` or planning mirrors.
- Branch `codex/<topic>`; one reviewable arc per PR; commit body = WHY. Review with `codex exec --profile deep-review` (sandbox/approval per `~/.codex/config.toml`); never read, echo, or commit secrets.
- Co-maintained repo (Pascal/pcharbon70 as architect): respect existing `.spec/`/README conventions.

## Pointers

- Plan/spec: `.spec/specs/architecture.spec.md`, `.spec/AGENTS.md`, `.spec/specs/governance/`
- Open work: `gh pr list --repo The-Metagraph/unified_ui`
- Workspace core: `~/.codex/AGENTS.md`
