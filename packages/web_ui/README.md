# web_ui

Phoenix + Elm runtime library for the unified ecosystem.

## Overview

`web_ui` provides a split runtime that combines Phoenix's server-authoritative
rendering with Elm's type-safe client-side interactivity.

## Architecture

The package is organized into six main areas:

* **Widgets** - Native widget modules for direct use
* **Server Runtime** - Phoenix server-side runtime entrypoints
* **Frontend Runtime** - Elm client-side runtime modules
* **Renderer** - Canonical IUR rendering through the Phoenix + Elm pipeline
* **Transport** - Signal transport and browser bridge
* **Tooling** - Development and maintenance helpers

## Usage

```elixir
# In your mix.exs
defp deps do
  [
    {:web_ui, "~> 0.1.0"}
  ]
end

# In your application
use WebUi

# Use native widgets
import WebUi.Widgets
```

## Development

### Installing Dependencies

```bash
mix deps.get
cd assets && npm install
```

### Building Elm Assets

```bash
mix assets.build
```

### Watching Assets During Development

```bash
mix assets.watch
```

## License

Apache-2.0
