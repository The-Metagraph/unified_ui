# Phase 1 - CSS Authoring Surface and Parser Boundary

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces

- `UnifiedUi.Dsl`
- `UnifiedUi.Dsl.Node`
- `UnifiedUi.Dsl.Sections.Themes`
- `UnifiedUi.Style`
- `UnifiedUi.Compiler`
- `UnifiedUi.Tooling`
- CSS parser adapter module to be introduced under `UnifiedUi`

## Relevant Assumptions / Defaults

- The authored API may use a `css` stylesheet block or an equivalent named DSL
  section, but the block contents remain CSS stylesheet text.
- Multiple authored CSS blocks are allowed and preserve deterministic source
  order.
- Class selectors use portable authored class metadata; a class name is not
  treated as proof that a runtime stylesheet already exists.
- Parser selection is an implementation detail behind a small internal adapter.
- Parser recovery diagnostics are surfaced without treating every recoverable
  CSS syntax issue as a fatal DSL error.

[ ] 1 Phase 1 - CSS Authoring Surface and Parser Boundary
  Define the authored CSS stylesheet block, parser adapter, source-order model,
  and recoverable diagnostics needed before selector matching or style lowering
  can be implemented.

  [x] 1.1 Section - Authored CSS Block Shape
    Establish the DSL syntax and source metadata for authored CSS stylesheet
    blocks while keeping existing style and theme authoring intact.

    [x] 1.1.1 Task - Define CSS block placement and identity
      Specify where CSS blocks may appear and how they are named, ordered, and
      associated with authored modules or fragments.

      [x] 1.1.1.1 Subtask - Define whether the primary authoring surface is a top-level `css` block, a theming-section entry, or both.
      [x] 1.1.1.2 Subtask - Define source names, optional block ids, and deterministic ordering for multiple CSS blocks in one authored module.
      [x] 1.1.1.3 Subtask - Define how CSS blocks compose with existing theme definitions, `style_refs`, local `style` values, and widget props.
      [x] 1.1.1.4 Subtask - Reject CSS block placement that would make style meaning depend on renderer-specific module loading.

    [x] 1.1.2 Task - Define portable class and identity authoring
      Clarify how CSS selectors can target authored nodes without treating
      browser class attributes as the only canonical selector mechanism.

      [x] 1.1.2.1 Subtask - Define the canonical source of selector identity for `#id` rules using authored stable node identity.
      [x] 1.1.2.2 Subtask - Define class metadata normalization for `.class` selectors, including whitespace handling and deterministic class ordering.
      [x] 1.1.2.3 Subtask - Document that authored `class` values are portable selector metadata and optional runtime hooks, not automatic stylesheet loading.
      [x] 1.1.2.4 Subtask - Preserve current explicit style and theme props while adding CSS block authoring as an additional style source.

  [x] 1.2 Section - CSS Parser Adapter and Syntax Recovery
    Introduce a parser boundary that accepts real CSS stylesheet text and
    normalizes parser output into an internal shape used by later phases.

    [x] 1.2.1 Task - Select and isolate the CSS parser strategy
      Evaluate parser options and hide the selected implementation behind a
      small adapter so the DSL and compiler do not depend on parser-specific
      data structures.

      [x] 1.2.1.1 Subtask - Evaluate available Elixir, Erlang, NIF, or port-based CSS parser options against CSS Syntax stylesheet parsing and recovery needs.
      [x] 1.2.1.2 Subtask - Define the parser adapter input and output contract, including source spans, rule order, declaration order, and recoverable error reporting.
      [x] 1.2.1.3 Subtask - Add a fallback parser-selection decision record if no dependency satisfies the required CSS Syntax-compatible behavior.

    [x] 1.2.2 Task - Normalize parsed stylesheet rules
      Convert parser output into a deterministic internal representation that
      later phases can match, cascade, translate, and inspect.

      [x] 1.2.2.1 Subtask - Normalize style rules, selector lists, declaration names, declaration values, importance flags, source spans, and source order.
      [x] 1.2.2.2 Subtask - Preserve recoverable parser diagnostics with enough source context for author-facing messages.
      [x] 1.2.2.3 Subtask - Normalize unsupported at-rules into ignored diagnostic entries rather than dropping them silently.
      [x] 1.2.2.4 Subtask - Ensure comments and insignificant whitespace do not affect deterministic parser output.

  [x] 1.3 Section - Authoring Diagnostics and Inspection
    Make CSS block behavior visible to authors before any canonical style
    lowering changes runtime output.

    [x] 1.3.1 Task - Add CSS authoring diagnostics
      Define the diagnostic categories and severity rules for parse recovery
      and ignored CSS constructs.

      [x] 1.3.1.1 Subtask - Add diagnostics for parser recovery, malformed declaration values, ignored at-rules, ignored selectors, and ignored properties.
      [x] 1.3.1.2 Subtask - Distinguish fatal parser failures from recoverable CSS issues that can continue through style lowering.
      [x] 1.3.1.3 Subtask - Include source block id, selector text, declaration name, and source span where available.
      [x] 1.3.1.4 Subtask - Keep diagnostic ordering deterministic across equivalent authored modules.

    [x] 1.3.2 Task - Expose parsed CSS inspection output
      Let developers inspect CSS blocks and parser diagnostics without running
      a renderer or relying on runtime stylesheet output.

      [x] 1.3.2.1 Subtask - Extend inspection output to list authored CSS blocks, normalized rule count, declaration count, ignored construct count, and recoverable parse diagnostics.
      [x] 1.3.2.2 Subtask - Extend export output with deterministic CSS block metadata suitable for review diffs.
      [x] 1.3.2.3 Subtask - Add examples that show valid CSS, recoverable parser issues, and ignored unsupported at-rules.

  [ ] 1.4 Section - Phase 1 Integration Tests
    Validate authored CSS block parsing, ordering, diagnostics, and inspection
    before selector matching and canonical style lowering are introduced.

    [ ] 1.4.1 Task - CSS block authoring scenarios
      Verify the DSL accepts valid CSS stylesheet blocks and preserves
      deterministic source metadata.

      [ ] 1.4.1.1 Subtask - Verify a module with one CSS block parses valid selector and declaration syntax successfully.
      [ ] 1.4.1.2 Subtask - Verify a module with multiple CSS blocks preserves deterministic block and rule source order.
      [ ] 1.4.1.3 Subtask - Verify CSS block authoring composes with existing style, theme, and widget declarations without changing their public syntax.
      [ ] 1.4.1.4 Subtask - Verify malformed block placement fails with an actionable DSL diagnostic.

    [ ] 1.4.2 Task - Parser recovery and inspection scenarios
      Verify CSS parser recovery and inspection output are deterministic and
      useful before lowering is implemented.

      [ ] 1.4.2.1 Subtask - Verify recoverable CSS syntax errors produce diagnostics while preserving later valid rules.
      [ ] 1.4.2.2 Subtask - Verify unsupported at-rules are represented as ignored diagnostics with source context.
      [ ] 1.4.2.3 Subtask - Verify comments and whitespace do not change normalized parser output.
      [ ] 1.4.2.4 Subtask - Verify inspection and export output list CSS block metadata and diagnostics in deterministic order.
