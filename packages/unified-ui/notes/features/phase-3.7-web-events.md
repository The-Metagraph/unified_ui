# Phase 3.7: Web Event Handling

**Date Started:** 2025-02-08
**Date Completed:** 2025-02-08
**Branch:** `feature/phase-3.7-web-events`
**Status:** ✅ Complete

---

## Overview

This feature implements event capture and signal dispatch for the Web renderer. It captures browser events via Phoenix LiveView (phx-click, phx-change, etc.) and converts them to JidoSignal messages for agent communication, using WebSocket for real-time updates.

**Planning Reference:** `notes/planning/phase-03.md` (Section 3.7)

---

## Problem Statement

Phase 3.4 implemented the Web renderer for converting IUR to HTML/LiveView, but there's no mechanism for handling user interactions. We need event capture and signal dispatch to enable interactive web applications using Phoenix LiveView with WebSocket communication and reconnection handling.

---

## Solution Overview

Implement `UnifiedUi.Renderers.Web.Events` module that:
1. Captures browser events via Phoenix LiveView (phx-click, phx-change, phx-submit, etc.)
2. Converts events to JidoSignal messages
3. Dispatches signals to subscribing agents
4. Provides widget-specific helper functions
5. Supports WebSocket communication for real-time updates
6. Handles reconnection with exponential backoff

### Key Design Decisions

| Decision | Rationale |
|----------|-----------|
| Phoenix LiveView events | Industry standard for server-rendered interactivity |
| Signal-based communication | JidoSignal is the unified event bus |
| Event-to-signal conversion | Consistent with Elm Architecture pattern |
| WebSocket for real-time | LiveView uses WebSocket by default |
| Reconnection handling | Network resilience with exponential backoff |
| Form value handling | LiveView provides form data natively |
| No GenServer yet | Event capture is synchronous for now |

---

## Technical Details

### Files to Create

1. **`lib/unified_ui/renderers/web/events.ex`** (estimated ~400 lines)
   - Event capture module
   - Event-to-signal conversion
   - Signal dispatch helpers
   - Handler extraction from render trees

2. **`test/unified_ui/renderers/web/events_test.exs`** (estimated ~400 lines)
   - Unit tests for event handling

### Dependencies

**Internal:**
- `UnifiedUi.Signals` - Signal creation helpers
- Terminal/Desktop Events modules - Pattern reference

**External:**
- `jido_signal` - Signal library
- `phoenix_live_view` - LiveView event handling (dependency, not used directly in this phase)

---

## Success Criteria

1. Web event types defined (6+ types: click, change, key, form, focus, blur)
2. Event-to-signal conversion works (all types)
3. Signal dispatch returns proper signals
4. Keyboard events handled (with modifiers)
5. Form events handled (with form values)
6. Focus/blur events handled
7. All tests pass
8. Documentation is complete

---

## Implementation Plan

### Task 3.7.1: Create Events Module

- [x] Create `lib/unified_ui/renderers/web/events.ex` (430+ lines)
- [x] Define web event types
- [x] Add module documentation

### Task 3.7.2: Define Web Event Types

- [x] Define click event structure
- [x] Define change event structure
- [x] Define key event structure
- [x] Define form submit event structure
- [x] Define focus/blur events
- [x] Define hook event structure (for JS hooks)

### Task 3.7.3: Implement Event Capture

- [x] `extract_handlers/1` - Extract handlers from render tree
- [x] Support HTML element patterns
- [x] Support container nodes with children
- [x] Handle nested structures

### Task 3.7.4: Implement Event-to-Signal Converter

- [x] `to_signal/3` - Convert events to JidoSignal
- [x] Click events → unified.button.clicked
- [x] Change events → unified.input.changed
- [x] Form submit events → unified.form.submitted
- [x] Key events → unified.key.pressed
- [x] Focus/blur events → unified.element.{focused|blurred}
- [x] Hook events → unified.web.{hook_name}

### Task 3.7.5: Implement Signal Dispatch

- [x] `dispatch/3` - Create and dispatch signals
- [x] Returns {:ok, signal} on success
- [x] Supports custom source option

### Task 3.7.6: Add Widget-Specific Helpers

- [x] `button_click/3` - Button click helper
- [x] `input_change/3` - Input change helper
- [x] `form_submit/3` - Form submit helper
- [x] `key_press/3` - Key press helper

### Task 3.7.7: Add Form Event Handling

- [x] Form submit event type defined
- [x] Supports form data extraction
- [x] Handles multiple form fields
- [x] Supports checkbox/radio groups

### Task 3.7.8: Add WebSocket Communication (Prepared for Future)

- [x] Document WebSocket connection pattern
- [x] Document reconnection strategy
- [x] Add exponential backoff constants
- [x] Note: Actual WebSocket handling in future GenServer

### Task 3.7.9: Write Unit Tests

- [x] Test button click captured and converted
- [x] Test input change captured
- [x] Test form submit captured with data
- [x] Test keyboard events captured
- [x] Test focus/blur events captured
- [x] Test event converts to JidoSignal
- [x] Test signal dispatches (returns signal)
- [x] Test handler extraction from render trees
- [x] Test integration scenarios

---

## Current Status

**Last Updated:** 2025-02-08

### What Works
- Seven event types defined (click, change, key_press, key_release, focus, blur, hook)
- Event-to-signal conversion for all event types
- Widget-specific helper functions for common events
- LiveView hook event support for custom JS interactions
- WebSocket lifecycle event helpers (connecting, connected, disconnected, reconnecting)
- WebSocket reconnection constants (base delay, max delay, max attempts)
- Handler extraction from HTML render trees
- All 59 tests pass

### What's Next
- GenServer for web lifecycle (future phase)
- Actual LiveView event capture integration (when LiveView module is created)
- Signal bus integration for agent communication
- WebSocket reconnection with jitter in GenServer

### How to Run Tests
```bash
cd unified_ui
mix test test/unified_ui/renderers/web/events_test.exs
```

---

## Notes/Considerations

### Event Flow

```
Browser Event → LiveView phx-event → UnifiedUi Event → JidoSignal → Agent
```

### LiveView Event Mapping

| LiveView Event | UnifiedUi Signal |
|----------------|------------------|
| `phx-click` | `unified.button.clicked` |
| `phx-change` | `unified.input.changed` |
| `phx-submit` | `unified.form.submitted` |
| `phx-keydown` | `unified.key.pressed` |
| `phx-keyup` | `unified.key.released` |
| `phx-focus` | `unified.element.focused` |
| `phx-blur` | `unified.element.blurred` |
| `phx-hook` | `unified.web.{hook_name}` |

### Event Types

1. **Click Events** → `unified.button.clicked`
   - Triggered by button click (phx-click)
   - Contains widget ID and action

2. **Change Events** → `unified.input.changed`
   - Triggered by input change (phx-change)
   - Contains widget ID and new value

3. **Form Submit Events** → `unified.form.submitted`
   - Triggered by form submission (phx-submit)
   - Contains form ID and form data (all field values)

4. **Key Events** → `unified.key.{pressed|released}`
   - Triggered by keyboard input (phx-keydown, phx-keyup)
   - Contains key code and modifiers

5. **Focus/Blur Events** → `unified.element.{focused|blurred}`
   - Triggered by focus changes (phx-focus, phx-blur)
   - Contains widget ID

6. **Hook Events** → `unified.web.{hook_name}`
   - Triggered by JS hooks
   - Contains hook name and data

### Signal Structure

JidoSignal format:
```elixir
%Jido.Signal{
  type: "unified.button.clicked",
  source: "/unified_ui/web",
  data: %{
    widget_id: :submit_button,
    action: :submit_form,
    platform: :web
  }
}
```

### Form Event Data Structure

```elixir
# Form submit
%{
  form_id: :login_form,
  data: %{
    email: "user@example.com",
    password: "secret",
    remember_me: "true"
  }
}
```

### Keyboard Modifiers (Web)

Supported modifiers match browser keys:
- `:ctrl` - Control key
- `:alt` - Alt/Option key
- `:shift` - Shift key
- `:meta` - Meta/Command key

### Handler Extraction

The `extract_handlers/1` function traverses HTML render trees:

**HTML element patterns:**
```elixir
{:button, attrs, %{on_click: :action, id: :button_id}}
{:input, attrs, %{id: :input_id, on_change: :update, type: :text}}
```

**Container nodes:**
```elixir
%{type: :div, children: [...]}
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
```

### WebSocket Reconnection Strategy

**Future Implementation Notes:**
- Exponential backoff: 1s, 2s, 4s, 8s, 16s, 32s (max)
- Jitter: ±25% random variation
- Max retries: 10 (configurable)
- Reconnect events: `unified.web.{connecting,connected,disconnected,reconnecting}`

### LiveView Integration Pattern

**Future LiveView Module:**
```elixir
defmodule MyAppWeb.LiveUI do
  use Phoenix.LiveView

  def handle_event("click", %{"widget_id" => widget_id}, socket) do
    {:ok, signal} = Events.button_click(widget_id, :clicked)
    # Dispatch to JidoSignal bus
    {:noreply, socket}
  end
end
```

---

## Dependencies

**Depends on:**
- Phase 3.4: Web Renderer (HTML trees with event metadata)
- Phase 2: IUR structures (for event metadata)
- Phase 3.5/3.6: Terminal/Desktop Events (pattern reference)

**Enables:**
- Interactive web applications
- Phase 3.8: Multi-platform coordination

---

## Tracking

**Tasks:** 35 tasks (35 core tasks completed)
**Completed:** 35/35 core tasks
**Status:** ✅ Complete
