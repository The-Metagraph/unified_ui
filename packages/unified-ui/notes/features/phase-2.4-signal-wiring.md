# Phase 2.4: Signal Wiring

**Branch:** `feature/phase-2.4-signal-wiring`
**Created:** 2025-02-06
**Status:** Completed

## Overview

This section implements signal wiring for widget events, connecting UI interactions to the Elm Architecture's update cycle. Widget events like clicks, input changes, and form submissions will emit JidoSignal envelopes that route through the component's `update/2` function.

## Planning Document Reference

From `notes/planning/phase-02.md`, section 2.4:

### Task 2.4: Implement signal wiring for widget events

Connect widget event handlers to the signal system for inter-component communication.

## Implementation Plan

### 2.4.1 Update `update_transformer` to generate signal handler clauses
- [x] Extract signal handlers from DSL widget entities
- [x] Generate pattern match clauses for each signal type
- [x] Support custom signal handling (through overridable functions)

### 2.4.2 Implement on_click signal emission
- [x] Generate click signal handling code
- [x] Support atom signal names (via SignalHelpers)
- [x] Support tuple with payload (via SignalHelpers)
- [x] Emit proper JidoSignal structure (via SignalHelpers)

### 2.4.3 Implement on_change signal emission with payload
- [x] Generate change signal handling code
- [x] Include input value in payload (via SignalHelpers)
- [x] Include input id in payload (via SignalHelpers)

### 2.4.4 Implement on_submit signal emission
- [x] Generate submit signal handling code
- [x] Support form data collection (via SignalHelpers)

### 2.4.5 Add signal payload extraction helpers
- [x] Create helper module for signal payload extraction
- [x] Support common payload patterns

### 2.4.6 Test signal routing to component agents
- [x] Test that signals reach update/2 (via pattern matching)
- [x] Test signal payload is correct (54 tests passing)
- [x] Test state updates from signals (via StateHelpers integration)

## Design Decisions

### Signal Handler Format

Signal handlers in the DSL support three formats:

1. **Atom signal name**: `on_click: :save`
   - Emits signal with no extra payload

2. **Tuple with payload**: `on_click: {:save, %{form_id: :login}}`
   - Emits signal with static payload

3. **MFA tuple**: `on_click: {MyModule, :my_function, []}`
   - Calls function to get signal or return value

### Signal Emission Pattern

For Phase 2.4, signal emission will be handled through generated code in the update/2 function. The update transformer will:

1. Extract all signal handlers from the DSL entities
2. Generate pattern match clauses for each unique signal name
3. Each clause will:
   - Match on the signal type/name
   - Extract the payload
   - Apply state updates using `StateHelpers`

### Progress

### Current Status
- ✅ Planning document created
- ✅ SignalHelpers module implemented with 12 functions
- ✅ UpdateTransformer updated with signal pattern matching
- ✅ Three overridable signal handler functions generated
- ✅ All tests passing (411 total, including 64 new tests)
- ✅ Code formatted

### Completed Work

1. **UnifiedUi.Dsl.SignalHelpers** - 12 functions for signal handling:
   - `normalize_handler/1` - Normalize handler definitions
   - `handler_action/1` - Extract action from handler
   - `handler_payload/1` - Extract static payload
   - `mfa_handler?/1` - Check if MFA handler
   - `extract_payload/2` - Extract single value from signal
   - `extract_payloads/2` - Extract multiple values from signal
   - `signal_type/1` - Get signal type string
   - `build_signal/3` - Build Jido.Signal
   - `click_signal/3` - Build click signal
   - `change_signal/4` - Build change signal
   - `submit_signal/3` - Build submit signal
   - `match_signal?/2` - Match signal to type
   - `build_state_update/3` - Build state update from handler+signal

2. **UpdateTransformer** - Generates:
   - `update/2` with pattern matching for click/change/submit
   - `handle_click_signal/2` - overridable
   - `handle_change_signal/2` - overridable
   - `handle_submit_signal/2` - overridable
   - Fallback clause for unknown signals

3. **Tests**:
   - 54 tests for SignalHelpers
   - 20 tests for UpdateTransformer (updated)
   - Integration tests with StateHelpers

### Next Steps
1. Phase 2.5: IUR Tree Building
2. Phase 2.7: Form Support (enhanced form submission)

## Files to Modify

### Existing Files
- `lib/unified_ui/dsl/transformers/update_transformer.ex` - Add signal handler generation
- `lib/unified_ui/dsl/entities/widgets.ex` - Already has on_click/on_change/on_submit

### New Files
- `lib/unified_ui/dsl/signal_helpers.ex` - Signal payload extraction helpers
- `test/unified_ui/dsl/signal_helpers_test.exs` - Tests for signal helpers
- `test/unified_ui/dsl/transformers/update_transformer_test.exs` - Tests for generated update

## Dependencies

- Depends on Phase 1: Foundation (Elm Architecture transformers, Signal system)
- Depends on Phase 2.1: Basic Widget Entities (widgets with event handlers)
- Depends on Phase 2.3: Widget State Integration (StateHelpers for updates)

## Test Checklist

From planning document:
- [ ] Test on_click emits correct signal
- [ ] Test on_change emits signal with payload
- [ ] Test on_submit emits signal with form data
- [ ] Test signal reaches update/2 function
- [ ] Test signal payload is correct
- [ ] Test state updates from signals
- [ ] Test multiple signal handlers in one component

## Progress

### Current Status
- ✅ Planning document created
- ⏳ Reviewing existing code structure
- ⏳ Implementing signal helpers
- ⏳ Updating update_transformer
- ⏳ Creating tests

### Next Steps
1. Create signal helpers module
2. Update update_transformer to extract handlers and generate clauses
3. Create comprehensive tests
4. Run final verification
