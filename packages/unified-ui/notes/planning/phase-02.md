# Phase 2: Core Widgets & Layouts

This phase implements the core widget entities and layout containers that form the building blocks of any UI. These widgets and layouts are defined once in the DSL and work across all platforms through the IUR and adapter system.

---

## 2.1 Basic Widget Entities

- [x] **Task 2.1** Define Spark.Dsl.Entity structs for core widgets

Create entity definitions for the foundational widgets: button, text, label, and text_input.

- [x] 2.1.1 Create `lib/unified_ui/dsl/entities/widgets.ex`
- [x] 2.1.2 Define `@button_entity` with schema:
  - args: `[:label]`
  - options: `id`, `on_click`, `disabled`, `style`, `visible`
- [x] 2.1.3 Define `@text_entity` with schema:
  - args: `[:content]`
  - options: `id`, `style`, `visible`
- [x] 2.1.4 Define `@label_entity` with schema:
  - args: `[:for, text]`
  - options: `id`, `style`, `visible`
- [x] 2.1.5 Define `@text_input_entity` with schema:
  - args: `[:id]`
  - options: `value`, `placeholder`, `type`, `on_change`, `on_submit`, `disabled`, `style`, `visible`
- [x] 2.1.6 Create corresponding target structs:
  - `UnifiedUi.Widgets.Button`
  - `UnifiedUi.Widgets.Text`
  - `UnifiedUi.Widgets.Label`
  - `UnifiedUi.Widgets.TextInput`
- [x] 2.1.7 Create corresponding IUR structs
- [x] 2.1.8 Add comprehensive `@doc` strings to each entity

**Implementation Notes:**
- `on_click` accepts: atom (signal name), `{atom, payload}`, or `fn -> ... end`
- `on_change` for text_input receives new value as argument
- Target structs store parsed DSL values for later use

**Unit Tests for Section 2.1:**
- [x] Test button entity with required label argument
- [x] Test button entity with all optional options
- [x] Test text entity with content argument
- [x] Test label entity with for and text arguments
- [x] Test text_input entity with required id argument
- [x] Test text_input with different type options
- [x] Test on_click accepts various formats
- [x] Verify target structs are created correctly

---

## 2.2 Basic Layout Entities

- [x] **Task 2.2** Define Spark.Dsl.Entity structs for basic layout containers

Create entity definitions for the foundational layout containers: vbox (vertical box) and hbox (horizontal box).

- [x] 2.2.1 Create `lib/unified_ui/dsl/entities/layouts.ex`
- [x] 2.2.2 Define `@vbox_entity` with schema:
  - args: `[:children]`
  - options: `id`, `spacing`, `padding`, `align_items`, `justify_content`, `style`, `visible`
- [x] 2.2.3 Define `@hbox_entity` with schema:
  - args: `[:children]`
  - options: `id`, `spacing`, `padding`, `align_items`, `justify_content`, `style`, `visible`
- [x] 2.2.4 Create corresponding target structs:
  - `UnifiedUi.Layouts.VBox`
  - `UnifiedUi.Layouts.HBox`
- [x] 2.2.5 Create corresponding IUR structs
- [x] 2.2.6 Define `align_items` values: `:start`, `:center`, `:end`, `:stretch`
- [x] 2.2.7 Define `justify_content` values: `:start`, `:center`, `:end`, `:space_between`, `:space_around`
- [x] 2.2.8 Add comprehensive `@doc` strings with examples

**Implementation Notes:**
- Children argument accepts list of widget/layout atoms or nested definitions
- `spacing` is platform-dependent unit
- Layout entities are recursive (can contain other layouts)

**Unit Tests for Section 2.2:**
- [x] Test vbox entity with children list
- [x] Test hbox entity with children list
- [x] Test vbox with nested layouts
- [x] Test hbox with nested layouts
- [x] Test spacing option
- [x] Test padding option
- [x] Test align_items option with all valid values
- [x] Test justify_content option with all valid values
- [x] Test invalid align_items value raises error
- [x] Verify target structs store children correctly

---

## 2.3 Widget State Integration

- [x] **Task 2.3** Implement state management for widgets in the Elm Architecture

Update the Elm Architecture transformers to properly handle widget state and state interpolation.

- [x] 2.3.1 Update `init_transformer` to extract widget initial state
- [x] 2.3.2 Update `view_transformer` to interpolate state into widget properties
- [x] 2.3.3 Implement state binding for text_input (value binding)
- [x] 2.3.4 Implement state binding for disabled attribute
- [x] 2.3.5 Implement state binding for visible attribute
- [x] 2.3.6 Add state update helpers for common patterns

**Implementation Notes:**
- State values referenced as `{:state, :key}` in DSL
- View transformer replaces references with actual state values
- Common patterns: increment, toggle, set value

**Unit Tests for Section 2.3:**
- [x] Test widget state initializes correctly
- [x] Test state interpolation in view works
- [x] Test text_input value binding
- [x] Test disabled state binding
- [x] Test visible state binding
- [x] Test state update helpers work

---

## 2.4 Signal Wiring

- [x] **Task 2.4** Implement signal wiring for widget events

Connect widget event handlers to the signal system for inter-component communication.

- [x] 2.4.1 Update `update_transformer` to generate signal handler clauses
- [x] 2.4.2 Implement on_click signal emission
- [x] 2.4.3 Implement on_change signal emission with payload
- [x] 2.4.4 Implement on_submit signal emission
- [x] 2.4.5 Add signal payload extraction helpers
- [x] 2.4.6 Test signal routing to component agents

**Implementation Notes:**
- Signal handlers generate JidoSignal envelopes
- Payload includes event data (e.g., input value, coordinates)
- Signals dispatched via Jido.Agent.Server

**Unit Tests for Section 2.4:**
- [x] Test on_click emits correct signal
- [x] Test on_change emits signal with payload
- [x] Test on_submit emits signal with form data
- [x] Test signal reaches target agent
- [x] Test signal payload is correct

---

## 2.5 IUR Tree Building

- [x] **Task 2.5** Implement IUR tree building from DSL definitions

Create the system that traverses the DSL definition and builds the corresponding IUR tree.

- [x] 2.5.1 Create `lib/unified_ui/iur/builder.ex`
- [x] 2.5.2 Implement `build/1` function that traverses DSL state
- [x] 2.5.3 Implement widget-to-IUR conversion for all basic widgets
- [x] 2.5.4 Implement layout-to-IUR conversion for all basic layouts
- [x] 2.5.5 Handle nested structures recursively
- [x] 2.5.6 Apply style resolution during build
- [x] 2.5.7 Validate IUR tree structure

**Implementation Notes:**
- Builder uses Spark.Dsl.Extension.get_entities to read DSL
- Each entity type has corresponding build function
- Recursion handles arbitrary nesting depth
- Styles resolved and merged during build

**Unit Tests for Section 2.5:**
- [x] Test build creates correct IUR for single widget
- [x] Test build creates correct IUR for nested layouts
- [x] Test build handles deeply nested structures
- [x] Test build applies styles correctly
- [x] Test build validates structure

---

## 2.6 Enhanced Verifiers

- [x] **Task 2.6** Enhance verifiers for core widgets and layouts

Update and expand verifiers to handle validation of the new widget and layout entities.

- [x] 2.6.1 Update `unique_id_verifier` to handle all widgets
- [x] 2.6.2 Add `layout_structure_verifier` for layout validation
- [x] 2.6.3 Add `signal_handler_verifier` for signal reference validation
- [x] 2.6.4 Add `style_reference_verifier` for style name validation
- [x] 2.6.5 Add `state_reference_verifier` for state key validation
- [x] 2.6.6 Improve error messages with specific locations

**Implementation Notes:**
- Verifiers run after transformers
- Provide clear, actionable error messages
- Include file and line number in errors

**Unit Tests for Section 2.6:**
- [x] Test unique_id_verifier catches duplicate IDs
- [x] Test layout_structure_verifier catches invalid nesting
- [x] Test signal_handler_verifier catches undefined signals
- [x] Test style_reference_verifier catches undefined styles
- [x] Test state_reference_verifier catches invalid state keys

---

## 2.7 Form Support

- [x] **Task 2.7** Add basic form support for input widgets

Create the foundational pieces for form handling with input widgets.

- [x] 2.7.1 Define form association attributes for text_input
- [x] 2.7.2 Add form_id option to input widgets
- [x] 2.7.3 Implement form data collection helpers
- [x] 2.7.4 Add form submission signal helpers
- [x] 2.7.5 Create basic form validation helpers

**Implementation Notes:**
- Forms group inputs by form_id
- Submission collects all input values
- Validation runs before submit signal

**Unit Tests for Section 2.7:**
- [x] Test inputs can be associated with form
- [x] Test form submission collects all values
- [x] Test form validation works
- [x] Test form submit signal includes form data

---

## 2.8 Style System Foundation

- [x] **Task 2.8** Create the foundational style system

Implement the basic style system that will be expanded in later phases.

- [x] 2.8.1 Define `@style_entity` with schema:
  - args: `[:name]`
  - options: `attributes`, `extends`
- [x] 2.8.2 Create `UnifiedUi.Styles.Style` target struct
- [x] 2.8.3 Create IUR style struct
- [x] 2.8.4 Define base style attributes:
  - `fg` - foreground color
  - `bg` - background color
  - `attrs` - list of attributes (:bold, :italic, :underline)
- [x] 2.8.5 Create style resolver module
- [x] 2.8.6 Implement style merge function
- [x] 2.8.7 Add inline style support (keyword list)

**Implementation Notes:**
- Styles can extend other styles for inheritance
- Inline styles merged with named styles
- Platform-specific rendering handled by renderers

**Unit Tests for Section 2.8:**
- [x] Test style entity with attributes
- [x] Test style entity with extends
- [x] Test style resolver works
- [x] Test style merge works
- [x] Test inline styles apply correctly
- [x] Test style inheritance works

---

## 2.9 DSL Module

- [x] **Task 2.9** Create the main DSL module for users

Create the primary `UnifiedUi.Dsl` module that developers will use in their UI definitions.

- [x] 2.9.1 Create `lib/unified_ui/dsl/dsl.ex`
- [x] 2.9.2 Add `use Spark.Dsl` with default extensions
- [x] 2.9.3 Import all DSL entities
- [x] 2.9.4 Add `@moduledoc` with usage examples
- [x] 2.9.5 Add `@before_compile` hook for code generation
- [x] 2.9.6 Test DSL can be used in a module

**Implementation Notes:**
- This is the main entry point for users
- All entities imported for convenience
- Before_compile triggers transformers

**Unit Tests for Section 2.9:**
- [x] Test DSL module compiles
- [x] Test DSL can be used in a user module
- [x] Test all entities are available
- [x] Test example UI definition works

---

## 2.10 Phase 2 Integration Tests

Comprehensive integration tests to verify all core widgets and layouts work together correctly.

- [x] 2.10.1 Test complete UI with all basic widgets
- [x] 2.10.2 Test nested layouts (5+ levels deep)
- [x] 2.10.3 Test state updates flow through widgets
- [x] 2.10.4 Test signal emission and handling
- [x] 2.10.5 Test form submission works
- [x] 2.10.6 Test style application to all widgets
- [x] 2.10.7 Test IUR tree builds correctly
- [x] 2.10.8 Test verifiers catch all invalid configurations
- [x] 2.10.9 Test complex example UI (50+ elements)

**Implementation Notes:**
- Create comprehensive example UI
- Test all widget types
- Test all layout combinations
- Test state and signal flows

**Unit Tests for Section 2.10:**
- [x] Test example UI compiles
- [x] Test all widgets render to IUR correctly
- [x] Test state changes propagate
- [x] Test signals route correctly
- [x] Test styles apply correctly
- [x] Test validation catches errors

---

## Success Criteria

1. **Widget Entities**: All basic widgets defined in DSL
2. **Layout Entities**: VBox and HBox layouts defined
3. **State Management**: Widget state integrates with Elm Architecture
4. **Signal Wiring**: Widget events emit signals correctly
5. **IUR Building**: DSL definitions build correct IUR trees
6. **Validation**: Enhanced verifiers catch widget/layout errors
7. **Forms**: Basic form support works
8. **Styles**: Foundational style system in place
9. **DSL Module**: Users can write UI definitions
10. **Test Coverage**: 80%+ coverage for all new code

---

## Critical Files

**New Files:**
- `lib/unified_ui/dsl/entities/widgets.ex` - Basic widget entities
- `lib/unified_ui/dsl/entities/layouts.ex` - Basic layout entities
- `lib/unified_ui/widgets/` - Widget target structs
- `lib/unified_ui/layouts/` - Layout target structs
- `lib/unified_ui/iur/widgets.ex` - IUR widget structs
- `lib/unified_ui/iur/layouts.ex` - IUR layout structs
- `lib/unified_ui/iur/builder.ex` - IUR tree builder
- `lib/unified_ui/dsl/transformers/elm_arch.ex` - Updated Elm Architecture transformers
- `lib/unified_ui/dsl/transformers/verifiers.ex` - Enhanced verifiers
- `lib/unified_ui/styles/` - Style system
- `lib/unified_ui/dsl/dsl.ex` - Main DSL module
- `test/unified_ui/integration/phase2_test.exs` - Integration tests

**Modified Files:**
- `lib/unified_ui/dsl/extension.ex` - Add new sections and entities
- `lib/unified_ui/info.ex` - Regenerated with new entities

---

## Dependencies

**Depends on:**
- Phase 1: Foundation (DSL structure, IUR, signals, Elm Architecture)

**Enables:**
- Phase 3: Renderer Implementations (widgets and layouts to render)
- Phase 4: Advanced Features & Styling (base to expand upon)
