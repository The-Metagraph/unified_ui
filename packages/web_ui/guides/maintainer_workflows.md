# Maintainer Workflows

The scaffold phase establishes the package layout, namespace boundaries, and
minimal tests needed to grow `web_ui` safely.

Current workflow:

```bash
mix test
```

Later phases will add package-specific inspection, preview, export, and
validation commands once the runtime, renderer, and transport surfaces are in
place.
