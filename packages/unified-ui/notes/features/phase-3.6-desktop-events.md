# Phase 3.6: Desktop Event Handling

**Date Started:** 2025-02-08
**Branch:** `feature/phase-3.6-desktop-events`
**Status:** In Progress

---

## Overview

This feature implements event capture and signal dispatch for the Desktop renderer. It captures DesktopUi events (button clicks, text input changes, keyboard, mouse, window events) and converts them to JidoSignal messages for agent communication.

**Planning Reference:** `notes/planning/phase-03.md` (Section 3.6)

---

## Problem Statement

Phase 3.3 implemented the Desktop renderer for converting IUR to DesktopUi render trees, but there's no mechanism for handling user interactions. We need event capture and signal dispatch to enable interactive desktop applications with full mouse, keyboard, and window event support.

---

## Solution Overview

Implement `UnifiedUi.Renderers.Desktop.Events` module that:
1. Captures DesktopUi events (clicks, changes, keyboard, mouse, window)
2. Converts events to JidoSignal messages
3. Dispatches signals to subscribing agents
4. Provides widget-specific helper functions
5. Handles window lifecycle events (resize, move, close)

### Key Design Decisions

| Decision | Rationale |
|----------|-----------|
| Signal-based communication | JidoSignal is the unified event bus |
| Event-to-signal conversion | Consistent with Elm Architecture pattern |
| Handler extraction from render tree | Allows dynamic event discovery |
| Widget-specific helpers | Convenient functions for common events |
| Extended event support | Desktop has more event types than terminal (mouse coords, window events) |
| No GenServer yet | Event capture is synchronous for now |

---

## Technical Details

### Files to Create

1. **`lib/unified_ui/renderers/desktop/events.ex`** (estimated ~450 lines)
   - Event capture module
   - Event-to-signal conversion
   - Signal dispatch helpers
   - Handler extraction from render trees

2. **`test/unified_ui/renderers/desktop/events_test.exs`** (estimated ~450 lines)
   - Unit tests for event handling

### Dependencies

**Internal:**
- `UnifiedUi.Signals` - Signal creation helpers
- Terminal Events module (`UnifiedUi.Renderers.Terminal.Events`) - Pattern reference

**External:**
- `jido_signal` - Signal library

---

## Success Criteria

1. Desktop event types defined (7+ types: click, change, key_press, mouse, focus, blur, window)
2. Event-to-signal conversion works (all types)
3. Signal dispatch returns proper signals
4. Keyboard events handled (with modifiers)
5. Mouse events handled (with coordinates)
6. Window events handled (resize, move, close)
7. All tests pass
8. Documentation is complete

---

## Implementation Plan

### Task 3.6.1: Create Events Module

- [x] Create `lib/unified_ui/renderers/desktop/events.ex` (480+ lines)
- [x] Define desktop event types
- [x] Add module documentation

### Task 3.6.2: Define Desktop Event Types

- [x] Define click event structure
- [x] Define change event structure
- [x] Define key press event structure
- [x] Define mouse event structure (with coordinates)
- [x] Define focus/blur events
- [x] Define window event structure (resize, move, close, minimize, maximize)

### Task 3.6.3: Implement Event Capture

- [x] `extract_handlers/1` - Extract handlers from render tree
- [x] Support tagged tuple widgets ({:button, ...})
- [x] Support container nodes with children
- [x] Handle nested structures

### Task 3.6.4: Implement Event-to-Signal Converter

- [x] `to_signal/3` - Convert events to JidoSignal
- [x] Click events → unified.button.clicked
- [x] Change events → unified.input.changed
- [x] Submit events → unified.form.submitted
- [x] Key press events → unified.key.pressed
- [x] Mouse events → unified.mouse.{action}
- [x] Focus/blur events → unified.element.{focused|blurred}
- [x] Window events → unified.window.{action}

### Task 3.6.5: Implement Signal Dispatch

- [x] `dispatch/3` - Create and dispatch signals
- [x] Returns {:ok, signal} on success
- [x] Supports custom source option

### Task 3.6.6: Add Widget-Specific Helpers

- [x] `button_click/3` - Button click helper
- [x] `input_change/3` - Input change helper
- [x] `form_submit/3` - Form submit helper
- [x] `key_press/3` - Key press helper

### Task 3.6.7: Add Keyboard Event Handling

- [x] Key press event type defined
- [x] Supports key name atom
- [x] Supports modifier key list (ctrl, alt, shift, meta)

### Task 3.6.8: Add Mouse Event Handling

- [x] Mouse event type defined
- [x] Supports click, double_click, right_click, move, scroll
- [x] Includes x, y coordinates
- [x] Supports button information

### Task 3.6.9: Add Window Event Handling

- [x] Window event type defined
- [x] Supports resize (width, height)
- [x] Supports move (x, y)
- [x] Supports close, minimize, maximize, restore

### Task 3.6.10: Write Unit Tests

- [x] Test button click captured and converted
- [x] Test text input change captured
- [x] Test keyboard events captured
- [x] Test mouse events captured (with coordinates)
- [x] Test window events captured (resize, move, close)
- [x] Test event converts to JidoSignal
- [x] Test signal dispatches (returns signal)
- [x] Test handler extraction from render trees
- [x] Test integration scenarios

---

## Current Status

**Last Updated:** 2025-02-08

### What Works
- Seven event types defined (click, change, key_press, mouse, focus, blur, window)
- Event-to-signal conversion for all event types
- Widget-specific helper functions for common events
- Mouse event helpers with coordinate support (click, double_click, move, scroll)
- Window event helpers (resize, move, close, minimize, maximize, restore, focus, blur)
- Handler extraction from DesktopUI render trees
- All 71 tests pass

### What's Next
- GenServer for desktop lifecycle (future phase)
- Actual DesktopUI event capture integration (when DesktopUI supports it)
- Signal bus integration for agent communication

### How to Run Tests
```bash
cd unified_ui
mix test test/unified_ui/renderers/desktop/events_test.exs
```

---

## Notes/Considerations

### Event Flow

```
User Action → DesktopUi Event → UnifiedUi Event → JidoSignal → Agent
```

### Event Types (Extended from Terminal)

1. **Click Events** → `unified.button.clicked`
   - Triggered by button press
   - Contains widget ID and action

2. **Change Events** → `unified.input.changed`
   - Triggered by text input
   - Contains widget ID and new value

3. **Submit Events** → `unified.form.submitted`
   - Triggered by form submission
   - Contains form ID and form data

4. **Key Press Events** → `unified.key.pressed`
   - Triggered by key press
   - Contains key code and modifiers

5. **Mouse Events** → `unified.mouse.{action}`
   - Triggered by mouse actions
   - Contains action type and coordinates
   - Actions: click, double_click, right_click, move, scroll, wheel

6. **Focus/Blur Events** → `unified.element.{focused|blurred}`
   - Triggered by focus changes
   - Contains widget ID

7. **Window Events** → `unified.window.{action}` (NEW for Desktop)
   - Triggered by window lifecycle
   - Actions: resize, move, close, minimize, maximize, restore, focus, blur
   - Contains window dimensions or coordinates

### Signal Structure

JidoSignal format:
```elixir
%Jido.Signal{
  type: "unified.button.clicked",
  source: "/unified_ui/desktop",
  data: %{
    widget_id: :submit_button,
    action: :submit_form,
    platform: :desktop
  }
}
```

### Mouse Event Data Structure

```elixir
# Mouse click
%{
  widget_id: :my_button,
  action: :click,
  x: 100,
  y: 200,
  button: :left,  # :left, :middle, :right
  modifiers: []
}

# Mouse move
%{
  x: 150,
  y: 250,
  buttons: []  # List of currently pressed buttons
}
```

### Window Event Data Structure

```elixir
# Window resize
%{
  action: :resize,
  width: 800,
  height: 600
}

# Window move
%{
  action: :move,
  x: 100,
  y: 50
}

# Window close
%{
  action: :close
}
```

### Keyboard Modifiers

Supported modifiers:
- `:ctrl` - Control key
- `:alt` - Alt/Meta key
- `:shift` - Shift key
- `:meta` - Meta/Windows/Command key

### Handler Extraction

The `extract_handlers/1` function traverses DesktopUI render trees:

**Tagged tuple format:**
```elixir
{:button, text_node, %{on_click: :action, id: :button_id}}
{:text_input, text_node, %{id: :input_id, on_change: :update}}
```

**Container nodes:**
```elixir
%{type: :vbox, children: [...]}
```

Returns map of widget IDs to their handler configurations.

### Widget Helper Examples

```elixir
# Button click
Events.button_click(:submit_button, :submit_form)

# Input change
Events.input_change(:email_input, "user@example.com")

# Form submit
Events.form_submit(:login_form, %{email: "...", password: "..."})

# Key press
Events.key_press(:enter, [])
Events.key_press(:s, [:ctrl])  # Ctrl+S

# Mouse click (NEW)
Events.mouse_click(:my_button, :left, 100, 200)

# Window resize (NEW)
Events.window_resize(800, 600)

# Window move (NEW)
Events.window_move(100, 50)

# Window close (NEW)
Events.window_close()
```

---

## Dependencies

**Depends on:**
- Phase 3.3: Desktop Renderer (widget trees with event metadata)
- Phase 2: IUR structures (for event metadata)
- Phase 3.5: Terminal Events (pattern reference)

**Enables:**
- Interactive desktop applications
- Phase 3.8: Multi-platform coordination

---

## Tracking

**Tasks:** 40 tasks (40 core tasks completed)
**Completed:** 40/40 core tasks
**Status:** ✅ Complete
