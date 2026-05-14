# Phase 2 - UnifiedIUR Representation, Compiler, and Hydration Alignment

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `UnifiedUi.Compiler`
- `UnifiedUi.Tooling`
- `UnifiedIUR.Element`
- `UnifiedIUR.Interaction`
- `UnifiedIUR.Binding`
- `UnifiedIUR.Validation`
- `UnifiedIUR.Fixtures`

## Relevant Assumptions / Defaults
- UnifiedIUR remains renderer-independent and does not carry LiveUi, Phoenix,
  AshUi, Elm, desktop, or terminal implementation details.
- Redline and code content are plain text plus semantic metadata, not trusted
  host markup.
- Repeat may be represented as metadata before hydration, but runtimes should
  receive deterministic concrete child nodes.
- All work in this phase is not done.

[ ] 2 Phase 2 - UnifiedIUR Representation, Compiler, and Hydration Alignment
  Add canonical IUR representation and compiler lowering for the expanded
  widget-component catalog and list-repeat composition behavior.

  [x] 2.1 Section - UnifiedIUR Node Models and Content Contracts
    Define the canonical element shapes, properties, children, and metadata for
    every widget family in the expanded catalog.

    [x] 2.1.1 Task - Implement content, identity, and disclosure IUR models
      Represent passive content and identity widgets without losing
      accessibility or state meaning.

      [x] 2.1.1.1 Subtask - Represent inline rich heading levels and inline `text` or `emphasis` segments.
      [x] 2.1.1.2 Subtask - Represent kicker item order, separator behavior, avatar identity fields, and presence state.
      [x] 2.1.1.3 Subtask - Represent disclosure summary, initial open state, and child body content.

    [x] 2.1.2 Task - Implement form, control, row, and composer IUR models
      Represent interactive controls while keeping interaction descriptors
      renderer-independent.

      [x] 2.1.2.1 Subtask - Represent segmented control options, active state, disabled state, and selection intent.
      [x] 2.1.2.2 Subtask - Represent runtime-owned form fields, submit/change intent, labels, validation metadata, and host adapter hints.
      [x] 2.1.2.3 Subtask - Represent list rows, artifact rows, and chat composer children, row identity, active state, and event metadata.

    [x] 2.1.3 Task - Implement progress, layer, callout, redline, and code IUR models
      Represent the operational and text-specialized widgets with enough
      structure for renderer parity.

      [x] 2.1.3.1 Subtask - Represent steppers, segmented progress, vertical stages, and thin meters with normalized values and labels.
      [x] 2.1.3.2 Subtask - Represent sticky headers, slide-over panels, and event callouts with child placement, state, size, and tone metadata.
      [x] 2.1.3.3 Subtask - Represent redline and pre-tokenized code segments as plain text plus semantic segment or token types.

  [x] 2.2 Section - Compiler Lowering and Canonical Interaction Descriptors
    Lower UnifiedUi authored declarations into deterministic IUR nodes and
    canonical interaction descriptors.

    [x] 2.2.1 Task - Lower widget declarations into IUR
      Connect the Phase 1 authoring surface to the new IUR models.

      [x] 2.2.1.1 Subtask - Lower every expanded widget family to a canonical element type or semantic variant.
      [x] 2.2.1.2 Subtask - Normalize defaults such as open state, active state, progress ranges, token lists, and child ordering during compile.
      [x] 2.2.1.3 Subtask - Preserve canonical names in exported IUR while retaining optional alias diagnostics for authoring inputs.

    [x] 2.2.2 Task - Lower interactions into renderer-independent descriptors
      Ensure interactive widgets carry canonical event meaning rather than
      runtime callback names.

      [x] 2.2.2.1 Subtask - Lower selection, row activation, step navigation, submit, change, send, disclosure, panel, and inline action intent.
      [x] 2.2.2.2 Subtask - Preserve payload mapping for selected values, row ids, field values, composer text, and step ids.
      [x] 2.2.2.3 Subtask - Verify descriptors can be transported as Jido.Signal-compatible event meaning.

  [x] 2.3 Section - List-Repeat Metadata and Hydration
    Implement the deterministic row expansion behavior that turns repeat
    composition into concrete child IUR nodes.

    [x] 2.3.1 Task - Represent repeat metadata before expansion
      Keep repeat composition inspectable in canonical IUR before row data is
      applied.

      [x] 2.3.1.1 Subtask - Represent repeat binding id, template identity, child slot, order, and row-scope binding metadata.
      [x] 2.3.1.2 Subtask - Validate repeat metadata against list binding descriptors.
      [x] 2.3.1.3 Subtask - Include repeat metadata in export and inspection output without requiring renderer participation.

    [x] 2.3.2 Task - Expand repeated children deterministically
      Hydrate repeated child templates into concrete IUR children before
      runtime rendering.

      [x] 2.3.2.1 Subtask - Define stable generated ids for row-expanded child instances.
      [x] 2.3.2.2 Subtask - Project row-scope binding values into child props or binding states.
      [x] 2.3.2.3 Subtask - Preserve child interactions and accessibility metadata for each repeated row.

  [ ] 2.4 Section - Safety, Accessibility, and Validation Fixtures
    Provide shared fixtures and validation rules that prove the IUR contract
    carries safety and accessibility meaning.

    [ ] 2.4.1 Task - Add text-safety and token validation
      Ensure IUR accepts semantic text metadata without treating user-provided
      text as trusted markup.

      [ ] 2.4.1.1 Subtask - Validate redline segment kinds and states.
      [ ] 2.4.1.2 Subtask - Validate supported code token types while allowing plain text fallback tokens.
      [ ] 2.4.1.3 Subtask - Add malicious-content fixtures for renderers to escape in host output.

    [ ] 2.4.2 Task - Add accessibility and state fixtures
      Give runtime packages a shared target for roles, labels, progress state,
      active state, and open state.

      [ ] 2.4.2.1 Subtask - Add fixtures for headings, labels, button pressed state, progress values, disclosure state, and panel labels.
      [ ] 2.4.2.2 Subtask - Add fixture summaries that runtimes can use in parity tests.
      [ ] 2.4.2.3 Subtask - Add validation that required accessible names are present where the canonical contract requires them.

  [ ] 2.5 Section - Phase 2 Integration Tests
    Validate compiler lowering, IUR representation, repeat expansion, and
    shared fixtures end to end.

    [ ] 2.5.1 Task - Compiler and IUR snapshot scenarios
      Verify the expanded authored catalog compiles into deterministic IUR.

      [ ] 2.5.1.1 Subtask - Snapshot representative IUR for every expanded widget family.
      [ ] 2.5.1.2 Subtask - Verify interaction descriptors are runtime-independent and preserve expected payload mappings.
      [ ] 2.5.1.3 Subtask - Verify exported IUR contains canonical names and normalized defaults.

    [ ] 2.5.2 Task - Repeat hydration scenarios
      Verify list-repeat metadata and row expansion preserve identity and row
      data.

      [ ] 2.5.2.1 Subtask - Verify repeat metadata appears before hydration.
      [ ] 2.5.2.2 Subtask - Verify hydrated children have stable ids, row values, and preserved interactions.
      [ ] 2.5.2.3 Subtask - Verify empty lists produce deterministic empty child output without renderer errors.
