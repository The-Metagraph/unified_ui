# Phase 1: Architecture Validation

This phase establishes the core architectural foundations of DesktopUI in pure Elixir, proving the Elm Architecture pattern works effectively for desktop UI components before introducing the complexity of C/NIFs. We will build a skeletal but functional runtime system with a mock renderer to validate component lifecycles, state management, and the declarative UI model.

---

## 1.1 Elm Behaviour Definition

Define the contract that all UI components must implement, following the Elm Architecture pattern (TEA). This behaviour provides the foundation for predictable state management and unidirectional data flow.

- [ ] **Task 1.1** Create `DesktopUI.Elm` behaviour module

Define the three core callbacks that components must implement:

- [ ] 1.1.1 Define `init/1` callback specification - receives options, returns `{initial_state, initial_commands}`
- [ ] 1.1.2 Define `update/2` callback specification - receives message and state, returns `{new_state, commands}`
- [ ] 1.1.3 Define `view/1` callback specification - receives state, returns `ui_element()` structure
- [ ] 1.1.4 Define `ui_element()` type specification - recursive structure for UI trees
- [ ] 1.1.5 Define `command()` type specification - structured side effect representation

**Implementation Notes:**
- Use `@callback` directive for each function specification
- Include `@type` definitions for `ui_element()` and `command()`
- Provide `__using__/1` macro to scaffold boilerplate for component modules
- Include optional `@impl true` annotations for better Dialyzer support
- Document each callback with clear examples in module documentation

**Unit Tests for Section 1.1:**
- [ ] 1.1.1 Verify behaviour is defined with correct callback specifications
- [ ] 1.1.2 Verify `use DesktopUI.Elm` generates required function stubs
- [ ] 1.1.3 Verify `ui_element()` type compiles correctly
- [ ] 1.1.4 Verify `command()` type compiles correctly
- [ ] 1.1.5 Verify Dialyzer type checking passes for behaviour module

---

## 1.2 Widget Construction DSL

Create the declarative widget system that components use to build their UI trees. These are pure data structures, not renderers— they describe what to render, not how.

- [ ] **Task 1.2** Create `DesktopUI.Widget` module and widget constructors

Define the core widget data structure and helper functions:

- [ ] 1.2.1 Define `DesktopUI.Widget` struct with `:type`, `:id`, `:props`, `:children` fields
- [ ] 1.2.2 Create `label/2` helper function - text string and optional props
- [ ] 1.2.3 Create `button/3` helper function - text, on_click message, and optional props
- [ ] 1.2.4 Create `container/3` helper function - type (`:vbox`, `:hbox`), children list, and props
- [ ] 1.2.5 Define `@type` specifications for all widget constructors
- [ ] 1.2.6 Add validation functions for widget structure integrity

**Implementation Notes:**
- Widget structs should be serializable and comparable
- Use keyword lists or maps for props to allow flexible properties
- Support nested widgets through the `:children` field
- Include optional `:id` field for event targeting and debugging
- Consider using `@enforce_keys` for required fields
- Props should support common attributes like `:width`, `:height`, `:spacing`, `:padding`

**Unit Tests for Section 1.2:**
- [ ] 1.2.1 Verify widget struct creation with all fields
- [ ] 1.2.2 Verify `label/2` creates correct widget structure
- [ ] 1.2.3 Verify `button/3` creates correct widget with on_click property
- [ ] 1.2.4 Verify `container/3` supports both :vbox and :hbox types
- [ ] 1.2.5 Verify nested widgets through children field
- [ ] 1.2.6 Verify widget validation catches invalid structures
- [ ] 1.2.7 Verify widget equality comparison works correctly

---

## 1.3 DesktopUI.Runtime GenServer

Build the central orchestrator that manages component lifecycle, event dispatch, and render triggering. This is the heart of the application that drives the Elm Architecture loop.

- [ ] **Task 1.3** Create `DesktopUI.Runtime` GenServer

Implement the core runtime process:

- [ ] 1.3.1 Define `child_spec/1` for OTP supervision integration
- [ ] 1.3.2 Implement `init/1` - initialize with root component module and options
- [ ] 1.3.3 Implement state structure holding component state, UI tree, and renderer module
- [ ] 1.3.4 Create `start_link/2` function to start the runtime with a root component
- [ ] 1.3.5 Implement component initialization by calling root component's `init/1`
- [ ] 1.3.6 Add `handle_info/2` for event loop messages
- [ ] 1.3.7 Add `handle_call/3` for synchronous queries (get_state, etc.)

**Implementation Notes:**
- Use a struct for runtime state (component_module, component_state, ui_tree, renderer)
- Store renderer module as dependency injection for testing
- Implement backoff/restart logic for robustness
- Include logging for lifecycle events (init, state change, render)
- Support dynamic component swapping for hot code reloading
- Include a registry or name registration for discovery

**Unit Tests for Section 1.3:**
- [ ] 1.3.1 Verify runtime starts successfully with valid component module
- [ ] 1.3.2 Verify runtime calls component's `init/1` on startup
- [ ] 1.3.3 Verify runtime stores initial component state
- [ ] 1.3.4 Verify runtime handles synchronous state queries
- [ ] 1.3.5 Verify runtime terminates cleanly on shutdown
- [ ] 1.3.6 Verify runtime logs appropriate lifecycle events

---

## 1.4 Event Processing Loop

Implement the event-driven core that translates external events into component messages and triggers re-renders when state changes.

- [ ] **Task 1.4** Implement event processing and state update cycle

Create the Elm update-render loop:

- [ ] 1.4.1 Create `dispatch_event/2` function to send events to component
- [ ] 1.4.2 Implement state update by calling component's `update/2`
- [ ] 1.4.3 Store new state when `update/2` returns changed state
- [ ] 1.4.4 Detect state changes to trigger re-render (dirty checking)
- [ ] 1.4.5 Queue render requests when state changes
- [ ] 1.4.6 Implement command processing from `update/2` return value

**Implementation Notes:**
- Use `handle_info` for async event dispatch
- Implement debounce/throttle for rapid state changes
- Support both direct messages and signal-based events (future Jido integration)
- Commands should be executed after state update
- Render requests should be batchable
- Include timeout for event processing to prevent blocking

**Unit Tests for Section 1.4:**
- [ ] 1.4.1 Verify event dispatch calls component's `update/2`
- [ ] 1.4.2 Verify state is updated after `update/2` returns new state
- [ ] 1.4.3 Verify render is triggered when state changes
- [ ] 1.4.4 Verify render is NOT triggered when state is unchanged
- [ ] 1.4.5 Verify multiple rapid events are batched appropriately
- [ ] 1.4.6 Verify commands returned from `update/2` are processed
- [ ] 1.4.7 Verify event loop continues after errors (with logging)

---

## 1.5 Mock Renderer

Create a test double renderer that validates UI trees without actually drawing anything. This proves the rendering pipeline works before we have real graphics.

- [ ] **Task 1.5** Create `DesktopUI.Renderer.Mock` module

Implement a validating renderer:

- [ ] 1.5.1 Define `render/2` function that accepts UI tree and state
- [ ] 1.5.2 Validate UI tree structure (well-formedness check)
- [ ] 1.5.3 Record render calls for test assertions
- [ ] 1.5.4 Support widget introspection for debugging
- [ ] 1.5.5 Return success/failure status
- [ ] 1.5.6 Provide a "screenshot" function returning tree as readable text

**Implementation Notes:**
- Store render history in agent or ETS for test verification
- Return `:ok` or `{:error, reason}` tuple
- Text representation should be indented hierarchy
- Include widget type and key props in text output
- Support render count tracking for optimization testing
- Should be thread-safe for concurrent test access

**Unit Tests for Section 1.5:**
- [ ] 1.5.1 Verify mock render accepts valid UI tree
- [ ] 1.5.2 Verify mock render rejects invalid UI tree
- [ ] 1.5.3 Verify render history is recorded correctly
- [ ] 1.5.4 Verify text representation shows widget hierarchy
- [ ] 1.5.5 Verify render count tracking works
- [ ] 1.5.6 Verify multiple renders are recorded sequentially

---

## 1.6 Runtime-Renderer Integration

Wire the Runtime to use the Renderer, completing the update-view-render cycle.

- [ ] **Task 1.6** Connect Runtime to Mock Renderer

Complete the rendering pipeline:

- [ ] 1.6.1 Call component's `view/1` to get UI tree on state change
- [ ] 1.6.2 Pass UI tree to renderer module
- [ ] 1.6.3 Handle renderer errors gracefully
- [ ] 1.6.4 Store current UI tree in runtime state
- [ ] 1.6.5 Support manual render trigger (force redraw)
- [ ] 1.6.6 Support renderer hot-swapping for development

**Implementation Notes:**
- Renderer module should be configurable in runtime options
- Cache UI tree to avoid redundant `view/1` calls
- Log render failures with full context for debugging
- Consider a "dry run" mode for testing
- Support render callbacks/hooks for extensibility
- Include timing metrics for performance monitoring

**Unit Tests for Section 1.6:**
- [ ] 1.6.1 Verify `view/1` is called on component after state change
- [ ] 1.6.2 Verify UI tree is passed to renderer
- [ ] 1.6.3 Verify renderer errors are caught and logged
- [ ] 1.6.4 Verify current UI tree is stored in runtime state
- [ ] 1.6.5 Verify force render triggers `view/1` and renderer
- [ ] 1.6.6 Verify renderer can be hot-swapped at runtime

---

## 1.7 Example Counter Component

Build a complete working example component demonstrating the entire architecture.

- [ ] **Task 1.7** Create `DesktopUI.Examples.Counter` component

Implement a classic counter component:

- [ ] 1.7.1 Define component with `use DesktopUI.Elm`
- [ ] 1.7.2 Implement `init/1` returning initial count of 0
- [ ] 1.7.3 Implement `update/2` handling `:increment`, `:decrement`, `:reset` messages
- [ ] 1.7.4 Implement `view/1` returning label and button widgets
- [ ] 1.7.5 Include quit button with `:quit` message
- [ ] 1.7.6 Demonstrate nested container (vbox with hbox for buttons)

**Implementation Notes:**
- Keep it simple but representative of real components
- Use integer state for count
- Show spacing and padding props in action
- Demonstrate button on_click message binding
- Include comments explaining each callback's purpose
- Make it readable as documentation/example

**Unit Tests for Section 1.7:**
- [ ] 1.7.1 Verify counter initializes with count of 0
- [ ] 1.7.2 Verify `:increment` message increases count by 1
- [ ] 1.7.3 Verify `:decrement` message decreases count by 1
- [ ] 1.7.4 Verify `:reset` message sets count to 0
- [ ] 1.7.5 Verify `view/1` returns valid UI tree with all widgets
- [ ] 1.7.6 Verify UI tree structure matches expected hierarchy

---

## 1.8 Phase 1 Integration Tests

Comprehensive integration tests verifying all Phase 1 components work together correctly.

- [ ] **Task 1.8** Create end-to-end integration test suite

Verify the complete Elm Architecture loop:

- [ ] 1.8.1 Test full lifecycle: init → update → view → render
- [ ] 1.8.2 Test Counter component through Runtime with Mock Renderer
- [ ] 1.8.3 Test multiple state changes in sequence
- [ ] 1.8.4 Test state unchanged skips render
- [ ] 1.8.5 Test command processing from update
- [ ] 1.8.6 Test error handling in component callbacks
- [ ] 1.8.7 Test concurrent event dispatch
- [ ] 1.8.8 Test runtime shutdown and cleanup

**Implementation Notes:**
- Use ExUnit's async: false for tests involving named processes
- Clean up any registered processes between tests
- Use timeout to catch hangs in event loop
- Include performance benchmarks (render time, state update time)
- Test should verify mock renderer received expected calls
- Use setup/callbacks for consistent test environment

**Actual Test Coverage:**
- Runtime lifecycle: 3 tests
- Event processing: 4 tests
- Render triggering: 3 tests
- Component behavior: 5 tests
- Error handling: 3 tests

**Total: 18 integration tests**

---

## Success Criteria

1. **Behaviour Complete**: `DesktopUI.Elm` behaviour is fully defined and compiles with Dialyzer
2. **Runtime Functional**: Counter component runs through full lifecycle (init, update, view, render) with mock renderer
3. **Test Coverage**: Unit test coverage >80% for all new modules
4. **Documentation**: All modules have @moduledoc with examples
5. **Clean Architecture**: Clear separation between behaviour, runtime, renderer, and components

---

## Critical Files

**New Files:**
- `lib/desktop_ui/elm.ex` - Elm behaviour definition
- `lib/desktop_ui/widget.ex` - Widget struct and constructors
- `lib/desktop_ui/runtime.ex` - Runtime GenServer
- `lib/desktop_ui/renderer/mock.ex` - Mock renderer for testing
- `lib/desktop_ui/examples/counter.ex` - Example counter component
- `test/desktop_ui/elm_test.exs` - Behaviour unit tests
- `test/desktop_ui/widget_test.exs` - Widget unit tests
- `test/desktop_ui/runtime_test.exs` - Runtime unit tests
- `test/desktop_ui/renderer/mock_test.exs` - Mock renderer tests
- `test/desktop_ui/examples/counter_test.exs` - Counter component tests
- `test/integration/phase_1_integration_test.exs` - Integration tests

**Dependencies:**
- None (pure Elixir, no external dependencies)

---

## Dependencies

**This phase has no dependencies** - it establishes the foundational architecture.

**Phases that depend on this phase:**
- Phase 2: The Graphics Bridge (depends on Runtime, Elm behaviour, Widget DSL)
- Phase 3: First Real Widget (depends on all Phase 1 components)
