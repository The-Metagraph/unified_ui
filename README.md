# WebUi

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `web_ui` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:web_ui, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/web_ui>.

## Conformance

Run the deterministic conformance harness locally:

```bash
./scripts/run_conformance.sh
```

Quick scenario-alignment report without running tests:

```bash
./scripts/run_conformance.sh --report-only
```

Convenience aliases:

```bash
make conformance
make conformance-report
```

Triage flow for failures:

1. Fix any scenario-alignment errors first (`SCN-*` missing from catalog/matrix/tests).
2. Re-run `./scripts/run_conformance.sh --report-only` and confirm alignment passes.
3. Run `./scripts/run_conformance.sh` to reproduce test failures with deterministic seed.
4. Update contracts, matrix, and tests in the same change set when behavior changes.

## RFC Governance

Validate RFC governance mappings and lifecycle checks:

```bash
./scripts/validate_rfc_governance.sh
# or
make rfc-governance
```

Preview spec generation from an RFC plan:

```bash
./scripts/gen_specs_from_rfc.sh --rfc rfcs/RFC-0001-rfc-governance-and-spec-intake.md --dry-run
# or
make rfc-specs-dry-run RFC=rfcs/RFC-0001-rfc-governance-and-spec-intake.md
```

Generate stubs (skip existing by default, optional overwrite):

```bash
make rfc-specs-generate RFC=rfcs/RFC-0001-rfc-governance-and-spec-intake.md
make rfc-specs-generate RFC=rfcs/RFC-0001-rfc-governance-and-spec-intake.md OVERWRITE=1
```

Scan for governance debt:

```bash
./scripts/scan_rfc_governance_debt.sh
# or
make rfc-governance-debt-scan
```

## Release Readiness

Run the full release-readiness gate locally:

```bash
./scripts/run_release_readiness.sh
# or
make release-readiness
```

Run report mode (governance + conformance alignment, no full test suite):

```bash
./scripts/run_release_readiness.sh --report-only
# or
make release-readiness-report
```

## Frontend Toolchain (Elm + Tailwind + DaisyUI)

This repository now includes a frontend scaffold under `assets/` with:

- Elm app source in `assets/src/Main.elm`
- Tailwind CSS input in `assets/css/app.css`
- DaisyUI configured in `assets/tailwind.config.cjs`
- Static preview shell in `assets/index.html`

Setup and build:

```bash
mix assets.setup
mix assets.build
```

Makefile wrappers:

```bash
make assets-setup
make assets-build
make assets-css-watch
```

Build output:

- `assets/dist/app.css` (Tailwind + DaisyUI)
- `assets/dist/app.js` (compiled Elm)
