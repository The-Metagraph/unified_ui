# CSS Style Authoring Planning

This directory contains the phased implementation plan for CSS stylesheet
authoring in `UnifiedUi`, canonical style lowering into `UnifiedIUR`, and
tooling/runtime alignment for CSS-derived canonical style data.

The plan aligns to:
- [CSS Style Authoring ADR](../../decisions/architecture/repo.ecosystem.css_style_authoring.md)
- [DSL and IUR Symbiosis](../../specs/dsl_iur_symbiosis.spec.md)
- [UnifiedUi DSL](../../specs/unified-ui/dsl.spec.md)
- [Unified UI Theming](../../specs/unified-ui/theming.spec.md)
- [UnifiedUi Compiler](../../specs/unified-ui/compiler.spec.md)
- [UnifiedIUR Theming](../../specs/unified-iur/theming.spec.md)

## Phase Files

1. [Phase 1 - CSS Authoring Surface and Parser Boundary](./phase-01-css-authoring-surface-and-parser-boundary.md): implement the authored CSS block shape, parser adapter, source model, and recoverable syntax diagnostics.
2. [Phase 2 - Selector Matching and Cascade Resolution](./phase-02-selector-matching-and-cascade-resolution.md): implement the supported selector subset, authored-node matching, specificity, source order, and style precedence behavior.
3. [Phase 3 - Declaration Translation and Canonical Style Mapping](./phase-03-declaration-translation-and-canonical-style-mapping.md): map supported CSS declarations, values, units, shorthands, and state-scoped rules into canonical style concepts while ignoring unsupported constructs with diagnostics.
4. [Phase 4 - Compiler, IUR, Tooling, and Runtime Alignment](./phase-04-compiler-iur-tooling-and-runtime-alignment.md): integrate CSS lowering into compiler output, IUR representation, inspection/export tooling, examples, and runtime realization checks.

## Numbering

- Phases: `N`
- Sections: `N.M`
- Tasks: `N.M.K`
- Subtasks: `N.M.K.L`

Every phase, section, task, and subtask uses Markdown checkboxes. Every phase,
section, and task starts with a short description paragraph. Each phase ends
with an integration-testing section.

## Shared Assumptions and Defaults

- CSS stylesheet blocks are an authored DSL convenience, not a raw CSS runtime
  interchange format.
- CSS input is parsed through a CSS Syntax-compatible stylesheet parser with
  standard recovery behavior.
- Accepting actual CSS syntax does not imply full browser CSS semantic
  equivalence.
- Unsupported selectors, at-rules, declarations, values, units, functions, and
  unsafe external-resource features are ignored with deterministic diagnostics.
- Supported CSS rules lower into canonical style and theme data before
  `UnifiedIUR` output is emitted.
- Runtime packages remain native UI libraries and consume canonical style data
  rather than authored CSS blocks.
