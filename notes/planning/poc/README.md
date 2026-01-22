# DesktopUI Proof-of-Concept Implementation Plan

This directory contains the detailed implementation plan for building a minimal but functional DesktopUI proof-of-concept. The plan follows the "Skeletal Vertical Slice" approach: validate architecture in pure Elixir first, then add graphics, then complete with layout.

## Phase Overview

### Phase 1: Architecture Validation
**File:** `phase-1-architecture-validation.md`

Builds the core Elm Architecture system in pure Elixir with a mock renderer. This proves the architectural concepts before introducing C/NIF complexity.

**Sections:**
- 1.1 Elm Behaviour Definition
- 1.2 Widget Construction DSL
- 1.3 DesktopUI.Runtime GenServer
- 1.4 Event Processing Loop
- 1.5 Mock Renderer
- 1.6 Runtime-Renderer Integration
- 1.7 Example Counter Component
- 1.8 Integration Tests

**Outcome:** A working Counter component with full Elm Architecture lifecycle, rendering to a mock renderer for verification.

---

### Phase 2: The Graphics Bridge
**File:** `phase-2-graphics-bridge.md`

Builds the SDL2 NIF layer and Graphics API, enabling real window creation and rendering.

**Sections:**
- 2.1 C NIF Foundation
- 2.2 SDL2 Initialization and Window Management
- 2.3 Renderer and Drawing Primitives
- 2.4 Event Polling and Translation
- 2.5 DesktopUI.Graphics API Wrapper
- 2.6 SDL2 Renderer
- 2.7 Runtime Integration with SDL2
- 2.8 Integration Tests

**Outcome:** Real windows open, display colored rectangles for widgets, respond to mouse clicks.

---

### Phase 3: First Real Widget
**File:** `phase-3-first-real-widget.md`

Adds a layout engine and completes the proof-of-concept with fully functional widgets.

**Sections:**
- 3.1 Layout Engine Foundation
- 3.2 VBox Container Layout
- 3.3 HBox Container Layout
- 3.4 Widget Size Hints
- 3.5 Renderer with Layout
- 3.6 Hit Testing with Layout
- 3.7 Runtime Layout Integration
- 3.8 Enhanced Counter Demo
- 3.9 Integration Tests

**Outcome:** A complete, working desktop UI with clickable buttons, proper layout, and visual feedback.

---

## Summary Statistics

| Phase | Sections | Tasks | Integration Tests |
|-------|----------|-------|-------------------|
| 1 | 8 | 47 | 18 |
| 2 | 8 | 54 | 38 |
| 3 | 9 | 57 | 47 |
| **Total** | **25** | **158** | **103** |

---

## Dependencies

```
Phase 1 (Pure Elixir)
    ↓
Phase 2 (C/NIFs + SDL2)
    ↓
Phase 3 (Layout + Complete Widget)
```

## Success Criteria

After completing all three phases:

1. **Functional Demo**: Counter component displays in a real window
2. **Interactive**: Buttons respond to clicks and update the display
3. **Proper Layout**: Widgets arrange with spacing, padding, and alignment
4. **Clean Architecture**: Clear separation between Elm behaviour, Runtime, Renderer, and Graphics
5. **Extensible**: Foundation ready for text rendering, advanced widgets, and Jido integration

## Next Steps After POC

- Text rendering (SDL2_ttf integration)
- More widget types (TextInput, Slider, Checkbox)
- Styling and theming system
- Jido integration for agent-based components
- Advanced layouts (grid, flexbox)
- Accessibility support
