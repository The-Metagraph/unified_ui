# Phase 2.7: Form Support

**Branch:** `feature/phase-2.7-form-support`
**Created:** 2025-02-07
**Completed:** 2025-02-07
**Status:** Completed

## Overview

This section implements basic form support for input widgets. Forms allow grouping multiple inputs together for coordinated data collection, validation, and submission.

## Planning Document Reference

From `notes/planning/phase-02.md`, section 2.7:

### Task 2.7: Add basic form support for input widgets

Create the foundational pieces for form handling with input widgets.

## Problem Statement

Currently, text_input widgets operate independently. There is no mechanism to:
1. Group related inputs together as a form
2. Collect all input values together on submission
3. Validate multiple inputs as a unit
4. Associate submission events with grouped data

This makes form handling cumbersome - developers must manually track which inputs belong to which form and manually collect their values.

## Solution Overview

Add form support through:
1. **Form ID association**: Add `form_id` option to text_input widgets
2. **Form data collection**: Helper functions to extract all input values for a form
3. **Form submission signals**: Signal helpers that include form data
4. **Basic form validation**: Validation helpers that work with form data

## Design Decisions

### Form Association Model

- **Declarative association**: Inputs declare their form membership via `form_id` option
- **No form entity**: Forms are implicit - defined by which inputs share a `form_id`
- **Multiple forms**: Multiple forms can coexist by using different `form_id` values

### Form Data Structure

Form data will be collected as a map with input IDs as keys:

```elixir
%{
  email: "user@example.com",
  password: "secret123",
  name: "John Doe"
}
```

### Signal Integration

Form submission signals will include the collected form data in their payload:

```elixir
{:form_submit, %{form_id: :login, data: %{email: "...", password: "..."}}}
```

## Implementation Plan

### 2.7.1 Define form association attributes for text_input

- [x] Add `form_id` option to `@text_input_entity` schema
- [x] Set type as `:atom`
- [x] Mark as optional (no default)
- [x] Update documentation with examples

**Files to modify:**
- `lib/unified_ui/dsl/entities/widgets.ex` - Add form_id to text_input schema

### 2.7.2 Add form_id to IUR TextInput struct

- [x] Add `form_id` field to `UnifiedUi.IUR.Widgets.TextInput`
- [x] Update type specification
- [x] Update documentation

**Files to modify:**
- `lib/unified_ui/iur/widgets.ex` - Add form_id to TextInput struct

### 2.7.3 Implement form data collection helpers

- [x] Create `lib/unified_ui/dsl/form_helpers.ex`
- [x] Implement `collect_form_data(dsl_state, form_id)` function
- [x] Extract all inputs with matching form_id
- [x] Build map of input_id => value pairs
- [x] Handle inputs with nil values

**Files to create:**
- `lib/unified_ui/dsl/form_helpers.ex` - Form data collection module

### 2.7.4 Add form submission signal helpers

- [x] Add `build_form_submit_signal(form_id, data)` function
- [x] Add `build_form_submit_signal(form_id, data, extra_payload)` function
- [x] Create signal in format: `{:form_submit, %{form_id: ..., data: ...}}`
- [x] Document usage pattern

**Files to modify:**
- `lib/unified_ui/dsl/form_helpers.ex` - Add signal builder functions

### 2.7.5 Create basic form validation helpers

- [x] Add `validate_required(form_data, required_fields)` function
- [x] Add `validate_email(form_data, field)` function
- [x] Add `validate_length(form_data, field, min, max)` function
- [x] Add `validate_format(form_data, field, pattern)` function
- [x] Return `:ok` or `{:error, reasons}` tuple

**Files to modify:**
- `lib/unified_ui/dsl/form_helpers.ex` - Add validation functions

## Entity Schema Summary

### Updated TextInput Entity

```elixir
@text_input_entity %Spark.Dsl.Entity{
  name: :text_input,
  target: Widgets.TextInput,
  args: [:id],
  schema: [
    # ... existing fields ...
    form_id: [
      type: :atom,
      doc: "Optional form identifier to group this input with a form.",
      required: false
    ]
  ]
}
```

## API Design

### Form Data Collection

```elixir
# In a UI module using UnifiedUi.Dsl
ui do
  text_input :email, form_id: :login, placeholder: "Email"
  text_input :password, form_id: :login, type: :password
  button "Submit", on_click: {:submit_login, %{form_id: :login}}
end

# In update/2
def update(:submit_login, %{form_id: form_id}, state) do
  form_data = UnifiedUi.Dsl.FormHelpers.collect_form_data(__dsl_state__, form_id)
  # form_data => %{email: "...", password: "..."}
  {:noreply, state}
end
```

### Form Validation

```elixir
case UnifiedUi.Dsl.FormHelpers.validate_required(form_data, [:email, :password]) do
  :ok ->
    case UnifiedUi.Dsl.FormHelpers.validate_email(form_data, :email) do
      :ok -> # Process form
      {:error, _} -> # Show error
    end
  {:error, _} -> # Show error
end
```

## Test Checklist

From planning document:
- [x] Test inputs can be associated with form via form_id
- [x] Test form data collection gathers all input values
- [x] Test form data collection handles nil values correctly
- [x] Test form submission signal includes form data
- [x] Test validate_required catches missing fields
- [x] Test validate_email validates email format
- [x] Test validate_length enforces length constraints
- [x] Test validate_format matches regex patterns
- [x] Test multiple forms can coexist with different form_ids
- [x] Test inputs without form_id are not collected

## Files to Create

### New Files
- `lib/unified_ui/dsl/form_helpers.ex` - Form data collection and validation helpers
- `test/unified_ui/dsl/form_helpers_test.exs` - Comprehensive form helpers tests

### Files to Modify
- `lib/unified_ui/dsl/entities/widgets.ex` - Add form_id option to text_input
- `lib/unified_ui/iur/widgets.ex` - Add form_id field to TextInput struct

## Dependencies

- Depends on Phase 1: Foundation (DSL structure)
- Depends on Phase 2.1: Basic Widget Entities (text_input widget)
- Depends on Phase 2.4: Signal Wiring (signal helpers)
- Enables Phase 2.10: Integration Tests (form testing)

## Progress

### Current Status
- ✅ Planning document created
- ✅ Feature branch created
- ✅ Form association attributes implemented
- ✅ form_id added to entities
- ✅ Form helpers implemented
- ✅ Comprehensive tests written (53 tests passing)
- ✅ Summary written

### Implementation Summary
- Created `UnifiedUi.Dsl.FormHelpers` module with 8 public functions
- Added `form_id` option to text_input DSL entity
- Added `form_id` field to IUR TextInput struct
- Total: 541 tests passing (488 previous + 53 new)
