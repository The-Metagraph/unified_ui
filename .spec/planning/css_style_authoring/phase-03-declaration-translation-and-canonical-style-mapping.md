# Phase 3 - Declaration Translation and Canonical Style Mapping

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces

- `UnifiedUi.Style`
- `UnifiedIUR.Style`
- `UnifiedIUR.Theme`
- CSS declaration representation from Phase 1
- CSS cascade result representation from Phase 2

## Relevant Assumptions / Defaults

- Declaration support is driven by explicit canonical style fields, not by
  browser property coverage.
- Unsupported declarations are ignored with diagnostics and do not become raw
  runtime CSS.
- Values normalize into canonical colors, text style attributes, spacing,
  sizing, layout hints, borders, radii, opacity, and state-scoped variants only
  where those concepts already have or receive canonical representation.
- External resources such as `url()` are ignored until a safe canonical asset
  contract exists.

[ ] 3 Phase 3 - Declaration Translation and Canonical Style Mapping
  Translate supported CSS declarations, values, units, shorthands, and
  state-scoped rules into canonical style concepts while preserving diagnostics
  for ignored or unsafe CSS features.

  [x] 3.1 Section - Property Coverage and Canonical Mapping
    Define a reviewed property map from CSS declaration names to canonical style
    fields so support expands deliberately and remains renderer-independent.

    [x] 3.1.1 Task - Map foundational visual properties
      Implement mappings for common color, text, spacing, border, radius, and
      opacity properties that correspond to canonical style concepts.

      [x] 3.1.1.1 Subtask - Map `color`, `background-color`, and supported border colors to canonical named, indexed, RGB, or semantic color values.
      [x] 3.1.1.2 Subtask - Map supported font weight, font style, text decoration, and opacity declarations to canonical style attributes.
      [x] 3.1.1.3 Subtask - Map supported spacing, gap, padding, margin, border width, and radius declarations where canonical layout and style models can represent them.
      [x] 3.1.1.4 Subtask - Ignore unsupported visual properties with declaration-level diagnostics.

    [x] 3.1.2 Task - Map layout and display-adjacent properties conservatively
      Translate only layout-related CSS that has a clear canonical equivalent
      and leave browser layout models outside the initial canonical contract.

      [x] 3.1.2.1 Subtask - Identify which dimensions, alignment, overflow, and display declarations map to existing canonical layout or display-system fields.
      [x] 3.1.2.2 Subtask - Ignore CSS layout systems without canonical representation, such as unrestricted flex, grid, container-query, and position behavior.
      [x] 3.1.2.3 Subtask - Add diagnostics that point authors to canonical layout DSL constructs when CSS declarations are not the right authoring surface.
      [x] 3.1.2.4 Subtask - Keep translated layout-adjacent declarations deterministic across renderer targets.

  [x] 3.2 Section - Value Normalization and Shorthand Expansion
    Normalize CSS values into canonical value types and expand supported
    shorthands without carrying parser-specific tokens into later compiler
    passes.

    [x] 3.2.1 Task - Normalize colors, units, keywords, and functions
      Translate supported value forms into canonical values and ignore values
      that cannot be represented portably.

      [x] 3.2.1.1 Subtask - Normalize CSS named colors, hex colors, `rgb()`, `rgba()`, and supported semantic token references into canonical color values.
      [x] 3.2.1.2 Subtask - Normalize supported lengths, percentages, zero values, and unitless values into canonical unit structures.
      [x] 3.2.1.3 Subtask - Normalize supported keywords such as `none`, `solid`, `bold`, `italic`, and canonical state keywords.
      [x] 3.2.1.4 Subtask - Ignore unsupported functions, calculations, variables, and external-resource values with diagnostics.

    [x] 3.2.2 Task - Expand supported shorthands
      Support high-value shorthand declarations only when expansion is
      unambiguous and every expanded field has canonical meaning.

      [x] 3.2.2.1 Subtask - Expand supported box shorthands such as padding, margin, border width, border color, and border radius.
      [x] 3.2.2.2 Subtask - Expand supported text decoration and font shorthands only where canonical style fields can represent the result.
      [x] 3.2.2.3 Subtask - Emit diagnostics for partially supported shorthands rather than applying incomplete or misleading style output.
      [x] 3.2.2.4 Subtask - Ensure longhand declarations override shorthand-derived values according to cascade result ordering.

  [ ] 3.3 Section - State, Variant, Safety, and Unsupported Feature Handling
    Preserve portable CSS-derived style meaning while preventing unsupported or
    unsafe browser-specific features from entering the canonical contract.

    [ ] 3.3.1 Task - Lower state-scoped declarations
      Convert rules matched through supported pseudo-classes into canonical
      state or variant style data.

      [ ] 3.3.1.1 Subtask - Map supported state pseudo-class matches into canonical focused, disabled, selected, active-like, or emphasis-oriented state styles.
      [ ] 3.3.1.2 Subtask - Define how state-scoped CSS-derived styles merge with existing component variants and state styles.
      [ ] 3.3.1.3 Subtask - Preserve state-style provenance for inspection output.
      [ ] 3.3.1.4 Subtask - Ignore state selectors that have no canonical state representation with diagnostics.

    [ ] 3.3.2 Task - Enforce unsupported and unsafe feature policy
      Keep CSS lowering loss-tolerant and safe by ignoring concepts that have no
      canonical style meaning or safe asset boundary.

      [ ] 3.3.2.1 Subtask - Ignore `@import`, external `url()` resources, remote fonts, animations, transitions, custom property definitions, and browser-only effects unless a later canonical contract supports them.
      [ ] 3.3.2.2 Subtask - Emit diagnostics that distinguish unsupported property, unsupported value, unsupported unit, unsafe external resource, and ignored at-rule cases.
      [ ] 3.3.2.3 Subtask - Ensure ignored declarations do not affect cascade resolution for supported declarations.
      [ ] 3.3.2.4 Subtask - Keep unsupported-feature diagnostics stable enough for tests and review tooling.

  [ ] 3.4 Section - Phase 3 Integration Tests
    Validate declaration translation, value normalization, shorthand behavior,
    state-style lowering, and unsupported-feature diagnostics against canonical
    style output.

    [ ] 3.4.1 Task - Supported declaration translation scenarios
      Verify common CSS declarations produce the expected canonical style and
      theme data.

      [ ] 3.4.1.1 Subtask - Verify colors, text attributes, opacity, spacing, border, and radius declarations lower into canonical style fields.
      [ ] 3.4.1.2 Subtask - Verify supported values normalize consistently across equivalent CSS spellings.
      [ ] 3.4.1.3 Subtask - Verify supported shorthands expand deterministically and respect longhand override behavior.
      [ ] 3.4.1.4 Subtask - Verify state pseudo-class rules lower into canonical state-scoped style data.

    [ ] 3.4.2 Task - Unsupported and unsafe declaration scenarios
      Verify unsupported CSS remains loss-tolerant and visible through
      diagnostics without becoming raw runtime CSS.

      [ ] 3.4.2.1 Subtask - Verify unsupported properties and unsupported values are ignored with declaration-level diagnostics.
      [ ] 3.4.2.2 Subtask - Verify unsafe external-resource values such as `url()` are ignored with safety diagnostics.
      [ ] 3.4.2.3 Subtask - Verify unsupported shorthands do not partially mutate canonical style output.
      [ ] 3.4.2.4 Subtask - Verify ignored declarations do not affect supported declaration cascade results.
