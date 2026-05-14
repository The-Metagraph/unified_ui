# UnifiedUi Compiler

This subject defines how `unified_ui` compiles authored DSL declarations into
canonical `unified_iur` output.

## Related General Specs

- [Ecosystem Architecture](../architecture.spec.md)
- [DSL and IUR Symbiosis](../dsl_iur_symbiosis.spec.md)
- [Platform Runtimes](../platform_runtimes.spec.md)
- [UnifiedUi DSL](./dsl.spec.md)
- [UnifiedUi Widgets](./widgets.spec.md)

```spec-meta
id: unified_ui.compiler
kind: subsystem
status: active
summary: Target compilation contract for translating authored `unified_ui` declarations into canonical `unified_iur`.
surface:
  - packages/unified-ui
  - .spec/specs/unified-ui/compiler.spec.md
decisions:
  - repo.ecosystem.contract_model
  - repo.ecosystem.canonical_navigation_boundary
```

## Requirements

```spec-requirements
- id: unified_ui.compiler.canonical_iur_output
  statement: The package compiler shall emit canonical `unified_iur` output as the primary compiled result for authored UI modules and authored UI fragments.
  priority: must
  stability: stable

- id: unified_ui.compiler.deterministic_results
  statement: Equivalent authored input shall compile into deterministic canonical IUR so that package behavior is diff-friendly, reviewable, and stable across runtime-library consumers.
  priority: must
  stability: stable

- id: unified_ui.compiler.style_theme_layer_resolution
  statement: Compilation shall resolve style defaults, theme tokens, layer ordering, and structural defaults into canonical IUR data rather than leaving those concerns as renderer-specific interpretation gaps.
  priority: must
  stability: stable

- id: unified_ui.compiler.runtime_independent_bindings
  statement: Dynamic data access and interaction binding information shall compile into runtime-independent canonical descriptors rather than renderer-specific callback closures or renderer-local payload logic.
  priority: must
  stability: stable

- id: unified_ui.compiler.introspection_surface
  statement: The package shall expose compiler and introspection helpers that let developers inspect compiled canonical widgets, layouts, layers, style data, and signal descriptors without running a renderer.
  priority: must
  stability: stable

- id: unified_ui.compiler.no_renderer_output_modes
  statement: The package shall not define platform-specific compile targets for `elm_ui`, `live_ui`, or `desktop_ui`; renderer libraries consume canonical IUR instead.
  priority: must
  stability: stable

- id: unified_ui.compiler.navigation_transition_lowering
  statement: The compiler shall lower authored screen-transition navigation intent into canonical `unified_iur` interaction descriptors that preserve transition action, symbolic screen target, modal target, and params without embedding host-router semantics.
  priority: must
  stability: stable
```

## Scenarios

```spec-scenarios
- id: unified_ui.compiler.compile_screen_to_iur
  covers:
    - unified_ui.compiler.canonical_iur_output
    - unified_ui.compiler.deterministic_results
    - unified_ui.compiler.style_theme_layer_resolution
    - unified_ui.compiler.runtime_independent_bindings
    - unified_ui.compiler.introspection_surface
    - unified_ui.compiler.no_renderer_output_modes
    - unified_ui.compiler.navigation_transition_lowering
  given:
    - A developer authors a screen module with widgets, layout, style, theme, and interaction declarations
  when:
    - The package compiler runs
  then:
    - The result is canonical `unified_iur` plus canonical signal descriptors, not a renderer-specific widget tree

- id: unified_ui.compiler.inspect_compiled_artifact
  covers:
    - unified_ui.compiler.canonical_iur_output
    - unified_ui.compiler.deterministic_results
    - unified_ui.compiler.style_theme_layer_resolution
    - unified_ui.compiler.runtime_independent_bindings
    - unified_ui.compiler.introspection_surface
    - unified_ui.compiler.no_renderer_output_modes
    - unified_ui.compiler.navigation_transition_lowering
  given:
    - A developer needs to understand what canonical output a DSL module produces
  when:
    - The developer uses compiler or introspection helpers
  then:
    - The package can report the compiled canonical structure without requiring a runtime library to render it
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/unified-ui/compiler.spec.md
  covers:
    - unified_ui.compiler.canonical_iur_output
    - unified_ui.compiler.deterministic_results
    - unified_ui.compiler.style_theme_layer_resolution
    - unified_ui.compiler.runtime_independent_bindings
    - unified_ui.compiler.introspection_surface
    - unified_ui.compiler.no_renderer_output_modes
    - unified_ui.compiler.navigation_transition_lowering
    - unified_ui.compiler.compile_screen_to_iur
    - unified_ui.compiler.inspect_compiled_artifact
```
