# Phase 2 - Selector Matching and Cascade Resolution

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces

- `UnifiedUi.Dsl.Node`
- `UnifiedUi.Compiler`
- `UnifiedUi.Style`
- CSS selector representation from Phase 1
- CSS diagnostic representation from Phase 1

## Relevant Assumptions / Defaults

- Supported selectors start with stable ids, portable classes, widget or
  component kinds, explicitly supported structural selectors, and canonical
  state pseudo-classes.
- Unsupported selectors are ignored with diagnostics rather than interpreted
  approximately.
- Pseudo-elements, media queries, container queries, animation selectors, and
  browser-only dynamic states are not canonical until explicitly represented.
- Cascade behavior is deterministic and reviewable across equivalent authored
  modules.

[ ] 2 Phase 2 - Selector Matching and Cascade Resolution
  Implement the supported selector subset, authored-node matching, specificity,
  source order, and canonical style precedence behavior for CSS-derived rules.

  [x] 2.1 Section - Supported Selector Model
    Define the exact selector subset that can participate in canonical style
    lowering and the diagnostics used when selectors are ignored.

    [x] 2.1.1 Task - Define simple selectors and combinations
      Establish the portable selector forms that can be matched against the
      authored DSL tree without requiring browser DOM semantics.

      [x] 2.1.1.1 Subtask - Support `#id` selectors against authored stable node identity.
      [x] 2.1.1.2 Subtask - Support `.class` selectors against normalized portable class metadata.
      [x] 2.1.1.3 Subtask - Support widget and component kind selectors using canonical authored kind names.
      [x] 2.1.1.4 Subtask - Support comma-separated selector lists while preserving per-selector diagnostics and source order.

    [x] 2.1.2 Task - Define structural and state selector boundaries
      Add only the structural and pseudo-class behavior that has portable
      canonical meaning across the ecosystem.

      [x] 2.1.2.1 Subtask - Decide whether descendant and child combinators are supported in the initial implementation.
      [x] 2.1.2.2 Subtask - Map supported pseudo-classes such as focused, disabled, selected, and active-like canonical states to state-scoped style variants.
      [x] 2.1.2.3 Subtask - Ignore unsupported pseudo-classes and pseudo-elements with diagnostics.
      [x] 2.1.2.4 Subtask - Ignore selectors that depend on browser DOM structure unavailable in authored canonical nodes.

  [ ] 2.2 Section - Authored-Node Matching Engine
    Implement deterministic selector matching against the authored DSL tree
    before style data is lowered into canonical IUR nodes.

    [ ] 2.2.1 Task - Build canonical selector match inputs
      Derive the node metadata needed for selector matching from authored
      widgets, layouts, layers, classes, identity, and state declarations.

      [ ] 2.2.1.1 Subtask - Build a traversal index for authored node identity, parentage, component kind, classes, and authored state declarations.
      [ ] 2.2.1.2 Subtask - Preserve node source metadata so selector-match diagnostics can point to authored targets.
      [ ] 2.2.1.3 Subtask - Ensure generated or compiler-expanded nodes have deterministic selector-match identities when they are eligible for CSS-derived styling.

    [ ] 2.2.2 Task - Implement selector matching and ignored-selector diagnostics
      Match supported selector forms exactly and reject unsupported forms
      without guessing or silently applying broad rules.

      [ ] 2.2.2.1 Subtask - Match ids, classes, kind selectors, selector lists, and supported structural selectors against the traversal index.
      [ ] 2.2.2.2 Subtask - Emit diagnostics for selectors that are syntactically valid CSS but unsupported by canonical selector semantics.
      [ ] 2.2.2.3 Subtask - Emit diagnostics for supported selectors that match no authored nodes when configured to do so by tooling or validation mode.
      [ ] 2.2.2.4 Subtask - Keep selector match ordering deterministic by node traversal order and CSS source order.

  [ ] 2.3 Section - Cascade, Specificity, and Style Source Precedence
    Resolve competing CSS-derived declarations using CSS ordering rules and
    then merge them into the existing canonical style precedence model.

    [ ] 2.3.1 Task - Implement specificity and CSS source order
      Apply CSS-style cascade behavior for the supported selector and
      declaration subset.

      [ ] 2.3.1.1 Subtask - Compute selector specificity for supported id, class, pseudo-class, and kind selectors.
      [ ] 2.3.1.2 Subtask - Resolve conflicts by specificity and source order within the CSS-derived style source.
      [ ] 2.3.1.3 Subtask - Decide how `!important` is represented, ignored, or diagnosed in the canonical style model.
      [ ] 2.3.1.4 Subtask - Preserve deterministic conflict provenance for inspection output.

    [ ] 2.3.2 Task - Merge CSS-derived results with canonical style sources
      Integrate CSS-derived styles with themes, component styles, `style_refs`,
      local `style` values, and direct widget props.

      [ ] 2.3.2.1 Subtask - Implement precedence where theme defaults and referenced component styles are weaker than CSS-derived rules.
      [ ] 2.3.2.2 Subtask - Preserve explicit local style declarations as stronger than CSS-derived rules.
      [ ] 2.3.2.3 Subtask - Define how CSS-derived state-scoped rules merge with existing variant and state style declarations.
      [ ] 2.3.2.4 Subtask - Emit diagnostics or provenance for overwritten CSS-derived declarations when inspection needs to explain final style values.

  [ ] 2.4 Section - Phase 2 Integration Tests
    Validate selector matching, ignored-selector behavior, specificity,
    source-order resolution, and source precedence before declaration
    translation is expanded.

    [ ] 2.4.1 Task - Selector matching scenarios
      Verify supported selectors target the expected authored nodes and
      unsupported selectors are ignored deterministically.

      [ ] 2.4.1.1 Subtask - Verify `#id`, `.class`, kind, selector-list, and supported structural selectors match the expected authored nodes.
      [ ] 2.4.1.2 Subtask - Verify supported state pseudo-classes produce state-scoped match output.
      [ ] 2.4.1.3 Subtask - Verify unsupported pseudo-elements, browser-only selectors, and unsupported combinators are ignored with diagnostics.
      [ ] 2.4.1.4 Subtask - Verify no-match selector diagnostics are deterministic when enabled.

    [ ] 2.4.2 Task - Cascade and precedence scenarios
      Verify CSS-derived conflicts and canonical style-source conflicts resolve
      predictably.

      [ ] 2.4.2.1 Subtask - Verify specificity outranks source order for supported selectors.
      [ ] 2.4.2.2 Subtask - Verify later source order wins when specificity ties.
      [ ] 2.4.2.3 Subtask - Verify CSS-derived rules outrank theme defaults and component style references.
      [ ] 2.4.2.4 Subtask - Verify explicit local style declarations outrank CSS-derived rules.
