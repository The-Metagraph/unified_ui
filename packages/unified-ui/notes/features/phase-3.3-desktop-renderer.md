# Phase 3.3: Desktop Renderer - Core

**Date Started:** 2025-02-07
**Date Completed:** 2025-02-07
**Branch:** `feature/phase-3.3-desktop-renderer`
**Status:** ✅ Complete

---

## Overview

This feature implements the Desktop renderer that converts IUR (Intermediate UI Representation) to DesktopUi-style widget maps. This is the second concrete renderer implementation, following the Terminal renderer pattern from Phase 3.2.

**Planning Reference:** `notes/planning/phase-03.md` (Section 3.3)

---

## Problem Statement

Phase 3.2 implemented the Terminal renderer, but we need a Desktop renderer to enable native desktop applications. The Desktop renderer follows the same architecture but targets the DesktopUi library.

---

## Solution Overview

Implement `UnifiedUi.Renderers.Desktop` module that:
1. Implements the `UnifiedUi.Renderer` behaviour
2. Converts IUR widgets to DesktopUi-compatible widget maps
3. Converts IUR layouts to DesktopUi containers
4. Maps IUR styles to DesktopUi styling properties
5. Uses pixel-based spacing (vs character cells for terminal)

### Key Design Decisions

| Decision | Rationale |
|----------|-----------|
| Direct widget map construction | DesktopUi not available as dependency yet |
| Pixel-based spacing | Desktop uses pixels, not character cells |
| Style mapping to props | DesktopUi uses widget props for styling |
| Follows Terminal renderer pattern | Consistent architecture across renderers |
| Defer Desktop.Server to Phase 3.6 | Event handling needs full renderer foundation first |

---

## DesktopUi Library Structure

Based on exploration of `/home/ducky/code/elixir-ui/desktop_ui/`:

### Widget Types
- Label widgets - Text labels
- Button widgets - Interactive buttons with click handlers
- Container widgets - Layout containers (vbox/hbox)

### Widget Properties
- Size constraints: `:width`, `:height`, `:min_width`, `:min_height`, `:max_width`, `:max_height`
- Expansion: `:expand` (`:width`, `:height`, `true`)
- Container styling: `:spacing`, `:padding`
- Alignment: `:align` (`:left`, `:center`, `:right` for VBox; `:top`, `:center`, `:bottom` for HBox)

### Color System
- Named colors: `:red`, `:blue`, `:black`, `:white`, etc.
- RGBA tuples: `{r, g, b, a}`
- RGB tuples: `{r, g, b}`
- Hex strings: `"#RRGGBB"`

### Layout Containers
- `:vbox` - Vertical box layout (children stacked vertically)
- `:hbox` - Horizontal box layout (children arranged horizontally)

---

## Technical Details

### Files Created

1. **`lib/unified_ui/renderers/desktop/renderer.ex`** (322 lines)
   - Main Desktop renderer module
   - Implements `UnifiedUi.Renderer` behaviour
   - Widget and layout converters
   - Widget builder functions

2. **`lib/unified_ui/renderers/desktop/style.ex`** (189 lines)
   - Style conversion utilities
   - Color mapping (IUR atoms to DesktopUi colors)
   - Style attribute mapping

3. **`test/unified_ui/renderers/desktop/renderer_test.exs`** (465 lines)
   - Unit tests for conversion functions

### Dependencies

**Internal:**
- `UnifiedUi.Renderer` - Behaviour to implement
- `UnifiedUi.Renderers.State` - State management
- `UnifiedUi.IUR.Element` - IUR protocol
- `UnifiedUi.IUR.Widgets` - Widget structs
- `UnifiedUi.IUR.Layouts` - Layout structs
- `UnifiedUi.IUR.Style` - Style struct

**External:**
- `desktop_ui` - Desktop UI library (NOT yet added as dependency)

---

## Success Criteria

1. ✅ Desktop renderer implements Renderer behaviour
2. ✅ All basic widgets convert correctly (text, button, label, text_input)
3. ✅ All layouts convert correctly (vbox, hbox)
4. ✅ Styles map to DesktopUi widget properties
5. ✅ All 35 tests pass
6. ✅ Documentation is complete

---

## Implementation Plan

### Task 3.3.1: Create Desktop Renderer Module

- [x] Create `lib/unified_ui/renderers/desktop/renderer.ex` (322 lines)
- [x] Implement `UnifiedUi.Renderer` behaviour
- [x] Add module documentation

### Task 3.3.2: Implement render/2 Entry Point

- [x] Create render function that traverses IUR tree
- [x] Track widgets in RendererState
- [x] Return state with root widget reference

### Task 3.3.3: Implement Widget Converters

- [x] `convert_text/2` - IUR.Text → Label widget map
- [x] `convert_button/2` - IUR.Button → Button widget map
- [x] `convert_label/2` - IUR.Label → Label widget map with :for metadata
- [x] `convert_text_input/2` - IUR.TextInput → Tagged tuple with label widget

### Task 3.3.4: Implement Layout Converters

- [x] `convert_vbox/2` - IUR.VBox → Container with direction: :vbox
- [x] `convert_hbox/2` - IUR.HBox → Container with direction: :hbox
- [x] Handle nesting correctly (tested with deeply nested layouts)
- [x] Map spacing, padding, alignment to DesktopUi props

### Task 3.3.5: Implement Style Converter

- [x] `add_props/2` - IUR.Style → DesktopUi widget props
- [x] Map foreground colors to :color prop
- [x] Map background colors to :background prop
- [x] Map text attributes (:bold, :underline, :italic) to :font_style prop

### Task 3.3.6: Write Unit Tests

- [x] Test widget converters (35 tests total)
- [x] Test layout converters
- [x] Test style converter
- [x] Test render/2
- [x] Test nested layouts

---

## Current Status

**Last Updated:** 2025-02-07

### What Works
- Desktop renderer converts all IUR widgets (Text, Button, Label, TextInput) to DesktopUi-style widget maps
- Desktop renderer converts all IUR layouts (VBox, HBox) to DesktopUi container maps
- Style conversion maps IUR styles to DesktopUi widget properties
- Nested layouts work correctly
- All 35 tests pass

### What's Next
- Desktop Server GenServer deferred to Phase 3.6 (Desktop Event Handling)
- Event wiring for desktop interactions
- Integration with actual DesktopUi library when added as dependency

### How to Run Tests
```bash
cd unified_ui
mix test test/unified_ui/renderers/desktop/renderer_test.exs
```

---

## Notes/Considerations

### DesktopUi Widget Structure

DesktopUi widgets are maps with a `:type` key:
```elixir
%{type: :label, id: nil, props: [text: "Hello"], children: []}
%{type: :button, id: nil, props: [label: "Click", on_click: :clicked], children: []}
%{type: :container, id: nil, props: [direction: :vbox, spacing: 8], children: [...]}
```

### Style Mapping Differences from Terminal

| IUR Style | Terminal (TermUI) | Desktop (DesktopUi) |
|-----------|-------------------|---------------------|
| `fg: :cyan` | `Style.fg(style, :cyan)` | `props: [color: :cyan]` |
| `bg: :blue` | `Style.bg(style, :blue)` | `props: [background: :blue]` |
| `attrs: [:bold]` | `Style.bold(style)` | `props: [font_style: :bold]` |

### TextInput Handling

DesktopUi doesn't have a dedicated TextInput widget yet. Represented as:
1. Tagged tuple `{:text_input, label_widget, metadata}`
2. Label widget shows value or placeholder text
3. Metadata includes input type, handlers, etc.

### Pixel-Based Spacing

DesktopUi uses pixel-based spacing:
- IUR spacing values are treated as pixels
- More flexible than terminal character cells
- May need scaling factors for high-DPI displays (future)

### DesktopUi Not in Dependencies

DesktopUi is not yet added to mix.exs dependencies. The renderer creates widget maps that follow the DesktopUi structure for future compatibility. When DesktopUi is added, these maps can be passed directly to rendering functions.

---

## Dependencies

**Depends on:**
- Phase 3.1: Renderer Architecture
- Phase 2: IUR structures complete
- Phase 3.2: Terminal renderer (as pattern reference)

**Enables:**
- Phase 3.6: Desktop Event Handling
- Phase 3.8: Multi-platform coordination

---

## Tracking

**Tasks:** 24 tasks (20 completed, 4 deferred)
**Completed:** 20/20 core tasks
**Deferred:** 4 (Desktop Server GenServer - moved to Phase 3.6)
**Status:** ✅ Complete
