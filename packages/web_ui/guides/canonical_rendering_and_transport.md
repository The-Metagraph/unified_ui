# Canonical Rendering And Transport

`WebUi.Renderer.render/2` accepts canonical `UnifiedIUR.Element` values and
realizes them through `WebUi.Widget` structures.

`WebUi.Transport` translates native web-oriented interactions into local
runtime envelopes or `Jido.Signal` boundary events.
