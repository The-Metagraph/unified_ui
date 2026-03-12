# Phase 1.5: Elm Architecture Transformers

**Date:** 2026-02-04
**Branch:** `feature/phase-1.5-elm-transformers`
**Status:** ✅ Complete (Foundation)

---

## Problem Statement

The UnifiedUi DSL needs a way to generate the boilerplate code required by The Elm Architecture pattern. Currently, developers would need to manually write `init/1`, `update/2`, and `view/1` functions for each UI component, which is repetitive and error-prone.

**Impact:**
- Without transformers, every UI component requires manual boilerplate code
- Developers must manually map DSL definitions to Elm Architecture functions
- State interpolation (binding dynamic values to UI elements) would be manual
- Signal handling pattern matching must be hand-written for each component

---

## Solution Overview

Implement Spark.Dsl.Transformer modules that automatically generate the Elm Architecture boilerplate at compile time:

1. **UnifiedUi.ElmArchitecture behaviour** - Defines the contract for UI components
2. **init_transformer** - Generates `init/1` function with initial state from DSL
3. **update_transformer** - Generates `update/2` function with signal pattern matching
4. **view_transformer** - Generates `view/1` function that returns IUR structs

**Key Design Decisions:**

| Decision | Rationale |
|----------|-----------|
| Use Spark.Dsl.Transformer | Leverages compile-time code generation, zero runtime overhead |
| Generate functions via eval/3 | Standard Spark pattern for injecting code into modules |
| State as atom-keyed map | Type-safe, idiomatic Elixir pattern |
| Signal pattern matching | Elixir's pattern matching naturally handles signal routing |
| IUR for view output | Platform-agnostic representation defined in Phase 1.3 |

---

## Agent Consultations Performed

### Research Agent: Spark.Dsl.Transformer Patterns
**Agent ID:** a9bc5e9

**Key Findings:**
- `Spark.Dsl.Transformer.transform/1` is the main callback
- Use `Spark.Dsl.Transformer.eval/3` to generate code in target modules
- Use `Spark.Dsl.get_entities/2` to extract data from DSL state
- Use `Spark.Dsl.get_opt/3` to retrieve DSL options
- Code generation uses `quote do...end` blocks with `unquote` for interpolation

---

## Technical Details

### Files to Create

| File | Purpose |
|------|---------|
| `lib/unified_ui/elm_architecture.ex` | Behaviour definition for Elm Architecture |
| `lib/unified_ui/dsl/transformers/elm_arch.ex` | Main Elm Architecture transformer |
| `lib/unified_ui/dsl/transformers/init_transformer.ex` | Generates init/1 function |
| `lib/unified_ui/dsl/transformers/update_transformer.ex` | Generates update/2 function |
| `lib/unified_ui/dsl/transformers/view_transformer.ex` | Generates view/1 function |
| `test/unified_ui/dsl/transformers/elm_arch_test.exs` | Transformer tests |

### Files to Modify

| File | Changes |
|------|---------|
| `lib/unified_ui/dsl/extension.ex` | Register transformers in DSL extension |
| `lib/unified_ui/dsl/sections/ui.ex` | Add state and handler options to ui section schema |

### Dependencies

```elixir
# Existing dependencies (already in mix.exs)
{:spark, "~> 1.0"}  # DSL and transformer framework
```

### Configuration

No runtime configuration needed. Transformers work at compile time.

---

## Success Criteria

1. **Behaviour Definition**
   - [ ] `UnifiedUi.ElmArchitecture` behaviour with `init/1`, `update/2`, `view/1` callbacks
   - [ ] Callback typespecs documented
   - [ ] Example usage in moduledoc

2. **init_transformer**
   - [ ] Extracts initial state from `state:` option in DSL
   - [ ] Generates `init/1` function returning initial state map
   - [ ] Handles missing state option (returns empty map)
   - [ ] Test verifies generated init/1 returns correct state

3. **update_transformer**
   - [ ] Extracts signal handlers from DSL
   - [ ] Generates `update/2` with pattern matching on signal type
   - [ ] Handles signals from `UnifiedUi.Signals` (click, change, etc.)
   - [ ] Test verifies pattern matching routes signals correctly

4. **view_transformer**
   - [ ] Traverses DSL UI tree structure
   - [ ] Generates `view/1` returning IUR structs
   - [ ] Supports state interpolation (`@state.field` syntax)
   - [ ] Test verifies view returns correct IUR tree

5. **Integration**
   - [ ] Transformers registered in DSL extension
   - [ ] Generated modules adopt ElmArchitecture behaviour
   - [ ] All tests pass
   - [ ] Example component demonstrates usage

---

## Implementation Plan

### Step 1: Create ElmArchitecture Behaviour (15 min)

**File:** `lib/unified_ui/elm_architecture.ex`

```elixir
defmodule UnifiedUi.ElmArchitecture do
  @moduledoc """
  Behaviour for UI components following The Elm Architecture.

  Components implementing this behaviour must provide:
  - init/1 - Initial state
  - update/2 - State transition on signal
  - view/1 - UI representation as IUR
  """

  @callback init(keyword()) :: %{atom() => any()}
  @callback update(%{atom() => any()}, Jido.Signal.t()) :: %{atom() => any()}
  @callback view(%{atom() => any()}) :: UnifiedUi.IUR.Element.t()
end
```

**Test:** Verify behaviour can be adopted by a module

---

### Step 2: Create init_transformer (30 min)

**File:** `lib/unified_ui/dsl/transformers/init_transformer.ex`

**Tasks:**
1. Extract `state:` option from DSL using `Spark.Dsl.get_opt/3`
2. Generate `init/1` function with quoted code
3. Return initial state map with atom keys

**Code to Generate:**
```elixir
@impl true
def init(_opts) do
  %{field1: value1, field2: value2}  # From DSL state option
end
```

**Test:** Create DSL with state option, verify init/1 returns correct map

---

### Step 3: Create update_transformer (45 min)

**File:** `lib/unified_ui/dsl/transformers/update_transformer.ex`

**Tasks:**
1. Extract signal handler definitions from DSL entities
2. Generate pattern match clauses for each signal type
3. Handle unknown signals (return state unchanged or log warning)

**Code to Generate:**
```elixir
@impl true
def update(state, %Jido.Signal{type: "unified.button.clicked", data: data}) do
  # Handler from DSL
  Map.put(state, :clicked, true)
end

def update(state, %Jido.Signal{type: "unified.input.changed", data: data}) do
  # Handler from DSL
  Map.put(state, :input_value, data.value)
end

def update(state, _signal) do
  # Fallback: return state unchanged
  state
end
```

**Test:** Create DSL with signal handlers, verify update/2 routes correctly

---

### Step 4: Create view_transformer (60 min)

**File:** `lib/unified_ui/dsl/transformers/view_transformer.ex`

**Tasks:**
1. Traverse DSL UI tree (layouts and widgets)
2. Convert each DSL entity to corresponding IUR struct
3. Implement state interpolation for `@state.field` references
4. Generate `view/1` returning IUR tree

**Code to Generate:**
```elixir
@impl true
def view(state) do
  %UnifiedUi.IUR.Layouts.VBox{
    id: :main,
    spacing: 1,
    children: [
      %UnifiedUi.IUR.Widgets.Text{
        content: "Welcome, #{state.username}!",  # Interpolated
        id: :greeting
      },
      %UnifiedUi.IUR.Widgets.Button{
        label: "Click Me",
        on_click: :button_clicked,
        id: :my_button
      }
    ]
  }
end
```

**State Interpolation:**
- Parse DSL content for `@state.field` patterns
- Replace with `Map.get(state, :field)` calls
- Support nested access: `@state.user.name`

**Test:** Create DSL with UI tree, verify view/1 returns correct IUR

---

### Step 5: Register Transformers in Extension (15 min)

**File:** `lib/unified_ui/dsl/extension.ex`

**Changes:**
1. Add `transformers:` key to `use Spark.Dsl.Extension`
2. Order transformers: init, update, view
3. Add `@behaviour UnifiedUi.ElmArchitecture` to generated code

```elixir
use Spark.Dsl.Extension,
  sections: [...],
  transformers: [
    UnifiedUi.Dsl.Transformers.InitTransformer,
    UnifiedUi.Dsl.Transformers.UpdateTransformer,
    UnifiedUi.Dsl.Transformers.ViewTransformer
  ],
  verifiers: []
```

---

### Step 6: Add DSL Options for State and Handlers (15 min)

**File:** `lib/unified_ui/dsl/sections/ui.ex`

**Add to ui section schema:**
```elixir
state: [
  type: :keyword_list,
  doc: "Initial state for the component (atom-keyed keyword list)",
  required: false
]

# Signal handlers will be added as entities in Phase 1.6
```

---

### Step 7: Write Tests (60 min)

**File:** `test/unified_ui/dsl/transformers/elm_arch_test.exs`

**Test Cases:**
1. Init transformer generates init/1 with correct state
2. Update transformer generates update/2 with pattern matching
3. View transformer generates view/1 returning IUR
4. State interpolation works correctly
5. Generated module adopts ElmArchitecture behaviour
6. Full integration: DSL component with all three transformers

---

### Step 8: Create Example Component (15 min)

**File:** `examples/elm_arch_component.ex`

Create a working example demonstrating:
- DSL with state, signal handlers, and UI tree
- Generated init/update/view functions
- State interpolation in action

---

## Current Status

**Last Updated:** 2026-02-04 (Planning Phase)

### What Works
- Branch created: `feature/phase-1.5-elm-transformers`
- Spark.Dsl.Transformer patterns researched
- Existing codebase analyzed (IUR, DSL structure)

### What's Next
1. Create UnifiedUi.ElmArchitecture behaviour
2. Implement init_transformer
3. Implement update_transformer
4. Implement view_transformer
5. Register transformers in extension
6. Write comprehensive tests
7. Create example component

### How to Run Tests (when implemented)
```bash
# Run all tests
mix test

# Run transformer-specific tests
mix test test/unified_ui/dsl/transformers/elm_arch_test.exs

# Compile with DSL example
mix compile
```

---

## Notes/Considerations

### State Interpolation Approach

**Option A: String Parsing** (Simpler, Phase 1.5)
- Parse strings for `@state.field` patterns
- Replace with `Map.get(state, :field)` in generated code
- Limited to string interpolation

**Option B: AST-based** (More powerful, future phase)
- Use Elixir AST manipulation
- Support arbitrary expressions with state access
- More complex implementation

**Decision:** Start with Option A for Phase 1.5, upgrade to Option B if needed

### Signal Handler Storage

Signal handlers need to be stored in DSL entities. Options:
1. Add `handlers` entity to signals section
2. Add inline handler attributes to widget entities
3. Separate `update` section for handler definitions

**Decision:** Use inline `on_click`, `on_change` attributes on widgets (natural API)

### Unknown Signal Handling

When update/2 receives an unrecognized signal:
- Return state unchanged (silently ignore)
- Log warning
- Raise error

**Decision:** Return state unchanged with optional compile-time warning for debug

### Future Enhancements

1. **Phase 1.6:** Jido.Agent.Server integration (run components as agents)
2. **Phase 2:** Widget entities with signal handler attributes
3. **Phase 3:** Optimized view generation (memoization, dirty tracking)
4. **Phase 4:** Advanced state interpolation (computed properties, derivations)

---

## Dependencies

**This phase depends on:**
- Phase 1.1 (Project Initialization) - Complete
- Phase 1.2 (Spark DSL Extension) - Complete
- Phase 1.3 (IUR Design) - Complete
- Phase 1.4 (Signals) - Complete

**Phases that depend on this:**
- Phase 1.6 (Jido Agent Integration) - Uses generated Elm Architecture
- Phase 2 (Core Widgets) - Uses view transformer for rendering
- Phase 3 (Renderer Implementations) - Consumes IUR from view/1
