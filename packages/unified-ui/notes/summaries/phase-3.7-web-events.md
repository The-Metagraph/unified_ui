# Phase 3.7: Web Event Handling - Implementation Summary

**Date:** 2025-02-08
**Branch:** `feature/phase-3.7-web-events`
**Status:** Complete

---

## Overview

Implemented event capture and signal dispatch for the Web renderer. This enables interactive web applications using Phoenix LiveView with WebSocket communication patterns, capturing browser events and converting them to JidoSignal messages for agent communication.

---

## Files Created

### 1. `lib/unified_ui/renderers/web/events.ex` (430+ lines)

Event capture and signal dispatch module for Web renderer.

**Key functions:**
- `event_types/0` - Returns list of supported event types (7 types)
- `create_event/2` - Creates a web event from type and data
- `to_signal/3` - Converts web event to JidoSignal
- `dispatch/3` - Creates and dispatches a signal

**WebSocket reconnection constants:**
- `base_reconnect_delay/0` - Returns 1000ms base delay
- `max_reconnect_delay/0` - Returns 32000ms max delay
- `max_reconnect_attempts/0` - Returns 10 max attempts

**Widget-specific helpers:**
- `button_click/3` - Creates button click signal
- `input_change/3` - Creates input change signal
- `form_submit/3` - Creates form submit signal
- `key_press/3` - Creates key press signal
- `key_release/3` - Creates key release signal

**LiveView hook event helpers:**
- `hook_event/3` - Creates custom hook event signal
- `ws_connecting/1` - Creates WebSocket connecting signal
- `ws_connected/1` - Creates WebSocket connected signal
- `ws_disconnected/1` - Creates WebSocket disconnected signal
- `ws_reconnecting/3` - Creates WebSocket reconnecting signal with attempt/delay

**Handler extraction:**
- `extract_handlers/1` - Extracts event handlers from HTML render trees

### 2. `test/unified_ui/renderers/web/events_test.exs` (480+ lines)

Comprehensive test suite with 59 tests covering:
- Event type creation (4 tests)
- WebSocket constants (3 tests)
- Event-to-signal conversion (11 tests)
- Signal dispatch (3 tests)
- Widget-specific helpers (10 tests)
- Hook event helpers (7 tests)
- WebSocket event helpers (5 tests)
- Handler extraction from render trees (12 tests)
- Integration scenarios (4 tests)

---

## Key Implementation Decisions

1. **Signal-Based Communication**
  All events converted to JidoSignal for unified agent communication:
  ```elixir
  {:ok, signal} = Events.to_signal(:click, %{widget_id: :btn, action: :submit})
  # => %Jido.Signal{type: "unified.button.clicked", ...}
  ```

2. **LiveView Event Mapping**
  Maps Phoenix LiveView events to UnifiedUi signals:
  ```elixir
  phx-click   → unified.button.clicked
  phx-change  → unified.input.changed
  phx-submit  → unified.form.submitted
  phx-keydown → unified.key.pressed
  phx-keyup   → unified.key.released
  phx-focus   → unified.element.focused
  phx-blur    → unified.element.blurred
  ```

3. **Extended Event Types**
  Seven standard event types defined:
  - `:click` - Button/widget clicked → `unified.button.clicked`
  - `:change` - Input value changed → `unified.input.changed`
  - `:key_press` - Key pressed → `unified.key.pressed`
  - `:key_release` - Key released → `unified.key.released` (NEW for Web)
  - `:focus`/`:blur` - Focus events → `unified.element.{focused|blurred}`
  - `:hook` - LiveView JS hooks → `unified.web.{hook_name}` (NEW for Web)

4. **Form Event Support with Values**
  Form submissions include all field values:
  ```elixir
  Events.form_submit(:login_form, %{email: "...", password: "..."})
  # => %{type: "unified.form.submitted", data: %{form_id: :login_form, data: %{...}}}
  ```

5. **LiveView Hook Support**
  Custom JS hooks can send events:
  ```elixir
  Events.hook_event(:scroll_tracker, %{scroll_top: 250, scroll_height: 2000})
  # => %{type: "unified.web.scroll_tracker", ...}
  ```

6. **WebSocket Reconnection Constants**
  Predefined constants for future GenServer implementation:
  - Base delay: 1000ms
  - Max delay: 32000ms
  - Max attempts: 10

7. **Handler Extraction**
  Traverse HTML render trees to find elements with event handlers:
  ```elixir
  # Extracts from tagged tuples like {:button, attrs, %{on_click: :action, id: :btn}}
  handlers = Events.extract_handlers(render_tree)
  # => %{btn: %{on_click: :action}}
  ```

8. **Platform Metadata**
  All signals include `platform: :web` for source identification.

---

## Event Flow

```
Browser Event → LiveView phx-event → UnifiedUi Event → JidoSignal → Agent
```

**Example:**
1. User clicks button in browser
2. LiveView emits phx-click event
3. `Events.to_signal(:click, %{widget_id: :submit, action: :submit_form})`
4. JidoSignal created: `%{type: "unified.button.clicked", data: %{...}, source: "/unified_ui/web"}`
5. Signal dispatched to JidoSignal bus
6. Subscribing agent receives and processes signal

---

## Test Results

All tests passing:
- 59 web events tests
- 0 failures

```
...........................................................
Finished in 0.4 seconds (0.4s async, 0.00s sync)
59 tests, 0 failures
```

---

## Widget Helpers

### Button Click
```elixir
Events.button_click(:submit_button, :submit_form)
# => {:ok, %Jido.Signal{type: "unified.button.clicked", ...}}
```

### Input Change
```elixir
Events.input_change(:email_input, "user@example.com")
# => {:ok, %Jido.Signal{type: "unified.input.changed", ...}}
```

### Form Submit
```elixir
Events.form_submit(:login_form, %{email: "...", password: "..."})
# => {:ok, %Jido.Signal{type: "unified.form.submitted", ...}}
```

### Key Press/Release
```elixir
Events.key_press(:enter, [])
Events.key_press(:s, [:ctrl])  # Ctrl+S
Events.key_release(:s, [:ctrl])
```

---

## Hook Event Helpers (LiveView JS Hooks)

### Custom Hook Events
```elixir
Events.hook_event(:scroll_tracker, %{scroll_top: 250, scroll_height: 2000})
# => {:ok, %Jido.Signal{type: "unified.web.scroll_tracker", ...}}
```

### Scroll Tracking
```elixir
Events.hook_event(:scroll_tracker, %{
  scroll_top: 250,
  scroll_left: 0,
  scroll_height: 2000,
  viewport_height: 600
})
```

### Resize Observer
```elixir
Events.hook_event(:resize_observer, %{
  element_id: :my_container,
  width: 800,
  height: 600
})
```

---

## WebSocket Event Helpers

### Connection Lifecycle
```elixir
Events.ws_connecting()   # => unified.web.connecting
Events.ws_connected()    # => unified.web.connected
Events.ws_disconnected() # => unified.web.disconnected
```

### Reconnection with Backoff
```elixir
Events.ws_reconnecting(1, 1000)   # Attempt 1, delay 1000ms
Events.ws_reconnecting(2, 2000)   # Attempt 2, delay 2000ms
Events.ws_reconnecting(3, 4000)   # Attempt 3, delay 4000ms
# => {:ok, %Jido.Signal{type: "unified.web.reconnecting",
#                        data: %{attempt: 3, delay_ms: 4000}}}
```

---

## WebSocket Reconnection Strategy

**Future Implementation Notes:**
- Exponential backoff: 1s, 2s, 4s, 8s, 16s, 32s (max)
- Base delay: `base_reconnect_delay()` = 1000ms
- Max delay: `max_reconnect_delay()` = 32000ms
- Max attempts: `max_reconnect_attempts()` = 10
- Jitter: ±25% random variation (to be implemented)
- Reconnect events: `unified.web.{connecting,connected,disconnected,reconnecting}`

---

## Handler Extraction

The `extract_handlers/1` function traverses HTML render trees to find elements with event handlers:

**HTML element patterns:**
```elixir
{:button, attrs, %{on_click: :action, id: :button_id}}
{:input, attrs, %{id: :input_id, on_change: :update, type: :text}}
{:form, attrs, %{id: :form_id, on_submit: :submit}}
```

**Container nodes:**
```elixir
%{type: :div, children: [...]}
```

Returns map of element IDs to their handler configurations.

---

## LiveView Integration Pattern (Future)

**Future LiveView Module:**
```elixir
defmodule MyAppWeb.LiveUI do
  use Phoenix.LiveView

  def handle_event("click", %{"widget_id" => widget_id}, socket) do
    {:ok, signal} = Events.button_click(widget_id, :clicked)
    # Dispatch to JidoSignal bus
    {:noreply, socket}
  end

  def handle_event("form_submit", %{"form_id" => form_id} = params, socket) do
    {:ok, signal} = Events.form_submit(form_id, params)
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
- JidoSignal (signal library)

**Enables:**
- Interactive web applications
- Phase 3.8: Multi-platform coordination

---

## Notes

### Signal Naming Convention

Follows JidoSignal pattern: `<domain>.<entity>.<action>`

- `unified.button.clicked`
- `unified.input.changed`
- `unified.form.submitted`
- `unified.key.pressed`
- `unified.key.released`
- `unified.element.focused`
- `unified.element.blurred`
- `unified.web.{hook_name}`

### Keyboard Modifiers

Supported modifiers match browser keys:
- `:ctrl` - Control key
- `:alt` - Alt/Option key
- `:shift` - Shift key
- `:meta` - Meta/Command key

### Input Event Types

Web supports both `on_change` and `on_input`:
- `on_change` - Fires when element loses focus after value change
- `on_input` - Fires immediately on any value change

### Comparison with Other Platforms

| Feature | Terminal | Desktop | Web |
|---------|----------|---------|-----|
| Basic events | ✓ | ✓ | ✓ |
| Keyboard events | ✓ | ✓ | ✓ (with key_release) |
| Mouse events | Limited | Full | Via LiveView hooks |
| Window events | ✗ | ✓ | ✗ (browser handles) |
| Hook/Custom events | ✗ | ✗ | ✓ |
| WebSocket lifecycle | ✗ | ✗ | ✓ (constants defined) |
| Total event types | 6 | 7 | 7 |
| Total tests | 34 | 71 | 59 |
