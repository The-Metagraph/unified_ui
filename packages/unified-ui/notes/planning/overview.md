# Unified UI DSL - Implementation Plan

## Overview

This implementation plan describes the construction of **UnifiedUi**, a Spark-powered Domain-Specific Language for building multi-platform user interfaces in Elixir. The architecture provides a declarative DSL that compiles to platform-specific adapters for terminal, desktop, and web applications.

## Architecture Diagram

```mermaid
graph TD
    subgraph UnifiedUi["UnifiedUi (Core Library)"]
        DSL["Spark DSL<br/>(declarative UI definitions)"]
        IUR["Intermediate UI Representation<br/>(%Text{}, %Button{}, %VBox{})"]
        Xform["Transformers<br/>(Elm Architecture + Jido)"]

        DSL --> IUR
        Xform --> DSL

        subgraph Renderers["Adapters (in UnifiedUi)"]
            TermR["UnifiedUi.Adapters.Terminal"]
            DeskR["UnifiedUi.Adapters.Desktop"]
            WebR["UnifiedUi.Adapters.Web"]
        end

        IUR --> TermR
        IUR --> DeskR
        IUR --> WebR
    end

    subgraphUILibs["UI Libraries (consumed as dependencies)"]
        TermUi["TermUi<br/>(Terminal)"]
        DeskUi["DesktopUi<br/>(Desktop)"]
        WebUi["WebUi<br/>(Web)"]
    end

    TermR -->|"consumes"| TermUi
    DeskR -->|"consumes"| DeskUi
    WebR -->|"consumes"| WebUi
```

## Key Principles

1. **Adapters in UnifiedUi** - All platform adapters live in the UnifiedUi library
2. **UI libraries are dependencies** - TermUi, DesktopUi, WebUi are consumed, not extended
3. **Platform-agnostic DSL** - Widget definitions have no platform-specific code
4. **IUR is the boundary** - DSL produces IUR; adapters consume IUR
5. **Parallel development** - All three adapters developed together, not sequentially

## Target Frameworks

| Framework | Status | Description |
|-----------|--------|-------------|
| **TermUi** | Mature | Terminal UI with 20+ widgets, 60 FPS rendering |
| **DesktopUi** | Early Stage | Desktop applications (developed in parallel) |
| **WebUi** | Conceptual | Phoenix + Elm SPA architecture (developed in parallel) |

## Technology Stack

| Component | Technology |
|-----------|------------|
| **DSL Framework** | Spark |
| **State Management** | Jido.Agent.Server |
| **Communication** | JidoSignal |
| **Architecture** | Elm Architecture (init/update/view) |
| **Terminal** | TermUi (consumed) |
| **Desktop** | DesktopUi (consumed, developed in parallel) |
| **Web** | WebUi (consumed, developed in parallel) |

## Phase Summaries

| Phase | Title | Description |
|-------|-------|-------------|
| 1 | Foundation | Project structure, Spark DSL setup, IUR design |
| 2 | Core Widgets & Layouts | Basic widgets, layouts, signals, Elm Architecture |
| 3 | Adapter Implementations | All 3 adapters (Terminal, Desktop, Web) in parallel |
| 4 | Advanced Features & Styling | Full widget library, theming, advanced layouts |
| 5 | Testing, Docs & Tooling | Coverage, documentation, mix tasks, CI/CD |

## Widget Library (from TermUi)

| Category | Widgets |
|----------|---------|
| **Basic** | text, label, button, text_input |
| **Data Display** | gauge, sparkline, table, bar_chart, line_chart |
| **Navigation** | menu, context_menu, tabs, tree_view |
| **Input** | pick_list, form_builder, command_palette |
| **Feedback** | dialog, alert_dialog, toast |
| **Containers** | viewport, split_pane |
| **Drawing** | canvas |
| **Monitoring** | log_viewer, stream_widget, process_monitor, supervision_tree_viewer, cluster_dashboard |

## Success Criteria

1. **Declarative DSL**: Clean, declarative syntax for UI definitions
2. **Multi-Platform**: Single DSL compiles to terminal, desktop, and web
3. **Widget Parity**: All TermUi widgets available in the DSL
4. **Agent Integration**: Components as Jido.Agent.Server processes
5. **Developer Experience**: Autocomplete, inline docs, compile-time validation
6. **Performance**: 60 FPS terminal, responsive desktop/web
7. **Test Coverage**: 80%+ coverage across all modules
8. **Documentation**: Comprehensive guides and API docs
9. **Extensibility**: Framework can be extended with custom widgets
10. **Code Generation**: Elm Architecture and Jido integration auto-generated

## Phase Files

- [Phase 1: Foundation](./phase-01.md)
- [Phase 2: Core Widgets & Layouts](./phase-02.md)
- [Phase 3: Renderer Implementations](./phase-03.md)
- [Phase 4: Advanced Features & Styling](./phase-04.md)
- [Phase 5: Testing, Docs & Tooling](./phase-05.md)

## Related Documentation

- [Research: Spark DSL Architecture](../research/spark-dsl.md)
- [Research: Unified UI Architecture](../research/unified-ui.md)
- [TermUi Repository](https://github.com/pcharbon70/term_ui)
- [DesktopUi Repository](https://github.com/pcharbon70/desktop_ui)
- [JidoSignal Repository](https://github.com/agentjido/jido_signal)
- [Spark Framework](https://github.com/ash-project/spark)
