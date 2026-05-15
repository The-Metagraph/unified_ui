---
id: repo.ecosystem.css_style_authoring
status: accepted
date: 2026-05-15
affects:
  - ecosystem.dsl_iur_symbiosis
  - unified_ui.dsl
  - unified_ui.theming
  - unified_ui.compiler
  - unified_iur.theming
---

# CSS Stylesheet Blocks Lower Into Canonical Style Data

## Context

The current styling and theming model is canonical: authors declare style and
theme intent in `unified_ui`, the compiler resolves that intent, and runtimes
consume renderer-independent `unified_iur` style and theme data. This keeps the
ecosystem portable across web, desktop, terminal, and other runtime targets.

Authors also expect CSS as a familiar authoring language, especially for class,
state, selector, and declaration-based styling. The ecosystem can support that
authoring workflow without making browser CSS the canonical interchange
contract. The boundary needs to accept real CSS syntax, recover like CSS
parsers do, translate supported style meaning into the existing canonical style
model, and ignore unsupported concepts without losing deterministic diagnostics.

## Decision

1. `unified_ui` may expose CSS stylesheet blocks as an authored styling
   convenience inside the DSL.
2. CSS stylesheet blocks are parsed through a CSS Syntax-compatible stylesheet
   parser with stylesheet-level error recovery rather than through ad-hoc
   string parsing.
3. Supported CSS selectors and declarations are lowered into canonical style
   and theme data before canonical `unified_iur` output is emitted.
4. Raw CSS is not a new `unified_iur` interchange format. Runtimes continue to
   consume canonical style and theme data, although renderers may realize that
   canonical data through native CSS, classes, terminal attributes, desktop
   drawing primitives, or other runtime-native mechanisms.
5. The initial selector model should match authored nodes through canonical
   identity, portable classes, widget or component kinds, explicitly supported
   structural selectors, and supported state pseudo-classes.
6. For supported rules, cascade resolution follows CSS specificity and source
   order, then participates in the existing canonical style precedence where
   theme defaults and referenced component styles are weaker than CSS-derived
   rules, and explicit local style declarations remain strongest.
7. Unsupported at-rules, selectors, properties, values, units, functions, and
   unsafe external-resource features are ignored with diagnostics. Ignoring an
   unsupported CSS construct shall not make the whole CSS block invalid when
   the CSS parser can recover and continue.
8. Accepting actual CSS syntax is not a promise of full browser CSS semantic
   equivalence. Only CSS concepts with an explicit canonical style meaning are
   translated into the ecosystem contract.

## Consequences

- CSS authoring becomes a front-end authoring convenience for canonical style
  data, not a renderer-specific escape hatch.
- `unified_ui` needs parser, selector matching, cascade, declaration
  translation, diagnostics, and inspection behavior for CSS stylesheet blocks.
- `unified_iur` needs to represent CSS-derived results as ordinary canonical
  style and theme data, with optional renderer-independent provenance or
  diagnostics metadata for tooling.
- Runtime libraries do not need to understand authored CSS blocks directly, but
  they must continue to realize the canonical style data that results from CSS
  lowering.
- The implementation plan should phase parser boundaries first, then selector
  and cascade behavior, then declaration translation, and finally compiler,
  IUR, tooling, and runtime alignment.
