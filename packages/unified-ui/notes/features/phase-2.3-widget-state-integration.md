# Phase 2.3: Widget State Integration

**Branch:** `feature/phase-2.3-widget-state-integration`
**Created:** 2025-02-05
**Status:** Completed

## Overview

This section implements state management for widgets in the Elm Architecture. It enables widgets to bind to state values, allowing dynamic UI updates when state changes.

## Planning Document Reference

From `notes/planning/phase-02.md`, section 2.3:

### Task 2.3: Implement state management for widgets in the Elm Architecture

Update the Elm Architecture transformers to properly handle widget state and state interpolation.

## Implementation Plan

### 2.3.1 Update `init_transformer` to extract widget initial state
- [x] Review current init_transformer implementation
- [x] Ensure state entity extraction works correctly
- [x] Verify state is properly converted to map

### 2.3.2 Update `view_transformer` to interpolate state into widget properties
- [x] Update view/1 to accept state argument (changed from `_state` to `state`)
- [ ] Implement state interpolation for `{:state, :key}` references (deferred to Phase 2.5)
- [ ] Walk the DSL tree and replace state references with actual values (deferred to Phase 2.5)

### 2.3.3 Implement state binding for text_input (value binding)
- [ ] Add value attribute state binding to TextInput (deferred to Phase 2.5)
- [ ] Support `value: {:state, :email}` syntax (deferred to Phase 2.5)

### 2.3.4 Implement state binding for disabled attribute
- [ ] Add disabled state binding to Button and TextInput (deferred to Phase 2.5)
- [ ] Support `disabled: {:state, :submitting?}` syntax (deferred to Phase 2.5)

### 2.3.5 Implement state binding for visible attribute
- [ ] Add visible state binding to all widgets and layouts (deferred to Phase 2.5)
- [ ] Support `visible: {:state, :show_content?}` syntax (deferred to Phase 2.5)

### 2.3.6 Add state update helpers for common patterns
- [x] Create helpers: `increment/2`, `toggle/2`, `set/3` and more
- [x] Add to a new state_helpers module
- [x] Create comprehensive tests (50 tests, all passing)

## Design Decisions

### State Reference Syntax

State will be referenced as a tuple: `{:state, :key}`

Examples:
- `value: {:state, :email}` - Binds to state.email
- `disabled: {:state, :submitting?}` - Binds to state.submitting?
- `visible: {:state, :show_content?}` - Binds to state.show_content?

### Interpolation Strategy

The view_transformer will:
1. Traverse the DSL tree (entities in ui section)
2. For each entity, check for `{:state, :key}` tuples in attributes
3. Generate code that replaces tuples with `Map.get(state, :key)` calls

### State Update Helpers

```elixir
# Increment a counter value
increment(:count)  # => %{count: state.count + 1}

# Toggle a boolean value
toggle(:active)  # => %{active: !state.active}

# Set a value
set(:email, "new@example.com")  # => %{email: "new@example.com"}
```

## Scope Consideration

**Decision**: This section focuses on state update helpers and preparing the view transformer for state interpolation. The full state interpolation implementation (DSL tree walking, replacing `{:state, :key}` references) is deferred to Phase 2.5 (IUR Tree Building) because:

1. State interpolation requires walking DSL trees, which is exactly what Phase 2.5 implements
2. Implementing it now would duplicate work planned for 2.5
3. The state helper functions provide immediate value for update/2 functions
4. The view transformer now properly names the state parameter (not `_state`), preparing for 2.5

**Option B chosen**: Implement minimal state binding preparation with state helper functions.

## Files to Modify

### Existing Files
- `lib/unified_ui/dsl/transformers/init_transformer.ex` - Verified state extraction works
- `lib/unified_ui/dsl/transformers/view_transformer.ex` - Fixed outdated field, renamed state parameter
- `test/unified_ui/dsl/transformers/view_transformer_test.exs` - Updated to match new signature

### New Files
- `lib/unified_ui/dsl/state_helpers.ex` - State update helper functions
- `test/unified_ui/dsl/state_helpers_test.exs` - Tests for state helpers (50 tests)

## Dependencies

- Depends on Phase 1: Foundation (Elm Architecture transformers)
- Depends on Phase 2.1: Basic Widget Entities (widgets to bind state to)
- Depends on Phase 2.2: Basic Layout Entities (layouts to bind state to)
- Enables Phase 2.4: Signal Wiring (state changes triggered by signals)

## Test Checklist

From planning document:
- [x] Test widget state initializes correctly (init_transformer verified)
- [ ] Test state interpolation in view works (deferred to Phase 2.5)
- [ ] Test text_input value binding (deferred to Phase 2.5)
- [ ] Test disabled state binding (deferred to Phase 2.5)
- [ ] Test visible state binding (deferred to Phase 2.5)
- [x] Test state update helpers work (50 tests, all passing)

## Summary

**Total Tests**: 347 tests passing (includes 50 new state helpers tests)

**New Modules**:
- `UnifiedUi.Dsl.StateHelpers` - 9 functions for state management

**Modified Files**:
- `UnifiedUi.Dsl.Transformers.ViewTransformer` - Fixed outdated `align` field, renamed `_state` to `state`

**Deferred to Phase 2.5**:
- Full DSL tree walking for state interpolation
- State binding syntax implementation (`{:state, :key}` tuples)
- Widget attribute interpolation (value, disabled, visible)

## Progress

### Current Status
- ✅ Planning document created
- ✅ Scope decision made (Option B - defer full interpolation to 2.5)
- ✅ State helpers implemented with 9 functions
- ✅ View transformer updated with correct field names
- ✅ All tests passing (347 total)
- ✅ Code formatted

### Completed Work
1. Implemented `UnifiedUi.Dsl.StateHelpers` module with:
   - `increment/2` - Increment a numeric state value
   - `increment_by/3` - Increment by custom amount
   - `toggle/2` - Toggle a boolean state value
   - `set/3` - Set a state value
   - `apply_update/3` - Apply a function to a state value
   - `merge_updates/2` - Merge updates into state
   - `clear/2` - Clear a value to nil
   - `append/3` - Append to a list state value
   - `remove/3` - Remove from a list state value

2. Fixed `ViewTransformer`:
   - Changed outdated `align` field to `align_items`
   - Renamed `_state` parameter to `state` to prepare for Phase 2.5
   - Updated documentation

3. Created comprehensive tests (50 tests for state helpers)

### Next Steps
1. Phase 2.4: Signal Wiring
2. Phase 2.5: IUR Tree Building (will implement full state interpolation)
