# Phase 5 - Examples, Documentation, Tooling, and Conformance

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `examples/catalog.tsv`
- `mix spec.plancheck`
- `mix spec.traceability.generate`
- `mix spec.compliance`
- `UnifiedUi.Tooling`
- `UnifiedIUR.Tooling`
- Runtime package inspect and validate tasks

## Relevant Assumptions / Defaults
- Examples are standalone focused apps under `examples/<widget_name>/`.
- Generated traceability markdown mirrors are regenerated from JSON rather than
  hand-edited.
- Conformance evidence remains separate from authored specs.
- All work in this phase is not done.

[ ] 5 Phase 5 - Examples, Documentation, Tooling, and Conformance
  Make the expanded widget-component catalog reviewable and maintainable
  through focused examples, developer and user guidance, tooling, validation,
  and conformance evidence.

  [ ] 5.1 Section - Focused Examples and Catalog Entries
    Add standalone examples that exercise the expanded widget families without
    reintroducing an aggregate demo application.

    [ ] 5.1.1 Task - Add focused widget-family examples
      Provide examples that are small enough to validate and review but broad
      enough to demonstrate realistic composition.

      [ ] 5.1.1.1 Subtask - Add a content and identity example covering rich heading, kicker, avatar, presence dot, and disclosure.
      [ ] 5.1.1.2 Subtask - Add a workflow and progress example covering stepper, segmented progress, stage list, and thin meter.
      [ ] 5.1.1.3 Subtask - Add a document-workflow example covering artifact row, event callout, redline, code block, slide-over panel, and chat composer.
      [ ] 5.1.1.4 Subtask - Add a list-repeat example that renders repeated row templates from list binding data.

    [ ] 5.1.2 Task - Update example catalog and runtime targets
      Make the new examples discoverable and runnable across relevant runtime
      targets.

      [ ] 5.1.2.1 Subtask - Add examples to `examples/catalog.tsv` with canonical package and runtime target metadata.
      [ ] 5.1.2.2 Subtask - Add runtime target coverage for LiveUi first and additional runtimes as Phase 4 support lands.
      [ ] 5.1.2.3 Subtask - Add example validation checks that verify examples stay self-contained.

  [ ] 5.2 Section - Developer and User Documentation
    Add guidance for authors, runtime implementers, and application users of
    the expanded catalog.

    [ ] 5.2.1 Task - Write authoring and behavior guides
      Explain the canonical mental model and the distinction between portable
      widgets and runtime-specific host behavior.

      [ ] 5.2.1.1 Subtask - Document each expanded widget family, its canonical props, children, states, and interaction meanings.
      [ ] 5.2.1.2 Subtask - Document runtime-owned form behavior and the relationship between canonical form shells and LiveUi Phoenix integration.
      [ ] 5.2.1.3 Subtask - Document list-repeat composition, row-scope bindings, and deterministic repeated child identity.

    [ ] 5.2.2 Task - Write runtime implementation guidance
      Help runtime maintainers implement parity without copying AshUi-specific
      assumptions.

      [ ] 5.2.2.1 Subtask - Document native widget expectations for LiveUi, ElmUi, DesktopUi, and TerminalUi.
      [ ] 5.2.2.2 Subtask - Document interaction translation requirements for each interactive widget family.
      [ ] 5.2.2.3 Subtask - Document TerminalUi degradation rules and minimum meaning-preservation requirements.

  [ ] 5.3 Section - Tooling, Inspection, and Validation
    Extend package tooling so maintainers can inspect, export, and validate the
    expanded catalog and repeat behavior.

    [ ] 5.3.1 Task - Extend UnifiedUi and UnifiedIUR inspection
      Make the expanded catalog visible in tooling output.

      [ ] 5.3.1.1 Subtask - Add inspect output for expanded widget props, children, interactions, accessibility metadata, and repeat metadata.
      [ ] 5.3.1.2 Subtask - Add export output that preserves canonical names and normalized defaults.
      [ ] 5.3.1.3 Subtask - Add validation output for alias use, malformed props, unsupported token types, and repeat errors.

    [ ] 5.3.2 Task - Extend runtime validation tools
      Give each runtime package focused checks for widget parity.

      [ ] 5.3.2.1 Subtask - Add LiveUi validation for native component and IUR renderer parity.
      [ ] 5.3.2.2 Subtask - Add ElmUi, DesktopUi, and TerminalUi validation against shared IUR fixtures.
      [ ] 5.3.2.3 Subtask - Add terminal degradation validation for rich and limited capability profiles.

  [ ] 5.4 Section - Conformance and Traceability
    Record package implementation evidence separately from the authored specs
    and keep plan coverage machine-readable.

    [ ] 5.4.1 Task - Update planning traceability manifests
      Connect the expanded widget-component requirements to implementation
      phases without hand-editing generated mirrors.

      [ ] 5.4.1.1 Subtask - Add plan coverage entries for UnifiedUi widget components and list-repeat authoring.
      [ ] 5.4.1.2 Subtask - Add plan coverage entries for UnifiedIUR representation, compiler lowering, and repeat hydration.
      [ ] 5.4.1.3 Subtask - Add plan coverage entries for runtime parity, examples, tooling, and docs.
      [ ] 5.4.1.4 Subtask - Regenerate traceability markdown mirrors through the owning Mix task.

    [ ] 5.4.2 Task - Update conformance evidence
      Record implementation proof in package-local conformance manifests after
      each package has real coverage.

      [ ] 5.4.2.1 Subtask - Add UnifiedUi and UnifiedIUR conformance entries for the expanded catalog and repeat behavior.
      [ ] 5.4.2.2 Subtask - Add LiveUi conformance entries for native component and renderer parity.
      [ ] 5.4.2.3 Subtask - Add ElmUi, DesktopUi, and TerminalUi conformance entries as runtime parity lands.

  [ ] 5.5 Section - Phase 5 Integration Tests
    Validate examples, docs, tooling, traceability, and conformance evidence as
    the final release-readiness pass for the expanded catalog.

    [ ] 5.5.1 Task - Example and documentation scenarios
      Verify focused examples and guides stay aligned with the implemented
      catalog.

      [ ] 5.5.1.1 Subtask - Run every focused example in its supported runtime target.
      [ ] 5.5.1.2 Subtask - Verify example catalog metadata matches actual example directories and package targets.
      [ ] 5.5.1.3 Subtask - Verify guides do not describe AshUi-specific names as canonical where portable names exist.

    [ ] 5.5.2 Task - Tooling and conformance scenarios
      Verify the expanded catalog is visible through repository tooling and
      conformance checks.

      [ ] 5.5.2.1 Subtask - Run package-local inspect, export, and validate commands for the expanded catalog fixtures.
      [ ] 5.5.2.2 Subtask - Run `mix spec.plancheck` and traceability generation for affected packages.
      [ ] 5.5.2.3 Subtask - Run `mix spec.compliance` for affected packages after conformance entries are added.
