# UnifiedUi

`UnifiedUi` is the authored DSL and compiler package for the unified ecosystem.

The package is intentionally a pure Elixir library. It owns:

- the authored DSL surface
- canonical signal and binding authoring
- compilation into canonical `UnifiedIUR`
- package reference, inspection, and tooling helpers

The package does not own renderer runtimes, renderer-specific widget trees, or
required long-lived runtime services.
