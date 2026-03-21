# WebUi

`web_ui` is the Phoenix-and-Elm runtime library scaffold for the unified
ecosystem.

It establishes:

- a directly usable native widget surface
- a Phoenix-side authoritative runtime model
- an Elm-facing frontend bridge and asset layout
- a canonical `UnifiedIUR` renderer entrypoint
- package-local transport and inspection helpers

This package is intentionally early-stage. The current code focuses on the
Phase 1 runtime backbone and package structure needed for later widget and
transport expansion.
