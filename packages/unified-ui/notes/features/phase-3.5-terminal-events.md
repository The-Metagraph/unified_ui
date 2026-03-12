# Phase 3.5: Terminal Event Handling

**Date Started:** 2025-02-07
**Date Completed:** 2025-02-07
**Branch:** `feature/phase-3.5-terminal-events`
**Status:** ✅ Complete

---

## Overview

This feature implements event capture and signal dispatch for the Terminal renderer. It captures TermUi events (button clicks, text input changes, keyboard input) and converts them to JidoSignal messages for agent communication.

**Planning Reference:** `notes/planning/phase-03.md` (Section 3.5)

---

## Problem Statement

Phase 3.2 implemented the Terminal renderer for converting IUR to TermUI render trees, but there's no mechanism for handling user interactions. We need event capture and signal dispatch to enable interactive terminal applications.

---

## Solution Overview

Implement `UnifiedUi.Renderers.Terminal.Events` module that:
1. Captures TermUi events (clicks, changes, keyboard)
2. Converts events to JidoSignal messages
3. Dispatches signals to subscribing agents
4. Provides widget-specific helper functions

### Key Design Decisions

| Decision | Rationale |
|----------|-----------|
| Signal-based communication | JidoSignal is the unified event bus |
| Event-to-signal conversion | Consistent with Elm Architecture pattern |
| Handler extraction from render tree | Allows dynamic event discovery |
| Widget-specific helpers | Convenient functions for common events |
| No GenServer yet | Event capture is synchronous for now |

---

## Technical Details

### Files Created

1. **`lib/unified_ui/renderers/terminal/events.ex`** (360+ lines)
   - Event capture module
   - Event-to-signal conversion
   - Signal dispatch helpers
   - Handler extraction from render trees

2. **`test/unified_ui/renderers/terminal/events_test.exs`** (380+ lines)
   - Unit tests for event handling

### Dependencies

**Internal:**
- `UnifiedUi.Signals` - Signal creation helpers

**External:**
- `jido_signal` - Signal library

---

## Success Criteria

1. ✅ Terminal event types defined (6 types)
2. ✅ Event-to-signal conversion works (all types)
3. ✅ Signal dispatch returns proper signals
4. ✅ Keyboard events handled
5. ✅ Mouse events handled
6. ✅ All 34 tests pass
7. ✅ Documentation is complete

---

## Implementation Plan

### Task 3.5.1: Create Events Module

- [x] Create `lib/unified_ui/renderers/terminal/events.ex` (360+ lines)
- [x] Define terminal event types
- [x] Add module documentation

### Task 3.5.2: Define Terminal Event Types

- [x] Define click event structure
- [x] Define change event structure
- [x] Define key press event structure
- [x] Define mouse event structure
- [x] Define focus/blur events

### Task 3.5.3: Implement Event Capture

- [x] `extract_handlers/1` - Extract handlers from render tree
- [x] Support tagged tuple widgets ({:button, ...})
- [x] Support container nodes with children
- [x] Handle nested structures

### Task 3.5.4: Implement Event-to-Signal Converter

- [x] `to_signal/3` - Convert events to JidoSignal
- [x] Click events → unified.button.clicked
- [x] Change events → unified.input.changed
- [x] Submit events → unified.form.submitted
- [x] Key press events → unified.key.pressed
- [x] Mouse events → unified.mouse.{action}
- [x] Focus/blur events → unified.element.{focused|blurred}

### Task 3.5.5: Implement Signal Dispatch

- [x] `dispatch/3` - Create and dispatch signals
- [x] Returns {:ok, signal} on success
- [x] Supports custom source option

### Task 3.5.6: Add Widget-Specific Helpers

- [x] `button_click/3` - Button click helper
- [x] `input_change/3` - Input change helper
- [x] `form_submit/3` - Form submit helper
- [x] `key_press/3` - Key press helper

### Task 3.5.7: Add Keyboard Event Handling

- [x] Key press event type defined
- [x] Supports key name atom
- [x] Supports modifier key list

### Task 3.5.8: Write Unit Tests

- [x] Test button click captured and converted
- [x] Test text input change captured
- [x] Test keyboard events captured
- [x] Test event converts to JidoSignal
- [x] Test signal dispatches (returns signal)
- [x] Test handler extraction from render trees

---

## Current Status

**Last Updated:** 2025-02-07

### What Works
- Six event types defined (click, change, submit, key_press, mouse, focus/blur)
- Event-to-signal conversion for all event types
- Widget-specific helper functions for common events
- Handler extraction from TermUI render trees
- All 34 tests pass

### What's Next
- GenServer for terminal lifecycle (future phase)
- Actual TermUI event capture integration (when TermUI supports it)
- Signal bus integration for agent communication

### How to Run Tests
```bash
cd unified_ui
mix test test/unified_ui/renderers/terminal/events_test.exs
```

---

## Notes/Considerations

### Event Flow

```
User Action → TermUi Event → UnifiedUi Event → JidoSignal → Agent
```

### Event Types

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

6. **Focus/Blur Events** → `unified.element.{focused|blurred}`
   - Triggered by focus changes
   - Contains widget ID

### Signal Structure

JidoSignal format:
```elixir
%Jido.Signal{
  type: "unified.button.clicked",
  source: "/unified_ui/terminal",
  data: %{
    widget_id: :submit_button,
    action: :submit_form,
    platform: :terminal
  }
}
```

### Handler Extraction

The `extract_handlers/1` function traverses TermUI render trees:

**Tagged tuple format:**
```elixir
{:button, text_node, %{on_click: :action, id: :button_id}}
{:text_input, text_node, %{id: :input_id, on_change: :update}}
```

**Container nodes:**
```elixir
%{type: :stack, children: [...]}
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
Events.key_press(:c, [:ctrl])  # Ctrl+C
```

---

## Dependencies

**Depends on:**
- Phase 3.2: Terminal Renderer (widget trees with event metadata)
- Phase 2: IUR structures (for event metadata)

**Enables:**
- Interactive terminal applications
- Phase 3.8: Multi-platform coordination

---

## Tracking

**Tasks:** 27 tasks (27 core tasks completed)
**Completed:** 27/27 core tasks
**Status:** ✅ Complete
