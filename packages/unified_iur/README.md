# UnifiedIUR

`UnifiedIUR` is the canonical intermediate representation package for the
unified ecosystem.

It is intentionally a pure Elixir library. The package owns renderer-independent
data structures and package-facing reference surfaces for:

- core canonical element concerns
- canonical construct families
- interaction descriptors
- normalization helpers
- interoperability helpers
- reference and inspection helpers
- package-local tooling helpers

This package does not own runtime rendering, transport servers, or long-lived
runtime processes.
