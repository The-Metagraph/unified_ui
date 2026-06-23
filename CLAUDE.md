# unified_ui

Spec-Led monorepo for the **unified UI ecosystem**: an authored DSL (`unified_ui`) lowers to a canonical intermediate representation (`unified_iur`), which several runtime libraries (`live_ui`, `elm_ui`, `desktop_ui`, `terminal_ui`) render natively or via the IUR. Canonical plan + contract live in [`.spec/specs/architecture.spec.md`](.spec/specs/architecture.spec.md).

<!-- Last reviewed 2026-06-22 - link live state, do not inline status. -->

## Quick start

The root `mix.exs` is thin (spec tooling + lint only). Real implementation lives in package-local Mix projects under `packages/`. Build and test per package.

```bash
# Per package (packages/*/):
cd packages/live_ui
mix deps.get
mix compile --warnings-as-errors
mix test
mix test test/path/to/specific_test.exs          # single file
mix test test/path/to/specific_test.exs:42        # single test by line

# Lint (Credo + Dialyzer wired at the repo root; Credo also per package):
mix format --check-formatted
mix credo --strict
mix dialyzer

# Spec-led workflow (repo root):
mix spec.plan            # generate/update .spec/state.json
mix spec.verify --debug  # verify all spec requirements
mix spec.check           # strict verification (fails on warnings)
mix spec.diffcheck       # run when code/docs/tests changed
mix spec.report          # coverage + weak-spot summaries
```

**The real quality gate** (mirrors `.githooks/pre-commit`, run from repo root):

```bash
mix format --check-formatted && mix compile --warnings-as-errors && mix credo --strict && mix dialyzer
```

Then `mix spec.check` and `mix spec.diffcheck` when specs/code/docs/tests moved.

## Architecture

Three-layer pipeline, authored once and rendered many ways:

- **`packages/unified-ui`** (app `:unified_ui`, namespace `UnifiedUi`) — the *only* authored DSL boundary. Uses Spark (vendored at `vendor/spark`) for sectioned authoring across identity, composition, theming, signals. Compiles authored modules into canonical `UnifiedIUR` — never renderer-specific output.
- **`packages/unified_iur`** (app `:unified_iur`, namespace `UnifiedIUR`) — pure, renderer-independent canonical IR: widgets, layout, layers, style, theming, bindings, interactions. The portable cross-package boundary.
- **Runtime libraries** — `live_ui` (Phoenix LiveView), `elm_ui` (Phoenix + Elm), `desktop_ui` (SDL3-oriented), `terminal_ui` (capability-aware TUI). Each is a first-class native widget library *and* an IUR renderer. Loading IUR is one entry point, not the only one.

Common flow: `UnifiedUi` DSL → `UnifiedIUR` → `LiveUi` (or another runtime).

Non-obvious dirs:
- `.spec/` — current-truth contract layer (specs, governance, ADRs, conformance evidence, planning manifests). See Pointers.
- `examples/<widget_name>/` — self-contained standalone example apps; `examples/catalog.tsv` is the machine-readable catalog. No shared example-support package.
- `vendor/spark` — vendored Spark DSL toolkit (path-dep of `unified-ui`).

## Dependencies & boundaries (MANDATORY)

**Upstream (consumed):** nothing from the Metagraph tree — this is a self-contained UI ecosystem. Internal seam: every runtime library path-deps `unified_iur` (`{:unified_iur, path: "../unified_iur"}`); `unified-ui` path-deps `unified_iur` + vendored `spark`. `live_ui`/`elm_ui` pull `jido_signal ~> 2.0`, `phoenix`, `phoenix_live_view`.

**Downstream (consumes this):** `ash_ui` (sibling, `TheMetagraph/ash_ui`) vendors these packages internally; `ariston-ui` declares only `:ash_ui` and gets `unified_ui`/`live_ui` transitively. Ariston-specific widgets that don't generalize stay in `ariston-ui`, not here.

**Contracts at each seam:**
- **IUR is the canonical interchange + rendering boundary.** Renderer packages consume `UnifiedIUR` and must NOT require authored DSL modules once IUR is available. Runtime-native structs must not leak into canonical core values.
- **`Jido.Signal` is the shared transport contract** — cross-package UI interaction meaning uses `Jido.Signal` with CloudEvents-compatible semantics. Runtimes translate between canonical signals and their local signal models.
- **DSL is the single authored boundary** — `unified_ui` is the only place widgets/layouts/theming/signals are authored.

## Hard rules (reverted if violated)

- `unified_ui` is the ONLY authored DSL boundary; `unified_iur` is the ONLY cross-package canonical interchange/rendering boundary.
- Runtime-native widget, runtime, styling, and local-signal responsibilities must NOT be moved into `unified_ui` or `unified_iur`. The runtimes are not IUR-only shells.
- When you change canonical `unified_ui` or `unified_iur` surface, the specs move with the code **in the same change set** (governed by the `*_change_contract.spec.md` files under `.spec/specs/governance/contracts/`).
- Do NOT create a branch-local proposal layer under `.spec/`. Authored subject specs are current truth; Git history / PRs are the change timeline.
- Do NOT hand-edit generated `.spec/state.json` or `.spec/planning/*/spec-traceability.md` — regenerate via the owning Mix tasks.
- Conformance evidence (`.spec/conformance/`) is separate from governance subjects; do not embed one into the other.

## Conventions

- Branch `claude/<topic>` (Claude) or `codex/<topic>` (Codex). One reviewable arc per PR.
- Commit subject is descriptive; body explains WHY (the diff shows WHAT).
- Spec-led deltas ride WITH the code: update `.spec/specs/**/*.spec.md` first, ADRs (`.spec/decisions/`) only for durable cross-cutting policy, conformance evidence separately.
- Prefer targeted package-local tests over broad repo-wide runs.
- Packages target Elixir `~> 1.19`; older runtimes fail before compilation.

## Claude Code specifics

- **Skills:** `specled` (spec workspace work — read specs, ADRs, phased plans), `widget` (designing/adding/reviewing widgets across AshUI / UnifiedUi / IUR / Live UI / Elm UI / Desktop UI, and the canonical-vs-`custom:*` decision).
- **Co-maintained repo** (Pascal/jallum as architect): be respectful of existing `.spec/` and README conventions. Substrate gaps become roadmap, not asks. Public-framework discipline applies (breaking-change care, release notes).
- Package-local tooling for inspection/preview/export:
  - `unified-ui`: `mix unified_ui.{inspect,export,validate}`
  - `unified_iur`: `mix unified_iur.{inspect,export,validate}`
  - `live_ui`: `mix live_ui.{demo,preview,inspect,export,validate}` (`mix live_ui.demo --serve` → http://127.0.0.1:4040)
  - `examples/<widget>`: `mix example.start` (→ http://127.0.0.1:5000), `--target-package desktop_ui|elm_ui|terminal_ui`

## Gotchas

- Three name spellings: repo dir `unified_ui` (underscore), DSL package dir `unified-ui` (hyphen), module/app `unified_ui` (underscore again). The hyphenated package dir is the lone outlier.
- Root `mix.exs` app is `:unified` and only carries `spec_led_ex` + `credo` + `dialyxir` — it is NOT where the UI code compiles. `cd` into a `packages/*` dir for real work.
- Spark is vendored at `vendor/spark` and `override: true`-d by `unified-ui`; don't expect it from Hex.
- `.spec/` is **current-truth only** — use Git history for the change timeline, not branch-local notes.

## Pointers (live, NOT inlined)

- Canonical architecture/contract: [`.spec/specs/architecture.spec.md`](.spec/specs/architecture.spec.md), [`.spec/specs/dsl_iur_symbiosis.spec.md`](.spec/specs/dsl_iur_symbiosis.spec.md), [`.spec/specs/platform_runtimes.spec.md`](.spec/specs/platform_runtimes.spec.md), [`.spec/specs/signal_transport.spec.md`](.spec/specs/signal_transport.spec.md)
- Spec workspace rules: [`.spec/AGENTS.md`](.spec/AGENTS.md), [`.spec/README.md`](.spec/README.md)
- Governance contracts: [`.spec/specs/governance/`](.spec/specs/governance/)
- Open work: `gh pr list --repo The-Metagraph/unified_ui`
- Workspace conventions (umbrella): [`../CLAUDE.md`](../CLAUDE.md)
