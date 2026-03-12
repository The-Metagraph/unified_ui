# Phase 3.4: Web Renderer - Core

**Date Started:** 2025-02-07
**Date Completed:** 2025-02-07
**Branch:** `feature/phase-3.4-web-renderer`
**Status:** ✅ Complete

---

## Overview

This feature implements the Web renderer that converts IUR (Intermediate UI Representation) to HTML/CSS for Phoenix LiveView integration. This is the third concrete renderer implementation, following the Terminal and Desktop renderers.

**Planning Reference:** `notes/planning/phase-03.md` (Section 3.4)

---

## Problem Statement

Phases 3.2 and 3.3 implemented Terminal and Desktop renderers, but we need a Web renderer to enable browser-based applications. The Web renderer follows the same architecture but targets HTML/CSS with Phoenix LiveView integration.

---

## Solution Overview

Implement `UnifiedUi.Renderers.Web` module that:
1. Implements the `UnifiedUi.Renderer` behaviour
2. Converts IUR widgets to HTML elements
3. Converts IUR layouts to CSS flexbox containers
4. Maps IUR styles to CSS inline styles
5. Supports Phoenix LiveView phx-event bindings

### Key Design Decisions

| Decision | Rationale |
|----------|-----------|
| HTML string output | Web browsers render HTML, not widget trees |
| CSS flexbox for layouts | Modern, flexible layout system |
| Inline styles for simplicity | No external stylesheet dependency |
| phx-event bindings | Native LiveView event handling |
| HTML escaping for security | Prevent XSS attacks |
| Defer Web.Server to Phase 3.7 | Event handling needs full renderer foundation first |

---

## Web Output Structure

The renderer produces HTML strings with inline styles and Phoenix LiveView bindings:

### Widget Mapping
- `Text` → `<span>` with text content and style
- `Button` → `<button>` with label, phx-click binding
- `Label` → `<label>` with text, for attribute
- `TextInput` → `<input>` with type, placeholder, phx-change binding

### Layout Mapping
- `VBox` → `<div>` with `display: flex; flex-direction: column`
- `HBox` → `<div>` with `display: flex; flex-direction: row`

### Style Mapping
- `fg: :cyan` → `color: cyan`
- `bg: :blue` → `background-color: blue`
- `attrs: [:bold]` → `font-weight: bold`

---

## Technical Details

### Files Created

1. **`lib/unified_ui/renderers/web/renderer.ex`** (350+ lines)
   - Main Web renderer module
   - Implements `UnifiedUi.Renderer` behaviour
   - Widget and layout converters

2. **`lib/unified_ui/renderers/web/style.ex`** (200+ lines)
   - Style conversion utilities (IUR.Style → CSS)
   - Color mapping
   - Attribute mapping

3. **`test/unified_ui/renderers/web/renderer_test.exs`** (460+ lines)
   - Unit tests for HTML generation

### Dependencies

**Internal:**
- `UnifiedUi.Renderer` - Behaviour to implement
- `UnifiedUi.Renderers.State` - State management
- `UnifiedUi.IUR.Element` - IUR protocol
- `UnifiedUi.IUR.Widgets` - Widget structs
- `UnifiedUi.IUR.Layouts` - Layout structs
- `UnifiedUi.IUR.Style` - Style struct

**External:**
- None required (HTML generation is pure string manipulation)

---

## Success Criteria

1. ✅ Web renderer implements Renderer behaviour
2. ✅ All basic widgets convert to HTML (text, button, label, text_input)
3. ✅ All layouts convert to CSS flexbox (vbox, hbox)
4. ✅ Styles map to CSS inline styles
5. ✅ Phoenix LiveView bindings included (phx-click, phx-change)
6. ✅ All 38 tests pass
7. ✅ Documentation is complete

---

## Implementation Plan

### Task 3.4.1: Create Web Renderer Module

- [x] Create `lib/unified_ui/renderers/web/renderer.ex` (350+ lines)
- [x] Implement `UnifiedUi.Renderer` behaviour
- [x] Add module documentation

### Task 3.4.2: Implement render/2 Entry Point

- [x] Create render function that traverses IUR tree
- [x] Track widgets in RendererState
- [x] Return state with root HTML string

### Task 3.4.3: Implement Widget Converters

- [x] `convert_text/2` - IUR.Text → `<span>` HTML
- [x] `convert_button/2` - IUR.Button → `<button>` with phx-click
- [x] `convert_label/2` - IUR.Label → `<label>` with for attribute
- [x] `convert_text_input/2` - IUR.TextInput → `<input>` with type, phx-change

### Task 3.4.4: Implement Layout Converters

- [x] `convert_vbox/2` - IUR.VBox → `<div>` with flexbox column
- [x] `convert_hbox/2` - IUR.HBox → `<div>` with flexbox row
- [x] Handle nesting correctly
- [x] Map spacing, padding, alignment to CSS

### Task 3.4.5: Implement Style Converter

- [x] `to_css/1` - IUR.Style → CSS string
- [x] Map foreground colors to `color`
- [x] Map background colors to `background-color`
- [x] Map text attributes to CSS (bold → font-weight, etc.)

### Task 3.4.6: Write Unit Tests

- [x] Test widget converters (38 tests total)
- [x] Test layout converters (CSS flexbox)
- [x] Test style converter (CSS output)
- [x] Test render/2
- [x] Test nested layouts

---

## Current Status

**Last Updated:** 2025-02-07

### What Works
- Web renderer converts all IUR widgets (Text, Button, Label, TextInput) to HTML
- Web renderer converts all IUR layouts (VBox, HBox) to CSS flexbox
- Style conversion maps IUR styles to CSS inline styles
- Phoenix LiveView event bindings (phx-click, phx-change) generated correctly
- HTML escaping prevents XSS attacks
- All 38 tests pass

### What's Next
- Web Server GenServer deferred to Phase 3.7 (Web Event Handling)
- Phoenix LiveView integration for full interactivity
- WebSocket communication for real-time updates

### How to Run Tests
```bash
cd unified_ui
mix test test/unified_ui/renderers/web/renderer_test.exs
```

---

## Notes/Considerations

### HTML Structure

Web renderer produces HTML strings:
```html
<span style="color: cyan;">Hello</span>
<button phx-click="clicked">Click Me</button>
<div style="display: flex; flex-direction: column; gap: 8px;">...</div>
```

### CSS Flexbox for Layouts

- `VBox` → `display: flex; flex-direction: column; gap: {spacing}px`
- `HBox` → `display: flex; flex-direction: row; gap: {spacing}px`

### Style Mapping

| IUR Style | CSS |
|-----------|-----|
| `fg: :cyan` | `color: cyan` |
| `bg: :blue` | `background-color: blue` |
| `attrs: [:bold]` | `font-weight: bold` |
| `attrs: [:underline]` | `text-decoration: underline` |
| `attrs: [:italic]` | `font-style: italic` |
| `attrs: [:strikethrough]` | `text-decoration: line-through` |

### Phoenix LiveView Bindings

- Button `on_click: :submit` → `phx-click="submit"`
- TextInput `on_change: :update` → `phx-change="update"`
- Event names with underscores converted to kebab-case: `submit_form` → `submit-form`

### Color Mapping

IUR color atoms map to CSS color names:
- Terminal colors (`:cyan`, `:magenta`, etc.) work in CSS
- RGB tuples: `{255, 0, 0}` → `rgb(255, 0, 0)`
- RGBA tuples: `{255, 0, 0, 128}` → `rgba(255, 0, 0, 0.5)`

### Security

All user-provided content is HTML-escaped to prevent XSS:
- `&` → `&amp;`
- `<` → `&lt;`
- `>` → `&gt;`
- `"` → `&quot;`
- `'` → `&#39;`

### Testing Strategy

Since HTML is just strings, we can test conversion easily:
- Verify HTML contains expected tags
- Verify styles are applied correctly
- Verify attributes (phx-click, for, type) are present
- Verify nesting structure

---

## Dependencies

**Depends on:**
- Phase 3.1: Renderer Architecture
- Phase 2: IUR structures complete
- Phase 3.2/3.3: Terminal/Desktop renderers (as pattern reference)

**Enables:**
- Phase 3.7: Web Event Handling
- Phase 3.8: Multi-platform coordination

---

## Tracking

**Tasks:** 23 tasks (19 completed, 4 deferred)
**Completed:** 19/19 core tasks
**Deferred:** 4 (Web Server GenServer - moved to Phase 3.7)
**Status:** ✅ Complete
