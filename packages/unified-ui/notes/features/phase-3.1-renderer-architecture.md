# Phase 3.1: Renderer Architecture

**Date Started:** 2025-02-07
**Branch:** `feature/phase-3.1-renderer-architecture`
**Status:** Planning

---

## Overview

This feature implements the common architecture that all platform renderers (Terminal, Desktop, Web) will follow. It defines the renderer behaviour, shared utilities for IUR tree traversal, and patterns for state management and event handling.

**Planning Reference:** `notes/planning/phase-03.md` (Section 3.1)

---

## Problem Statement

Phase 2 implemented the DSL and IUR (Intermediate UI Representation). Now we need to build the renderers that will convert IUR to actual UI widgets on each platform. Without a common architecture:

1. Each renderer would implement different patterns, making code harder to maintain
2. Shared functionality would be duplicated across renderers
3. Event handling would be inconsistent across platforms
4. Testing would be more difficult without common interfaces

---

## Solution Overview

We will create a renderer architecture with:

1. **Renderer Behaviour** - Common contract all renderers must implement
2. **Shared Utilities** - Tree traversal, element lookup, style collection
3. **State Management Pattern** - How renderers track platform-specific state
4. **Event-to-Signal Pattern** - Converting platform events to JidoSignal format

### Key Design Decisions

| Decision | Rationale |
|----------|-----------|
| Behaviour over Protocol | Renderers are modules/GenServers, not structs |
| Tree traversal as pure functions | Easier to test, no side effects |
| Event callbacks as pattern matching | Allows flexible event handling |
| Renderer state in separate struct | Clean separation from IUR |

---

## Agent Consultations Performed

None needed - architecture is clearly defined in Phase 3 planning and builds directly on existing IUR structures from Phase 2.

---

## Technical Details

### Files to Create

1. **`lib/unified_ui/adapters/protocol.ex`**
   - `UnifiedUi.Renderer` behaviour
   - Callbacks: `render/2`, `update/3`, `destroy/1`

2. **`lib/unified_ui/adapters/shared.ex`**
   - `traverse_iur/2` - Generic tree traversal with accumulator
   - `find_by_id/2` - Find element by ID in IUR tree
   - `collect_styles/1` - Gather all style definitions
   - `count_elements/1` - Count widgets and layouts

3. **`lib/unified_ui/adapters/state.ex`**
   - `RendererState` struct definition
   - State management helpers
   - Platform widget registry

4. **`lib/unified_ui/adapters/event.ex`**
   - Event-to-signal conversion helpers
   - Signal dispatching pattern

### Files to Modify

None - this is new code in a new directory.

### Dependencies

**Internal:**
- `UnifiedUi.IUR.Element` protocol (already exists)
- `UnifiedUi.IUR.Widgets` - widget structs (already exists)
- `UnifiedUi.IUR.Layouts` - layout structs (already exists)
- `UnifiedUi.IUR.Style` - style struct (already exists)

**External:**
- `jido_signal` - For signal emission (already in dependencies)

---

## Success Criteria

1. ✅ Renderer behaviour defined with all required callbacks
2. ✅ Shared utilities work with existing IUR structures
3. ✅ State management pattern documented
4. ✅ Event-to-signal conversion helpers defined
5. ✅ All new code has comprehensive tests
6. ✅ Documentation is clear and complete
7. ✅ No breaking changes to existing code

---

## Implementation Plan

### Task 3.1.1: Create Renderer Behaviour

- [ ] Create `lib/unified_ui/adapters/protocol.ex`
- [ ] Define `@callback render/2` - IUR → platform widgets
- [ ] Define `@callback update/3` - Update existing widgets
- [ ] Define `@callback destroy/1` - Cleanup resources
- [ ] Add documentation and examples

### Task 3.1.2: Create Shared Utilities

- [ ] Create `lib/unified_ui/adapters/shared.ex`
- [ ] Implement `traverse_iur/2` with pre/post order options
- [ ] Implement `find_by_id/2` for element lookup
- [ ] Implement `collect_styles/1` for style gathering
- [ ] Add helper: `count_elements/1`
- [ ] Add helper: `validate_iur/1` for validation

### Task 3.1.3: Define Renderer State Management

- [ ] Create `lib/unified_ui/adapters/state.ex`
- [ ] Define `RendererState` struct
- [ ] Add state initialization helpers
- [ ] Add widget registry functions
- [ ] Add lifecycle tracking

### Task 3.1.4: Define Event-to-Signal Conversion

- [ ] Create `lib/unified_ui/adapters/event.ex`
- [ ] Define `to_signal/3` helper
- [ ] Define signal dispatcher pattern
- [ ] Add event metadata helpers

### Task 3.1.5: Document Renderer Contract

- [ ] Add module documentation to all files
- [ ] Create usage examples in docs
- [ ] Document platform-specific considerations

### Task 3.1.6: Write Unit Tests

- [ ] Test renderer behaviour is properly defined
- [ ] Test `traverse_iur` works with all IUR types
- [ ] Test `find_by_id` finds nested elements
- [ ] Test `collect_styles` gathers all styles
- [ ] Test state management helpers
- [ ] Test event-to-signal conversion

---

## Current Status

**Last Updated:** 2025-02-07

### What Works
- Task 3.1.1: Renderer behaviour defined with all required callbacks ✅
- Task 3.1.2: Shared utilities implemented and tested ✅
- Task 3.1.3: Renderer state management implemented ✅
- Task 3.1.4: Event-to-signal conversion defined ✅
- Task 3.1.5: Documentation complete with examples ✅
- Task 3.1.6: Unit tests all passing (94 tests) ✅

### Implementation Complete
All 30 tasks across 6 implementation groups are complete.

### How to Run Tests
```bash
cd unified_ui
mix test test/unified_ui/adapters/
```

---

## Notes/Considerations

### IUR Element Protocol
The existing `UnifiedUi.IUR.Element` protocol provides:
- `children/1` - Get child elements for tree traversal
- `metadata/1` - Get element properties

We will leverage this protocol heavily in the shared utilities.

### Platform Widget Storage
Renderers need to track platform-specific widgets alongside IUR elements.
The `RendererState` struct will maintain this mapping using element IDs.

### Event Handling Strategy
Events will be converted to signals using this pattern:
1. Platform event captured
2. Element metadata extracted from renderer state
3. Signal constructed using element's defined handlers (on_click, on_change, etc.)
4. Signal dispatched via JidoSignal

### Testing Strategy
- Unit tests for pure functions (traversal, lookup)
- Property-based tests for traversal correctness
- Documentation tests for examples

### Known Limitations
- No actual rendering yet (that's in 3.2, 3.3, 3.4)
- No actual event capture yet (that's in 3.5, 3.6, 3.7)
- Platform-specific implementations will be in separate modules

---

## Dependencies

**Depends on:**
- Phase 2 complete (IUR structures, Element protocol)

**Enables:**
- Phase 3.2: Terminal Renderer
- Phase 3.3: Desktop Renderer
- Phase 3.4: Web Renderer

---

## Tracking

**Tasks:** 30 total
**Completed:** 0
**In Progress:** 0 (planning complete, ready to implement)
**Pending:** 30
