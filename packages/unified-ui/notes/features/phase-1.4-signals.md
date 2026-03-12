# Feature: Phase 1.4 - Signal and Event Handling Constructs

## Problem Statement

The UnifiedUi library requires signal constructs that enable UI components to emit and respond to JidoSignal messages. Without these constructs, there's no way to define how user interactions (clicks, input changes, etc.) translate to signals in the agent-based component model.

## Solution Overview

Create signal-related constructs that:
1. Define a `UnifiedUi.Signals.Signal` struct for DSL signal definitions
2. Create helper functions for signal creation, emission, and validation
3. Define standard signal types for common UI interactions
4. Integrate with the JidoSignal library for actual signal dispatch

## Agent Consultations Performed

- **research-agent**: Reviewed JidoSignal library documentation for API understanding
- **elixir-expert**: Consulted for Elixir patterns for signal handling and validation

## Technical Details

### Location
- **Signal struct**: `lib/unified_ui/signals/signal.ex`
- **Helper module**: `lib/unified_ui/signals.ex`
- **Tests**: `test/unified_ui/signals/`

### JidoSignal Integration

From the JidoSignal documentation:
```elixir
# Preferred: positional constructor
{:ok, signal} = Jido.Signal.new("type", %{data}, source: "/path")

# Custom signal types
defmodule MySignal do
  use Jido.Signal,
    type: "my.custom.signal",
    default_source: "/my/service",
    schema: [field: [type: :string, required: true]]
end
```

### Signal Naming Convention

Following the JidoSignal pattern:
```
<domain>.<entity>.<action>[.<qualifier>]
```

For UI signals:
- `unified.button.clicked`
- `unified.input.changed`
- `unified.form.submitted`

### Standard Signal Types

Based on the research document and common UI patterns:

| Name | Type String | Description |
|------|------------|-------------|
| `:click` | `unified.button.clicked` | Button/element clicked |
| `:change` | `unified.input.changed` | Input value changed |
| `:submit` | `unified.form.submitted` | Form submitted |
| `:focus` | `unified.element.focused` | Element gained focus |
| `:blur` | `unified.element.blurred` | Element lost focus |
| `:select` | `unified.item.selected` | Item selected (table row, menu item) |

## Success Criteria

1. [x] Signal struct created with proper fields
2. [x] Helper module with define_signal, emit_signal, subscribe functions
3. [x] Standard signal types defined
4. [x] Signal validation helpers implemented
5. [x] Tests verify signal creation and validation
6. [x] Documentation for signal usage

## Implementation Plan

### Step 1: Create Signal Struct
- [x] Create `lib/unified_ui/signals/signal.ex`
- [x] Define `UnifiedUi.Signals.Signal` struct:
  - Fields: name, type, payload_schema, description, targets
- [x] Add @moduledoc with usage examples
- [x] Implement validation helpers

### Step 2: Create Helper Module
- [x] Create `lib/unified_ui/signals.ex`
- [x] Implement `define_signal/3` - Creates a signal struct definition
- [x] Implement `to_jido_signal/2` - Converts to Jido.Signal struct
- [x] Implement `validate_name/1` - Validates signal name format
- [x] Add @moduledoc with examples

### Step 3: Define Standard Signals
- [x] Add standard signal type constants
- [x] Implement `standard_signals/0` function
- [x] Document each standard signal's usage

### Step 4: Create Tests
- [x] Create `test/unified_ui/signals/signals_test.exs`
- [x] Test Signal struct creation
- [x] Test define_signal creates valid struct
- [x] Test to_jido_signal conversion
- [x] Test signal name validation
- [x] Test standard signal types
- [x] Test invalid signal names are rejected

## Status

**Current**: ✅ Complete - All implementation steps finished

**Next**: Write summary and request permission to merge

---

## Implementation Log

### 2025-02-04 - Initial Planning
- Feature planning document created
- Branch created: `feature/phase-1.4-signals`
- Researched JidoSignal library API
- Ready to begin implementation

### 2025-02-04 - Implementation
- Created Signal struct at `lib/unified_ui/signals/signal.ex`
- Created helper module at `lib/unified_ui/signals.ex`
- Defined 6 standard signal types (:click, :change, :submit, :focus, :blur, :select)
- Implemented to_jido_signal/3 for JidoSignal integration
- Implemented validate_payload/2 for payload schema validation
- Created comprehensive tests at `test/unified_ui/signals/signals_test.exs`
- All 91 tests pass (36 new + 55 existing)

## Files Created

### Core Signal Modules
- `lib/unified_ui/signals/signal.ex` - Signal definition struct
- `lib/unified_ui/signals.ex` - Helper functions for signal operations

### Tests
- `test/unified_ui/signals/signals_test.exs` - Comprehensive tests (36 tests)

## Key Design Decisions

1. **Separation of concerns**: Signal struct is for DSL definitions, JidoSignal is for runtime signal instances
2. **Validation functions**: `valid_name/1` and `valid_type/1` ensure signal names/types follow conventions
3. **Standard signals**: Pre-defined common signal types to reduce boilerplate
4. **JidoSignal integration**: `to_jido_signal/3` converts DSL definitions to runtime JidoSignal instances
5. **Payload validation**: Basic payload schema validation for type safety
