# Phase 2: The Graphics Bridge

This phase builds the critical bridge between Elixir and native graphics through SDL2 NIFs. We create a minimal but functional graphics API that enables real window creation, basic drawing, and event handling. This phase introduces C code and the complexities of BEAM-C integration, establishing the foundation for all future rendering capabilities.

---

## 2.1 C NIF Foundation

Set up the build infrastructure and basic NIF scaffolding for C integration with BEAM.

- [ ] **Task 2.1** Create NIF build infrastructure

Establish C compilation and linking:

- [ ] 2.1.1 Create `c_src/` directory for C source files
- [ ] 2.1.2 Create `c_src/desktop_ui_nif.c` - main NIF implementation file
- [ ] 2.1.3 Update `mix.exs` with `:erlc_make` compiler for C code
- [ ] 2.1.4 Add `Makefile` for compiling NIF shared library
- [ ] 2.1.5 Configure NIF loading in `DesktopUI.Graphics` module
- [ ] 2.1.6 Add SDL2 dependency detection in build system
- [ ] 2.1.7 Implement basic NIF initialization stub

**Implementation Notes:**
- Use `ERL_NIF_INIT` macro for NIF entry point
- Create separate functions for each platform (Linux, macOS, Windows)
- Support pkg-config for SDL2 discovery on Linux
- Provide clear error messages if SDL2 is not found
- Include thread-local storage for resource management
- Add defensive coding to prevent BEAM crashes

**Unit Tests for Section 2.1:**
- [ ] 2.1.1 Verify NIF library compiles successfully
- [ ] 2.1.2 Verify NIF loads without errors in Elixir
- [ ] 2.1.3 Verify build works on target platform
- [ ] 2.1.4 Verify helpful error message when SDL2 missing
- [ ] 2.1.5 Verify NIF cleanup on unload

---

## 2.2 SDL2 Initialization and Window Management

Implement the core SDL2 functions for creating and managing windows.

- [ ] **Task 2.2** Implement window management NIFs

Create window creation and management functions:

- [ ] 2.2.1 Implement `sdl_init/0` - Initialize SDL2 video subsystem
- [ ] 2.2.2 Implement `create_window/4` - title, width, height, flags
- [ ] 2.2.3 Implement `destroy_window/1` - cleanup window resources
- [ ] 2.2.4 Implement `get_window_size/1` - query current dimensions
- [ ] 2.2.5 Implement `set_window_size/3` - resize window
- [ ] 2.2.6 Implement `set_window_title/2` - update window title
- [ ] 2.2.7 Add resource tracking for window lifecycle

**Implementation Notes:**
- Return window reference as opaque resource (not raw pointer)
- Use SDL_WINDOW_RESIZABLE flag for flexibility
- Track all windows for cleanup on shutdown
- Convert SDL return codes to Elixir-friendly tuples
- Support multiple windows for future use
- Include error strings from SDL for debugging

**Unit Tests for Section 2.2:**
- [ ] 2.2.1 Verify SDL2 initializes without errors
- [ ] 2.2.2 Verify window creates with specified dimensions
- [ ] 2.2.3 Verify window destroys cleanly
- [ ] 2.2.4 Verify get_window_size returns correct dimensions
- [ ] 2.2.5 Verify set_window_size resizes window
- [ ] 2.2.6 Verify set_window_title updates title
- [ ] 2.2.7 Verify multiple windows can coexist
- [ ] 2.2.8 Verify destroying invalid window returns error

---

## 2.3 Renderer and Drawing Primitives

Implement the core drawing functions for rendering shapes to the window.

- [ ] **Task 2.3** Implement basic drawing NIFs

Create rendering and drawing primitives:

- [ ] 2.3.1 Implement `create_renderer/1` - create SDL2 renderer for window
- [ ] 2.3.2 Implement `destroy_renderer/1` - cleanup renderer resources
- [ ] 2.3.3 Implement `set_render_draw_color/5` - set RGBA color
- [ ] 2.3.4 Implement `clear_render/1` - fill with current draw color
- [ ] 2.3.5 Implement `draw_rect/6` - outline rectangle (x, y, w, h, window_id, color)
- [ ] 2.3.6 Implement `fill_rect/6` - filled rectangle
- [ ] 2.3.7 Implement `present_render/1` - swap buffers (display frame)
- [ ] 2.3.8 Add renderer resource tracking

**Implementation Notes:**
- Use SDL_RENDERER_ACCELERATED flag for hardware acceleration
- Support SDL_RENDERER_PRESENTVSYNC for smooth animation
- Color should be {r, g, b, a} tuple (0-255 each)
- Return error tuples if renderer/window not found
- Batch drawing calls when possible for performance
- Include bounds checking for coordinates

**Unit Tests for Section 2.3:**
- [ ] 2.3.1 Verify renderer creates for valid window
- [ ] 2.3.2 Verify renderer destroys cleanly
- [ ] 2.3.3 Verify set_render_draw_color sets color
- [ ] 2.3.4 Verify clear_render fills window with color
- [ ] 2.3.5 Verify draw_rect draws outline
- [ ] 2.3.6 Verify fill_rect draws filled rectangle
- [ ] 2.3.7 Verify present_render displays content
- [ ] 2.3.8 Verify drawing with invalid resource returns error

---

## 2.4 Event Polling and Translation

Implement the event system that captures OS input and translates it to Elixir terms.

- [ ] **Task 2.4** Implement event polling NIFs

Create event handling functions:

- [ ] 2.4.1 Implement `poll_event/0` - non-blocking event poll
- [ ] 2.4.2 Implement `wait_event/1` - blocking event poll with timeout
- [ ] 2.4.3 Translate SDL_QUIT to `{:quit}` tuple
- [ ] 2.4.4 Translate SDL_MOUSEBUTTONDOWN to `{:mouse_button_down, button, x, y}`
- [ ] 2.4.5 Translate SDL_MOUSEBUTTONUP to `{:mouse_button_up, button, x, y}`
- [ ] 2.4.6 Translate SDL_MOUSEMOTION to `{:mouse_motion, x, y, xrel, yrel}`
- [ ] 2.4.7 Translate SDL_KEYDOWN to `{:key_down, keycode, mod}`
- [ ] 2.4.8 Translate SDL_KEYUP to `{:key_up, keycode, mod}`
- [ ] 2.4.9 Translate SDL_WINDOWEVENT to `{:window_event, event_id}`

**Implementation Notes:**
- Use `SDL_PollEvent` for non-blocking, `SDL_WaitEventTimeout` for blocking
- Return `:no_event` when no events pending
- Map SDL keycodes to Elixir atoms (e.g., `:key_a`, `:key_escape`)
- Include modifier state (shift, ctrl, alt) in keyboard events
- Window events should include resize, focus gain/loss
- Ensure event structs are small and copyable

**Unit Tests for Section 2.4:**
- [ ] 2.4.1 Verify poll_event returns :no_event when idle
- [ ] 2.4.2 Verify poll_event returns event after user action
- [ ] 2.4.3 Verify quit event translates correctly
- [ ] 2.4.4 Verify mouse click event includes correct coordinates
- [ ] 2.4.5 Verify mouse motion includes relative coordinates
- [ ] 2.4.6 Verify key press includes keycode and modifiers
- [ ] 2.4.7 Verify window resize event translates correctly
- [ ] 2.4.8 Verify wait_event times out correctly

---

## 2.5 DesktopUI.Graphics API Wrapper

Create the Elixir wrapper module that provides a clean, safe API over the NIFs.

- [ ] **Task 2.5** Implement `DesktopUI.Graphics` Elixir module

Create the public graphics API:

- [ ] 2.5.1 Create `init/0` - initialize SDL2 subsystem
- [ ] 2.5.2 Create `create_window/4` - title, width, height, options
- [ ] 2.5.3 Create `destroy_window/1` - cleanup window
- [ ] 2.5.4 Create `clear/2` - window_id, color
- [ ] 2.5.5 Create `draw_rect/6` - window_id, x, y, w, h, color
- [ ] 2.5.6 Create `fill_rect/6` - window_id, x, y, w, h, color
- [ ] 2.5.7 Create `poll_event/0` - get next event or :no_event
- [ ] 2.5.8 Create `present/1` - display the rendered frame
- [ ] 2.5.9 Add error handling and logging

**Implementation Notes:**
- Convert C error codes to descriptive Elixir errors
- Use `%{r: 0-255, g: 0-255, b: 0-255, a: 0-255}` for colors
- Return `{:ok, window_id}` or `{:error, reason}` tuples
- Include deprecation warnings for API changes
- Use `@spec` for all public functions
- Document thread safety guarantees

**Unit Tests for Section 2.5:**
- [ ] 2.5.1 Verify init initializes SDL2 successfully
- [ ] 2.5.2 Verify create_window returns {:ok, window_id}
- [ ] 2.5.3 Verify create_window returns {:error, reason} on failure
- [ ] 2.5.4 Verify clear fills window with color
- [ ] 2.5.5 Verify draw_rect draws outline rectangle
- [ ] 2.5.6 Verify fill_rect draws filled rectangle
- [ ] 2.5.7 Verify poll_event returns events or :no_event
- [ ] 2.5.8 Verify present displays rendered content
- [ ] 2.5.9 Verify operations on invalid window_id return error

---

## 2.6 SDL2 Renderer

Create a real renderer that uses DesktopUI.Graphics to draw widgets.

- [ ] **Task 2.6** Implement `DesktopUI.Renderer.SDL2` module

Create the SDL2-based renderer:

- [ ] 2.6.1 Implement `init/1` - initialize with window_id
- [ ] 2.6.2 Implement `render/2` - draw UI tree to window
- [ ] 2.6.3 Implement widget traversal for rendering
- [ ] 2.6.4 Implement label rendering (text placeholder)
- [ ] 2.6.5 Implement button rendering (rect with outline)
- [ ] 2.6.6 Implement container rendering (layout children)
- [ ] 2.6.7 Add color constants for widget styling
- [ ] 2.6.8 Implement cleanup/1 - release resources

**Implementation Notes:**
- For now, use simple colored rectangles (no real text yet)
- Label: use a filled rect with distinctive color
- Button: outlined rect with different color
- Container: just renders children, no visual of its own
- Each widget type has a pattern match in render function
- Use `apply/3` for dispatching to widget-specific renderers
- Include bounds checking to prevent drawing outside window

**Unit Tests for Section 2.6:**
- [ ] 2.6.1 Verify renderer initializes with window
- [ ] 2.6.2 Verify renderer draws label widget
- [ ] 2.6.3 Verify renderer draws button widget
- [ ] 2.6.4 Verify renderer draws nested containers
- [ ] 2.6.5 Verify renderer handles unknown widget type gracefully
- [ ] 2.6.6 Verify renderer cleans up resources

---

## 2.7 Runtime Integration with SDL2

Update the Runtime to use the SDL2 renderer and poll real events.

- [ ] **Task 2.7** Integrate SDL2 into Runtime

Connect Runtime to real graphics:

- [ ] 2.7.1 Update `DesktopUI.Runtime.start_link/2` to initialize SDL2
- [ ] 2.7.2 Add window creation with title and dimensions
- [ ] 2.7.3 Replace mock renderer with SDL2 renderer
- [ ] 2.7.4 Add event polling loop in Runtime
- [ ] 2.7.5 Translate SDL events to component messages
- [ ] 2.7.6 Handle SDL_QUIT to terminate Runtime
- [ ] 2.7.7 Implement hit testing for button clicks

**Implementation Notes:**
- Use `Process.send_after/3` for periodic event polling
- Create a simple event loop (not optimized yet)
- Hit testing: compare click coordinates to widget bounds
- For now, use fixed positions (no layout engine yet)
- Store widget bounds in UI tree for hit testing
- Gracefully handle SDL initialization failures
- Support fullscreen option in start_link

**Unit Tests for Section 2.7:**
- [ ] 2.7.1 Verify runtime creates SDL window on startup
- [ ] 2.7.2 Verify runtime polls SDL events
- [ ] 2.7.3 Verify button click triggers component message
- [ ] 2.7.4 Verify quit event stops runtime
- [ ] 2.7.5 Verify render draws to SDL window
- [ ] 2.7.6 Verify runtime cleans up SDL resources on shutdown

---

## 2.8 Phase 2 Integration Tests

Comprehensive integration tests verifying all Phase 2 components work together correctly.

- [ ] **Task 2.8** Create SDL integration test suite

Verify real graphics rendering:

- [ ] 2.8.1 Test full SDL initialization and cleanup
- [ ] 2.8.2 Test window creation, modification, and destruction
- [ ] 2.8.3 Test drawing primitives to window
- [ ] 2.8.4 Test event polling with real user input
- [ ] 2.8.5 Test Counter component with real SDL rendering
- [ ] 2.8.6 Test Runtime with SDL2 backend
- [ ] 2.8.7 Test multiple state changes with real rendering
- [ ] 2.8.8 Test button click handling from SDL events

**Implementation Notes:**
- Tests may require display (X11, Wayland, Windows, macOS)
- Use headless mode for CI if possible (SDL2 DUMMY driver)
- Mark tests that require user interaction
- Include screenshots for visual verification (if possible)
- Time-sensitive tests need appropriate margins
- Test cleanup should destroy all SDL resources

**Actual Test Coverage:**
- NIF loading: 2 tests
- Window management: 5 tests
- Drawing primitives: 6 tests
- Event handling: 6 tests
- Graphics API: 8 tests
- SDL2 Renderer: 5 tests
- Runtime integration: 6 tests

**Total: 38 integration tests**

---

## Success Criteria

1. **SDL2 Window Opens**: Counter component displays in a real window
2. **Click Works**: Clicking buttons triggers state changes
3. **Visual Feedback**: State changes are visible in the window
4. **Clean Shutdown**: All SDL resources released on exit
5. **Cross-Platform**: Works on Linux (primary), with hooks for macOS/Windows

---

## Critical Files

**New Files:**
- `c_src/desktop_ui_nif.c` - Main NIF implementation
- `c_src/desktop_ui_nif.h` - NIF header declarations
- `c_src/Makefile` - C build configuration
- `lib/desktop_ui/graphics.ex` - Graphics API wrapper
- `lib/desktop_ui/renderer/sdl2.ex` - SDL2 renderer implementation
- `test/desktop_ui/graphics_test.exs` - Graphics API tests
- `test/desktop_ui/renderer/sdl2_test.exs` - SDL2 renderer tests
- `test/integration/phase_2_integration_test.exs` - Integration tests

**Modified Files:**
- `mix.exs` - Add C compilation configuration
- `lib/desktop_ui/runtime.ex` - Integrate SDL2
- `lib/desktop_ui/examples/counter.ex` - Update for SDL demo

**Dependencies:**
- Phase 1: Architecture Validation (Runtime, Elm behaviour, Widget DSL)
- SDL2 development libraries (system package)

---

## Dependencies

**This phase depends on:**
- Phase 1: Architecture Validation (complete Runtime, Elm behaviour, Widget system)

**Phases that depend on this phase:**
- Phase 3: First Real Widget (depends on Graphics API, SDL2 renderer)
- Future phases: Text rendering, advanced widgets
