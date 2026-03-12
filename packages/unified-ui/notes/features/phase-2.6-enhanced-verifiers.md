# Phase 2.6: Enhanced Verifiers

**Branch:** `feature/phase-2.6-enhanced-verifiers`
**Created:** 2025-02-06
**Status:** Completed

## Overview

This section implements enhanced verifiers for the UnifiedUi DSL that validate widget and layout entities at compile time. Verifiers run after transformers and provide clear, actionable error messages before runtime.

## Planning Document Reference

From `notes/planning/phase-02.md`, section 2.6:

### Task 2.6: Enhance verifiers for core widgets and layouts

Update and expand verifiers to handle validation of the new widget and layout entities.

## Implementation Plan

### 2.6.1 Update `unique_id_verifier` to handle all widgets
- [x] Create `lib/unified_ui/dsl/verifiers.ex`
- [x] Implement `UniqueIdVerifier` module
- [x] Traverse all entities in [:widgets] and [:layouts] sections
- [x] Collect all `:id` attributes from widgets and layouts
- [x] Check for duplicate IDs
- [x] Provide error with file/line location

### 2.6.2 Add `layout_structure_verifier` for layout validation
- [x] Implement `LayoutStructureVerifier` module
- [x] Validate that labels have valid `:for` references to input IDs
- [x] Check that referenced text_input IDs exist

### 2.6.3 Add `signal_handler_verifier` for signal reference validation
- [x] Implement `SignalHandlerVerifier` module
- [x] Extract all signal handler references (on_click, on_change, on_submit)
- [x] Verify handler format is valid (atom, tuple, or MFA)
- [x] For MFA handlers, verify the module exists

### 2.6.4 Add `style_reference_verifier` for style name validation
- [x] Implement `StyleReferenceVerifier` module
- [x] Extract all style references from widgets/layouts
- [x] For inline styles, validate attribute names
- [x] Validate text attribute values

### 2.6.5 Add `state_reference_verifier` for state key validation
- [x] Implement `StateReferenceVerifier` module
- [x] Extract initial state definition from [:ui, :state] path
- [x] Verify state keys are atoms (not strings)
- [x] Provide clear error for invalid key types

### 2.6.6 Improve error messages with specific locations
- [x] All verifiers use Spark.Error.DslError with proper formatting
- [x] Include module, path, and detailed message in all errors
- [x] Provide suggestions for fixing common errors

## Design Decisions

### Verifier Architecture

All verifiers will:
1. Implement the `Spark.Dsl.Verifier` behavior
2. Use `Spark.Dsl.Verifier.run/2` pattern
3. Return `:ok` or `{:error, Spark.Error.t()}` with proper error struct
4. Traverse DSL state using `Spark.Dsl.Transformer.get_entities/2`

### Error Message Format

Errors will follow this pattern:
```
[UnifiedUi.Verifier.<Name>] <message>

  In <entity> at <file>:<line>

  <suggestion>
```

### Verification Order

Verifiers run in the order defined in Extension:
1. UniqueIdVerifier - Ensure IDs are unique first
2. LayoutStructureVerifier - Check structure is valid
3. SignalHandlerVerifier - Validate signal handlers
4. StyleReferenceVerifier - Validate styles
5. StateReferenceVerifier - Validate state references

## Entity Schema Summary

### Widget IDs
- **button**: id (optional)
- **text**: id (optional)
- **label**: id (optional), for (required, references text_input id)
- **text_input**: id (required)

### Layout IDs
- **vbox**: id (optional)
- **hbox**: id (optional)

### Signal Handlers
- **button**: on_click (optional)
- **text_input**: on_change (optional), on_submit (optional)

### Style Attributes
- **Common**: fg, bg, attrs, padding, margin, width, height, align, spacing
- **Text attributes**: :bold, :italic, :underline, :reverse, :blink, :strikethrough

### State Keys
- Defined in `state attrs: [...]` entity in [:ui] section
- Referenced as `{:state, :key}` in widget attributes (future phase)

## Files to Create

### New Files
- `lib/unified_ui/dsl/verifiers.ex` - All verifier modules
- `test/unified_ui/dsl/verifiers_test.exs` - Verifier tests

### Files to Modify
- `lib/unified_ui/dsl/extension.ex` - Add verifiers to section

## Dependencies

- Depends on Phase 1: Foundation (DSL structure)
- Depends on Phase 2.1: Basic Widget Entities (widget schemas)
- Depends on Phase 2.2: Basic Layout Entities (layout schemas)
- Enables all later phases (validation catches errors early)

## Test Checklist

From planning document:
- [x] Test unique_id_verifier catches duplicate IDs
- [x] Test layout_structure_verifier catches invalid nesting
- [x] Test signal_handler_verifier catches undefined signals
- [x] Test style_reference_verifier catches undefined styles
- [x] Test state_reference_verifier catches invalid state keys

## Progress

### Current Status
- ✅ Planning document created
- ✅ Understanding verifier patterns from Spark
- ✅ Implementing verifier modules
- ✅ All verifiers added to Extension
- ✅ Comprehensive tests created (24 tests, all passing)
- ✅ Summary written

### Summary
- Total tests: 488 passing (24 new for verifiers)
- All 5 verifiers implemented and tested
- Verifiers run automatically when using UnifiedUi.Dsl
