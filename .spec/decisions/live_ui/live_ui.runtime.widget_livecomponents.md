---
id: live_ui.runtime.widget_livecomponents
status: accepted
date: 2026-04-02
affects:
  - live_ui.package
  - live_ui.runtime
  - live_ui.native_widgets
  - live_ui.iur_renderer
  - live_ui.structure
---

# Widget LiveComponents for LiveUi

## Context

`live_ui` has consistently been described as a server-authoritative Phoenix
LiveView runtime library, but the current repository language does not make one
important architectural intent explicit: native widgets are supposed to be real
Phoenix LiveComponent-style runtime units that can be mounted in screens, not
just lightweight function-component facades or ad hoc HTML helpers.

That ambiguity creates drift in how maintainers interpret the package:

- one reading treats widgets as mostly stateless render helpers under a single
  shared screen host
- the original intent treats each widget as a mountable component boundary with
  its own lifecycle surface inside the shared server-authoritative runtime

The package still needs one shared server-authoritative runtime for screens,
canonical rendering, and signal handling. The question is what the runtime is
made of. This decision makes the intended answer explicit.

## Decision

`live_ui` shall treat native widgets as LiveComponent-backed runtime units that
are composed inside screens and inside canonical renderer output.

1. **Widget Component Boundary** - Every native `live_ui` widget surface shall
   have a Phoenix LiveComponent boundary as its primary runtime identity.
2. **Screen Composition Model** - Screens shall compose widget component
   instances inside the shared screen runtime rather than bypassing widget
   boundaries with direct HTML generation.
3. **Canonical Renderer Target** - Canonical `UnifiedIUR` rendering shall map
   into the same widget component boundaries used by direct native `live_ui`
   usage.
4. **Bounded Widget State** - Widget components may own bounded local UI
   lifecycle and ephemeral state, but authoritative workflow meaning and
   package-boundary semantics remain server-authoritative.
5. **Thin Ergonomic Wrappers** - If the package keeps function-component helper
   APIs for ergonomics, those wrappers shall delegate to the same widget
   component contract instead of becoming an alternate widget runtime model.
6. **Layout Primitives Remain Separate** - Pure layout primitives such as row,
   column, and grid remain structural composition helpers unless they need their
   own widget lifecycle or event boundary.

## Consequences

- The package contract now matches the original intended mental model: screens
  host a runtime made of widget components.
- Native usage and canonical rendering converge on the same widget boundaries,
  improving continuity and testability.
- Widgets can own bounded local lifecycle behavior without moving authority out
  of the server-led runtime.
- Maintainers must keep widget module boundaries, assigns contracts, and
  lifecycle semantics explicit instead of relying on anonymous HEEx fragments.
- The package may still use function-component convenience APIs, but they are
  subordinate to the widget LiveComponent architecture rather than replacing it.
