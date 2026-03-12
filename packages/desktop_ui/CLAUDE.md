# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

DesktopUI is an **Elixir-based cross-platform desktop UI framework** in early research/development phase. It aims to create a native desktop application framework using:

- **Elm Architecture** (TEA) for predictable state management
- **Direct desktop graphics** via SDL2 (through NIFs), not wrapping existing GUI toolkits
- **Component-based API** inspired by TermUI (https://github.com/pcharbon70/term_ui)
- **Jido integration** (planned) for agent-based component management and signal-driven communication

## Development Commands

```bash
# Run tests
mix test

# Run tests with file filter (single test file)
mix test test/desktop_ui_test.exs

# Run tests with line filter (specific test)
mix test test/desktop_ui_test.exs:7

# Format code
mix format

# Format checking (fails if not formatted)
mix format --check-formatted

# Start IEx with project loaded
iex -S mix

# Check for compiler warnings (treat warnings as errors)
mix compile --warnings-as-errors
```

## Architecture Overview

The framework follows a **layered architecture** with clear separation of concerns:

```
User Application (Components)
    ↓ implements
DesktopUI.Elm Behaviour (init/1, update/2, view/1)
    ↓ managed by
DesktopUI.Runtime (GenServer) - Event loop, state orchestration
    ↓ uses
Rendering Engine + Layout Engine
    ↓ calls
DesktopUI.Graphics API (Elixir)
    ↓ via NIFs
SDL2 (C library)
```

### Core Architectural Components

**DesktopUI.Elm Behaviour** (planned)
- Defines the contract for UI components
- Callbacks: `init/1`, `update/2`, `view/1`
- Components return `{state, commands}` tuples

**DesktopUI.Runtime** (planned)
- Central GenServer managing application lifecycle
- Polls SDL2 events via NIFs and translates to semantic messages
- Dispatches events to component `update/2` functions
- Triggers re-renders when state changes
- Executes commands (side effects)

**Widget System** (planned)
- Declarative UI tree constructed from widget primitives
- Widget types: `Label`, `Button`, `Container` (vbox, hbox)
- Widgets are data structures, not renderers themselves

**DesktopUI.Graphics API** (planned)
- Elixir module wrapping SDL2 operations via NIFs
- Functions: window management, drawing primitives, text rendering, event polling
- Internal API used by Rendering Engine, not end users

### Jido Integration (Planned Future)

The architecture plans to integrate Jido libraries for enhanced capabilities:

- **Jido.Agent** - Components as autonomous agents
- **JidoSignal** - Pub/sub for decoupled inter-component communication
- **JidoAction** - Structured async side effect handling

This would shift from centralized Runtime orchestration to a distributed, signal-driven model.

## Project Status

**Current State**: Research/prototype phase
- Only basic Elixir scaffold exists (`lib/desktop_ui.ex`)
- Extensive architectural research documented in `notes/research/`
- No SDL2 NIFs implemented yet
- No runtime or rendering engine implemented yet

**Next Steps** (from research):
1. Implement SDL2 NIFs for graphics primitives
2. Implement DesktopUI.Graphics API
3. Implement DesktopUI.Runtime (GenServer)
4. Implement Elm behaviour and widget system

## Key Design Philosophies

1. **No wrapper toolkits** - Direct SDL2 access, not wrapping Qt/wxWidgets/webview
2. **Declarative UI** - `view/1` returns data structure, not commands
3. **Elm Architecture** - Unidirectional data flow, pure state updates
4. **BEAM-native** - Leverage concurrency, fault tolerance, hot code reloading
5. **Performance target** - 60 FPS with differential updates (like TermUI)

## File Structure Notes

- `lib/` - Framework implementation (currently minimal)
- `test/` - ExUnit tests
- `notes/research/1.01-foundation/` - Architectural research documents
  - `1.01.2-architecture.md` - Full system architecture design
  - `1.01.4-component-architecture.md` - Jido integration design
