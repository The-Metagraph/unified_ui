# Maintainer Workflows

Run package-local checks from `packages/desktop_ui`:

```bash
mix deps.get
mix compile
mix test
```

Run the current workspace planning check from the repository root:

```bash
mix spec.plancheck desktop_ui
```

Phase 1 focuses on package structure, runtime seams, platform seams, and
reference helpers. Canonical renderer coverage, transport translation, and
artifact packaging workflows are layered in later phases.
