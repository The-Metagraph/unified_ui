# Canonical Rendering and Transport

`WebUi` will consume canonical `UnifiedIUR` and translate canonical boundary
events through the same native web runtime used for direct-native screens.

During the scaffold phase this means:

- renderer and transport modules exist as package boundaries
- they remain separate from native widget ownership
- they do not redefine canonical IUR or authored DSL concerns

Later phases will implement native widget reuse for canonical rendering and
`Jido.Signal` translation at package boundaries.
