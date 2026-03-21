# Runtime Backbone

The `web_ui` runtime is split across:

- `WebUi.ServerRuntime` for authoritative server-side screen state
- `WebUi.FrontendRuntime` for bounded browser-facing state
- `WebUi.Runtime` for the shared native and canonical entrypoints

Both native widget screens and canonical `UnifiedIUR` screens flow through the
same runtime boundary.
