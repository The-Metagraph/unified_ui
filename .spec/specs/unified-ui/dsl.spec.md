# UnifiedUi DSL

This subject defines the authored DSL surface that `unified_ui` must provide for
declaring canonical UI intent.

## Related General Specs

- [Ecosystem Architecture](../architecture.spec.md)
- [DSL and IUR Symbiosis](../dsl_iur_symbiosis.spec.md)
- [UnifiedUi Package](./package.spec.md)
- [UnifiedUi Widgets](./widgets.spec.md)
- [UnifiedUi Signals](./signals.spec.md)

```spec-meta
id: unified_ui.dsl
kind: subsystem
status: active
summary: Target authored DSL contract for `unified_ui`, including widgets, layouts, layering, styling, theming, and interaction binding declarations.
surface:
  - packages/unified-ui
  - .spec/specs/unified-ui/dsl.spec.md
decisions:
  - repo.ecosystem.contract_model
  - repo.ecosystem.css_style_authoring
```

## Requirements

```spec-requirements
- id: unified_ui.dsl.spark_style_authoring_surface
  statement: The package shall provide an Elixir-authored declarative DSL surface suitable for sectioned entity declaration, compile-time validation, and macro-based UI module authoring.
  priority: must
  stability: stable

- id: unified_ui.dsl.widgets_layouts_layers
  statement: The DSL shall author canonical widgets, layouts, layering relationships, and container hierarchy directly within the package rather than delegating those definitions to runtime libraries.
  priority: must
  stability: stable

- id: unified_ui.dsl.styling_and_theming
  statement: The DSL shall author canonical styling attributes, style variants, and theme-level configuration as first-class declarations that participate in canonical compilation.
  priority: must
  stability: stable

- id: unified_ui.dsl.interaction_binding
  statement: The DSL shall author interaction bindings in terms of canonical event meaning, payload mapping, and target intent rather than renderer-specific callback names or renderer-local event payload shapes.
  priority: must
  stability: stable

- id: unified_ui.dsl.compile_time_validation
  statement: DSL compilation shall validate entity identity, parent-child placement rules, layer relationships, style attribute compatibility, theme references, and signal binding structure before authored modules are accepted.
  priority: must
  stability: stable

- id: unified_ui.dsl.authoring_extensibility
  statement: The DSL shall be extensible in a way that allows new canonical widgets, layouts, style attributes, and interaction descriptors to be added without changing the authored module model for existing users.
  priority: must
  stability: stable

- id: unified_ui.dsl.css_stylesheet_blocks
  statement: The DSL shall support authored CSS stylesheet blocks as a styling and theming authoring surface that accepts CSS stylesheet text for canonical style lowering.
  priority: must
  stability: stable

- id: unified_ui.dsl.css_authoring_diagnostics
  statement: DSL validation shall report CSS parse recovery, ignored unsupported selectors, ignored unsupported at-rules, and ignored unsupported declarations without requiring recoverable CSS authoring issues to invalidate the entire authored module.
  priority: must
  stability: stable
```

## Scenarios

```spec-scenarios
- id: unified_ui.dsl.author_single_screen
  covers:
    - unified_ui.dsl.spark_style_authoring_surface
    - unified_ui.dsl.widgets_layouts_layers
    - unified_ui.dsl.styling_and_theming
    - unified_ui.dsl.interaction_binding
    - unified_ui.dsl.compile_time_validation
    - unified_ui.dsl.authoring_extensibility
  given:
    - A developer wants to define one canonical screen with widgets, layout, styles, and user interactions
  when:
    - The developer authors a `UnifiedUi` DSL module
  then:
    - The module can declare those concerns in one authored surface without embedding runtime-library widget calls

- id: unified_ui.dsl.reject_renderer_specific_callbacks
  covers:
    - unified_ui.dsl.spark_style_authoring_surface
    - unified_ui.dsl.widgets_layouts_layers
    - unified_ui.dsl.styling_and_theming
    - unified_ui.dsl.interaction_binding
    - unified_ui.dsl.compile_time_validation
    - unified_ui.dsl.authoring_extensibility
  given:
    - An authored UI module uses a renderer-specific callback name or renderer-local event payload shape
  when:
    - The module is compiled by the package DSL
  then:
    - The authoring surface rejects that declaration because canonical interaction meaning must stay renderer-independent

- id: unified_ui.dsl.author_css_stylesheet_block
  covers:
    - unified_ui.dsl.spark_style_authoring_surface
    - unified_ui.dsl.styling_and_theming
    - unified_ui.dsl.compile_time_validation
    - unified_ui.dsl.authoring_extensibility
    - unified_ui.dsl.css_stylesheet_blocks
    - unified_ui.dsl.css_authoring_diagnostics
  given:
    - A developer wants to style authored widgets with familiar CSS selector and declaration syntax
  when:
    - The developer authors a CSS stylesheet block inside a `UnifiedUi` DSL module
  then:
    - The DSL accepts the stylesheet as authoring input and reports any recoverable unsupported CSS concepts as diagnostics for canonical style lowering
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/unified-ui/dsl.spec.md
  covers:
    - unified_ui.dsl.spark_style_authoring_surface
    - unified_ui.dsl.widgets_layouts_layers
    - unified_ui.dsl.styling_and_theming
    - unified_ui.dsl.interaction_binding
    - unified_ui.dsl.compile_time_validation
    - unified_ui.dsl.authoring_extensibility
    - unified_ui.dsl.css_stylesheet_blocks
    - unified_ui.dsl.css_authoring_diagnostics
    - unified_ui.dsl.author_single_screen
    - unified_ui.dsl.reject_renderer_specific_callbacks
    - unified_ui.dsl.author_css_stylesheet_block
```
