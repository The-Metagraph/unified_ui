# Unified Examples Shared

`examples/shared` is the common support library for the standalone example-app
suite.

It owns:

- the shared dependency wiring to the local `unified_ui`, `unified_iur`, and
  `live_ui` packages
- the common DSL template used by all standalone example apps
- the shared default theme and default style profile for the suite
- helper functions for compiling authored examples and mounting them through the
  canonical `live_ui` runtime path

Standalone widget apps under `examples/<widget_name>/` should depend on this
package through a local path dependency.
