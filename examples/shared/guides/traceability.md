# Example Suite Traceability

The standalone example-app suite is meant to be reviewable against the package
contracts it demonstrates.

For every example app, the shared tooling records the same three-layer flow:

1. `unified_ui`
   The example screen is authored through the shared `UnifiedUi` DSL template
   and compiled through the `unified_ui` package contract.
2. `unified_iur`
   The authored result lowers into canonical `UnifiedIUR`, which is the
   renderer-independent boundary for the example suite.
3. `live_ui`
   The canonical output is mounted through `live_ui`, which renders the screen
   under the shared default theme and shared default style profile.

The shared traceability metadata exposes:

- package roots for `unified_ui`, `unified_iur`, and `live_ui`
- package spec files for each of those packages
- root ecosystem spec files that define the authored, canonical, and runtime
  contract
- the relevant governance contract files for `unified_ui` and `unified_iur`
- the example-suite package specs that define the suite itself

Use the traceability metadata when:

- reviewing whether a new example app belongs in the suite
- checking whether a shared-template change affects package boundaries
- proving that an example app is still aligned with the authored DSL,
  canonical IUR, and runtime rendering contracts
