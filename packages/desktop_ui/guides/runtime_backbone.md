# Runtime Backbone

`desktop_ui` is designed around one shared desktop runtime model.

Phase 1 establishes the package seams that later phases will fill in:

- `DesktopUi.Runtime` for shared runtime state and boot behavior
- `DesktopUi.Platform` for bounded Windows, macOS, and Linux integration
- `DesktopUi.Renderer` for canonical `UnifiedIUR` entry
- `DesktopUi.Transport` for future canonical boundary translation
- `DesktopUi.Artifacts` for platform-specific build and packaging workflows

SDL2 is the intended shared rendering and input foundation, but the package
keeps the binding policy explicit so the runtime seam can stabilize before
full platform packaging is introduced.
